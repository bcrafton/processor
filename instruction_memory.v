`timescale 1ns / 1ps

module instruction_memory(
  clk,
  pc,
  instruction
  );

  input wire clk;
  input wire [15:0] pc;
  output wire [15:0] instruction;
  reg [15:0] memory [0:127];

  initial $readmemh("code.hex", memory);

  assign instruction = memory[pc];

endmodule
