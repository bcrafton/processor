`timescale 1ns / 1ps

`include "defines.vh"

module test;

	// Inputs
	reg clk;
  reg reset;
  reg complete;

  wire [`INST_WIDTH-1:0] instruction0;
  wire [`INST_WIDTH-1:0] instruction1;
  wire [`ADDR_WIDTH-1:0] pc;
  
  wire [`ADDR_WIDTH-1:0] address;
  wire [`DATA_WIDTH-1:0] write_data;
  wire [`DATA_WIDTH-1:0] read_data;
  wire [`MEM_OP_BITS-1:0] mem_op;

  instruction_memory im(
  .reset(reset),
  .pc(pc), 
  .instruction0(instruction0),
  .instruction1(instruction1)
  );

  ram data_memory(
  .reset(reset),
  .complete(complete),

  .address(address), 
  .write_data(write_data), 
  .read_data(read_data), 
  .mem_op(mem_op)
  );

	processor p (
	.clk(clk),
	.reset(reset),
  .complete(complete),

  .pc(pc), 
  .instruction0(instruction0),
  .instruction1(instruction1),

  .address_out(address),
  .write_data_out(write_data),
  .read_data_in(read_data),
  .mem_op_out(mem_op)
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
    $dumpvars(0, test);

    init_bit <= $init(in_path, out_path);

    reset <= 1;
		clk <= 0;
    complete <= 0;

	end

  always #5 clk <= ~clk;

  always @(posedge clk) begin

    reset <= 0;

    if($time > run_time) begin
      dump_bit <= $dump($time);
      complete <= 1;
      #1 // i dont know why we need this
      $finish;
    end

  end
      
endmodule

