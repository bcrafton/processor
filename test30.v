`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   12:41:20 08/30/2015
// Design Name:   cpu
// Module Name:   C:/Users/Brian/Documents/GitHub/cpu_attempt_2/test30.v
// Project Name:  cpu_attempt_2
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: cpu
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module test30;

	// Inputs
	reg clk;

	// Outputs
	wire [15:0] pc;
	wire [15:0] instruction;
	wire [3:0] opcode;
	wire [2:0] rs;
	wire [2:0] rt;
	wire [2:0] rd;
	wire [15:0] id_ex_reg_read_data_1;
	wire [15:0] id_ex_reg_read_data_2;
	wire [15:0] ex_mem_data_1;
	wire [15:0] ex_mem_data_2;
	wire [15:0] ex_mem_alu_result;
	wire [15:0] mem_to_reg_result;
	wire [1:0] forward_a;
	wire [1:0] forward_b;
	wire flush;
	wire ex_mem_beq;
	wire ex_mem_bne;
	wire ex_mem_compare;
	wire jump;
	wire address_src;
	wire [15:0] address_src_result;

	// Instantiate the Unit Under Test (UUT)
	cpu uut (
		.clk(clk), 
		.pc(pc), 
		.instruction(instruction), 
		.opcode(opcode), 
		.rs(rs), 
		.rt(rt), 
		.rd(rd), 
		.id_ex_reg_read_data_1(id_ex_reg_read_data_1), 
		.id_ex_reg_read_data_2(id_ex_reg_read_data_2), 
		.ex_mem_data_1(ex_mem_data_1), 
		.ex_mem_data_2(ex_mem_data_2), 
		.ex_mem_alu_result(ex_mem_alu_result), 
		.mem_to_reg_result(mem_to_reg_result), 
		.forward_a(forward_a), 
		.forward_b(forward_b), 
		.flush(flush), 
		.ex_mem_beq(ex_mem_beq), 
		.ex_mem_bne(ex_mem_bne), 
		.ex_mem_compare(ex_mem_compare), 
		.jump(jump), 
		.address_src(address_src), 
		.address_src_result(address_src_result)
	);

	initial begin
		clk = 0;
	end

    always #5 clk = ~clk;

    always @(posedge clk) begin

        if($time > 500) begin
            $finish;
        end
    end
      
endmodule

