`timescale 1ns / 1ps

`include "defines.vh"

module processor(
  clk,
  reset,
  );
	 
  input clk;
  input reset;
  // could make the ram and the regfile outputs. wud be very convenient for testing.
  // problem becomes if ram is large, we wud need a bus we can access it or some shit.

  wire reg_dst0;
  wire mem_to_reg0;
  wire [`ALU_OP_BITS-1:0] alu_op0;
  wire [`MEM_OP_BITS-1:0] mem_op0;
  wire alu_src0;
  wire reg_write0;
  wire [`JUMP_BITS-1:0] jop0;
  wire address_src0;

  wire reg_dst1;
  wire mem_to_reg1;
  wire [`ALU_OP_BITS-1:0] alu_op1;
  wire [`MEM_OP_BITS-1:0] mem_op1;
  wire alu_src1;
  wire reg_write1;
  wire [`JUMP_BITS-1:0] jop1;
  wire address_src1;

  wire zero0;
  wire less0;
  wire greater0;

  wire zero1;
  wire less1;
  wire greater1;

  wire [`DATA_WIDTH-1:0] ram_read_data;

  wire [`DATA_WIDTH-1:0] reg_read_data_1_0;
  wire [`DATA_WIDTH-1:0] reg_read_data_2_0;

  wire [`DATA_WIDTH-1:0] reg_read_data_1_1;
  wire [`DATA_WIDTH-1:0] reg_read_data_2_1;

  wire [`DATA_WIDTH-1:0] alu_result0;
  wire [`DATA_WIDTH-1:0] alu_result1;

  wire [`NUM_REGISTERS_LOG2-1:0] reg_dst_result0;
  wire [`NUM_REGISTERS_LOG2-1:0] reg_dst_result1;

  wire [`DATA_WIDTH-1:0] alu_src_result0;
  wire [`DATA_WIDTH-1:0] alu_src_result1;
  wire [`DATA_WIDTH-1:0] mem_to_reg_result;

  wire [`ADDR_WIDTH-1:0] address_src_result0;
  wire [`ADDR_WIDTH-1:0] address_src_result1;

  // if/id
  wire [`INST_WIDTH-1:0] instruction0;
  wire [`INST_WIDTH-1:0] instruction1;
  wire [`ADDR_WIDTH-1:0] pc;

  wire [`OP_CODE_BITS-1:0] opcode0;
  wire [`NUM_REGISTERS_LOG2-1:0] rs0;
  wire [`NUM_REGISTERS_LOG2-1:0] rt0;
  wire [`NUM_REGISTERS_LOG2-1:0] rd0;
  wire [`IMM_WIDTH-1:0] immediate0;
  wire [`ADDR_WIDTH-1:0] address0;
  wire [`SHAMT_BITS-1:0] shamt0;

  wire [`OP_CODE_BITS-1:0] opcode1;
  wire [`NUM_REGISTERS_LOG2-1:0] rs1;
  wire [`NUM_REGISTERS_LOG2-1:0] rt1;
  wire [`NUM_REGISTERS_LOG2-1:0] rd1;
  wire [`IMM_WIDTH-1:0] immediate1;
  wire [`ADDR_WIDTH-1:0] address1;
  wire [`SHAMT_BITS-1:0] shamt1;

  // id/ex
  wire [`INST_WIDTH-1:0] id_ex_instruction0;
  wire [`NUM_REGISTERS_LOG2-1:0] id_ex_rs0, id_ex_rt0, id_ex_rd0;
  wire [`DATA_WIDTH-1:0] id_ex_reg_read_data_1_0, id_ex_reg_read_data_2_0;
  wire [`IMM_WIDTH-1:0] id_ex_immediate0;
  wire [`ADDR_WIDTH-1:0] id_ex_address0;
  wire [`SHAMT_BITS-1:0] id_ex_shamt0;
  wire id_ex_reg_dst0, id_ex_mem_to_reg0, id_ex_alu_src0, id_ex_reg_write0, id_ex_address_src0;
  wire [`JUMP_BITS-1:0] id_ex_jop0;
  wire [`ALU_OP_BITS-1:0] id_ex_alu_op0;
  wire [`MEM_OP_BITS-1:0] id_ex_mem_op0;

  wire [`INST_WIDTH-1:0] id_ex_instruction1;
  wire [`NUM_REGISTERS_LOG2-1:0] id_ex_rs1, id_ex_rt1, id_ex_rd1;
  wire [`DATA_WIDTH-1:0] id_ex_reg_read_data_1_1, id_ex_reg_read_data_2_1;
  wire [`IMM_WIDTH-1:0] id_ex_immediate1;
  wire [`ADDR_WIDTH-1:0] id_ex_address1;
  wire [`SHAMT_BITS-1:0] id_ex_shamt1;
  wire id_ex_reg_dst1, id_ex_mem_to_reg1, id_ex_alu_src1, id_ex_reg_write1, id_ex_address_src1;
  wire [`JUMP_BITS-1:0] id_ex_jop1;
  wire [`ALU_OP_BITS-1:0] id_ex_alu_op1;
  wire [`MEM_OP_BITS-1:0] id_ex_mem_op1;

  // ex/mem
  wire [`INST_WIDTH-1:0] ex_mem_instruction0;
  wire [`DATA_WIDTH-1:0] ex_mem_alu_result0;
  wire [`DATA_WIDTH-1:0] ex_mem_data_1_0, ex_mem_data_2_0;
  wire [`ADDR_WIDTH-1:0] ex_mem_address0;
  wire [`ADDR_WIDTH-1:0] ex_mem_address_src_result0;
  wire ex_mem_mem_to_reg0;
  wire ex_mem_reg_write0;
  wire [`JUMP_BITS-1:0] ex_mem_jop0;
  wire [`MEM_OP_BITS-1:0] ex_mem_mem_op0;
  wire [`NUM_REGISTERS_LOG2-1:0] ex_mem_reg_dst_result0;

  wire ex_mem_jump_address;
  wire [`ADDR_WIDTH-1:0] jump_address_result;

  wire [`INST_WIDTH-1:0] ex_mem_instruction1;
  wire [`DATA_WIDTH-1:0] ex_mem_alu_result1;
  wire [`DATA_WIDTH-1:0] ex_mem_data_1_1, ex_mem_data_2_1;
  wire [`ADDR_WIDTH-1:0] ex_mem_address1;
  wire [`ADDR_WIDTH-1:0] ex_mem_address_src_result1;
  wire ex_mem_mem_to_reg1;
  wire ex_mem_reg_write1;
  wire [`JUMP_BITS-1:0] ex_mem_jop1;
  wire [`MEM_OP_BITS-1:0] ex_mem_mem_op1;
  wire [`NUM_REGISTERS_LOG2-1:0] ex_mem_reg_dst_result1;

  // mem/wb
  wire [`INST_WIDTH-1:0] mem_wb_instruction;
  wire [`DATA_WIDTH-1:0] mem_wb_ram_read_data, mem_wb_alu_result;
  wire [`NUM_REGISTERS_LOG2-1:0] mem_wb_reg_dst_result;
  wire mem_wb_mem_to_reg, mem_wb_reg_write;

  wire [`FORWARD_BITS-1:0] forward_a, forward_b;
  wire stall;
  wire flush;
  wire [`DATA_WIDTH-1:0] alu_input_mux_1_result0, alu_input_mux_2_result0;
  wire [`DATA_WIDTH-1:0] alu_input_mux_1_result1, alu_input_mux_2_result1;

  assign opcode0 = instruction0[`OPCODE_MSB:`OPCODE_LSB];
  assign rs0 = instruction0[`REG_RS_MSB:`REG_RS_LSB];
  assign rt0 = instruction0[`REG_RT_MSB:`REG_RT_LSB];
  assign rd0 = instruction0[`REG_RD_MSB:`REG_RD_LSB];
  assign immediate0 = instruction0[`IMM_MSB:`IMM_LSB];
  assign address0 = instruction0[`IMM_MSB:`IMM_LSB];
  assign shamt0 = instruction0[`SHAMT_MSB:`SHAMT_LSB];

  assign opcode1 = instruction1[`OPCODE_MSB:`OPCODE_LSB];
  assign rs1 = instruction1[`REG_RS_MSB:`REG_RS_LSB];
  assign rt1 = instruction1[`REG_RT_MSB:`REG_RT_LSB];
  assign rd1 = instruction1[`REG_RD_MSB:`REG_RD_LSB];
  assign immediate1 = instruction1[`IMM_MSB:`IMM_LSB];
  assign address1 = instruction1[`IMM_MSB:`IMM_LSB];
  assign shamt1 = instruction1[`SHAMT_MSB:`SHAMT_LSB];

  ///////////////////////////////////////////////////////////////////////////////////////////

  mux2x1 #(`ADDR_WIDTH) jump_address_mux(
  .in0(ex_mem_data_1_0[`ADDR_WIDTH-1:0]), 
  .in1(ex_mem_address0), 
  .sel(ex_mem_jump_address), 
  .out(jump_address_result));

  program_counter pc_unit(
  .clk(clk), 
  .reset(reset),
  .prev_opcode0(opcode0),
  .prev_address0(address0),
  .prev_opcode1(opcode1),
  .prev_address1(address1),
  .branch_address(jump_address_result), 
  .pc(pc), 
  .flush(flush), 
  .stall(stall));
  
  instruction_memory im(
  .pc(pc), 
  .instruction0(instruction0),
  .instruction1(instruction1));

  ///////////////////////////////////////////////////////////////////////////////////////////
  
  hazard_detection_unit hdu(
  .id_ex_mem_op(id_ex_mem_op0), 
  .id_ex_rt(id_ex_rt0), 
  .if_id_rs(rs0), 
  .if_id_rt(rt0), 
  .stall(stall));

  control_unit cu0(
  .opcode(opcode0), 
  .reg_dst(reg_dst0), 
  .mem_to_reg(mem_to_reg0), 
  .alu_op(alu_op0), 
  .alu_src(alu_src0), 
  .reg_write(reg_write0), 
  .mem_op(mem_op0), 
  .jop(jop0),
  .address_src(address_src0));

  control_unit cu1(
  .opcode(opcode1), 
  .reg_dst(reg_dst1), 
  .mem_to_reg(mem_to_reg1), 
  .alu_op(alu_op1), 
  .alu_src(alu_src1), 
  .reg_write(reg_write1), 
  .mem_op(mem_op1), 
  .jop(jop1),
  .address_src(address_src1));

  register_file regfile0( 
  .write(mem_wb_reg_write), 
  .write_address(mem_wb_reg_dst_result), 
  .write_data(mem_to_reg_result), 
  .read_address_1(rs0), 
  .read_data_1(reg_read_data_1_0), 
  .read_address_2(rt0), 
  .read_data_2(reg_read_data_2_0));

  register_file regfile1( 
  .write(1'b0), // this cannot write stuff or it will break us
  .write_address(mem_wb_reg_dst_result), 
  .write_data(mem_to_reg_result), 
  .read_address_1(rs1), 
  .read_data_1(reg_read_data_1_1), 
  .read_address_2(rt1), 
  .read_data_2(reg_read_data_2_1));

  id_ex_register id_ex_reg(
  .clk(clk), 
  // flush will have to flush all instructions behind it. 
  // cud be even the one in parallel as well.
  .flush(flush), 
  // stall will stall both instructions. easiest way moving forward.
  // need to finish in order.
  .stall(stall), 

  .rs_in0(rs0), 
  .rt_in0(rt0), 
  .rd_in0(rd0), 
  .reg_read_data_1_in0(reg_read_data_1_0),
  .reg_read_data_2_in0(reg_read_data_2_0), 
  .immediate_in0(immediate0), 
  .address_in0(address0), 
  .shamt_in0(shamt0),
  .reg_dst_in0(reg_dst0), 
  .mem_to_reg_in0(mem_to_reg0), 
  .alu_op_in0(alu_op0), 
  .mem_op_in0(mem_op0), 
  .alu_src_in0(alu_src0), 
  .reg_write_in0(reg_write0), 
  .jop_in0(jop0), 
  .address_src_in0(address_src0),
  .instruction_in0(instruction0),

  .rs_in1(rs1), 
  .rt_in1(rt1), 
  .rd_in1(rd1), 
  .reg_read_data_1_in1(reg_read_data_1_1),
  .reg_read_data_2_in1(reg_read_data_2_1), 
  .immediate_in1(immediate1), 
  .address_in1(address1), 
  .shamt_in1(shamt1),
  .reg_dst_in1(reg_dst1), 
  .mem_to_reg_in1(mem_to_reg1), 
  .alu_op_in1(alu_op1), 
  .mem_op_in1(mem_op1), 
  .alu_src_in1(alu_src1), 
  .reg_write_in1(reg_write1), 
  .jop_in1(jop1), 
  .address_src_in1(address_src1),
  .instruction_in1(instruction1),

  .rs_out0(id_ex_rs0), 
  .rt_out0(id_ex_rt0), 
  .rd_out0(id_ex_rd0), 
  .reg_read_data_1_out0(id_ex_reg_read_data_1_0),
  .reg_read_data_2_out0(id_ex_reg_read_data_2_0), 
  .immediate_out0(id_ex_immediate0), 
  .address_out0(id_ex_address0),
  .shamt_out0(id_ex_shamt0),
  .reg_dst_out0(id_ex_reg_dst0), 
  .mem_to_reg_out0(id_ex_mem_to_reg0), 
  .alu_op_out0(id_ex_alu_op0), 
  .mem_op_out0(id_ex_mem_op0), 
  .alu_src_out0(id_ex_alu_src0), 
  .reg_write_out0(id_ex_reg_write0), 
  .jop_out0(id_ex_jop0), 
  .address_src_out0(id_ex_address_src0),
  .instruction_out0(id_ex_instruction0),

  .rs_out1(id_ex_rs1), 
  .rt_out1(id_ex_rt1), 
  .rd_out1(id_ex_rd1), 
  .reg_read_data_1_out1(id_ex_reg_read_data_1_1),
  .reg_read_data_2_out1(id_ex_reg_read_data_2_1), 
  .immediate_out1(id_ex_immediate1), 
  .address_out1(id_ex_address1),
  .shamt_out1(id_ex_shamt1),
  .reg_dst_out1(id_ex_reg_dst1), 
  .mem_to_reg_out1(id_ex_mem_to_reg1), 
  .alu_op_out1(id_ex_alu_op1), 
  .mem_op_out1(id_ex_mem_op1), 
  .alu_src_out1(id_ex_alu_src1), 
  .reg_write_out1(id_ex_reg_write1), 
  .jop_out1(id_ex_jop1), 
  .address_src_out1(id_ex_address_src1),
  .instruction_out1(id_ex_instruction1)
  );

  ///////////////////////////////////////////////////////////////////////////////////////////////

  forwarding_unit fu(
  .id_ex_rs(id_ex_rs0), 
  .id_ex_rt(id_ex_rt0), 
  .ex_mem_rd(ex_mem_reg_dst_result0), 
  .mem_wb_rd(mem_wb_reg_dst_result), 
  .ex_mem_reg_write(ex_mem_reg_write0), 
  .mem_wb_reg_write(mem_wb_reg_write),
  .forward_a(forward_a), 
  .forward_b(forward_b));

  // pipe 1
  mux4x2 #(`DATA_WIDTH) alu_input_mux_1_0(
  .in0(id_ex_reg_read_data_1_0), 
  .in1(mem_to_reg_result), 
  .in2(ex_mem_alu_result0), 
  .in3(),
  .sel(forward_a), 
  .out(alu_input_mux_1_result0));

  mux4x2 #(`DATA_WIDTH) alu_input_mux_2_0(
  .in0(id_ex_reg_read_data_2_0), 
  .in1(mem_to_reg_result), 
  .in2(ex_mem_alu_result0), 
  .in3(),
  .sel(forward_b), 
  .out(alu_input_mux_2_result0));

  // pipe 2
  mux4x2 #(`DATA_WIDTH) alu_input_mux_1_1(
  .in0(id_ex_reg_read_data_1_1), 
  .in1(), 
  .in2(), 
  .in3(),
  .sel(), 
  .out(alu_input_mux_1_result1));

  mux4x2 #(`DATA_WIDTH) alu_input_mux_2_1(
  .in0(id_ex_reg_read_data_2_1), 
  .in1(), 
  .in2(), 
  .in3(),
  .sel(), 
  .out(alu_input_mux_2_result1));
  //

  mux2x1 #(`DATA_WIDTH) alu_src_mux0(
  .in0(alu_input_mux_2_result0), 
  .in1({16'h0000, id_ex_immediate0}), 
  .sel(id_ex_alu_src0), 
  .out(alu_src_result0));

  mux2x1 #(`DATA_WIDTH) alu_src_mux1(
  .in0(alu_input_mux_2_result1), 
  .in1({16'h0000, id_ex_immediate1}), 
  .sel(id_ex_alu_src1), 
  .out(alu_src_result1));

  alu alu0(
  .alu_op(id_ex_alu_op0), 
  .data1(alu_input_mux_1_result0), 
  .data2(alu_src_result0), 
  .zero(zero0),
  .less(less0),
  .greater(greater0),
  .alu_result(alu_result0));

  alu alu1(
  .alu_op(id_ex_alu_op1), 
  .data1(alu_input_mux_1_result1), 
  .data2(alu_src_result1), 
  .zero(zero1),
  .less(less1),
  .greater(greater1),
  .alu_result(alu_result1));

  mux2x1 #(`NUM_REGISTERS_LOG2) reg_dst_mux0(
  .in0(id_ex_rt0), 
  .in1(id_ex_rd0), 
  .sel(id_ex_reg_dst0), 
  .out(reg_dst_result0));

  mux2x1 #(`NUM_REGISTERS_LOG2) reg_dst_mux1(
  .in0(id_ex_rt1), 
  .in1(id_ex_rd1), 
  .sel(id_ex_reg_dst1), 
  .out(reg_dst_result1));

  mux2x1 #(`ADDR_WIDTH) address_src_mux0(
  .in0(alu_result0[`ADDR_WIDTH-1:0]), 
  .in1(id_ex_address0), 
  .sel(id_ex_address_src0), 
  .out(address_src_result0));

  mux2x1 #(`ADDR_WIDTH) address_src_mux1(
  .in0(alu_result1[`ADDR_WIDTH-1:0]), 
  .in1(id_ex_address1), 
  .sel(id_ex_address_src1), 
  .out(address_src_result1));

  ex_mem_register ex_mem_reg(
  .clk(clk), 
  .flush(flush), 

  .alu_result_in0(alu_result0), 
  .data_1_in0(alu_input_mux_1_result0),
  .data_2_in0(alu_input_mux_2_result0), 
  .reg_dst_result_in0(reg_dst_result0), 
  .jop_in0(id_ex_jop0), 
  .mem_op_in0(id_ex_mem_op0), 
  .mem_to_reg_in0(id_ex_mem_to_reg0), 
  .reg_write_in0(id_ex_reg_write0), 
  .address_in0(id_ex_address0), 
  .address_src_result_in0(address_src_result0),
  .instruction_in0(id_ex_instruction0),

  .alu_result_in1(alu_result1), 
  .data_1_in1(alu_input_mux_1_result1),
  .data_2_in1(alu_input_mux_2_result1), 
  .reg_dst_result_in1(reg_dst_result1), 
  .jop_in1(id_ex_jop1), 
  .mem_op_in1(id_ex_mem_op1), 
  .mem_to_reg_in1(id_ex_mem_to_reg1), 
  .reg_write_in1(id_ex_reg_write1), 
  .address_in1(id_ex_address1), 
  .address_src_result_in1(address_src_result1),
  .instruction_in1(id_ex_instruction1),

  .alu_result_out0(ex_mem_alu_result0), 
  .data_1_out0(ex_mem_data_1_0), 
  .data_2_out0(ex_mem_data_2_0),
  .reg_dst_result_out0(ex_mem_reg_dst_result0), 
  .jop_out0(ex_mem_jop0), 
  .mem_op_out0(ex_mem_mem_op0),
  .mem_to_reg_out0(ex_mem_mem_to_reg0), 
  .reg_write_out0(ex_mem_reg_write0), 
  .address_out0(ex_mem_address0),
  .address_src_result_out0(ex_mem_address_src_result0),
  .instruction_out0(ex_mem_instruction0),

  .alu_result_out1(ex_mem_alu_result1), 
  .data_1_out1(ex_mem_data_1_1), 
  .data_2_out1(ex_mem_data_2_1),
  .reg_dst_result_out1(ex_mem_reg_dst_result1), 
  .jop_out1(ex_mem_jop1), 
  .mem_op_out1(ex_mem_mem_op1),
  .mem_to_reg_out1(ex_mem_mem_to_reg1), 
  .reg_write_out1(ex_mem_reg_write1), 
  .address_out1(ex_mem_address1),
  .address_src_result_out1(ex_mem_address_src_result1),
  .instruction_out1(ex_mem_instruction1)

  );

  ///////////////////////////////////////////////////////////////////////////////////////////////

  ram data_memory(
  .address(ex_mem_address_src_result0), 
  .write_data(ex_mem_data_2_0), 
  .read_data(ram_read_data), 
  .mem_op(ex_mem_mem_op0));

  branch_unit bu(
  .zero(zero0),
  .less(less0),
  .greater(greater0),
  .jop(ex_mem_jop0), 
  .flush(flush),
  .jump_address(ex_mem_jump_address));

  mem_wb_register mem_wb_reg(
  .clk(clk), 
  .mem_to_reg_in(ex_mem_mem_to_reg0), 
  .ram_read_data_in(ram_read_data), 
  .alu_result_in(ex_mem_alu_result0), 
  .reg_dst_result_in(ex_mem_reg_dst_result0), 
  .reg_write_in(ex_mem_reg_write0), 
  .instruction_in(ex_mem_instruction0),

  .mem_to_reg_out(mem_wb_mem_to_reg), 
  .ram_read_data_out(mem_wb_ram_read_data), 
  .alu_result_out(mem_wb_alu_result),
  .reg_dst_result_out(mem_wb_reg_dst_result), 
  .reg_write_out(mem_wb_reg_write),
  .instruction_out(mem_wb_instruction)
  );

  ///////////////////////////////////////////////////////////////////////////////////////////////

  mux2x1 #(`DATA_WIDTH) mem_to_reg_mux(
  .in0(mem_wb_alu_result), 
  .in1(mem_wb_ram_read_data), 
  .sel(mem_wb_mem_to_reg), 
  .out(mem_to_reg_result));

endmodule











