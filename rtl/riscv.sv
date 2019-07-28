module riscv
  (
   /* Instruction Bus */
   output reg        iBus_cmd_valid,
   input wire        iBus_cmd_ready,
   output reg [31:0] iBus_cmd_payload_pc,
   input wire        iBus_rsp_ready,
   input wire        iBus_rsp_err,
   input wire [31:0] iBus_rsp_inst,
   /* Data Bus */
   output reg        dBus_cmd_valid,
   input wire        dBus_cmd_ready,
   output reg [31:0] dBus_cmd_payload_address,
   output reg [31:0] dBus_cmd_payload_data,
   output reg [1:0]  dBus_cmd_payload_size,

  
  
   input wire        clk, rstf);

   reg [31:0]        pc_addr;

   always @(posedge clk) 
     if(~rstf) 
       pc_addr <= 0;
     else if(pc_addr_inc)
       pc_addr <= pc_addr + 1;
     else
       pc_addr <= jump_addr[PC_SIZE-1:2];

   // Decode
   enum              wire [6:0] {OP_LUI = 7'b0110111
                                 , OP_AUIPC = 7'b0010111
                                 , OP_JAL = 7'b1101111
                                 , OP_JALR = 7'b1100111
                                 , OP_BRANCH = 7'b1100011
                                 , OP_LOAD = 7'b0000011
                                 , OP_STORE = 7'b0100011
                                 , OP_ALU_IMM = 7'b0010011
                                 , OP_ALU_REG = 7'b0110011
                                 } opcode;
   wire [4:0]                   rd;
   wire [2:0]                   funct3;
   wire [4:0]                   rs1, rs2;
   wire [6:0]                   funct7;

   assign opcode = iBus_rsp_inst[6:0];
   assign rd = iBus_rsp_inst[11:7];
   assign funct3 = iBus_rsp_inst[14:12];
   assign rs1 = iBus_rsp_inst[19:15];
   assign rs2 = iBus_rsp_inst[24:20];
   assign funct7 = iBus_rsp_inst[31:25];

   wire                         op_branch;
   wire                         op_load;
   wire                         op_store;
   wire                         op_alu_imm;
   wire                         op_alu_reg;

   assign op_branch = (opcode == OP_BRANCH);
   assign op_load = (opcode == OP_LOAD);
   assign op_store = (opcode == OP_STORE);
   assign op_alu_imm = (opcode == OP_ALU_IMM);
   assign op_alu_reg = (opcode == OP_ALU_REG);

   wire                         instr_lui;
   wire                         instr_auipic;
   wire                         instr_jal;
   wire                         instr_jalr;

   assign instr_lui = (opcode == OP_LUI);
   assign instr_auipc = (opcode == OP_AUIPC);
   assign instr_jal = (opcode == OP_JAL);
   assign instr_jalr = (opcode == OP_JALR);

   wire                         instr_beq;
   wire                         instr_bne;
   wire                         instr_blt;
   wire                         instr_bge;
   wire                         instr_bltu;
   wire                         instr_bgeu;

   assign instr_beq = op_branch && (funct3 == 3'b000);
   assign instr_bne = op_branch && (funct3 == 3'b001);
   assign instr_blt = op_branch && (funct3 == 3'b100);
   assign instr_bge = op_branch && (funct3 == 3'b101);
   assign instr_bltu = op_branch && (funct3 == 3'b110);
   assign instr_bgeu = op_branch && (funct3 == 3'b111);

   wire                         instr_lb;
   wire                         instr_lh;
   wire                         instr_lw;
   wire                         instr_lbu;
   wire                         instr_lhu;

   assign instr_lb = op_load && (funct3 == 3'b000);
   assign instr_lh = op_load && (funct3 == 3'b001);
   assign instr_lw = op_load && (funct3 == 3'b010);
   assign instr_lbu = op_load && (funct3 == 3'b100);
   assign instr_lhu = op_load && (funct3 == 3'b101);

   wire                         instr_addi;
   wire                         instr_slti;
   wire                         instr_sltiu;
   wire                         instr_xori;
   wire                         instr_ori;
   wire                         instr_andi;
   wire                         instr_slli;
   wire                         instr_srli;
   wire                         instr_srai;

   wire                         funct7_0;
   wire                         funct7_32;

   assign funct7_0 = (funct7 == 7'b0000000);
   assign funct7_32 = (funct7 == 7'b0100000);

   assign instr_addi = op_alu_imm && (funct3 == 3'b000);
   assign instr_slti = op_alu_imm && (funct3 == 3'b010);
   assign instr_sltiu = op_alu_imm && (funct3 == 3'b011);
   assign instr_xori = op_alu_imm && (funct3 == 3'b100);
   assign instr_ori = op_alu_imm && (funct3 == 3'b110);
   assign instr_andi = op_alu_imm && (funct3 == 3'b111);
   assign instr_slli = op_alu_imm && (funct3 == 3'b001) && funct7_0;
   assign instr_srli = op_alu_imm && (funct3 == 3'b101) && funct7_0;
   assign instr_srai = op_alu_imm && (funct3 == 3'b101) && funct7_32;
   
   wire                         instr_add;
   wire                         instr_sub;
   wire                         instr_sll;
   wire                         instr_slt;
   wire                         instr_sltu;
   wire                         instr_xor;
   wire                         instr_srl;
   wire                         instr_sra;
   wire                         instr_or;
   wire                         instr_and;

   assign instr_add = op_alu_reg && (funct3 == 3'b000) && funct7_0;
   assign instr_sub = op_alu_reg && (funct3 == 3'b000) && funct7_32;
   assign instr_sll = op_alu_reg && (funct3 == 3'b001) && funct7_0;
   assign instr_slt = op_alu_reg && (funct3 == 3'b010) && funct7_0;
   assign instr_sltu = op_alu_reg && (funct3 == 3'b011) && funct7_0;
   assign instr_xor = op_alu_reg && (funct3 == 3'b100) && funct7_0;
   assign instr_srl = op_alu_reg && (funct3 == 3'b101) && funct7_0;
   assign instr_sra = op_alu_reg && (funct3 == 3'b101) && funct7_32;
   assign instr_or = op_alu_reg && (funct3 == 3'b110) && funct7_0;
   assign instr_and = op_alu_reg && (funct3 == 3'b111) && funct7_0;
   
   wire                         instr_load;
   wire                         instr_store;
   wire                         instr_alu_imm;
   wire                         instr_alu_reg;
   wire                         instr_branch;
   wire                         instr_jump;
   wire                         instr_illegal;
   
   assign instr_load = instr_lb | instr_lw | instr_lbu | instr_lhu;
   assign instr_store = instr_sb | instr_sh | instr_sw;
   assign instr_alu_imm = instr_addi | instr_slti | instr_sltiu | instr_xori | instr_ori | instr_andi | ins
   
endmodule // riscv
