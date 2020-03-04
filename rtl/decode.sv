typedef struct packed {
   reg [6:0] 	    opcode;
   reg [4:0]       rd;
   reg [2:0] 	    funct3;
   reg [4:0] 	    rs1, rs2;
   reg [6:0] 	    funct7;

   reg 	    is_branch;
   reg 	    is_load;
   reg 	    is_store;
   reg 	    is_alu_imm;
   reg 	    is_alu_reg;

   reg 	    is_instr_lui;
   reg 	    is_instr_lui;
   reg 	    is_instr_auipc;
   reg 	    is_instr_jal;
   reg 	    is_instr_jalr;

   reg       is_instr_beq;
   reg       is_instr_bne;
   reg       is_instr_blt;
   reg       is_instr_bge;
   reg       is_instr_bltu;
   reg       is_instr_bgeu;

   reg       is_instr_lb;
   reg       is_instr_lh;
   reg       is_instr_lw;
   reg       is_instr_lbu;
   reg       is_instr_lhu;

   reg       is_instr_sb;
   reg       is_instr_sh;
   reg       is_instr_sw;

   reg       is_instr_addi;
   reg       is_instr_slti;
   reg       is_instr_sltiu;
   reg       is_instr_xori;
   reg       is_instr_ori;
   reg       is_instr_andi;
   reg       is_instr_slli;
   reg       is_instr_srli;
   reg       is_instr_srai;

   reg       funct7_0;
   reg       funct7_32;

   reg       is_instr_add;
   reg       is_instr_sub;
   reg       is_instr_sll;
   reg       is_instr_slt;
   reg       is_instr_sltu;
   reg       is_instr_xor;
   reg       is_instr_srl;
   reg       is_instr_sra;
   reg       is_instr_or;
   reg       is_instr_and;

   reg       is_instr_load;
   reg       is_instr_store;
   reg       is_instr_alu_imm;
   reg       is_instr_alu_reg;
   reg       is_instr_branch;
   reg       is_instr_jump;
   reg       is_instr_illegal;

   reg [31:0]         u_imm;
   reg [31:0]         j_imm;
   reg [31:0]         b_imm;
   reg [31:0]         i_imm;
   reg [31:0]         s_imm;
   
   reg [31:0] 	       imm;
   
} decode_t;

localparam OP_LUI = 7'b0110111
                    , OP_AUIPC = 7'b0010111
                    , OP_JAL = 7'b1101111
                    , OP_JALR = 7'b1100111
                    , OP_BRANCH = 7'b1100011
                    , OP_LOAD = 7'b0000011
                    , OP_STORE = 7'b0100011
                    , OP_ALU_IMM = 7'b0010011
                    , OP_ALU_REG = 7'b0110011;

function automatic decode_t decode_instr(reg[31:0] instr);
   decode_t di;

   
   di.opcode = instr[6:0];
   di.rd = instr[11:7];
   di.funct3 = instr[14:12];
   di.rs1 = instr[19:15];
   di.rs2 = instr[24:20];
   di.funct7 = instr[31:25];

   di.op_branch = (opcode == OP_BRANCH);
   di.op_load = (opcode == OP_LOAD);
   di.op_store = (opcode == OP_STORE);
   di.op_alu_imm = (opcode == OP_ALU_IMM) | (opcode == OP_LUI);
   di.op_alu_reg = (opcode == OP_ALU_REG);

   di.is_instr_lui = (opcode == OP_LUI);
   di.is_instr_auipc = (opcode == OP_AUIPC);
   di.is_instr_jal = (opcode == OP_JAL);
   di.is_instr_jalr = (opcode == OP_JALR);

   di.is_instr_beq = op_branch && (funct3 == 3'b000);
   di.is_instr_bne = op_branch && (funct3 == 3'b001);
   di.is_instr_blt = op_branch && (funct3 == 3'b100);
   di.is_instr_bge = op_branch && (funct3 == 3'b101);
   di.is_instr_bltu = op_branch && (funct3 == 3'b110);
   di.is_instr_bgeu = op_branch && (funct3 == 3'b111);

   di.is_instr_lb = op_load && (funct3 == 3'b000);
   di.is_instr_lh = op_load && (funct3 == 3'b001);
   di.is_instr_lw = op_load && (funct3 == 3'b010);
   di.is_instr_lbu = op_load && (funct3 == 3'b100);
   di.is_instr_lhu = op_load && (funct3 == 3'b101);

   di.is_instr_sb = op_store && (funct3 == 3'b000);
   di.is_instr_sh = op_store && (funct3 == 3'b001);
   di.is_instr_sw = op_store && (funct3 == 3'b010);

   di.funct7_0 = (funct7 == 7'b0000000);
   di.funct7_32 = (funct7 == 7'b0100000);

   di.is_instr_addi = di.op_alu_imm && (funct3 == 3'b000);
   di.is_instr_slti = di.op_alu_imm && (funct3 == 3'b010);
   di.is_instr_sltiu = di.op_alu_imm && (funct3 == 3'b011);
   di.is_instr_xori = di.op_alu_imm && (funct3 == 3'b100);
   di.is_instr_ori = di.op_alu_imm && (funct3 == 3'b110);
   di.is_instr_andi = di.op_alu_imm && (funct3 == 3'b111);
   di.is_instr_slli = di.op_alu_imm && (funct3 == 3'b001) && funct7_0;
   di.is_instr_srli = di.op_alu_imm && (funct3 == 3'b101) && funct7_0;
   di.is_instr_srai = di.op_alu_imm && (funct3 == 3'b101) && funct7_32;
   
   di.is_instr_add = di.op_alu_reg && (funct3 == 3'b000) && funct7_0;
   di.is_instr_sub = di.op_alu_reg && (funct3 == 3'b000) && funct7_32;
   di.is_instr_sll = di.op_alu_reg && (funct3 == 3'b001) && funct7_0;
   di.is_instr_slt = di.op_alu_reg && (funct3 == 3'b010) && funct7_0;
   di.is_instr_sltu = di.op_alu_reg && (funct3 == 3'b011) && funct7_0;
   di.is_instr_xor = di.op_alu_reg && (funct3 == 3'b100) && funct7_0;
   di.is_instr_srl = di.op_alu_reg && (funct3 == 3'b101) && funct7_0;
   di.is_instr_sra = di.op_alu_reg && (funct3 == 3'b101) && funct7_32;
   di.is_instr_or = di.op_alu_reg && (funct3 == 3'b110) && funct7_0;
   di.is_instr_and = di.op_alu_reg && (funct3 == 3'b111) && funct7_0;
   
   di.is_instr_load = is_instr_lb | is_instr_lw | is_instr_lbu | is_instr_lhu;
   di.is_instr_store = is_instr_sb | is_instr_sh | is_instr_sw;
   di.is_instr_alu_imm = is_instr_addi | is_instr_slti | is_instr_sltiu | is_instr_xori | is_instr_ori | is_instr_andi | is_instr_slli | is_instr_srli | is_instr_srai;
   di.is_instr_alu_reg = is_instr_add | is_instr_sub | is_instr_sll | is_instr_slt | is_instr_sltu | is_instr_xor | is_instr_srl | is_instr_sra | is_instr_or | is_instr_or | is_instr_and;
   di.is_instr_branch = is_instr_beq | is_instr_bne | is_instr_blt | is_instr_bge | is_instr_bltu | is_instr_bgeu;
   di.is_instr_jump = is_instr_jal | is_instr_jalr;
   di.is_instr_illegal = !(is_instr_load | is_instr_store | is_instr_alu_imm | is_instr_alu_reg | is_instr_branch | is_instr_jump);

   di.u_imm = { instr[31:12], 12'h0 };
   di.j_imm = { {12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0 };
   di.b_imm = { {20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0 };
   di.i_imm = { {20{instr[31]}}, instr[31:20] };
   di.s_imm = { {20{instr[31]}}, instr[31:25], instr[11:7] };

   di.imm = (is_instr_lui | is_instr_auipc) ? u_imm:
                is_instr_jal ? j_imm:
                is_instr_branch ? b_imm:
                (is_instr_load | is_instr_jalr | is_instr_alu_imm) ? i_imm:
                is_instr_store ? s_imm:32'h0;
   
