module riscv_top
  (
   output wire [31:0] debug_uart_tx_data,
   output wire      debug_uart_tx_valid,
   input wire       debug_uart_tx_ready,
   input wire       clk, rstf
   );

   localparam DEPTH = 8192;
   
   
   wire        iBus_cmd_valid;
   wire        iBus_cmd_ready;
   wire [31:0] iBus_cmd_payload_pc;
   wire        iBus_rsp_ready;
   wire        iBus_rsp_err;
   wire [31:0] iBus_rsp_instr;
   /* Data Bus */
   wire        dBus_cmd_valid;
   wire        dBus_cmd_ready;
   wire [31:0] dBus_cmd_payload_addr;
   wire [31:0] dBus_cmd_payload_data;
   wire [3:0]  dBus_cmd_payload_size;
   wire        dBus_cmd_payload_wr; //1 - write, 0 - read
   wire [31:0] dBus_rsp_data;
   wire        dBus_rsp_valid;
   wire        dBus_rsp_error;

   assign iBus_rsp_err = 1'b0;
   assign dBus_rsp_error = 1'b0;
   
   riscv riscv_0p
     (.*);
   
   reg [$clog2(DEPTH)+2-1:0] datamem_addr;
   reg [31:0]              datamem_wdata;
   reg [3:0]               datamem_mask;
   reg                     datamem_we;
   reg                     datamem_valid;
   wire                    datamem_ready;
   
   wire [31:0]             datamem_rdata;
   wire                    datamem_rvalid;
   
   dpram_32_ba 
     #(.DEPTH(DEPTH),
       .MEM0_INIT(`MEM0_INIT),
       .MEM1_INIT(`MEM1_INIT),
       .MEM2_INIT(`MEM2_INIT),
       .MEM3_INIT(`MEM3_INIT)
       ) imem_dmem
       (.t_p0_valid(iBus_cmd_valid),
        .t_p0_ready(iBus_cmd_ready),
        .t_p0_we(1'b0),
        .t_p0_addr(iBus_cmd_payload_pc[$clog2(DEPTH)+2-1:0]),
        .t_p0_data(32'b0),
        .t_p0_mask(4'h0),

        .i_p0_valid(iBus_rsp_ready),
        .i_p0_ready(1'b1),
        .i_p0_data(iBus_rsp_instr),

        .t_p1_valid(datamem_valid),
        .t_p1_ready(datamem_ready),
        .t_p1_we(datamem_we),
        .t_p1_addr(datamem_addr[$clog2(DEPTH)+2-1:0]),
        .t_p1_data(datamem_wdata),
        .t_p1_mask(datamem_mask),

        .i_p1_valid(datamem_rvalid),
        .i_p1_ready(1'b1),
        .i_p1_data(datamem_rdata),

/*
        .t_p1_valid(dBus_cmd_valid),
        .t_p1_ready(dBus_cmd_ready),
        .t_p1_we(dBus_cmd_payload_wr),
        .t_p1_addr(dBus_cmd_payload_addr[$clog2(DEPTH)+2-1:0]),
        .t_p1_data(dBus_cmd_payload_data),
        .t_p1_mask(dBus_cmd_payload_size),

        .i_p1_valid(dBus_rsp_valid),
        .i_p1_ready(1'b1),
        .i_p1_data(dBus_rsp_data),

 */      
        .clk(clk),
        .rstf(rstf)
        );


   wire [31:0]             m_axi_awaddr;
   wire                    m_axi_awprot;
   wire                    m_axi_awvalid;
   wire                    m_axi_awready;

   wire [31:0]             m_axi_wdata;
   wire                    m_axi_wstrb;
   wire                    m_axi_wvalid;
   wire                    m_axi_wready;

   wire [1:0]              m_axi_bresp;
   wire                    m_axi_bvalid;
   wire                    m_axi_bready;

   wire                    m_axi_arvalid;
   wire                    m_axi_arready;
   wire [31:0]             m_axi_araddr;
   wire                    m_axi_arprot;

   wire                    m_axi_rvalid;
   wire                    m_axi_rready;
   wire [31:0]             m_axi_rdata;
   wire [3:0]              m_axi_rresp;
   
   databus_demux databus_demux_inst
     (.*
      );
   

   wire [31:0]             uart_axi_awaddr;
   wire                    uart_axi_awprot;
   wire                    uart_axi_awvalid;
   wire                    uart_axi_awready;

   wire [31:0]             uart_axi_wdata;
   wire                    uart_axi_wstrb;
   wire                    uart_axi_wvalid;
   wire                    uart_axi_wready;

/*   wire [1:0]              uart_axi_bresp;
   wire                    uart_axi_bvalid;
   wire                    uart_axi_bready;
*/
   wire                    uart_axi_arvalid;
   wire                    uart_axi_arready;
   wire [31:0]             uart_axi_araddr;
   wire                    uart_axi_arprot;

   wire                    uart_axi_rvalid;
   wire                    uart_axi_rready;
   wire [31:0]             uart_axi_rdata;
   wire [3:0]              uart_axi_rresp;
   
   axi_lite_crossbar axi_lite_crossbar_0
     (.*,
      .s0_axi_awaddr(uart_axi_awaddr),
      .s0_axi_awprot(uart_axi_awprot),
      .s0_axi_awvalid(uart_axi_awvalid),
      .s0_axi_awready(uart_axi_awready),

      .s0_axi_wdata(uart_axi_wdata),
      .s0_axi_wstrb(uart_axi_wstrb),
      .s0_axi_wvalid(uart_axi_wvalid),
      .s0_axi_wready(uart_axi_wready),
      
      .s0_axi_bresp(2'b0),
      .s0_axi_bvalid(1'b0),
      /* verilator lint_off PINCONNECTEMPTY */
      .s0_axi_bready(),
       /* verilator lint_on PINCONNECTEMPTY */
      
      .s0_axi_arvalid(uart_axi_arvalid),
      .s0_axi_arready(uart_axi_arready),
      .s0_axi_araddr(uart_axi_araddr),
      .s0_axi_arprot(uart_axi_arprot),
      
      .s0_axi_rvalid(uart_axi_rvalid),
      .s0_axi_rready(uart_axi_rready),
      .s0_axi_rdata(uart_axi_rdata),
      .s0_axi_rresp(uart_axi_rresp),
      
      .aclk(clk),
      .aresetn(rstf)
      );

   wire [31:0]              uart_rx_data;
   wire                    uart_rx_valid, uart_rx_ready;

   assign uart_rx_data = 0;
   assign uart_rx_valid = 0;

   axi2axis uart_axis
     (
      .s_axi_awaddr(uart_axi_awaddr),
      .s_axi_awprot(uart_axi_awprot),
      .s_axi_awvalid(uart_axi_awvalid),
      .s_axi_awready(uart_axi_awready),

      .s_axi_wdata(uart_axi_wdata),
      .s_axi_wstrb(uart_axi_wstrb),
      .s_axi_wvalid(uart_axi_wvalid),
      .s_axi_wready(uart_axi_wready),
      /*
      .s_axi_bresp(uart_axi_bresp),
      .s_axi_bvalid(uart_axi_bvalid),
      .s_axi_bready(uart_axi_bready),
      */
      .s_axi_arvalid(uart_axi_arvalid),
      .s_axi_arready(uart_axi_arready),
      .s_axi_araddr(uart_axi_araddr),
      .s_axi_arprot(uart_axi_arprot),
      
      .s_axi_rvalid(uart_axi_rvalid),
      .s_axi_rready(uart_axi_rready),
      .s_axi_rdata(uart_axi_rdata),
      .s_axi_rresp(uart_axi_rresp),

      .m_axis_wdata(debug_uart_tx_data),
      .m_axis_wvalid(debug_uart_tx_valid),
      .m_axis_wready(1'b1),//uart_tx_ready),

      .m_axis_rdata(uart_rx_data),
      .m_axis_rvalid(uart_rx_valid),
      .m_axis_rready(uart_rx_ready),
      
      .aclk(clk),
      .aresetn(rstf)
      );
   

   
endmodule
