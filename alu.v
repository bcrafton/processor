`timescale 1ns / 1ps

module alu(
	 clk,
    alu_op,
	 data1,
	 data2,
	 compare,
	 alu_result
    );
	 
	 input wire clk;
	 input wire [3:0] alu_op;
	 input wire [15:0] data1;
	 input wire [15:0] data2;
	 output reg compare;
	 output reg [15:0] alu_result;
	 
	 always @(posedge clk) begin
		 case(alu_op)
			0: alu_result <= data1 + data2; // ADD
			1: alu_result <= data1 - data2; // SUB
			2: alu_result <= !data1; // NOT
			3: alu_result <= data1 & data2; // AND
			4: alu_result <= data1 | data2; // OR
			5: alu_result <= ~(data1 &data2); // NAND
			6: alu_result <= ~(data1 | data2); // NOR
			7: alu_result <= data1;
			8: alu_result <= data2;
		 endcase
		if (data1 == data2)
			compare <= 1'b1;
		else
			compare <= 1'b0;
	 end
endmodule
