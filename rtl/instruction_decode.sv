`include "riscv.svh"
module instruction_decode
  (input wire[31:0] t_instr,
   input wire         t_instr_valid,
   output wire        t_instr_ready,

   output wire [31:0] i_instr,
   output wire        i_instr_valid,
   input wire         i_instr_ready,

   input wire [31:0]  iPC,
   output wire [31:0] oPC,

   output wire [4:0]  rs1,
   output wire [4:0]  rs2,
   output wire [4:0]  rd,

   output wire [4:0]  decodedOP,
   output wire [31:0] immediate,

   input wire         clk, rstf
   );

   logic               utype, jtype, itype, btype, stype, rtype;
   wire [31:0]        u_imm, j_imm, b_imm, i_imm, s_imm;

   assign i_instr = t_instr;
   assign i_instr_valid = t_instr_valid;
   assign t_instr_ready = i_instr_ready;

   assign oPC = iPC;

   opcode_t opcode;
   assign rs1 = t_instr[19:15];
   assign rs2 = t_instr[24:20];
   assign rd = t_instr[11:7];
   assign opcode = t_instr`opcode;
   
   
   
   always_comb begin
      utype = 0;
      jtype = 0;
      itype = 0;
      btype = 0;
      stype = 0;
      rtype = 0;
      case(opcode)
        OP_LUI,OP_AUIPC:
          utype = 1;
        OP_JAL:
          jtype = 1;
        OP_JALR,OP_LOAD,OP_ALU_IMM,OP_MISC_MEM,OP_MISC:
          itype = 1;
        OP_BRANCH:
          btype = 1;
        OP_STORE:
          stype = 1;
        OP_ALU:
          rtype = 1;
        default: begin end
      endcase // case (opcode)
   end // always_comb

   assign u_imm = { t_instr[31:12], 12'h0 };
   assign j_imm = { {12{t_instr[31]}}, t_instr[19:12], t_instr[20], t_instr[30:21], 1'b0 };
   assign b_imm = { {20{t_instr[31]}}, t_instr[7], t_instr[30:25], t_instr[11:8], 1'b0 };
   assign i_imm = { {20{t_instr[31]}}, t_instr[31:20] };
   assign s_imm = { {20{t_instr[31]}}, t_instr[31:25], t_instr[11:7] };
   
   assign immediate = itype ? i_imm :
                      stype ? s_imm :
                      btype ? b_imm :
                      utype ? u_imm :
                      jtype ? j_imm :
                      0;// rtype

   assign decodedOP = decodeOP(t_instr);

   //partially unused bits of input instruction
   /* verilator lint_off UNUSED */
   function operation_t decodeOP(bit[31:0] instruction);
      /* verilator lint_on UNUSED */
      case(opcode_t'(instruction`opcode))
        OP_LUI: return LUI;
        OP_AUIPC: return AUIPC;
        OP_JAL: return JAL;
        OP_JALR: return JALR;
        OP_BRANCH:
          case(funct3_branch_t'(instruction`funct3))
            F3_BEQ: return BEQ;
            F3_BNE: return BNE;
            F3_BLT: return BLT;
            F3_BGE: return BGE;
            F3_BLTU: return BLTU;
            F3_BGEU: return BGEU;
            default: begin end
          endcase // case (instrunction`func3)
        OP_STORE: return STORE;
        OP_LOAD: return LOAD;
        OP_ALU:
          case(funct3_alu_t'(instruction`funct3))
            F3_ADDSUB:
              case(funct7_alu_t'(instruction`funct7))
                F7_ADD_SRL: return ADD;
                F7_SUB_SRA: return SUB;
                default: begin end
              endcase // case (instruction`func7)
            F3_SLL: return SLL;
            F3_SLT: return SLT;
            F3_SLTU: return SLTU;
            F3_XOR: return XOR;
            F3_SRLSRA:
              case(funct7_alu_t'(instruction`funct7))
                F7_ADD_SRL: return SRL;
                F7_SUB_SRA: return SRA;
                default: begin end
              endcase // case (instruction`func7)
            F3_OR: return OR;
            F3_AND: return AND;
            default: begin end
          endcase // case (instruction`func3)
        OP_ALU_IMM:
          case(funct3_alu_t'(instruction`funct3))
            F3_ADDSUB: return ADD;
            F3_SLL: return SLL;
            F3_SLT: return SLT;
            F3_SLTU: return SLTU;
            F3_XOR: return XOR;
            F3_SRLSRA:
              case(funct7_alu_t'(instruction`funct7))
                F7_ADD_SRL: return SRL;
                F7_SUB_SRA: return SRA;
                default: begin end
              endcase // case (instruction`func7)
             F3_OR: return OR;
            F3_AND: return AND;
            default: begin end
          endcase // case (instruction`func3)
        OP_MISC_MEM:
          case(funct3_misc_mem_t'(instruction`funct3))
            F3_FENCE: return FENCE;
            F3_FENCE_I: return FENCE_I;
            default: begin end
          endcase // case (instruction`funct3)
        OP_MISC:
          case(funct3_misc_t'(instruction`funct3))
            F3_ECALL_EBREAK:
              case(instruction`funct12)
                F12_ECALL: return ECALL;
                F12_EBREAK: return EBREAK;
                default: begin end
              endcase // case (instruction`funct12)
            F3_CSRRW: return CSRRW;
            F3_CSRRS: return CSRRS;
            F3_CSRRC: return CSRRC;
            default: begin end
          endcase // case (instruction`funct3)
        default: begin end
      endcase // case (instruction`opcode)
   endfunction
   
endmodule
