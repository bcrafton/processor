`timescale 1ns / 1ps

`include "defines.vh"

`define RUNTIME 1000

module test;

	// Inputs
	reg clk;
  reg complete;
  reg reset;
  reg [`NUM_TESTS_LOG2-1:0] program;

  integer start_time = 0;

	processor p (
		.clk(clk),
		.complete(complete),
    .program(program)
	);

	initial begin

    $dumpfile("test.vcd");
    $dumpvars(0,test);

		clk <= 0;
    complete <= 0;
    reset <= 0;
    program <= 0;
    start_time = $time; 
    
	end

  always #5 clk <= ~clk;

  always @(posedge clk) begin

    if($time - start_time > `RUNTIME) begin
      // if the file we dump is all 0s, its because we wrote after reset.
      complete <= 0;
      reset <= 1;
      start_time = $time;
      program <= program + 1;

      if(program == `NUM_TESTS) begin
        $finish;
      end
    end

    else if($time - start_time > `RUNTIME-10) begin
      complete <= 1;
      reset <= 0;
    end

    else begin
      complete <= 0;
      reset <= 0;
    end

  end
      
endmodule

