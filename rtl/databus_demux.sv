module databus_demux
  #(DATAMEM_DEPTH = 8192)
   (input wire        dBus_cmd_valid,
    output reg                             dBus_cmd_ready,
    input wire [31:0]                      dBus_cmd_payload_addr,
    input wire [31:0]                      dBus_cmd_payload_data,
    input wire [3:0]                       dBus_cmd_payload_size,
    input wire                             dBus_cmd_payload_wr, //1 - write, 0 - read
    output reg [31:0]                      dBus_rsp_data,
    output reg                             dBus_rsp_valid,
    output reg                             dBus_rsp_error,

    //DATA MEMORY (internal bram)
    output reg [$clog2(DATAMEM_DEPTH)-1:0] datamem_addr,
    output reg [31:0]                      datamem_wdata,
    output reg [3:0]                       datamem_mask,
    output reg                             datamem_we,
    output reg                             datamem_wvalid,
    input wire                             datamem_ready,

    input wire [31:0]                      datamem_rdata,
    input wire                             datamem_rvalid,

    //PERIPHERALS and other memory AXI-lite
    output wire [31:0]                     m_axi_awaddr,
    output wire                            m_axi_awprot,
    output wire                            m_axi_awvalid,
    input wire                             m_axi_awready,

    output wire [31:0]                     m_axi_wdata,
    output wire                            m_axi_wstrb,
    output wire                            m_axi_wvalid,
    input wire                             m_axi_wready,

    input wire [1:0]                       m_axi_bresp,
    input wire                             m_axi_bvalid,
    output wire                            m_axi_bready,

    output wire                            m_axi_arvalid,
    input wire                             m_axi_arready,
    output wire [31:0]                     m_axi_araddr,
    output wire                            m_axi_arprot,

    input wire                             m_axi_rvalid,
    output wire                            m_axi_rready,
    input wire [31:0]                      m_axi_rdata,
    input wire [3:0]                       m_axi_rresp,
    

   

    input wire                             clk, rstf
    );

   localparam bit [31:0]                   datamem_base = 0;

   localparam ST_ADDR = 0;
   localparam ST_DATA = 1;

   reg                                     axi_state;
   

   always_comb begin
      if(dBus_cmd_payload_addr[31:$clog2(DATAMEM_DEPTH)] == 0) begin // data mem
         datamem_addr = dBus_cmd_payload_addr[$clog2(DATAMEM_DEPTH)-1:0];
         datamem_wdata = dBus_cmd_payload_data;
         datamem_mask = dBus_cmd_payload_size;
         datamem_we = dBus_cmd_payload_wr;
         dBus_cmd_ready = datamem_ready;

         dBus_rsp_data = datamem_rdata;
         dBus_rsp_valid = datamem_rvalid;
         
      end
      else begin
         if(dBus_cmd_payload_wr & dBus_cmd_valid && axi_state == ST_ADDR) begin
            m_axi_awaddr = dBus_cmd_payload_addr;
            m_axi_awvalid = 1'b1;
         end
         else if(dBus_cmd_payload_wr & dBus_cmd_valid && axi_state == ST_DATA) begin
            m_axi_wdata = dBus_cmd_payload_data;
            m_axi_wvalid = 1'b1;
            dBus_cmd_ready = m_axi_wready;
         end
         else if(~dBus_cmd_payload_wr & dBus_cmd_valid && axi_state == ST_ADDR) begin
            m_axi_araddr = dBus_cmd_payload_addr;
            m_axi_arvalid = 1'b1;
         end
         else if(~dBus_cmd_payload_wr & dBus_cmd_valid && axi_state == ST_DATA) begin
            dBus_rsp_data = m_axi_rdata;
            dBus_rsp_valid = m_axi_rvalid;
         end
      end
   end // always_comb

   always_ff @(posedge clk or negedge rstf) begin
      if(~rstf) begin
         axi_state <= ST_ADDR;
      end
      else begin
         if((m_axi_awvalid & m_axi_awready) | (m_axi_arvalid & m_axi_arready))
           axi_state <= ST_DATA;
         else if((m_axi_wvalid & m_axi_wready) | (m_axi_rvalid & m_axi_rready))
           axi_state <= ST_ADDR;
      end
   end // always_ff @ (posedge clk or negedge rstf)
   
         
   
   
endmodule
