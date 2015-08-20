`timescale 1ns / 1ps

module program_counter(
		clk,
		address,
		pc,
		stall,
		flush
    );
	 
	 input wire clk;
	 input wire [15:0] address;
	 output reg [15:0] pc;
	 input wire flush;
	 input wire stall;

	 initial begin
		pc = 0;
	 end

	 always @(posedge clk) begin
		if(!stall) begin
			if(flush) begin
				pc <= address;
			end
			else begin
				pc <= pc + 1'b1;
			end
		end
	 end
endmodule
