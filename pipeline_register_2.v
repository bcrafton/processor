`timescale 1ns / 1ps

module id_ex_register(
	  	clk,
		flush,
		
		rs_in,
		rt_in,
		rd_in,
		reg_read_data_1_in,
		reg_read_data_2_in,
		immediate_in,
		address_in,
		reg_dst_in,
		mem_to_reg_in,
		alu_op_in,
		mem_op_in,
		alu_src_in,
		reg_write_in,
		beq_in,
		bne_in,
		
		rs_out,
		rt_out,
		rd_out,
		reg_read_data_1_out,
		reg_read_data_2_out,
		immediate_out,
		address_out,
		reg_dst_out,
		mem_to_reg_out,
		alu_op_out,
		mem_op_out,
		alu_src_out,
		reg_write_out,
		beq_out,
		bne_out
    );
	 
		input wire clk;
		input wire flush;
		
		
		input wire [2:0] rs_in;
		input wire [2:0] rt_in;
		input wire [2:0] rd_in;
		input wire [15:0] reg_read_data_1_in;
		input wire [15:0] reg_read_data_2_in;
		input wire [15:0] immediate_in;
		input wire [15:0] address_in;
		input wire reg_dst_in;
	   input wire mem_to_reg_in;
	   input wire [3:0] alu_op_in;
	   input wire [1:0] mem_op_in;
	   input wire alu_src_in;
	   input wire reg_write_in;
	   input wire beq_in;
	   input wire bne_in;
		
		output reg [2:0] rs_out;
		output reg [2:0] rt_out;
		output reg [2:0] rd_out;
		output reg [15:0] reg_read_data_1_out;
		output reg [15:0] reg_read_data_2_out;
		output reg [15:0] immediate_out;
		output reg [15:0] address_out;
		output reg reg_dst_out;
	   output reg mem_to_reg_out;
	   output reg [3:0] alu_op_out;
	   output reg [1:0] mem_op_out;
	   output reg alu_src_out;
	   output reg reg_write_out;
	   output reg beq_out;
	   output reg bne_out;

		initial begin
			reg_read_data_1_out <= 0;
			reg_read_data_2_out <= 0;
			immediate_out <= 0;
			address_out <= 0;
			reg_dst_out <= 0;
			mem_to_reg_out <= 0;
			alu_op_out <= 0;
			mem_op_out <= 0;
			alu_src_out <= 0;
			reg_write_out <= 0;
			beq_out <= 0;
			bne_out <= 0;
		end

		always @(negedge clk) begin
			if(flush) begin
				rs_out <= 0;
				rt_out <= 0;
				rd_out <= 0;
				reg_read_data_1_out <= 0;
				reg_read_data_2_out <= 0;
				immediate_out <= 0;
				address_out <= 0;
				reg_dst_out <= 0;
				mem_to_reg_out <= 0;
				alu_op_out <= 0;
				mem_op_out <= 0;
				alu_src_out <= 0;
				reg_write_out <= 0;
				beq_out <= 0;
				bne_out <= 0;
			end
			else begin	
				rs_out <= rs_in;
				rt_out <= rt_in;
				rd_out <= rd_in;
				reg_read_data_1_out <= reg_read_data_1_in;
				reg_read_data_2_out <= reg_read_data_2_in;
				immediate_out <= immediate_in;
				address_out <= address_in;
				reg_dst_out <= reg_dst_in;
				mem_to_reg_out <= mem_to_reg_in;
				alu_op_out <= alu_op_in;
				mem_op_out <= mem_op_in;
				alu_src_out <= alu_src_in;
				reg_write_out <= reg_write_in;
				beq_out <= beq_in;
				bne_out <= bne_in;
			end
		end
endmodule
