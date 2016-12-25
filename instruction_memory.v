`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:24:42 07/28/2015 
// Design Name: 
// Module Name:    instruction_memory 
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
module instruction_memory(
    clk,
	 pc,
    instruction
    );
	 
	 input wire clk;
	 input wire [15:0] pc;
    output wire [15:0] instruction;
	 reg [15:0] memory [0:127];
	 
	 initial $readmemh("code.hex", memory);
	 
	 // i guess whenever pc changes this also changes?
	 // i guess basically works as a mux.
	 assign instruction = memory[pc];
endmodule
