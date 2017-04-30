`timescale 1ns / 1ps

module instruction_memory(
  clk,
  pc,
  instruction
  );

  input wire clk;
  input wire [`ADDR_WIDTH-1:0] pc; // this should be log2 of imemory size, but should also be width of register since it is pc. but pc dosnt have to be same size as register
// and instruction does not need to be same size as register.
  output wire [`INST_WIDTH-1:0] instruction;
  reg [`INST_WIDTH-1:0] memory [0:`IMEMORY_SIZE-1];

  initial $readmemh("programs/code_jump_test2.hex", memory);

  assign instruction = memory[pc];

endmodule
