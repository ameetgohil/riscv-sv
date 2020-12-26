`include "riscv.svh"
module instruction_memoryaccess
  (input wire[31:0] t_instr,
   input wire          t_instr_valid,
   output logic        t_instr_ready,

   output logic [31:0] i_instr,
   output logic        i_instr_valid,
   input wire          i_instr_ready,
   
   input wire [31:0]   iPC,
   output logic [31:0]  oPC,
   
   input wire [4:0]    iDecodedOP,
   output logic [4:0]   oDecodedOP,

   input wire [31:0]   aluValue,
   input wire [31:0]   rs2Value,

   output logic [31:0]  maAluValue,
   
   output logic [31:0]  dbus_cmd_addr,
   output logic [31:0]  dbus_cmd_data,
   output logic         dbus_cmd_we,
   output logic [3:0]  dbus_cmd_size,
   output logic         dbus_cmd_valid,
   input wire          dbus_cmd_ready,
   input wire [31:0]   dbus_rsp_data,
   input wire          dbus_rsp_valid,

   input               clk, rstf
   );

   always_comb i_instr = t_instr;
   always_comb i_instr_valid = t_instr_valid;
   always_comb t_instr_ready = i_instr_ready;
   always_comb oDecodedOP = iDecodedOP;
   always_comb oPC = iPC;
   
   always_comb dbus_cmd_addr = aluValue;
   always_comb dbus_cmd_data = rs2Value;
   always_comb dbus_cmd_we = (operation_t'(iDecodedOP) == STORE);
   always_comb dbus_cmd_valid = (operation_t'(iDecodedOP) == STORE) | (operation_t'(iDecodedOP) == LOAD);
   always_comb dbus_cmd_size = memsize(t_instr, iDecodedOP);
   
   always_comb maAluValue = (operation_t'(iDecodedOP) == LOAD) ? dbus_rsp_data : aluValue;

   /* verilator lint_off UNUSED */
   function automatic logic[3:0] memsize(logic[31:0] instr, operation_t decodedOP);
      /* verilator lint_off UNUSED */
      if(decodedOP == STORE) begin
        case(funct3_load_t'(instr`funct3))
          F3_LB, F3_LBU: return 4'b0001;
          F3_LH, F3_LHU: return 4'b0011;
          default: return 4'b1111;
        endcase // unique case (funct3_load_t'(t_instr`funct3))
      end
      else if(decodedOP == LOAD) begin
         case(funct3_store_t'(instr`funct3))
          F3_SB: return 4'b0001;
          F3_SH: return 4'b0011;
          default: return 4'b1111;
        endcase // unique case (funct3_store_t'(t_insstr`funct3))
      end // else: !if(decodedOP == STORE)
      else return 4'b1111;
   endfunction
      

            
endmodule // instruction_memoryaccess

