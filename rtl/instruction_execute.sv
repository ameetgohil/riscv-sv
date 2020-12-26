`include "riscv.svh"
module instruction_execute
  (input wire[31:0] t_instr,
   input wire          t_instr_valid,
   output logic        t_instr_ready,

   output logic [31:0] i_instr,
   output logic        i_instr_valid,
   input wire          i_instr_ready,
  
   input wire [31:0]   iPC,
   output logic [31:0] oPC,
  
   input wire [31:0]   rs1Value,
   input wire [31:0]   rs2Value,

   input wire [4:0]    iDecodedOP,
   output logic [4:0]  oDecodedOP,

   output logic [31:0] aluValue,
   output logic [31:0] oRs2Value,
   input wire [31:0]   immediate,

   output logic        branchTaken,

   input wire          clk, rstf
   );

   logic [31:0]        rs1ValueMux, rs2ValueMux;
   logic               isBranch, isALU, isALUIMM;

   always_comb i_instr = t_instr;
   always_comb i_instr_valid = t_instr_valid;
   always_comb t_instr_ready = i_instr_ready;

   always_comb oPC = iPC;
   always_comb oDecodedOP = iDecodedOP;
   

   
   always_comb isBranch = t_instr`opcode == OP_BRANCH;
   always_comb isALU = t_instr`opcode == OP_ALU;
   always_comb isALUIMM = t_instr`opcode == OP_ALU_IMM;

   /* verilator lint_off UNUSED */
   operation_t op_debug;
   always_comb op_debug = operation_t'(iDecodedOP);
   /* verilator lint_on UNUSED */
   
   function automatic logic isBranchTaken(operation_t op, logic[31:0] dataA, logic[31:0] dataB);
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

   function automatic logic[31:0] ALU(operation_t op, logic[31:0] dataA, logic[31:0] dataB);
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
   

   always_comb branchTaken = isBranchTaken(iDecodedOP, rs1Value, rs2Value);


   // rs1Value Mux
   always_comb begin
      unique case(operation_t'(iDecodedOP))
        JAL, AUIPC, BEQ, BNE, BLT, BGE, BLTU, BGEU: rs1ValueMux = iPC;
        default: rs1ValueMux = rs1Value;
      endcase // unique case (decodedOP)
   end

   // rs2Value Mux
   always_comb rs2ValueMux = (t_instr`opcode == OP_ALU) ? rs2Value : immediate;

   always_comb aluValue = ALU(iDecodedOP, rs1ValueMux, rs2ValueMux);

   always_comb oRs2Value = rs2Value;
   
endmodule
