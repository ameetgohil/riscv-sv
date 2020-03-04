module axi_lite_crossbar
  (
   input wire [31:0]  m_axi_awaddr,
   input wire         m_axi_awprot,
   input wire         m_axi_awvalid,
   output wire        m_axi_awready,
  
   input wire [31:0]  m_axi_wdata,
   input wire         m_axi_wstrb,
   input wire         m_axi_wvalid,
   output wire        m_axi_wready,
  
   output wire [1:0]  m_axi_bresp,
   output wire        m_axi_bvalid,
   input wire         m_axi_bready,
  
   input wire         m_axi_arvalid,
   output wire        m_axi_arready,
   input wire [31:0]  m_axi_araddr,
   input wire         m_axi_arprot,
  
   output wire        m_axi_rvalid,
   input wire         m_axi_rready,
   output wire [31:0] m_axi_rdata,
   output wire [3:0]  m_axi_rresp,
  
   //slave 0
   output wire [31:0] s0_axi_awaddr,
   output wire        s0_axi_awprot,
   output wire        s0_axi_awvalid,
   input wire         s0_axi_awready,

   output wire [31:0] s0_axi_wdata,
   output wire        s0_axi_wstrb,
   output wire        s0_axi_wvalid,
   input wire         s0_axi_wready,

   input wire [1:0]   s0_axi_bresp,
   input wire         s0_axi_bvalid,
   output wire        s0_axi_bready,

   output wire        s0_axi_arvalid,
   input wire         s0_axi_arready,
   output wire [31:0] s0_axi_araddr,
   output wire        s0_axi_arprot,

   input wire         s0_axi_rvalid,
   output wire        s0_axi_rready,
   input wire [31:0]  s0_axi_rdata,
   input wire [3:0]   s0_axi_rresp,

   input wire         aclk, aresetn
   );

   
   typedef enum reg   {ADDR, DATA} state_t;
   state_t w_state, r_state;

   reg [1:0]          q_select, n_select;

   reg                read_addr_done, read_data_done;
   reg                write_addr_done, write_data_done;

   // READ
   always_comb begin
      read_addr_done = 0;
      read_data_done = 0;
      if(r_state == ADDR && m_axi_arvalid) begin
         case(m_axi_araddr)
           {20'h00010,12'h???}: begin
              m_axi_arvalid = s0_axi_arvalid;
              m_axi_araddr = s0_axi_araddr;
              s0_axi_arready = m_axi_arready;
              read_addr_done = m_axi_arready;
              n_select = 2'b01;
           end
           default: begin
              s0_axi_arready = 1'b1;
           end
         endcase // case (m_axi_awaddr)
      end // if (state == ADDR && m_axi_awvalid)
      else if(r_state == DATA && m_axi_wvalid) begin
         case(q_select)
           2'b01: begin // s0
              m_axi_rdata = s0_axi_rdata;
              m_axi_rstrb = s0_axi_rstrb;
              m_axi_rvalid = s0_axi_rvalid;
              s0_axi_rready = m_axi_rready;
           end
           default: begin
              invalid_rstate = 1'b1;
           end
         endcase // case (q_select)
      end
   end // always_comb
   
   // WRITE
   always_comb begin
      write_addr_done = 0;
      write_data_done = 0;
      if(w_state == ADDR && m_axi_awvalid) begin
         case(m_axi_awaddr)
           {20'h00010,12'h???}: begin
              s0_axi_awvalid = m_axi_awvalid;
              s0_axi_awaddr = m_axi_awaddr;
              m_axi_awready = s0_axi_awready;
              write_addr_done = s0_axi_awready;
              n_select = 2'b01;
           end
           default: begin
              m_axi_awready = 1'b1;
           end
         endcase // case (m_axi_awaddr)
      end // if (state == ADDR && m_axi_awvalid)
      else if(w_state == DATA && m_axi_wvalid) begin
         case(q_select)
           2'b01: begin // s0
              s0_axi_wdata = m_axi_wdata;
              s0_axi_wstrb = m_axi_wstrb;
              s0_axi_wvalid = m_axi_wvalid;
              m_axi_wready = s0_axi_wready;
           end
           default: begin
              invalid_wstate = 1'b1;
           end
         endcase // case (q_select)
      end
   end // always_comb
   
   always @(posedge aclk)
     if(~aresetn) begin
        w_state <= ADDR;
        r_state <= ADDR;
        q_select <= 0;
     end
     else begin
        q_select <= n_select;
        
        if(read_addr_done)
          r_state <= DATA;
        else if(read_data_done)
          r_state <= ADDR;

        if(write_addr_done)
          w_state <= DATA;
        else if(write_data_done)
          w_state <= ADDR;
     end
   
   
endmodule // axi_lite_crossbar


