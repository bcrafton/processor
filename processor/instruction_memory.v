`timescale 1ns / 1ps

module instruction_memory(
  clk,
  pc,
  program,
  instruction
  );

  input wire clk;
  input wire [`ADDR_WIDTH-1:0] pc; // this should be log2 of imemory size, but should also be width of register since it is pc. but pc dosnt have to be same size as register
// and instruction does not need to be same size as register.
  input wire [`NUM_TESTS_LOG2-1:0] program;

  output wire [`INST_WIDTH-1:0] instruction;
  reg [`INST_WIDTH-1:0] memory [0:`IMEMORY_SIZE-1];

  always @(program) begin
    case (program)
      0: $readmemh("../assembler/prog.hex", memory);
      1: $readmemh("../assembler/prog.hex", memory);
      2: $readmemh("../assembler/prog.hex", memory);
      3: $readmemh("../assembler/prog.hex", memory);
    endcase
  end

  assign instruction = memory[pc];

endmodule
