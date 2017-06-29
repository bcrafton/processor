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
  reg [100 * 8 - 1 : 0] in_path;
  reg [100 * 8 - 1 : 0] out_path;
  integer run_time;

	initial begin

    if (! $value$plusargs("run_time=%d", run_time)) begin
      $display("ERROR: please specify +run_time=<value> to start.");
      $finish;
    end

    if (! $value$plusargs("in_path=%s", in_path)) begin
      $display("ERROR: please specify +in_path=<value> to start.");
      $finish;
    end

    if (! $value$plusargs("out_path=%s", out_path)) begin
      $display("ERROR: please specify +out_path=<value> to start.");
      $finish;
    end

    $dumpfile("test.vcd");
    $dumpvars(0,test);

    init_bit <= $init(in_path, out_path);

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

