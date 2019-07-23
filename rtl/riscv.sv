module riscv
  (
   /* Instruction Bus */
   output reg        iBus_cmd_valid,
   input wire        iBus_cmd_ready,
   output reg [31:0] iBus_cmd_payload_pc,
   input wire        iBus_rsp_ready,
   input wire        iBus_rsp_err,
   input wire [31:0] iBus_rsp_inst,
   /* Data Bus */
   output reg        dBus_cmd_valid,
   input wire        dBus_cmd_ready,
   output reg [31:0] dBus_cmd_payload_address,
   output reg [31:0] dBus_cmd_payload_data,
   output reg [1:0]  dBus_cmd_payload_size,

   
   
   input wire        clk, rstf);

   
   
endmodule // riscv
