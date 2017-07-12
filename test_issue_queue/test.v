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

	initial begin

    $dumpfile("dump.vcd");
    $dumpvars(0, test);

		clk <= 0;
    flush <= 0;

    pop0 <= 1;
    pop_key0 <= 0;

    pop1 <= 0;
    pop_key1 <= 1;

    push0 <= 1;
    push_data0 <= 1;

    push1 <= 1;
    push_data1 <= 2;

    for(i=0; i<16; i=i+1) begin

      #5
      clk = ~clk;
      
      if (i % 2 == 0) begin
        push_data0 <= push_data0 + 2;
        push_data1 <= push_data1 + 2;
      end

    end

    #5 
    push0 <= 0;
    push1 <= 0;

    pop_key0 <= 2;
    pop_key1 <= 3;
    pop0 <= 1;
    pop1 <= 1;

    for(i=0; i<8; i=i+1) begin

      #5
      clk = ~clk;
      
      pop_key0 <= pop_key0;

    end

	end

  issue_queue q (
		  .clk(clk),
		  .flush(flush),
      .free(),

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

      
endmodule

