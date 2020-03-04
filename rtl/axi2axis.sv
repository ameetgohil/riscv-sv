module axi2axis
  (
   input wire [31:0] s_axi_awaddr,
   input wire        s_axi_awprot,
   input wire        s_axi_awvalid,
   output reg        s_axi_awready,

   input wire [31:0] s_axi_wdata,
   input wire        s_axi_wstrb,
   input wire        s_axi_wvalid,
   output reg        s_axi_wready,

   input wire        s_axi_arvalid,
   input wire        s_axi_arready,
   input wire [31:0] s_axi_araddr,
   output reg        s_axi_arprot,

   output reg        s_axi_rvalid,
   input wire        s_axi_rready,
   output reg [31:0] s_axi_rdata,
   input wire [3:0]  s_axi_rresp,

   output reg [31:0] m_axis_wdata,
   output reg        m_axis_wvalid,
   input wire        m_axis_wready,

   input wire [31:0] m_axis_rdata,
   input wire        m_axis_rvalid,
   output reg        m_axis_rready,

   input             aclk, aresetn
   );

   /*
    ADDR 0: Write/Read
    ADDR 1: Pending RX
    */

   reg               q_write_stream, n_write_stream;
   
   always_comb begin
      n_write_stream = 1'b0;
      m_axis_wdata = s_axis_wdata;
      m_axis_wvalid = 0;
      s_axi_wready = 0;
      if(w_state == ADDR && s_axi_awvalid) begin
         case(s_axi_awaddr)
           32'h0: begin
              n_write_stream = 1'b1;
              s_axi_awready = 1'b1;
           end
           default: begin
              s_axi_awready = 1'b0;
           end
         endcase // case (s_axi_awaddr)
      end // if (w_state == ADDR && s_axi_awvalid)
      else if(w_state == DATA && q_write_stream) begin
         m_axis_wvalid = s_axi_wvalid;
         s_axi_wready = m_axis_wready;
      end
      
   end // always_comb
   

   always @(posedge aclk) begin
      if(~aresetn) begin
         q_write_stream <= 0;
      end
      else
        if((s_axi_awvalid & s_axi_awready) | (s_axi_wvalid & s_axi_wready))
          q_write_stream <= n_write_stream;
   end

   
endmodule
