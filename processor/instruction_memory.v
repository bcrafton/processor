`timescale 1ns / 1ps

`include "defines.vh"

module instruction_memory(
  reset,
  pc,
  instruction0,
  instruction1
  );

  input wire reset;
  input wire [`ADDR_WIDTH-1:0] pc; 


  output reg [`INST_WIDTH-1:0] instruction0;
  output reg [`INST_WIDTH-1:0] instruction1;

  integer i;
  reg [`INST_WIDTH-1:0] imem [0:`IMEMORY_SIZE-1];

  always @(*) begin 

    if (reset) begin
      for(i=0; i<`IMEMORY_SIZE; i=i+1) begin
        imem[i] = 32'h40000001;
      end
    end

    instruction0 = imem[pc];
    instruction1 = imem[pc+1];

  end

endmodule
