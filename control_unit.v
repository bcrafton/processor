`timescale 1ns / 1ps

module control_unit(
	 clk,
	 stall,
    opcode,
	 reg_dst,
	 jump,
	 mem_to_reg,
	 alu_op,
	 alu_src,
	 reg_write,
	 mem_op,
	 beq,
	 bne
    );
	 
	 input wire clk;
	 input wire stall;
	 input wire [3:0] opcode;
	 output reg reg_dst;
	 output reg jump;
	 output reg [1:0] mem_op;
	 output reg mem_to_reg;
	 output reg [3:0] alu_op;
	 output reg alu_src;
	 output reg reg_write;
	 output reg beq;
	 output reg bne;
	 
	 // this is fine because we are just setting flags, 
	 // and only want to change it if opcode changes.
	 always @(opcode) begin
		 case(opcode)
			 0: begin
				 reg_dst <= 1;
				 mem_op <= 2'b00;
				 alu_src <= 0;
				 jump <= 0;
				 mem_to_reg <= 0;
				 reg_write <= 1;
				 alu_op <= 4'b0000;
				 beq <= 1'b0;
				 bne <= 1'b0;
			 end
			 1: begin
				 reg_dst <= 0;
				 mem_op <= 2'b00;
				 alu_src <= 1; // want to load immediate not read_data_2
				 jump <= 0;
				 mem_to_reg <= 0;
				 reg_write <= 1;
				 alu_op <= 4'b0000;
				 beq <= 1'b0;
				 bne <= 1'b0;
			 end
			 2: begin
				 reg_dst <= 1; // want to write to third register
				 mem_op <= 2'b00;
				 alu_src <= 0;
				 jump <= 0;
				 mem_to_reg <= 0;
				 reg_write <= 1;
				 alu_op <= 4'b0001;
				 beq <= 1'b0;
				 bne <= 1'b0;
			 end
			 3: begin
				 reg_dst <= 0;
				 mem_op <= 2'b00;
				 alu_src <= 1; // want to load immediate not read_data_2
				 jump <= 0;
				 mem_to_reg <= 0;
				 reg_write <= 1;
				 alu_op <= 4'b0001;
				 beq <= 1'b0;
				 bne <= 1'b0;
			 end
			 4: begin
				 reg_dst <= 1; // want to write to third register
				 mem_op <= 2'b00;
				 alu_src <= 0;
				 jump <= 0;
				 mem_to_reg <= 0;
				 reg_write <= 1;
				 alu_op <= 4'b0010;
				 beq <= 1'b0;
				 bne <= 1'b0;
			 end
			 5: begin
				 reg_dst <= 1; // want to write to third register
				 mem_op <= 2'b00;
				 alu_src <= 0;
				 jump <= 0;
				 mem_to_reg <= 0;
				 reg_write <= 1;
				 alu_op <= 4'b0011;
				 beq <= 1'b0;
				 bne <= 1'b0;
			 end
			 6: begin
				 reg_dst <= 1; // want to write to third register
				 mem_op <= 2'b00;
				 alu_src <= 0;
				 jump <= 0;
				 mem_to_reg <= 0;
				 reg_write <= 1;
				 alu_op <= 4'b0100;
				 beq <= 1'b0;
				 bne <= 1'b0;
			 end
			 7: begin
				 reg_dst <= 1; // want to write to third register
				 mem_op <= 2'b00;
				 alu_src <= 0;
				 jump <= 0;
				 mem_to_reg <= 0;
				 reg_write <= 1;
				 alu_op <= 4'b0101;
				 beq <= 1'b0;
				 bne <= 1'b0;
			 end
			 8: begin
				 reg_dst <= 1; // want to write to third register
				 mem_op <= 2'b00;
				 alu_src <= 0;
				 jump <= 0;
				 mem_to_reg <= 0;
				 reg_write <= 1;
				 alu_op <= 4'b0110;
				 beq <= 1'b0;
				 bne <= 1'b0;
			 end
			 9: begin
				 reg_dst <= 0; // want to write to third register
				 mem_op <= 2'b00;
				 alu_src <= 0;
				 jump <= 0;
				 mem_to_reg <= 0;
				 reg_write <= 1;
				 alu_op <= 4'b0111;
				 beq <= 1'b0;
				 bne <= 1'b0;
			 end
			 10: begin
				 reg_dst <= 0; // want to write to third register
				 mem_op <= 2'b00;
				 alu_src <= 1;
				 jump <= 0;
				 mem_to_reg <= 0;
				 reg_write <= 1;
				 alu_op <= 4'b1000;
				 beq <= 1'b0;
				 bne <= 1'b0;
			 end
			 11: begin
				 reg_dst <= 0; // want to write to third register
				 mem_op <= 2'b01;
				 jump <= 0;
				 mem_to_reg <= 1;
				 reg_write <= 1;
				 beq <= 1'b0;
				 bne <= 1'b0;
			 end
			 12: begin
				 reg_dst <= 0;
				 mem_op <= 2'b10;
				 alu_src <= 0;
				 jump <= 0;
				 mem_to_reg <= 0;
				 reg_write <= 0;
				 alu_op <= 4'b0000;
				 beq <= 1'b0;
				 bne <= 1'b0;
			 end
			 13: begin
				 mem_op <= 2'b00;
				 alu_src <= 0;
				 jump <= 0;
				 reg_write <= 0;
				 beq <= 1'b1;
				 bne <= 1'b0;
			 end
			 14: begin
				 mem_op <= 2'b00;
				 alu_src <= 0;
				 jump <= 0;
				 reg_write <= 0;
				 beq <= 1'b0;
				 bne <= 1'b1;
			 end
			 15: begin
				 mem_op <= 2'b00;
				 jump <= 1;
				 reg_write <= 0;
				 beq <= 1'b0;
				 bne <= 1'b0;
			 end
		 endcase
	 end
endmodule
