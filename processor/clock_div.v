`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:24:53 12/28/2017 
// Design Name: 
// Module Name:    clock_div 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module clock_div24(
	 clk,
	 reset,
	 clk_div
    );

	parameter DIV_SIZE = 1 << 24;
	parameter HALF_DIV = 1 << 23;

	input wire clk;
	input wire reset;
	output reg clk_div;
	
	reg [23:0] count;
	
	always @(*) begin
		if (count < HALF_DIV) begin
			clk_div <= 0;
		end else begin
			clk_div <= 1;
		end
	end
	
	always @(posedge clk) begin
		if (reset) begin
			count <= 0;
		end else begin
			count <= count + 1;
		end
	end

endmodule

module clock_div20(
	 clk,
	 reset,
	 clk_div
    );

	parameter DIV_SIZE = 1 << 20;
	parameter HALF_DIV = 1 << 19;

	input wire clk;
	input wire reset;
	output reg clk_div;
	
	reg [19:0] count;
	
	always @(*) begin
		if (count < HALF_DIV) begin
			clk_div <= 0;
		end else begin
			clk_div <= 1;
		end
	end
	
	always @(posedge clk) begin
		if (reset) begin
			count <= 0;
		end else begin
			count <= count + 1;
		end
	end

endmodule
