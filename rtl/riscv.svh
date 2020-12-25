`ifndef RISCV_SVH
`define RISCV_SVH

`define opcode [6:0]
`define funct3 [14:12]
`define funct7 [31:25]
`define funct12 [31:20]
typedef enum logic [6:0] 
             { OP_LUI = 7'b0110111,
               OP_AUIPC = 7'b0010111,
               OP_JAL = 7'b1101111,
               OP_JALR = 7'b1100111,
               OP_BRANCH = 7'b1100011,
               OP_LOAD = 7'b0000011,
               OP_STORE = 7'b0100011,
               OP_ALU_IMM = 7'b0010011,
               OP_ALU = 7'b0110011,
               OP_MISC_MEM = 7'b0001111,
               OP_MISC = 7'b1110011
               } opcode_t;

typedef enum logic [2:0]
             { F3_BEQ = 3'b000,
               F3_BNE = 3'b001,
               F3_BLT = 3'b100,
               F3_BGE = 3'b101,
               F3_BLTU = 3'b110,
               F3_BGEU = 3'b111
               } funct3_branch_t;

typedef enum logic [2:0]
             { F3_LB = 3'b000,
               F3_LH = 3'b001,
               F3_LW = 3'b010,
               F3_LBU = 3'b100,
               F3_LHU = 3'b101
               } funct3_load_t;

typedef enum logic [2:0]
             { F3_SB = 3'b000,
               F3_SH = 3'b001,
               F3_SW = 3'b010
               } funct3_store_t;

typedef enum logic [2:0]
             { F3_ADDSUB = 3'b000,
               F3_SLL = 3'b001,
               F3_SLT = 3'b010,
               F3_SLTU = 3'b011,
               F3_XOR = 3'b100,
               F3_SRLSRA = 3'b101,
               F3_OR = 3'b110,
               F3_AND = 3'b111
               }  funct3_alu_t;

typedef enum logic [6:0]
             { F7_ADD_SRL = 7'b0000000,
               F7_SUB_SRA = 7'b0100000
               } funct7_alu_t;

typedef enum logic [2:0]
             { F3_FENCE = 3'b000,
               F3_FENCE_I = 3'b001
               } funct3_misc_mem_t;

typedef enum logic [2:0]
             { F3_ECALL_EBREAK = 3'b000,
               F3_CSRRW = 3'b001,
               F3_CSRRS = 3'b010,
               F3_CSRRC = 3'b011,
               F3_CSRRWI = 3'b101,
               F3_CSRRSE = 3'b110,
               F3_CSRRCI = 3'b111
               } funct3_misc_t;

typedef enum logic [11:0]
             { F12_ECALL = 12'b000000000000,
               F12_EBREAK = 12'b000000000001
               } funct12_misc_t;


typedef enum logic [4:0] {
    LUI,
    AUIPC,
    JAL,
    JALR,
    BEQ,
    BNE,
    BLT,
    BGE,
    BLTU,
    BGEU,
    LOAD,
    STORE,
    ADD,
    SUB,
    SLT,
    SLTU,
    XOR,
    OR,
    AND,
    SLL,
    SRL,
    SRA,
    FENCE,
    FENCE_I,
    ECALL,
    EBREAK,
    MRET,
    WFI,
    CSRRW,
    CSRRS,
    CSRRC,
    INVALID
} operation_t;

`endif
