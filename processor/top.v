`timescale 1ns / 1ps

`include "defines.vh"

`timescale 1ns / 1ps

`include "defines.vh"

module top (
  clk,
  reset,
  complete
  
  );
  
  input wire clk;
  input wire reset;
  input wire complete;

  wire [`INST_WIDTH-1:0] instruction0;
  wire [`INST_WIDTH-1:0] instruction1;
  wire [`ADDR_WIDTH-1:0] pcounter;
  
  wire [`ADDR_WIDTH-1:0] address;
  wire [`DATA_WIDTH-1:0] write_data;
  wire [`DATA_WIDTH-1:0] read_data;
  wire [`MEM_OP_BITS-1:0] mem_op;

/*
	processor p (
	.clk(clk),
   .reset(reset),
   .complete(complete),

   .pc(pcounter)
   //.instruction0(instruction0),
   //.instruction1(instruction1),

   //.address_out(address),
   //.write_data_out(write_data),
   //.read_data_in(read_data),
   //.mem_op_out(mem_op)
 	);
*/
    

  instruction_memory im(
  .reset(reset),
  .pc(pc), 
  .instruction0(instruction0),
  .instruction1(instruction1)
  );

  data_memory dm(
	.reset(reset),
	.complete(complete),

	.address(address),
	.write_data(write_data),
	.read_data(read_data),
	.mem_op(mem_op)
  );
		
endmodule
