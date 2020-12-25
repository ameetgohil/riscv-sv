module riscv
  (output wire [31:0] iBus_cmd_payload_pc,
   output wire        iBus_cmd_valid,
   input wire         iBus_rsp_ready,
   input wire [31:0]  iBus_rsp_instr,

   output wire        dBus_cmd_valid,
   input wire         dBus_cmd_ready,
   output wire [31:0] dBus_cmd_payload_addr,
   output wire [31:0] dBus_cmd_payload_data,
   output wire [3:0]  dBus_cmd_payload_size,
   output wire        dBus_cmd_payload_wr, //1 - write, 0 - read
   input wire [31:0]  dBus_rsp_data,
   input wire         dBus_rsp_valid,
   input wire         dBus_rsp_error,
/*   output wire [31:0] instr,
   output wire instr_valid,
   output wire instr_ready,
*/
   input wire         clk, rstf
   );

   wire [31:0] regfile_rs1Value;
   wire [31:0] regfile_rs2Value;

   wire [31:0] fetch_instr;
   wire        fetch_instr_valid;
   wire fetch_instr_ready;
   wire [31:0] fetch_pc;

   wire [31:0] decode_instr;
   wire        decode_instr_valid;
   wire        decode_instr_ready;
   wire [31:0] decode_pc;
   wire [4:0] decode_rs1;
   wire [4:0] decode_rs2;
   wire [4:0] decode_rd;
   wire [4:0] decode_decodedOP;
   wire [31:0] decode_immediate;

   wire [31:0] execute_instr;
   wire        execute_instr_valid;
   wire        execute_instr_ready;
   wire [31:0] execute_pc;
   wire [4:0]  execute_decodedOP;
   wire [31:0] execute_aluValue;
   wire [31:0] execute_rs2Value;
   wire        execute_branchTaken;

   wire [31:0] memoryaccess_instr;
   wire        memoryaccess_instr_valid;
   wire        memoryaccess_instr_ready;
   wire [31:0] memoryaccess_pc;
   wire [4:0]  memoryaccess_decodedOP;
   wire [31:0] memoryaccess_maAluValue;

   wire [31:0] writeback_rdValue;
   wire        writeback_we;
   wire [4:0]  writeback_rd;
   
   
   
   
   regfile u_regfile
     (.addrA(decode_rs1),
      .regA(regfile_rs1Value),
      .addrB(decode_rs2),
      .regB(regfile_rs2Value),
      .addrDest(writeback_rd),
      .dataDest(writeback_rdValue),
      .weDest(writeback_we),
      .clk(clk),
      .rstf(rstf)
      );

   instruction_fetch u_fetch
     (.ibus_addr(iBus_cmd_payload_pc),
      .valid(iBus_cmd_valid),
      .ready(iBus_rsp_ready),
      .ibus_instr(iBus_rsp_instr),

      .instr(fetch_instr),
      .instr_valid(fetch_instr_valid),
      .instr_ready(1'b1),//fetch_instr_ready),

      .oPC(fetch_pc),
      
      .aluPC(execute_aluValue),
      .branchTaken(execute_branchTaken),
      
      .clk(clk),
      .rstf(rstf)
      );

   instruction_decode u_decode
     (.t_instr(fetch_instr),
      .t_instr_valid(fetch_instr_valid),
      .t_instr_ready(fetch_instr_ready),

      .i_instr(decode_instr),
      .i_instr_valid(decode_instr_valid),
      .i_instr_ready(decode_instr_ready),

      .iPC(fetch_pc),
      .oPC(decode_pc),

      .rs1(decode_rs1),
      .rs2(decode_rs2),
      .rd(decode_rd),

      .decodedOP(decode_decodedOP),
      .immediate(decode_immediate),

      .clk(clk),
      .rstf(rstf)
      );

   instruction_execute u_execute
     (.t_instr(decode_instr),
      .t_instr_valid(decode_instr_valid),
      .t_instr_ready(decode_instr_ready),

      .i_instr(execute_instr),
      .i_instr_valid(execute_instr_valid),
      .i_instr_ready(execute_instr_ready),

      .iPC(decode_pc),
      .oPC(execute_pc),

      .rs1Value(regfile_rs1Value),
      .rs2Value(regfile_rs2Value),

      .iDecodedOP(decode_decodedOP),
      .oDecodedOP(execute_decodedOP),

      .aluValue(execute_aluValue),
      .oRs2Value(execute_rs2Value),
      .immediate(decode_immediate),

      .branchTaken(execute_branchTaken),

      .clk(clk),
      .rstf(rstf)
      );

   instruction_memoryaccess u_memoryaccess
     (.t_instr(execute_instr),
      .t_instr_valid(execute_instr_valid),
      .t_instr_ready(execute_instr_ready),

      .i_instr(memoryaccess_instr),
      .i_instr_valid(memoryaccess_instr_valid),
      .i_instr_ready(memoryaccess_instr_ready),

      .iPC(execute_pc),
      .oPC(memoryaccess_pc),
      
      .iDecodedOP(execute_decodedOP),
      .oDecodedOP(memoryaccess_decodedOP),

      .aluValue(execute_aluValue),
      .rs2Value(execute_rs2Value),
      
      .maAluValue(memoryaccess_maAluValue),

      .dbus_cmd_addr(dBus_cmd_payload_addr),
      .dbus_cmd_data(dBus_cmd_payload_data),
      .dbus_cmd_size(dBus_cmd_payload_size),
      .dbus_cmd_we(dBus_cmd_payload_wr),
      .dbus_cmd_valid(dBus_cmd_valid),
      .dbus_cmd_ready(dBus_cmd_ready),
      .dbus_rsp_data(dBus_rsp_data),
      .dbus_rsp_valid(dBus_rsp_valid),

      .clk(clk),
      .rstf(rstf)
      );

   instruction_writeback u_writeback
     (.t_instr(memoryaccess_instr),
      .t_instr_valid(memoryaccess_instr_valid),
      .t_instr_ready(memoryaccess_instr_ready),

      .iDecodedOP(memoryaccess_decodedOP),
      /* verilator lint_off PINCONNECTEMPTY */
      .oDecodedOP(),
      /* verilator lint_on PINCONNECTEMPTY */
      //.dbus_rdata(memoryaccess_dbus_rdata),
      .maAlu_rdValue(memoryaccess_maAluValue),
      .rd(writeback_rd),
      .rdValue(writeback_rdValue),
      .we(writeback_we),

      .iPC(memoryaccess_pc),
      /* verilator lint_off PINCONNECTEMPTY */
      .oPC(),
      /* verilator lint_on PINCONNECTEMPTY */
      .clk(clk),
      .rstf(rstf)
      );
endmodule
