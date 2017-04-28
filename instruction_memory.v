`timescale 1ns / 1ps

module instruction_memory(
  clk,
  pc,
  instruction
  );

  input wire clk;
  input wire [`INST_WIDTH-1:0] pc;
  output wire [`INST_WIDTH-1:0] instruction;
  reg [`INST_WIDTH-1:0] memory [0:`IMEMORY_SIZE-1];

  initial $readmemh("code.hex", memory);

  assign instruction = memory[pc];

endmodule
