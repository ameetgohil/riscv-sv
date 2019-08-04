// Byte addressable 32bit memory
module dpram_32b_ba
  #(
    parameter DEPTH = 8192,
    parameter MEM_0_INIT = "mem.mif",
    parameter MEM_1_INIT = "mem.mif",
    parameter MEM_2_INIT = "mem.mif",
    parameter MEM_3_INIT = "mem.mif"
    )
   (
    input wire                      t_p0_valid,
    output wire                     t_p0_ready,
    input wire                      t_p0_we,
    input wire [$clog(DEPTH)+2-1:0] t_p0_addr, // +2 b/c byte addressable
    input wire [3:0][7:0]           t_p0_data,
    input wire [3:0]                t_p0_mask,

    output reg                      i_p0_valid,
    input wire                      i_p0_ready,
    output reg [3:0][7:0]           i_p0_data,

    input wire                      t_p1_valid,
    output wire                     t_p1_ready,
    input wire                      t_p1_we,
    input wire [$clog(DEPTH)+2-1:0] t_p1_addr,
    input wire [3:0][7:0]           t_p1_data,
    input wire [3:0]                t_p1_mask,

    output reg                      i_p1_valid,
    input wire                      i_p1_ready,
    output reg [3:0][7:0]           i_p1_data,

    input wire                      clk, rstf
    );

   reg [7:0]                        mem0 [DEPTH] /* synthesis syn_ramstyle = "block_ram" */;
   reg [7:0]                        mem1 [DEPTH] /* synthesis syn_ramstyle = "block_ram" */;
   reg [7:0]                        mem2 [DEPTH] /* synthesis syn_ramstyle = "block_ram" */;
   reg [7:0]                        mem3 [DEPTH] /* synthesis syn_ramstyle = "block_ram" */;

   initial begin
      $readmemh(MEM_0_INIT, mem0);
      $readmemh(MEM_1_INIT, mem0);
      $readmemh(MEM_2_INIT, mem0);
      $readmemh(MEM_3_INIT, mem0);
   end

   wire [$clog(DEPTH)-1:0] addr0, addr1; //addr0 for port 0, addr1 for port1

   assign addr0 = t_p0_addr[$clog(DEPTH)+2-1:2];
   assign addr1 = t_p1_addr[$clog(DEPTH)+2-1:2];


   /**********************************************
    ***********PORT0******************************
    **********************************************/

   assign t_p0_ready = 1'b1;
   
   always @(posedge clk)
     i_p0_valid <= ~t_p0_we && t_p0_valid;

`ifdef ZERO_READ
   assign i_p0_data[0] = mem0[addr0];
`endif
   
   always @(posedge clk) begin
      i_p0_data[0] <= mem0[addr0];
      if(t_p0_mask[0] & t_p0_valid & t_p0_we) begin
         mem0[addr0] <= t_p0_data[0];
         i_p0_data[0] <= t_p0_data[0];
      end
   end

`ifdef ZERO_READ
   assign i_p0_data[1] = mem1[addr0];
`endif
   
   always @(posedge clk) begin
      i_p0_data[1] <= mem1[addr0];
      if(t_p0_mask[1] & t_p0_valid & t_p0_we) begin
         mem1[addr0] <= t_p0_data[1];
         i_p0_data[1] <= t_p0_data[1];
      end
   end

`ifdef ZERO_READ
   assign i_p0_data[2] = mem2[addr0];
`endif
   
   always @(posedge clk) begin
      i_p0_data[2] <= mem2[addr0];
      if(t_p0_mask[2] & t_p0_valid & t_p0_we) begin
         mem2[addr0] <= t_p0_data[2];
         i_p0_data[2] <= t_p0_data[2];
      end
   end

`ifdef ZERO_READ
   assign i_p0_data[3] = mem3[addr0];
`endif
   
   always @(posedge clk) begin
      i_p0_data[3] <= mem3[addr0];
      if(t_p0_mask[3] & t_p0_valid & t_p0_we) begin
         mem3[addr0] <= t_p0_data[3];
         i_p0_data[3] <= t_p0_data[3];
      end
   end
   

   /**********************************************
    ***********PORT1******************************
    **********************************************/

   assign t_p1_ready = 1'b1;
   
   always @(posedge clk)
     i_p1_valid <= ~t_p1_we && t_p1_valid;

`ifdef ZERO_READ
   assign i_p1_data[0] = mem0[addr1];
`endif

   
   always @(posedge clk) begin
      i_p1_data[0] <= mem0[addr1];
      if(t_p1_mask[0] & t_p1_valid & t_p1_we) begin
         mem0[addr1] <= t_p1_data[0];
         i_p1_data[0] <= t_p1_data[0];
      end
   end

`ifdef ZERO_READ
   assign i_p1_data[1] = mem1[addr1];
`endif
   
   always @(posedge clk) begin
      i_p1_data[1] <= mem1[addr1];
      if(t_p1_mask[1] & t_p1_valid & t_p1_we) begin
         mem1[addr1] <= t_p1_data[1];
         i_p1_data[1] <= t_p1_data[1];
      end
   end

`ifdef ZERO_READ
   assign i_p1_data[2] = mem2[addr1];
`endif
   
   always @(posedge clk) begin
      i_p1_data[2] <= mem2[addr1];
      if(t_p1_mask[2] & t_p1_valid & t_p1_we) begin
         mem2[addr1] <= t_p1_data[2];
         i_p1_data[2] <= t_p1_data[2];
      end
   end

`ifdef ZERO_READ
   assign i_p1_data[3] = mem3[addr1];
`endif
   
   always @(posedge clk) begin
      i_p1_data[3] <= mem3[addr1];
      if(t_p1_mask[3] & t_p1_valid & t_p1_we) begin
         mem3[addr1] <= t_p1_data[3];
         i_p1_data[3] <= t_p1_data[3];
      end
   end

   
endmodule


                      
