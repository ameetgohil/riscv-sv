module instruction_fetch
  (output logic [31:0] ibus_addr,
   output logic        valid,
   input wire         ready,
   input wire [31:0]  ibus_instr,

   output logic [31:0] instr,
   output logic        instr_valid,
   input wire        instr_ready,

   output logic [31:0] oPC,

   input wire [31:0]  aluPC,
   input wire         branchTaken, 

   input wire         clk, rstf
   );

   always_comb ibus_addr = oPC;
   always_comb valid = 1'b1;


   always_comb instr = ibus_instr;
   always_comb instr_valid = 1'b1;
   
   always @(posedge clk or negedge rstf) begin
      if(~rstf)
        oPC <= 0;
      else
        oPC <= ~instr_ready ? oPC :
              branchTaken ? aluPC : oPC + 4;
   end

   

endmodule
