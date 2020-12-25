module instruction_writeback
  (input wire[31:0] t_instr,
   input wire          t_instr_valid,
   output logic        t_instr_ready,

   input wire [31:0]   iPC,
   output logic [31:0] oPC,
   
   input wire [4:0]    iDecodedOP,
   output logic [4:0]  oDecodedOP,

//   input wire [31:0]  dbus_rdata,
   output reg [4:0]    rd,
   input wire [31:0]   maAlu_rdValue,
   output reg          we,

   output wire [31:0]  rdValue,

   input               clk, rstf
   );

   always_comb oPC = iPC;
   always_comb oDecodedOP = iDecodedOP;
   always_comb t_instr_ready = 1'b1;
   
   always_comb rd = t_instr[11:7];

      /* verilator lint_off UNUSED */
   opcode_t op_debug;
   always_comb op_debug = opcode_t'(t_instr`opcode);
   /* verilator lint_on UNUSED */

   
   always_comb begin
      case(opcode_t'(t_instr`opcode))
        OP_JAL: begin
           rdValue = iPC + 4;
           we = 1'b1;
        end
        OP_LOAD, OP_ALU: begin
           rdValue = maAlu_rdValue;
           we = 1'b1;
        end
        default: begin
           rdValue = maAlu_rdValue;
           we =1'b1;
        end
      endcase
   end

endmodule // instruction_writeback

