`timescale 1ns / 1ps

`include "defines.vh"

module test;

	// Inputs
	reg clk;
  reg flush;

  reg pop0;
  reg [`NUM_IQ_ENTRIES_LOG2-1:0] pop_key0;

  reg pop1;
  reg [`NUM_IQ_ENTRIES_LOG2-1:0] pop_key1; 

  reg push0;
  reg [`IQ_ENTRY_SIZE-1:0] push_data0;

  reg push1;
  reg [`IQ_ENTRY_SIZE-1:0] push_data1;

  integer i;

	issue_queue q (
		.clk(clk),
		.flush(flush),
    .free(free),
    .count(count),

    .pop0(pop0),
    .pop_key0(pop_key0),

    .pop1(pop1),
    .pop_key1(pop_key1),

    .push0(push0),
    .push_data0(push_data0),

    .push1(push1),
    .push_data1(push_data1),

    .data0(),
    .data1(),
    .data2(),
    .data3(),
    .data4(),
    .data5(),
    .data6(),
    .data7()

	);

	initial begin

    $dumpfile("test.vcd");
    $dumpvars(0,test);

		clk <= 0;
    flush <= 0;

    pop0 <= 0;
    pop_key0 <= 0;

    pop1 <= 0;
    pop_key1 <= 0;

    push0 <= 1;
    push_data0 <= 15;

    push1 <= 0;
    push_data1 <= 255;

    for(i=0; i<16; i=i+1) begin

      #5
      push1 <= 1;
      clk = ~clk;
      
      push_data0 <= push_data0;

    end

    #5 
    push0 <= 0;
    pop0 <= 1;

    for(i=0; i<8; i=i+1) begin

      #5
      clk = ~clk;
      
      pop_key0 <= pop_key0 + 1;

    end

	end
      
endmodule

