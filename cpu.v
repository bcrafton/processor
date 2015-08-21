`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:13:52 07/26/2015 
// Design Name: 
// Module Name:    cpu 
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
module cpu(
	 clk,
	 pc,
	 instruction,
	 opcode,
	 rs,
	 rt,
	 rd,
	 id_ex_reg_read_data_1,
	 id_ex_reg_read_data_2,
	 ex_mem_data_1,
	 ex_mem_data_2,
	 ex_mem_alu_result,
	 mem_to_reg_result,
	 stall,
	 ex_mem_mem_op,
	 ram_read_data,
	 forward_a,
	 forward_b
    );
	 
	 input clk;
	 output wire [15:0] pc;
	 
	 output wire [3:0] opcode;
	 output wire [2:0] rs;
	 output wire [2:0] rt;
	 output wire [2:0] rd;
	 wire [15:0] immediate;
	 wire [15:0] address;
	 
	 wire  reg_dst;
	 wire  jump;
	 wire  mem_to_reg;
	 wire  [3:0] alu_op;
	 wire  [1:0] mem_op;
	 wire  alu_src;
	 wire  reg_write;
	 wire  beq;
	 wire  bne;
	 
	 output wire [15:0] instruction;
	 output wire [15:0] ram_read_data;
	 
	 wire [15:0] reg_read_data_1;
	 wire [15:0] reg_read_data_2;
	 
	 wire compare;
	 wire [15:0] alu_result;
	 
	 wire [2:0] reg_dst_result;
	 wire [15:0] alu_src_result;
	 output wire [15:0] mem_to_reg_result;
	 		
	 // if/id
	 wire [15:0] if_id_instruction, if_id_pc;
	 // id/ex
	 wire [2:0] id_ex_rs, id_ex_rt, id_ex_rd;
	 output wire [15:0] id_ex_reg_read_data_1, id_ex_reg_read_data_2;
	 wire [15:0] id_ex_immediate;
	 wire [15:0] id_ex_address;
	 wire id_ex_reg_dst, id_ex_jump, id_ex_mem_to_reg, id_ex_beq, id_ex_bne, id_ex_alu_src, id_ex_reg_write;
	 wire [3:0] id_ex_alu_op; 
	 wire [1:0] id_ex_mem_op;
	 // ex/mem
	 output wire [15:0] ex_mem_alu_result;
	 output wire [15:0] ex_mem_data_1, ex_mem_data_2;
	 wire [15:0] ex_mem_address;
	 wire ex_mem_beq, ex_mem_bne, ex_mem_mem_to_reg;
	 output wire [1:0] ex_mem_mem_op;
	 wire [2:0] ex_mem_reg_dst_result;
	 // mem/wb
	 wire [15:0] mem_wb_ram_read_data, mem_wb_alu_result;
	 wire [2:0] mem_wb_reg_dst_result;
	 wire mem_wb_mem_to_reg, mem_wb_reg_write;
		
	 output wire [1:0] forward_a, forward_b;
	 output wire stall;
	 wire	flush;
	 wire [15:0] alu_input_mux_1_result, alu_input_mux_2_result;

	 assign opcode = if_id_instruction[15:12];
	 assign rs = if_id_instruction[11:9];
	 assign rt = if_id_instruction[8:6];
	 assign rd = if_id_instruction[5:3];
	 assign immediate[5:0] = if_id_instruction[5:0];
	 assign address[5:0] = if_id_instruction[5:0];
	 assign immediate[15:6] = 9'b000000000;
	 assign address[15:6] = 9'b000000000;
	 ///////////////////////////////////////////////////////////////////////////////////////////
	 // address shud be getting passed through ex_mem.
	 program_counter pc_unit(.clk(clk), .address(ex_mem_address), .pc(pc), .flush(flush), .stall(stall));
	 instruction_memory im(.clk(clk), .pc(pc), .instruction(instruction));
	 if_id_register if_id_reg(.clk(clk), .stall(stall), .instruction_in(instruction), .instruction_out(if_id_instruction));
	 ///////////////////////////////////////////////////////////////////////////////////////////
	 hazard_detection_unit hdu(.id_ex_mem_op(id_ex_mem_op), .id_ex_rt(id_ex_rt), .if_id_rs(rs), .if_id_rt(rt), .stall(stall));
	 
	 control_unit cu(.clk(clk), .opcode(opcode), .reg_dst(reg_dst), .jump(jump), .mem_to_reg(mem_to_reg), 
		.alu_op(alu_op), .alu_src(alu_src), .reg_write(reg_write), .mem_op(mem_op), .beq(beq), .bne(bne));
	
	 register_file regfile(.clk(clk), .write(mem_wb_reg_write), .write_address(mem_wb_reg_dst_result), 
		.write_data(mem_to_reg_result), .read_address_1(rs), .read_data_1(reg_read_data_1), 
		.read_address_2(rt), .read_data_2(reg_read_data_2));

	 id_ex_register id_ex_reg(.clk(clk), .flush(flush), .stall(stall), .rs_in(rs), .rt_in(rt), .rd_in(rd), .reg_read_data_1_in(reg_read_data_1),
		 .reg_read_data_2_in(reg_read_data_2), .immediate_in(immediate), .address_in(address), .reg_dst_in(reg_dst), 
		 .mem_to_reg_in(mem_to_reg), .alu_op_in(alu_op), .mem_op_in(mem_op), .alu_src_in(alu_src), .reg_write_in(reg_write), 
		 .beq_in(beq), .bne_in(bne), 
			
		 .rs_out(id_ex_rs), .rt_out(id_ex_rt), .rd_out(id_ex_rd), .reg_read_data_1_out(id_ex_reg_read_data_1),
		 .reg_read_data_2_out(id_ex_reg_read_data_2), .immediate_out(id_ex_immediate), .address_out(id_ex_address),
		 .reg_dst_out(id_ex_reg_dst), .mem_to_reg_out(id_ex_mem_to_reg), .alu_op_out(id_ex_alu_op), .mem_op_out(id_ex_mem_op), 
		 .alu_src_out(id_ex_alu_src), .reg_write_out(id_ex_reg_write), .beq_out(id_ex_beq), .bne_out(id_ex_bne));
	 ///////////////////////////////////////////////////////////////////////////////////////////////
	 forwarding_unit fu(.id_ex_rs(id_ex_rs), .id_ex_rt(id_ex_rt), .ex_mem_rd(ex_mem_reg_dst_result), 
		.mem_wb_rd(mem_wb_reg_dst_result), .ex_mem_reg_write(ex_mem_reg_write), .mem_wb_reg_write(mem_wb_reg_write),
		.forward_a(forward_a), .forward_b(forward_b));

	 mux16_3x2 alu_input_mux_1(.in0(id_ex_reg_read_data_1), .in1(mem_to_reg_result), 
		.in2(ex_mem_alu_result), .sel(forward_a), .out(alu_input_mux_1_result));
	
    mux16_3x2 alu_input_mux_2(.in0(id_ex_reg_read_data_2), .in1(mem_to_reg_result), 
		.in2(ex_mem_alu_result), .sel(forward_b), .out(alu_input_mux_2_result));
	 
	 mux16_2x1 alu_src_mux(.in0(alu_input_mux_2_result), .in1(id_ex_immediate), .sel(id_ex_alu_src), .out(alu_src_result));
	
	 alu alu_unit(.clk(clk), .alu_op(id_ex_alu_op), .data1(alu_input_mux_1_result), .data2(alu_src_result), 
		.compare(compare), .alu_result(alu_result));
	
	 mux3_2x1 reg_dst_mux(.in0(id_ex_rt), .in1(id_ex_rd), .sel(id_ex_reg_dst), .out(reg_dst_result));
	 
	 ex_mem_register ex_mem_reg(.clk(clk), .flush(flush), .alu_result_in(alu_result), .data_1_in(alu_input_mux_1_result),
		.data_2_in(alu_input_mux_2_result), .reg_dst_result_in(reg_dst_result), .beq_in(id_ex_beq), .bne_in(id_ex_bne),
		.mem_op_in(id_ex_mem_op), .mem_to_reg_in(id_ex_mem_to_reg), .reg_write_in(id_ex_reg_write), .compare_in(compare),
		.address_in(id_ex_address),
		
		.alu_result_out(ex_mem_alu_result), .data_1_out(ex_mem_data_1), .data_2_out(ex_mem_data_2),
		.reg_dst_result_out(ex_mem_reg_dst_result), .beq_out(ex_mem_beq), .bne_out(ex_mem_bne), .mem_op_out(ex_mem_mem_op),
		.mem_to_reg_out(ex_mem_mem_to_reg), .reg_write_out(ex_mem_reg_write), .compare_out(ex_mem_compare), .address_out(ex_mem_address));
	 ///////////////////////////////////////////////////////////////////////////////////////////////
    ram data_memory(.clk(clk), .address(ex_mem_data_1), .write_data(ex_mem_data_2), 
		.read_data(ram_read_data), .mem_op(ex_mem_mem_op));
	 
	 branch_unit bu(.beq(ex_mem_beq), .bne(ex_mem_bne), .compare(ex_mem_compare), .flush(flush));
	 
	 mem_wb_register mem_wb_reg(.clk(clk), .mem_to_reg_in(ex_mem_mem_to_reg), .ram_read_data_in(ram_read_data), 
		.alu_result_in(ex_mem_alu_result), .reg_dst_result_in(ex_mem_reg_dst_result), .reg_write_in(ex_mem_reg_write), 
		
		.mem_to_reg_out(mem_wb_mem_to_reg), .ram_read_data_out(mem_wb_ram_read_data), .alu_result_out(mem_wb_alu_result),
		.reg_dst_result_out(mem_wb_reg_dst_result), .reg_write_out(mem_wb_reg_write));
	 
	 ///////////////////////////////////////////////////////////////////////////////////////////////
    mux16_2x1 mem_to_reg_mux(.in0(mem_wb_alu_result), .in1(mem_wb_ram_read_data), .sel(mem_wb_mem_to_reg), 
	 	.out(mem_to_reg_result));
	  
endmodule
