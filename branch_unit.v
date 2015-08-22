`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:27:00 08/12/2015 
// Design Name: 
// Module Name:    branch_unit 
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
module branch_unit(
		beq,
		bne,
		compare,
		flush
    );
	 
	 input wire beq;
	 input wire bne;
	 input wire compare;
	 output reg flush;

	 always@(*) begin
		 if((beq && compare) || (bne && !compare)) begin
			flush <= 1;
		 end
		 else begin
			flush <= 0;
		 end
	 end

endmodule
