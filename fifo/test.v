
`timescale 1ns / 1ps

module test;

  reg clk;
  reg reset;

  reg push;
  reg [32-1:0] data_in;

  reg pop;
  wire [32-1:0] data_out;

  wire full;
  wire empty;

  integer i;

	fifo f (
		.clk(clk),
		.reset(reset),

    .push(push),
    .data_in(data_in),

    .pop(pop),
    .data_out(data_out),

    .full(full),
    .empty(empty)
    
	);

	initial begin

    $dumpfile("test.vcd");
    $dumpvars(0,test);

		clk = 0;
    reset = 0;

    push = 0;
    data_in = 0;

    pop = 0;
    //data_out = 0;

    //full = 0;
    //empty = 0;

    for(i=0; i<16; i=i+1) begin
      #5
      clk <= !clk;
      push <= 1;
      data_in <= data_in + 1;
    end

    for(i=0; i<16; i=i+1) begin
      #5
      clk <= !clk;
      pop <= 1;
      $display("%x\n", data_out);
    end

	end
      
endmodule

