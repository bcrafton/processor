`timescale 1ns / 1ps

module instruction_memory(
  reset,
  pc,
  instruction0,
  instruction1,
  );

  input wire reset;
  input wire [`ADDR_WIDTH-1:0] pc; // this should be log2 of imemory size, but should also be width of register since it is pc. but pc dosnt have to be same size as register
// and instruction does not need to be same size as register.

  reg [`INST_WIDTH-1:0] imem [0:`IMEMORY_SIZE-1];

  output reg [`INST_WIDTH-1:0] instruction0;
  output reg [`INST_WIDTH-1:0] instruction1;


  always @(*) begin 

    if (reset) begin
      $readmemh("../test_bench/programs/code/bin/to_10.bc.s.hex", imem);
    end

    // instruction0 = $mem_read(pc, `IMEM_ID);
    // instruction1 = $mem_read(pc+1, `IMEM_ID);

    instruction0 = imem[pc];
    instruction1 = imem[pc+1];

  end

endmodule

// readmemh
