`timescale 1ns / 1ps

`include "defines.vh"

module processor(
  clk,
  complete,
  // regfile
  // mem
  );
	 
  input clk;
  input complete;
  // could make the ram and the regfile outputs. wud be very convenient for testing.
  // problem becomes if ram is large, we wud need a bus we can access it or some shit.

  wire [`ADDR_WIDTH-1:0] pc;

  wire [`OP_CODE_BITS-1:0] opcode;
  wire [`NUM_REGISTERS_LOG2-1:0] rs;
  wire [`NUM_REGISTERS_LOG2-1:0] rt;
  wire [`NUM_REGISTERS_LOG2-1:0] rd;
  wire [`IMM_WIDTH-1:0] immediate;
  wire [`ADDR_WIDTH-1:0] address;
  wire [`SHAMT_BITS-1:0] shamt;

  wire reg_dst;
  wire jump;
  wire mem_to_reg;
  wire [`ALU_OP_BITS-1:0] alu_op;
  wire [`MEM_OP_BITS-1:0] mem_op;
  wire alu_src;
  wire reg_write;
  wire beq;
  wire bne;

  wire zero;
  wire less;
  wire greater;

  wire [`INST_WIDTH-1:0] instruction;
  wire [`DATA_WIDTH-1:0] ram_read_data;

  wire [`DATA_WIDTH-1:0] reg_read_data_1;
  wire [`DATA_WIDTH-1:0] reg_read_data_2;

  wire compare;
  wire [`DATA_WIDTH-1:0] alu_result;

  wire [`NUM_REGISTERS_LOG2-1:0] reg_dst_result;
  wire [`DATA_WIDTH-1:0] alu_src_result;
  wire [`DATA_WIDTH-1:0] mem_to_reg_result;

  wire address_src;
  wire [`ADDR_WIDTH-1:0] address_src_result;

  // if/id
  wire [`INST_WIDTH-1:0] if_id_instruction;
  wire [`ADDR_WIDTH-1:0] if_id_pc;

  // id/ex
  wire [`NUM_REGISTERS_LOG2-1:0] id_ex_rs, id_ex_rt, id_ex_rd;
  wire [`DATA_WIDTH-1:0] id_ex_reg_read_data_1, id_ex_reg_read_data_2;
  wire [`IMM_WIDTH-1:0] id_ex_immediate;
  wire [`ADDR_WIDTH-1:0] id_ex_address;
  wire [`SHAMT_BITS-1:0] id_ex_shamt;
  wire id_ex_reg_dst, id_ex_mem_to_reg, id_ex_beq, id_ex_bne, id_ex_alu_src, id_ex_reg_write, id_ex_address_src;
  wire [`ALU_OP_BITS-1:0] id_ex_alu_op;
  wire [`MEM_OP_BITS-1:0] id_ex_mem_op;
  // ex/mem
  wire [`DATA_WIDTH-1:0] ex_mem_alu_result;
  wire [`DATA_WIDTH-1:0] ex_mem_data_1, ex_mem_data_2;
  wire [`ADDR_WIDTH-1:0] ex_mem_address;
  wire ex_mem_mem_to_reg, ex_mem_address_src;
  wire ex_mem_beq, ex_mem_bne, ex_mem_compare;
  wire [`MEM_OP_BITS-1:0] ex_mem_mem_op;
  wire [`NUM_REGISTERS_LOG2-1:0] ex_mem_reg_dst_result;
  // mem/wb
  wire [`DATA_WIDTH-1:0] mem_wb_ram_read_data, mem_wb_alu_result;
  wire [`NUM_REGISTERS_LOG2-1:0] mem_wb_reg_dst_result;
  wire mem_wb_mem_to_reg, mem_wb_reg_write;

  wire [`FORWARD_BITS-1:0] forward_a, forward_b;
  wire stall;
  wire flush;
  wire [`DATA_WIDTH-1:0] alu_input_mux_1_result, alu_input_mux_2_result;

  assign opcode = if_id_instruction[`OPCODE_MSB:`OPCODE_LSB];
  assign rs = if_id_instruction[`REG_RS_MSB:`REG_RS_LSB];
  assign rt = if_id_instruction[`REG_RT_MSB:`REG_RT_LSB];
  assign rd = if_id_instruction[`REG_RD_MSB:`REG_RD_LSB];
  assign immediate = if_id_instruction[`IMM_MSB:`IMM_LSB];
  assign address = if_id_instruction[`IMM_MSB:`IMM_LSB];
  assign shamt = if_id_instruction[`SHAMT_MSB:`SHAMT_LSB];

  ///////////////////////////////////////////////////////////////////////////////////////////

  program_counter pc_unit(
  .clk(clk), 
  .if_id_opcode(opcode),
  .if_id_address(address),
  .branch_address(ex_mem_address), 
  .pc(pc), 
  .flush(flush), 
  .stall(stall));
  
  instruction_memory im(
  .clk(clk), 
  .pc(pc), 
  .instruction(instruction));

  if_id_register if_id_reg(
  .clk(clk), 
  .stall(stall), 
  .instruction_in(instruction), 
  .instruction_out(if_id_instruction));

  ///////////////////////////////////////////////////////////////////////////////////////////
  
  hazard_detection_unit hdu(
  .id_ex_mem_op(id_ex_mem_op), 
  .id_ex_rt(id_ex_rt), 
  .if_id_rs(rs), 
  .if_id_rt(rt), 
  .stall(stall));

  control_unit cu(
  .clk(clk), 
  .opcode(opcode), 
  .reg_dst(reg_dst), 
  .mem_to_reg(mem_to_reg), 
  .alu_op(alu_op), 
  .alu_src(alu_src), 
  .reg_write(reg_write), 
  .mem_op(mem_op), 
  .beq(beq), 
  .bne(bne), 
  .address_src(address_src));

  register_file regfile(
  .clk(clk), 
  .complete(complete), 
  .write(mem_wb_reg_write), 
  .write_address(mem_wb_reg_dst_result), 
  .write_data(mem_to_reg_result), 
  .read_address_1(rs), 
  .read_data_1(reg_read_data_1), 
  .read_address_2(rt), 
  .read_data_2(reg_read_data_2));

  id_ex_register id_ex_reg(
  .clk(clk), 
  .flush(flush), 
  .stall(stall), 
  .rs_in(rs), 
  .rt_in(rt), 
  .rd_in(rd), 
  .reg_read_data_1_in(reg_read_data_1),
  .reg_read_data_2_in(reg_read_data_2), 
  .immediate_in(immediate), 
  .address_in(address), 
  .shamt_in(shamt),
  .reg_dst_in(reg_dst), 
  .mem_to_reg_in(mem_to_reg), 
  .alu_op_in(alu_op), 
  .mem_op_in(mem_op), 
  .alu_src_in(alu_src), 
  .reg_write_in(reg_write), 
  .beq_in(beq), 
  .bne_in(bne), 
  .address_src_in(address_src),

  .rs_out(id_ex_rs), 
  .rt_out(id_ex_rt), 
  .rd_out(id_ex_rd), 
  .reg_read_data_1_out(id_ex_reg_read_data_1),
  .reg_read_data_2_out(id_ex_reg_read_data_2), 
  .immediate_out(id_ex_immediate), 
  .address_out(id_ex_address),
  .shamt_out(id_ex_shamt),
  .reg_dst_out(id_ex_reg_dst), 
  .mem_to_reg_out(id_ex_mem_to_reg), 
  .alu_op_out(id_ex_alu_op), 
  .mem_op_out(id_ex_mem_op), 
  .alu_src_out(id_ex_alu_src), 
  .reg_write_out(id_ex_reg_write), 
  .beq_out(id_ex_beq), 
  .bne_out(id_ex_bne),
  .address_src_out(id_ex_address_src));

  ///////////////////////////////////////////////////////////////////////////////////////////////

  forwarding_unit fu(
  .id_ex_rs(id_ex_rs), 
  .id_ex_rt(id_ex_rt), 
  .ex_mem_rd(ex_mem_reg_dst_result), 
  .mem_wb_rd(mem_wb_reg_dst_result), 
  .ex_mem_reg_write(ex_mem_reg_write), 
  .mem_wb_reg_write(mem_wb_reg_write),
  .forward_a(forward_a), 
  .forward_b(forward_b));

// this takes 2 forwards and the normal 1, not 3 forwards.
  mux4x2 #(`DATA_WIDTH) alu_input_mux_1(
  .in0(id_ex_reg_read_data_1), 
  .in1(mem_to_reg_result), // so is this out of mem/wb pipeline reg, the power point slides says mem/wb register
  .in2(ex_mem_alu_result), 
  .in3(),
  .sel(forward_a), 
  .out(alu_input_mux_1_result));

// this takes 2 forwards and the normal 1, not 3 forwards.
  mux4x2 #(`DATA_WIDTH) alu_input_mux_2(
  .in0(id_ex_reg_read_data_2), 
  .in1(mem_to_reg_result), 
  .in2(ex_mem_alu_result), 
  .in3(),
  .sel(forward_b), 
  .out(alu_input_mux_2_result));

  mux2x1 #(`DATA_WIDTH) alu_src_mux(
  .in0(alu_input_mux_2_result), 
  .in1({16'h0000, id_ex_immediate}), 
  .sel(id_ex_alu_src), 
  .out(alu_src_result));

  alu alu_unit(
  .clk(clk), 
  .alu_op(id_ex_alu_op), 
  .data1(alu_input_mux_1_result), 
  .data2(alu_src_result), 
  .compare(compare), 
  .zero(zero),
  .less(less),
  .greater(greater),
  .alu_result(alu_result));

  mux2x1 #(`NUM_REGISTERS_LOG2) reg_dst_mux(
  .in0(id_ex_rt), 
  .in1(id_ex_rd), 
  .sel(id_ex_reg_dst), 
  .out(reg_dst_result));

  ex_mem_register ex_mem_reg(
  .clk(clk), 
  .flush(flush), 
  .alu_result_in(alu_result), 
  .data_1_in(alu_input_mux_1_result),
  .data_2_in(alu_input_mux_2_result), 
  .reg_dst_result_in(reg_dst_result), 
  .beq_in(id_ex_beq), 
  .bne_in(id_ex_bne),
  .mem_op_in(id_ex_mem_op), 
  .mem_to_reg_in(id_ex_mem_to_reg), 
  .reg_write_in(id_ex_reg_write), 
  .compare_in(compare),
  .address_in(id_ex_address), 
  .address_src_in(id_ex_address_src),
  .alu_result_out(ex_mem_alu_result), 
  .data_1_out(ex_mem_data_1), 
  .data_2_out(ex_mem_data_2),
  .reg_dst_result_out(ex_mem_reg_dst_result), 
  .beq_out(ex_mem_beq), 
  .bne_out(ex_mem_bne), 
  .mem_op_out(ex_mem_mem_op),
  .mem_to_reg_out(ex_mem_mem_to_reg), 
  .reg_write_out(ex_mem_reg_write), 
  .compare_out(ex_mem_compare), 
  .address_out(ex_mem_address),
  .address_src_out(ex_mem_address_src));

  ///////////////////////////////////////////////////////////////////////////////////////////////

  // ex_mem_data_1: register result
  // ex_mem_address: address in instruction
  // la, sa = ex_mem_address
  // lw, sw = ex_mem_data_1

  mux2x1 #(`ADDR_WIDTH) address_src_mux(
  .in0(ex_mem_data_1[`ADDR_WIDTH-1:0]), 
  .in1(ex_mem_address), 
  .sel(ex_mem_address_src), 
  .out(address_src_result));

  ram data_memory(
  .clk(clk), 
  .complete(complete), 
  .address(address_src_result), 
  .write_data(ex_mem_data_2), 
  .read_data(ram_read_data), 
  .mem_op(ex_mem_mem_op));

  branch_unit bu(
  .beq(ex_mem_beq), 
  .bne(ex_mem_bne), 
  .compare(ex_mem_compare), 
  .flush(flush));

  mem_wb_register mem_wb_reg(
  .clk(clk), 
  .mem_to_reg_in(ex_mem_mem_to_reg), 
  .ram_read_data_in(ram_read_data), 
  .alu_result_in(ex_mem_alu_result), 
  .reg_dst_result_in(ex_mem_reg_dst_result), 
  .reg_write_in(ex_mem_reg_write), 
  .mem_to_reg_out(mem_wb_mem_to_reg), 
  .ram_read_data_out(mem_wb_ram_read_data), 
  .alu_result_out(mem_wb_alu_result),
  .reg_dst_result_out(mem_wb_reg_dst_result), 
  .reg_write_out(mem_wb_reg_write));

  ///////////////////////////////////////////////////////////////////////////////////////////////

  mux2x1 #(`DATA_WIDTH) mem_to_reg_mux(
  .in0(mem_wb_alu_result), 
  .in1(mem_wb_ram_read_data), 
  .sel(mem_wb_mem_to_reg), 
  .out(mem_to_reg_result));

endmodule











