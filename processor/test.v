`timescale 1ns / 1ps

`include "defines.vh"
`define RUNTIME 1000

module test;

	// Inputs
	reg clk;
  reg complete;

	processor p (
		.clk(clk),
		.complete(complete)
	);

  reg init_bit;

	initial begin

    $dumpfile("test.vcd");
    $dumpvars(0,test);

    init_bit <= $init(`IMEM_ID, $time);

		clk <= 0;
	end

  always #5 clk <= ~clk;

  always @(posedge clk) begin

    if($time > `RUNTIME-10) begin
      complete <= 1;
    end

    if($time > `RUNTIME) begin
      $finish;
    end

  end
      
endmodule

