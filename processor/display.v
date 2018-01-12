`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:24:38 12/28/2017 
// Design Name: 
// Module Name:    display 
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
module display(
		clk,
		reset,
		in,
		seg,
		an
    );

	input wire clk;
	input wire reset;
	input wire [15:0] in;
	output reg [7:0] seg;
	output reg [3:0] an;	
	
	///////////////////////////////////
	
	wire [3:0] val0 = in[3:0];
	wire [3:0] val1 = in[7:4];
	wire [3:0] val2 = in[11:8];
	wire [3:0] val3 = in[15:12];
	
	reg [1:0] count;
	reg [3:0] val;

	always @(*) begin
		case (count)
			0: val = val0;
			1: val = val1;
			2: val = val2;
			3: val = val3;
		endcase
	end
	
	always @(*) begin
		case (count)
			0: an = 4'b0111;
			1: an = 4'b1011;
			2: an = 4'b1101;
			3: an = 4'b1110;
		endcase
	end

	always @(*) begin
		case (val)
			0: seg = 8'b11000000;
			1: seg = 8'b11111001;
			2: seg = 8'b10100100;
			3: seg = 8'b10110000;
			4: seg = 8'b10011001;
			5: seg = 8'b10010010;
			6: seg = 8'b10000010;
			7: seg = 8'b11111000;
			8: seg = 8'b10000000;
			9: seg = 8'b10010000;
			// not doing these right now.
			10: seg = 8'b11000000;
			11: seg = 8'b11000000;
			12: seg = 8'b11000000;
			13: seg = 8'b11000000;
			14: seg = 8'b11000000;
			15: seg = 8'b11000000;
		endcase
	end
	
	always @(posedge clk) begin
		if (reset) begin
			count <= 0;
		end else begin
			count <= count + 1;
		end
	end
	
endmodule





