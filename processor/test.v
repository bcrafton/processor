`timescale 1ns / 1ps

`include "defines.vh"

module test;

	// Inputs
	reg clk;
  reg complete;
  reg reset;

	processor p (
		.clk(clk),
		.reset(reset)
	);

  reg init_bit;
  reg dump_bit;

  reg [100 * 8 - 1 : 0] test_name;
  reg [100 * 8 - 1 : 0] program_dir;
  reg [100 * 8 - 1 : 0] out_dir;
  integer run_time;

	initial begin

    if (! $value$plusargs("test_name=%s", test_name)) begin
      $display("ERROR: please specify +test_name=<value> to start.");
      $finish;
    end

    if (! $value$plusargs("run_time=%d", run_time)) begin
      $display("ERROR: please specify +run_time=<value> to start.");
      $finish;
    end

    if (! $value$plusargs("program_dir=%s", program_dir)) begin
      $display("ERROR: please specify +program_dir=<value> to start.");
      $finish;
    end

    if (! $value$plusargs("out_dir=%s", out_dir)) begin
      $display("ERROR: please specify +out_dir=<value> to start.");
      $finish;
    end

    $display("%s %d\n", test_name, run_time);

    $dumpfile("test.vcd");
    $dumpvars(0,test);

    init_bit <= $init(test_name, program_dir, out_dir);

		clk <= 0;
	end

  always #5 clk <= ~clk;

  always @(posedge clk) begin

    //{reset, complete} <= $update($time);
    if($time > run_time) begin
      dump_bit <= $dump($time);
      $finish;
    end

  end
      
endmodule

