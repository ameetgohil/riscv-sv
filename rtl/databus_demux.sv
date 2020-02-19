module databus_demux
  #(DATAMEM_DEPTH = 8192)
  (input wire        dBus_cmd_valid;
   output reg 				  dBus_cmd_ready;
   input wire [31:0] 			  dBus_cmd_payload_addr;
   input wire [31:0] 			  dBus_cmd_payload_data;
   input wire [3:0] 			  dBus_cmd_payload_size;
   input wire 				  dBus_cmd_payload_wr; //1 - write, 0 - read
   output reg [31:0] 			  dBus_rsp_data;
   output reg 				  dBus_rsp_valid;
   output reg 				  dBus_rsp_error

   //DATA MEMORY (internal bram)
   output reg [$clog2(DATAMEM_DEPTH)-1:0] datamem_addr,
   output reg [31:0] 			  datamem_wdata,
   output reg [3:0] 			  datamem_mask,
   output reg 				  datamem_we,
   output reg 				  datamem_wvalid,
   input wire 				  datamem_ready,

   input wire [31:0] 			  datamem_rdata,
   input wire [31:0] 			  datamem_rvalid

   //PERIPHERALS and other memory AXI-lite
   output wire 				  m_axi_awid,
   output wire [31:0] 			  m_axi_awaddr,
   output wire [7:0] 			  m_axi_awlen,
   output wire [2:0] 			  m_axi_awsize,
   output wire 				  m_axi_awvalid,
   input wire 				  m_axi_awready,

   output wire [31:0] 			  m_axi_wdata,
   output wire [3:0] 			  m_axi_wstrb,
   output wire 				  m_axi_wlast,
   output wire 				  m_axi_wvalid,
   input wire 				  m_axi_wready,

   input wire 				  m_axi_bid,
   input wire [1:0] 			  m_axi_bresp,
   input wire 				  m_axi_bvalid,
   output wire 				  m_axi_bready,

   

   input wire 				  clk, rstf
   );
   
   
   
