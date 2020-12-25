module regfile
  (input wire[4:0] addrA,
   output wire [31:0] regA,
   input wire [4:0]   addrB,
   output wire [31:0] regB,
   input wire [4:0]   addrDest,
   input wire [31:0]  dataDest,
   input wire         weDest,
   
   input wire         clk, rstf
   );
   
   reg [31:0]         registers[32];

   assign regA = registers[addrA];
   assign regB = registers[addrB];

   always @(posedge clk or negedge rstf) begin
      if(~rstf) begin
         registers <= '{default:'0};
      end
      else begin
         if(weDest & | addrDest)
           registers[addrDest] <= dataDest;
      end
   end

endmodule
   
