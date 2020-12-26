module regfile
  (input wire[4:0] addrA,
   output logic [31:0] regA,
   input wire [4:0]    addrB,
   output logic [31:0] regB,
   input wire [4:0]    addrDest,
   input wire [31:0]   dataDest,
   input wire          weDest,
  
   input wire          clk, rstf
   );
   
   logic [31:0]        registers[32];

   always_comb regA = registers[addrA];
   always_comb regB = registers[addrB];

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

