`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:02:41 08/05/2015 
// Design Name: 
// Module Name:    hazard_detection_unit 
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
module hazard_detection_unit(
		id_ex_mem_op,
		id_ex_rt, // the place we are loading to.
		if_id_rs,
		if_id_rt,
		
		stall
    );
	 
	 input wire [1:0] id_ex_mem_op;
	 input wire [2:0] if_id_rs;
	 input wire [2:0] if_id_rt;
	 input wire [2:0] id_ex_rt;
	 
	 output reg stall;
	 
	 // this is fine because we are just setting a flag
	 // and only want to load changes if there is a difference.
	 // cud probably run it on negedge ... but difference is fine.
	 always@(*) begin
		 if((if_id_rs == id_ex_rt || if_id_rt == id_ex_rt) && (id_ex_mem_op == 2'b01)) begin
				stall <= 1'b1;
		 end
		 else begin
				stall <= 1'b0;
		 end
	end
endmodule
