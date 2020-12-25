interface instruction_intf;
   wire [31:0] instruction;
   wire [5:0]  addrA;
   wire [31:0] dataA;
   wire [5:0]  addrB;
   wire [31:0] dataB;

   wire [5:0]  addrDest;
   wire [31:0] destData;

   wire [31:0] pc;

   wire        flush;
   wire        valid;
   wire        ready;
endmodule
