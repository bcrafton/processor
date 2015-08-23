`timescale 1ns / 1ps

module if_id_register(
			clk,
			stall,
			
			instruction_in, 
			instruction_out
    );
	 
	 input wire clk;
	 input wire stall;
	 
	 input wire [15:0] instruction_in;
	 output reg [15:0] instruction_out;
	 
	 initial begin
		instruction_out <= 0;
	 end
	 
	 always @(*) begin
		if(!stall) begin
			instruction_out <= instruction_in;
		end
	end
endmodule