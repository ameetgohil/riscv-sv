`include "riscv.svh"
module instruction_execute
  (input wire[31:0] t_instr,
   input wire         t_instr_valid,
   output wire        t_instr_ready,

   output wire [31:0]  i_instr,
   output wire         i_instr_valid,
   input wire        i_instr_ready,
   
   input wire [31:0]  iPC,
   output wire [31:0] oPC,
   
   input wire [31:0]  rs1Value,
   input wire [31:0]  rs2Value,

   input wire [4:0]   iDecodedOP,
   output wire [4:0]  oDecodedOP,

   output wire [31:0] aluValue,
   output wire [31:0] oRs2Value,
   input wire [31:0]  immediate,

   output wire        branchTaken,

   input wire         clk, rstf
   );

   logic [31:0]        rs1ValueMux, rs2ValueMux;
   wire               isBranch, isALU, isALUIMM;

   assign i_instr = t_instr;
   assign i_instr_valid = t_instr_valid;
   assign t_instr_ready = i_instr_ready;

   assign oPC = iPC;
   assign oDecodedOP = iDecodedOP;
   

   
   assign isBranch = t_instr`opcode == OP_BRANCH;
   assign isALU = t_instr`opcode == OP_ALU;
   assign isALUIMM = t_instr`opcode == OP_ALU_IMM;

   /* verilator lint_off UNUSED */
   operation_t op_debug;
   always_comb op_debug = operation_t'(iDecodedOP);
   /* verilator lint_on UNUSED */
   
   function automatic reg isBranchTaken(operation_t op, reg[31:0] dataA, reg[31:0] dataB);
     unique case(op)
       BEQ: return dataA == dataB;
       BNE: return dataA != dataB;
       BLT: return $signed(dataA) < $signed(dataB);
       BGE: return $signed(dataA) >= $signed(dataB);
       BLTU: return dataA < dataB;
       BGEU: return dataA >= dataB;
       JAL, JALR: return '1;
       default:
         return '0;
     endcase // unique case (instr`func3)
   endfunction // isBranchTaken

   function automatic reg[31:0] ALU(operation_t op, reg[31:0] dataA, reg[31:0] dataB);
      unique case(op)
        ADD, AUIPC, BEQ, BNE, BLT, BGE, BLTU, BGEU, JAL, JALR, LOAD, STORE: return dataA + dataB;
        SUB: return dataA - dataB;
        SLT: return $signed(dataA) < $signed(dataB) ? 32'b1:32'b0;
        SLTU: return dataA < dataB ? 32'b1:32'b0;
        XOR: return dataA ^ dataB;
        OR: return dataA | dataB;
        AND: return dataA & dataB;
        SLL: return dataA << dataB[4:0];
        SRL: return dataA >> dataB[4:0];
        SRA: return $signed(dataA) >>> dataB[4:0];
        LUI: return dataB;
        //JAL, JALR: return dataB;
        default: return dataB;
      endcase
   endfunction // ALU
   

   assign branchTaken = isBranchTaken(iDecodedOP, rs1Value, rs2Value);


   // rs1Value Mux
   always_comb begin
      unique case(operation_t'(iDecodedOP))
        JAL, AUIPC, BEQ, BNE, BLT, BGE, BLTU, BGEU: rs1ValueMux = iPC;
        default: rs1ValueMux = rs1Value;
      endcase // unique case (decodedOP)
   end

   // rs2Value Mux
   always_comb rs2ValueMux = (t_instr`opcode == OP_ALU) ? rs2Value : immediate;

   assign aluValue = ALU(iDecodedOP, rs1ValueMux, rs2ValueMux);

   assign oRs2Value = rs2Value;
   
endmodule
