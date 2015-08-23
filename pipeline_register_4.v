`timescale 1ns / 1ps

module mem_wb_register(
		clk,
		
		mem_to_reg_in,
		ram_read_data_in,
		alu_result_in,
		reg_dst_result_in,
		reg_write_in,
		
		mem_to_reg_out,
		ram_read_data_out,
		alu_result_out,
		reg_dst_result_out,
		reg_write_out
    );
	 
	input wire clk;
	 
	input wire mem_to_reg_in;
	input wire [15:0] ram_read_data_in;
	input wire [15:0] alu_result_in;
	input wire [2:0] reg_dst_result_in;
	input wire reg_write_in;
	
	output reg mem_to_reg_out;
	output reg [15:0] ram_read_data_out;
	output reg [15:0] alu_result_out;
	output reg [2:0] reg_dst_result_out;
	output reg reg_write_out;
	
	initial begin
		mem_to_reg_out <= 0;
		ram_read_data_out <= 0;
		alu_result_out <= 0;
		reg_dst_result_out <= 0;
		reg_write_out <= 0;
	end
	
	always @(posedge clk) begin
		mem_to_reg_out <= mem_to_reg_in;
		ram_read_data_out <= ram_read_data_in;
		alu_result_out <= alu_result_in;
		reg_dst_result_out <= reg_dst_result_in;
		reg_write_out <= reg_write_in;
	end
endmodule
