module riscv_top
  (input wire clk, rstf
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
   wire         dBus_rsp_ready;

   assign iBus_rsp_err = 1'b0;
   assign dBus_rsp_error = 1'b0;
   
   riscv riscv_0p
                (.*);

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

        .t_p1_valid(dBus_cmd_valid),
        .t_p1_ready(dBus_cmd_ready),
        .t_p1_we(dBus_cmd_payload_wr),
        .t_p1_addr(dBus_cmd_payload_addr[$clog2(DEPTH)+2-1:0]),
        .t_p1_data(dBus_cmd_payload_data),
        .t_p1_mask(dBus_cmd_payload_size),

        .i_p1_valid(dBus_rsp_valid),
        .i_p1_ready(1'b1),
        .i_p1_data(dBus_rsp_data),
        .clk(clk),
        .rstf(rstf)
        );

   

   
endmodule
