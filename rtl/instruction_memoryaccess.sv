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
   output wire [4:0]   oDecodedOP,

   input wire [31:0]   aluValue,
   input wire [31:0]   rs2Value,

   output wire [31:0]  maAluValue,
   
   output wire [31:0]  dbus_cmd_addr,
   output wire [31:0]  dbus_cmd_data,
   output wire         dbus_cmd_we,
   output logic [3:0]  dbus_cmd_size,
   output wire         dbus_cmd_valid,
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
   
   assign dbus_cmd_addr = aluValue;
   assign dbus_cmd_data = rs2Value;
   assign dbus_cmd_we = (operation_t'(iDecodedOP) == STORE);
   assign dbus_cmd_valid = (operation_t'(iDecodedOP) == STORE) | (operation_t'(iDecodedOP) == LOAD);
   always_comb dbus_cmd_size = memsize(t_instr, iDecodedOP);
   
   assign maAluValue = (operation_t'(iDecodedOP) == LOAD) ? dbus_rsp_data : aluValue;

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

