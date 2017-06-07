`timescale 1ns / 1ps

`include "defines.vh"
`define RUNTIME 1000

module test;

	// Inputs
	reg clk;
  reg write;
  
  reg [`ADDR_WIDTH-1:0] write_key;
  reg [`ADDR_WIDTH-1:0] write_val;

  reg  [`ADDR_WIDTH-1:0] read_key;
  wire [`ADDR_WIDTH-1:0] read_val;

  wire read_valid;

	lut l (
		.clk(clk),
		.write(write),

		.write_key(write_key),
		.write_val(write_val),

		.read_key(read_key),
		.read_val(read_val),
		.read_valid(read_valid)
	);

	initial begin
    $dumpfile("test.vcd");
    $dumpvars(0,test);

    clk = 0;
    write = 0;

    write_key = 0;
    write_val = 0;

    read_key = 0;
    //read_val = 0;
    //read_valid = 0;
  
    # 5
    write_key = 16'ha5a5;
    write_val = 16'hdead;
    write = 1;
    # 5
    clk = 1;
    # 5
    clk = 0;
    write = 0;
    read_key = 16'ha5a5;    
    # 5
    clk = 1;
    # 5
    clk = 0;
    write = 1;
    write_val = 16'hafaf;
    # 5
    clk = 1;
    # 0
    clk = 1;
    # 5
    clk = 1;

	end
/*
  always #5 clk <= ~clk;

  always @(posedge clk) begin

    if($time > `RUNTIME) begin
      $finish;
    end


  end
*/    
endmodule










