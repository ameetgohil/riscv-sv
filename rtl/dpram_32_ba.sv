// Byte addressable 32bit memory
module dpram_32_ba
  #(
    parameter DEPTH = 8192,
    parameter MEM0_INIT = "mem.mif",
    parameter MEM1_INIT = "mem.mif",
    parameter MEM2_INIT = "mem.mif",
    parameter MEM3_INIT = "mem.mif"
    )
   (
    input wire                      t_p0_valid,
    output wire                     t_p0_ready,
    input wire                      t_p0_we,
    input wire [$clog2(DEPTH)+2-1:0] t_p0_addr, // +2 b/c byte addressable
    input wire [3:0][7:0]           t_p0_data,
    input wire [3:0]                t_p0_mask,

    output reg                      i_p0_valid,
    input wire                      i_p0_ready,
    output reg [3:0][7:0]           i_p0_data,

    input wire                      t_p1_valid,
    output wire                     t_p1_ready,
    input wire                      t_p1_we,
    input wire [$clog2(DEPTH)+2-1:0] t_p1_addr,
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

   reg [3:0][7:0]            p0_dout;
   reg [3:0][7:0]            p1_dout;
   
   /* verilator lint_off WIDTH */
   initial begin
      $readmemh(MEM0_INIT, mem0);
      $readmemh(MEM1_INIT, mem1);
      $readmemh(MEM2_INIT, mem2);
      $readmemh(MEM3_INIT, mem3);
   end

   wire [$clog2(DEPTH)-1:0] addr0, addr1; //addr0 for port 0, addr1 for port1

   assign addr0 = t_p0_addr[$clog2(DEPTH)+2-1:2];
   assign addr1 = t_p1_addr[$clog2(DEPTH)+2-1:2];


   /**********************************************
    ***********PORT0******************************
    **********************************************/

   assign t_p0_ready = 1'b1;
   
   always @(posedge clk)
     i_p0_valid <= ~t_p0_we && t_p0_valid;

`ifdef ZERO_READ
   assign i_p0_data[0] = mem0[addr0];
`else
   assign i_p0_data[0] = p0_dout[0];
`endif
   
   always @(posedge clk) begin
      p0_dout[0] <= mem0[addr0];
      if(t_p0_mask[0] & t_p0_valid & t_p0_we) begin
         mem0[addr0] <= t_p0_data[0];
         p0_dout[0] <= t_p0_data[0];
      end
   end

`ifdef ZERO_READ
   assign i_p0_data[1] = mem1[addr0];
`else
   assign i_p0_data[1] = p0_dout[1];
`endif
   
   always @(posedge clk) begin
      p0_dout[1] <= mem1[addr0];
      if(t_p0_mask[1] & t_p0_valid & t_p0_we) begin
         mem1[addr0] <= t_p0_data[1];
         p0_dout[1] <= t_p0_data[1];
      end
   end

`ifdef ZERO_READ
   assign i_p0_data[2] = mem2[addr0];
`else
   assign i_p0_data[2] = p0_dout[2];
`endif
   
   always @(posedge clk) begin
      p0_dout[2] <= mem2[addr0];
      if(t_p0_mask[2] & t_p0_valid & t_p0_we) begin
         mem2[addr0] <= t_p0_data[2];
         p0_dout[2] <= t_p0_data[2];
      end
   end

`ifdef ZERO_READ
   assign i_p0_data[3] = mem3[addr0];
`else
   assign i_p0_data[3] = p0_dout[3];
`endif
   
   always @(posedge clk) begin
      p0_dout[3] <= mem3[addr0];
      if(t_p0_mask[3] & t_p0_valid & t_p0_we) begin
         mem3[addr0] <= t_p0_data[3];
         p0_dout[3] <= t_p0_data[3];
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
`else
   assign i_p1_data[0] = p1_dout[0];
`endif

   
   always @(posedge clk) begin
      p1_dout[0] <= mem0[addr1];
      if(t_p1_mask[0] & t_p1_valid & t_p1_we) begin
         mem0[addr1] <= t_p1_data[0];
         p1_dout[0] <= t_p1_data[0];
      end
   end

`ifdef ZERO_READ
   assign i_p1_data[1] = mem1[addr1];
`else
   assign i_p1_data[1] = p1_dout[1];
`endif
   
   always @(posedge clk) begin
      p1_dout[1] <= mem1[addr1];
      if(t_p1_mask[1] & t_p1_valid & t_p1_we) begin
         mem1[addr1] <= t_p1_data[1];
         p1_dout[1] <= t_p1_data[1];
      end
   end

`ifdef ZERO_READ
   assign i_p1_data[2] = mem2[addr1];
`else
   assign i_p1_data[2] = p1_dout[2];
`endif
   
   always @(posedge clk) begin
      p1_dout[2] <= mem2[addr1];
      if(t_p1_mask[2] & t_p1_valid & t_p1_we) begin
         mem2[addr1] <= t_p1_data[2];
         p1_dout[2] <= t_p1_data[2];
      end
   end

`ifdef ZERO_READ
   assign i_p1_data[3] = mem3[addr1];
`else
   assign i_p1_data[3] = p1_dout[3];
`endif
   
   always @(posedge clk) begin
      p1_dout[3] <= mem3[addr1];
      if(t_p1_mask[3] & t_p1_valid & t_p1_we) begin
         mem3[addr1] <= t_p1_data[3];
         p1_dout[3] <= t_p1_data[3];
      end
   end

   
endmodule


                      
