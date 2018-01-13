`timescale 1ns / 1ps

`include "defines.vh"

module instruction_memory(
  clk,
  reset,
  pc,
  instruction0,
  instruction1
  );

  input wire clk;
  input wire reset;
  input wire [`ADDR_WIDTH-1:0] pc; 


  output wire [`INST_WIDTH-1:0] instruction0;
  output wire [`INST_WIDTH-1:0] instruction1;

  integer i;
  reg [`INST_WIDTH-1:0] imem [0:`IMEMORY_SIZE-1];
  
   initial begin
      $readmemh("/home/brian/Desktop/processor/test_bench/programs/code/bin/to_10.bc.s.hex", imem);
	end
  
  
	blk_mem_gen_v7_3 BRAM1 (
      .clka        (clk), 
      .wea         (1'b0),
      .addra       (),
      .dina        (),
      .clkb        (clk),
      .addrb       (pc),
		.doutb       ()
	);

	assign instruction0 = imem[pc];
	assign instruction1 = imem[pc+1];


endmodule
