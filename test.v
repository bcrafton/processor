`timescale 1ns / 1ps

module test;

	// Inputs
	reg clk;
  reg complete;

	processor p (
		.clk(clk),
		.complete(complete)
	);

	initial begin

    $dumpfile("test.vcd");
    $dumpvars(0,test);

		clk <= 0;
	end

  always #5 clk <= ~clk;

  always @(posedge clk) begin

    if($time > 490) begin
      complete <= 1;
    end

    if($time > 500) begin
      $finish;
    end

  end
      
endmodule

