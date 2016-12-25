`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    03:19:55 08/22/2015 
// Design Name: 
// Module Name:    jump_unit 
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
module jump_unit(
		instruction,
		jump,
		address
    );

	 input wire [15:0] instruction;
	 output reg jump;
	 output reg [15:0] address;
	 
	 always @(*) begin
		if(instruction[15:12] == 4'b1111) begin
			jump <= 1;
			address[5:0] <= instruction[5:0];
			address[15:6] <= 9'b000000000;
		end else begin
			jump <= 0;
			address <= 0;
		end
	end
endmodule
