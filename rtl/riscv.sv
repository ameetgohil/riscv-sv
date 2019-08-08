module riscv
  (
   /* Instruction Bus */
   output reg        iBus_cmd_valid,
   input wire        iBus_cmd_ready,
   output reg [31:0] iBus_cmd_payload_pc,
   input wire        iBus_rsp_ready,
   input wire        iBus_rsp_err,
   input wire [31:0] iBus_rsp_instr,
   /* Data Bus */
   output reg        dBus_cmd_valid,
   input wire        dBus_cmd_ready,
   output reg [31:0] dBus_cmd_payload_addr,
   output reg [31:0] dBus_cmd_payload_data,
   output reg [3:0]  dBus_cmd_payload_size,
   output reg        dBus_cmd_payload_wr, //1 - write, 0 - read
   input wire [31:0] dBus_rsp_data,
   input wire        dBus_rsp_valid,
   input wire        dBus_rsp_error,
  
  
   input wire        clk, rstf);


   reg [31:0]        xregs[32];
   
   reg [31:0]        pc;

   localparam PC_SIZE = 32;
   

   
   // Decode
   enum              logic [6:0] {OP_LUI = 7'b0110111
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

   assign opcode = iBus_rsp_instr[6:0];
   assign rd = iBus_rsp_instr[11:7];
   assign funct3 = iBus_rsp_instr[14:12];
   assign rs1 = iBus_rsp_instr[19:15];
   assign rs2 = iBus_rsp_instr[24:20];
   assign funct7 = iBus_rsp_instr[31:25];

   wire                         op_branch;
   wire                         op_load;
   wire                         op_store;
   wire                         op_alu_imm;
   wire                         op_alu_reg;

   assign op_branch = (opcode == OP_BRANCH);
   assign op_load = (opcode == OP_LOAD);
   assign op_store = (opcode == OP_STORE);
   assign op_alu_imm = (opcode == OP_ALU_IMM) | (opcode == OP_LUI);
   assign op_alu_reg = (opcode == OP_ALU_REG);

   wire                         instr_lui;
   wire                         instr_auipc;
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

   wire                         instr_sb;
   wire                         instr_sh;
   wire                         instr_sw;

   assign instr_sb = op_store && (funct3 == 3'b000);
   assign instr_sh = op_store && (funct3 == 3'b001);
   assign instr_sw = op_store && (funct3 == 3'b010);

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
   assign instr_alu_imm = instr_addi | instr_slti | instr_sltiu | instr_xori | instr_ori | instr_andi | instr_slli | instr_srli | instr_srai;
   assign instr_alu_reg = instr_add | instr_sub | instr_sll | instr_slt | instr_sltu | instr_xor | instr_srl | instr_sra | instr_or | instr_or | instr_and;
   assign instr_branch = instr_beq | instr_bne | instr_blt | instr_bge | instr_bltu | instr_bgeu;
   assign instr_jump = instr_jal | instr_jalr;
   assign instr_illegal = !(instr_load | instr_store | instr_alu_imm | instr_alu_reg | instr_branch | instr_jump);

   //extract immediate value
   wire [31:0]                  u_imm;
   wire [31:0]                  j_imm;
   wire [31:0]                  b_imm;
   wire [31:0]                  i_imm;
   wire [31:0]                  s_imm;

   wire [31:0]                  imm;

   assign u_imm = { iBus_rsp_instr[31:12], 12'h0 };
   assign j_imm = { {12{iBus_rsp_instr[31]}}, iBus_rsp_instr[19:12], iBus_rsp_instr[20], iBus_rsp_instr[30:21], 1'b0 };
   assign b_imm = { {20{iBus_rsp_instr[31]}}, iBus_rsp_instr[7], iBus_rsp_instr[30:25], iBus_rsp_instr[11:8], 1'b0 };
   assign i_imm = { {20{iBus_rsp_instr[31]}}, iBus_rsp_instr[31:20] };
   assign s_imm = { {20{iBus_rsp_instr[31]}}, iBus_rsp_instr[31:25], iBus_rsp_instr[11:7] };

   assign imm = (instr_lui | instr_auipc) ? u_imm:
                instr_jal ? j_imm:
                instr_branch ? b_imm:
                (instr_load | instr_jalr | instr_alu_imm) ? i_imm:
                instr_store ? s_imm:32'h0;

   enum logic [3:0] { ALU_ADD,
                      ALU_SUB,
                      ALU_SLL,
                      ALU_SLT,
                      ALU_SLTU,
                      ALU_XOR,
                      ALU_SRL,
                      ALU_SRA,
                      ALU_OR,
                      ALU_AND,
                      ALU_AUIPC } alu_type;

   assign alu_type = (instr_add | instr_addi | instr_lui | op_load | op_store) ? ALU_ADD:
                   (instr_sub) ? ALU_SUB:
                   (instr_sll | instr_slli) ? ALU_SLL:
                   (instr_slt | instr_slti) ? ALU_SLT:
                   (instr_sltu | instr_sltiu) ? ALU_SLTU:
                   (instr_xor | instr_xori) ? ALU_XOR:
                   (instr_srl | instr_srli) ? ALU_SRL:
                   (instr_sra | instr_srai) ? ALU_SRA:
                   (instr_or | instr_ori) ? ALU_OR:
                   (instr_and | instr_andi) ? ALU_AND:
                   (instr_auipc) ? ALU_AUIPC:4'hF;

   enum logic [2:0] { BR_NONE,
                      BR_EQ,
                      BR_NE,
                      BR_LT,
                      BR_GE,
                      BR_LTU,
                      BR_GEU,
                      BR_JUMP } branch_type;

   assign branch_type = instr_beq ? BR_EQ:
                      instr_bne ? BR_NE:
                      instr_blt ? BR_LT:
                      instr_bge ? BR_GE:
                      instr_bltu ? BR_LTU:
                      instr_bgeu ? BR_GEU:
                      instr_jump ? BR_JUMP:BR_NONE;

   wire [4:0] rs1_index;
   wire [4:0] rs2_index;
   
   assign rs1_index = (instr_lui | instr_auipc | instr_jal) ? 5'h0:rs1;
   assign rs2_index = (op_load | instr_jump | op_alu_imm) ? 5'h0:rs2;

   wire op_is_imm;

   assign op_is_imm = op_alu_imm | instr_jal | op_load | op_store;
   
   wire [31:0] rs1_value;
   wire [31:0] rs2_value;

   assign rs1_value = xregs[rs1_index];
   assign rs2_value = xregs[rs2_index];
   
   wire [31:0] alu_srca;
   wire [31:0] alu_srcb;
   
   assign alu_srca = rs1_value;
   //assign alu_srcb = rs2_value;


   assign alu_srcb = op_is_imm ? imm : rs2_value;

   reg [31:0] alu_res;

   // ALU

   always @(*) begin
      case(alu_type)
         ALU_ADD:
           alu_res = $signed(alu_srca) + $signed(alu_srcb);
        ALU_SUB:
          alu_res = $signed(alu_srca) + $signed(alu_srcb);
        ALU_SLL:
          alu_res = alu_srca << alu_srcb;
        ALU_SLT:
          alu_res = $signed(alu_srca) < $signed(alu_srcb) ? 1:0;
        ALU_SLTU:
          alu_res = alu_srca < alu_srcb ? 1:0;
        ALU_XOR:
          alu_res = alu_srca ^ alu_srcb;
        ALU_SRL:
          alu_res = alu_srca >> alu_srcb;
        ALU_SRA:
          alu_res = $signed(alu_srca) >> alu_srcb;
        ALU_OR:
          alu_res = alu_srca | alu_srcb;
        ALU_AND:
          alu_res = alu_srca & alu_srcb;
        ALU_AUIPC:
          alu_res = pc + alu_srcb;
        default:
          alu_res = 0;
      endcase // case (alu_type)
   end // always @ (*)


   wire branch_taken;
   
   assign branch_taken = 
        (BR_JUMP == branch_type) ? 1'b1 :
        (BR_EQ   == branch_type) ? rs1_value == rs2_value :
        (BR_NE   == branch_type) ? rs1_value != rs2_value :
        (BR_LT   == branch_type) ? rs1_value < rs2_value :
        (BR_GE   == branch_type) ? rs1_value > rs2_value :
        (BR_LTU  == branch_type) ? rs1_value <= rs2_value :
        (BR_GEU  == branch_type) ? rs1_value >= rs2_value : 1'b0;
   
   wire [31:0] jump_addr;

   assign jump_addr = instr_jalr ? rs1_value + imm : pc + imm;
   
   enum logic [1:0]  { SIZE_BYTE = 2'd0,
                      SIZE_HALF = 2'd1,
                      SIZE_WORD = 2'd2 } mem_size;

   assign mem_size = (instr_lb | instr_lbu | instr_sb) ? SIZE_BYTE :
                     (instr_lh | instr_lhu | instr_sh) ? SIZE_HALF : SIZE_WORD;
   

   assign dBus_cmd_payload_addr = alu_res;
   assign dBus_cmd_payload_data = rs2_value;
   assign dBus_cmd_payload_size = mem_size == 0 ? 4'b0001:
                                  mem_size == 1 ? 4'b0011:
                                  mem_size == 2 ? 4'b1111:0;
   assign dBus_cmd_payload_wr = op_store;
   assign dBus_cmd_valid = op_store | op_load;

   wire [31:0]      mem_rdata;
   assign mem_rdata = (mem_size == SIZE_BYTE) ? { {24{dBus_rsp_data[7]}}, dBus_rsp_data[7:0]} :
                      (mem_size == SIZE_HALF) ? { {16{dBus_rsp_data[15]}}, dBus_rsp_data[15:0]} :
                      dBus_rsp_data;

   

   
   wire [31:0]      rd_value;
   wire             rd_we;
   
   assign rd_value = (op_load | op_store) ? mem_rdata : alu_res;
   assign rd_we = ~(op_branch | op_store);

   always @(posedge clk)
     if(rd_we)
       xregs[rd] <= rd_value;

   
   always @(posedge clk) 
     if(~rstf) 
       pc <= 0;
     else if(branch_taken)
       pc <= jump_addr[PC_SIZE-1:0];
     else
       pc <= pc + 'd4;

   assign iBus_cmd_valid = 1'b1;
   assign iBus_cmd_payload_pc = pc;
   
endmodule // riscv
