`timescale 1ns / 1ps

module id_ex_register(
  clk,
  stall,
  flush,

  rs_in0,
  rt_in0,
  rd_in0,
  reg_read_data_1_in0,
  reg_read_data_2_in0,
  immediate_in0,
  address_in0,
  shamt_in0,
  reg_dst_in0,
  mem_to_reg_in0,
  alu_op_in0,
  mem_op_in0,
  alu_src_in0,
  reg_write_in0,
  jop_in0,
  address_src_in0,
  instruction_in0,

  rs_in1,
  rt_in1,
  rd_in1,
  reg_read_data_1_in1,
  reg_read_data_2_in1,
  immediate_in1,
  address_in1,
  shamt_in1,
  reg_dst_in1,
  mem_to_reg_in1,
  alu_op_in1,
  mem_op_in1,
  alu_src_in1,
  reg_write_in1,
  jop_in1,
  address_src_in1,
  instruction_in1,

  rs_out0,
  rt_out0,
  rd_out0,
  reg_read_data_1_out0,
  reg_read_data_2_out0,
  immediate_out0,
  address_out0,
  shamt_out0,
  reg_dst_out0,
  mem_to_reg_out0,
  alu_op_out0,
  mem_op_out0,
  alu_src_out0,
  reg_write_out0,
  jop_out0,
  address_src_out0,
  instruction_out0,

  rs_out1,
  rt_out1,
  rd_out1,
  reg_read_data_1_out1,
  reg_read_data_2_out1,
  immediate_out1,
  address_out1,
  shamt_out1,
  reg_dst_out1,
  mem_to_reg_out1,
  alu_op_out1,
  mem_op_out1,
  alu_src_out1,
  reg_write_out1,
  jop_out1,
  address_src_out1,
  instruction_out1,
  );

  input wire clk;
  input wire flush;
  input wire stall;

  input wire [`NUM_REGISTERS_LOG2-1:0] rs_in0;
  input wire [`NUM_REGISTERS_LOG2-1:0] rt_in0;
  input wire [`NUM_REGISTERS_LOG2-1:0] rd_in0;
  input wire [`DATA_WIDTH-1:0] reg_read_data_1_in0;
  input wire [`DATA_WIDTH-1:0] reg_read_data_2_in0;
  input wire [`IMM_WIDTH-1:0] immediate_in0;
  input wire [`ADDR_WIDTH-1:0] address_in0;
  input wire [`SHAMT_BITS-1:0] shamt_in0;
  input wire reg_dst_in0;
  input wire mem_to_reg_in0;
  input wire [`ALU_OP_BITS-1:0] alu_op_in0;
  input wire [`MEM_OP_BITS-1:0] mem_op_in0;
  input wire alu_src_in0;
  input wire reg_write_in0;
  input wire [`JUMP_BITS-1:0] jop_in0;
  input wire address_src_in0;
  input wire [`INST_WIDTH-1:0] instruction_in0;

  input wire [`NUM_REGISTERS_LOG2-1:0] rs_in1;
  input wire [`NUM_REGISTERS_LOG2-1:0] rt_in1;
  input wire [`NUM_REGISTERS_LOG2-1:0] rd_in1;
  input wire [`DATA_WIDTH-1:0] reg_read_data_1_in1;
  input wire [`DATA_WIDTH-1:0] reg_read_data_2_in1;
  input wire [`IMM_WIDTH-1:0] immediate_in1;
  input wire [`ADDR_WIDTH-1:0] address_in1;
  input wire [`SHAMT_BITS-1:0] shamt_in1;
  input wire reg_dst_in1;
  input wire mem_to_reg_in1;
  input wire [`ALU_OP_BITS-1:0] alu_op_in1;
  input wire [`MEM_OP_BITS-1:0] mem_op_in1;
  input wire alu_src_in1;
  input wire reg_write_in1;
  input wire [`JUMP_BITS-1:0] jop_in1;
  input wire address_src_in1;
  input wire [`INST_WIDTH-1:0] instruction_in1;

  output reg [`NUM_REGISTERS_LOG2-1:0] rs_out0;
  output reg [`NUM_REGISTERS_LOG2-1:0] rt_out0;
  output reg [`NUM_REGISTERS_LOG2-1:0] rd_out0;
  output reg [`DATA_WIDTH-1:0] reg_read_data_1_out0;
  output reg [`DATA_WIDTH-1:0] reg_read_data_2_out0;
  output reg [`IMM_WIDTH-1:0] immediate_out0;
  output reg [`ADDR_WIDTH-1:0] address_out0;
  output reg [`SHAMT_BITS-1:0] shamt_out0;
  output reg reg_dst_out0;
  output reg mem_to_reg_out0;
  output reg [`ALU_OP_BITS-1:0] alu_op_out0;
  output reg [`MEM_OP_BITS-1:0] mem_op_out0;
  output reg alu_src_out0;
  output reg reg_write_out0;
  output reg [`JUMP_BITS-1:0] jop_out0;
  output reg address_src_out0;
  output reg [`INST_WIDTH-1:0] instruction_out0;

  output reg [`NUM_REGISTERS_LOG2-1:0] rs_out1;
  output reg [`NUM_REGISTERS_LOG2-1:0] rt_out1;
  output reg [`NUM_REGISTERS_LOG2-1:0] rd_out1;
  output reg [`DATA_WIDTH-1:0] reg_read_data_1_out1;
  output reg [`DATA_WIDTH-1:0] reg_read_data_2_out1;
  output reg [`IMM_WIDTH-1:0] immediate_out1;
  output reg [`ADDR_WIDTH-1:0] address_out1;
  output reg [`SHAMT_BITS-1:0] shamt_out1;
  output reg reg_dst_out1;
  output reg mem_to_reg_out1;
  output reg [`ALU_OP_BITS-1:0] alu_op_out1;
  output reg [`MEM_OP_BITS-1:0] mem_op_out1;
  output reg alu_src_out1;
  output reg reg_write_out1;
  output reg [`JUMP_BITS-1:0] jop_out1;
  output reg address_src_out1;
  output reg [`INST_WIDTH-1:0] instruction_out1;

  initial begin
    rs_out0 <= 0;
    rt_out0 <= 0;
    rd_out0 <= 0;
    reg_read_data_1_out0 <= 0;
    reg_read_data_2_out0 <= 0;
    immediate_out0 <= 0;
    address_out0 <= 0;
    shamt_out0 <= 0;
    reg_dst_out0 <= 0;
    mem_to_reg_out0 <= 0;
    alu_op_out0 <= 0;
    mem_op_out0 <= 0;
    alu_src_out0 <= 0;
    reg_write_out0 <= 0;
    jop_out0 <= 0;
    address_src_out0 <= 0;
    instruction_out0 <= 0;

    rs_out1 <= 0;
    rt_out1 <= 0;
    rd_out1 <= 0;
    reg_read_data_1_out1 <= 0;
    reg_read_data_2_out1 <= 0;
    immediate_out1 <= 0;
    address_out1 <= 0;
    shamt_out1 <= 0;
    reg_dst_out1 <= 0;
    mem_to_reg_out1 <= 0;
    alu_op_out1 <= 0;
    mem_op_out1 <= 0;
    alu_src_out1 <= 0;
    reg_write_out1 <= 0;
    jop_out1 <= 0;
    address_src_out1 <= 0;
    instruction_out1 <= 0;
  end

  always @(posedge clk) begin

    if(flush || stall) begin
      rs_out0 <= 0;
      rt_out0 <= 0;
      rd_out0 <= 0;
      reg_read_data_1_out0 <= 0;
      reg_read_data_2_out0 <= 0;
      immediate_out0 <= 0;
      address_out0 <= 0;
      shamt_out0 <= 0;
      reg_dst_out0 <= 0;
      mem_to_reg_out0 <= 0;
      alu_op_out0 <= 0;
      mem_op_out0 <= 0;
      alu_src_out0 <= 0;
      reg_write_out0 <= 0;
      jop_out0 <= 0;
      address_src_out0 <= 0;
      instruction_out0 <= 0;

      rs_out1 <= 0;
      rt_out1 <= 0;
      rd_out1 <= 0;
      reg_read_data_1_out1 <= 0;
      reg_read_data_2_out1 <= 0;
      immediate_out1 <= 0;
      address_out1 <= 0;
      shamt_out1 <= 0;
      reg_dst_out1 <= 0;
      mem_to_reg_out1 <= 0;
      alu_op_out1 <= 0;
      mem_op_out1 <= 0;
      alu_src_out1 <= 0;
      reg_write_out1 <= 0;
      jop_out1 <= 0;
      address_src_out1 <= 0;
      instruction_out1 <= 0;
    end else begin	
      rs_out0 <= rs_in0;
      rt_out0 <= rt_in0;
      rd_out0 <= rd_in0;
      reg_read_data_1_out0 <= reg_read_data_1_in0;
      reg_read_data_2_out0 <= reg_read_data_2_in0;
      immediate_out0 <= immediate_in0;
      address_out0 <= address_in0;
      shamt_out0 <= shamt_in0;
      reg_dst_out0 <= reg_dst_in0;
      mem_to_reg_out0 <= mem_to_reg_in0;
      alu_op_out0 <= alu_op_in0;
      mem_op_out0 <= mem_op_in0;
      alu_src_out0 <= alu_src_in0;
      reg_write_out0 <= reg_write_in0;
      jop_out0 <= jop_in0;
      address_src_out0 <= address_src_in0;
      instruction_out0 <=instruction_in0;

      rs_out1 <= rs_in1;
      rt_out1 <= rt_in1;
      rd_out1 <= rd_in1;
      reg_read_data_1_out1 <= reg_read_data_1_in1;
      reg_read_data_2_out1 <= reg_read_data_2_in1;
      immediate_out1 <= immediate_in1;
      address_out1 <= address_in1;
      shamt_out1 <= shamt_in1;
      reg_dst_out1 <= reg_dst_in1;
      mem_to_reg_out1 <= mem_to_reg_in1;
      alu_op_out1 <= alu_op_in1;
      mem_op_out1 <= mem_op_in1;
      alu_src_out1 <= alu_src_in1;
      reg_write_out1 <= reg_write_in1;
      jop_out1 <= jop_in1;
      address_src_out1 <= address_src_in1;
      instruction_out1 <=instruction_in1;
    end

  end

endmodule

module ex_mem_register(
  clk,
  flush,

  alu_result_in0,
  data_1_in0,
  data_2_in0,
  reg_dst_result_in0,
  jop_in0,
  mem_op_in0,
  mem_to_reg_in0,
  reg_write_in0,
  address_in0,
  address_src_result_in0,
  instruction_in0,

  alu_result_in1,
  data_1_in1,
  data_2_in1,
  reg_dst_result_in1,
  jop_in1,
  mem_op_in1,
  mem_to_reg_in1,
  reg_write_in1,
  address_in1,
  address_src_result_in1,
  instruction_in1,

  alu_result_out0,
  data_1_out0,
  data_2_out0,
  reg_dst_result_out0,
  jop_out0,
  mem_op_out0,
  mem_to_reg_out0,
  reg_write_out0,
  address_out0,
  address_src_result_out0,
  instruction_out0,

  alu_result_out1,
  data_1_out1,
  data_2_out1,
  reg_dst_result_out1,
  jop_out1,
  mem_op_out1,
  mem_to_reg_out1,
  reg_write_out1,
  address_out1,
  address_src_result_out1,
  instruction_out1,
  );

  input wire clk;
  input wire flush;

  input wire [`DATA_WIDTH-1:0] alu_result_in0;
  input wire [`DATA_WIDTH-1:0] data_1_in0;
  input wire [`DATA_WIDTH-1:0] data_2_in0;
  input wire [`NUM_REGISTERS_LOG2-1:0] reg_dst_result_in0;
  input wire [`JUMP_BITS-1:0] jop_in0;
  input wire [`MEM_OP_BITS-1:0] mem_op_in0;
  input wire mem_to_reg_in0;
  input wire reg_write_in0;
  input wire [`ADDR_WIDTH-1:0] address_in0;
  input wire [`ADDR_WIDTH-1:0] address_src_result_in0;
  input wire [`INST_WIDTH-1:0] instruction_in0;

  input wire [`DATA_WIDTH-1:0] alu_result_in1;
  input wire [`DATA_WIDTH-1:0] data_1_in1;
  input wire [`DATA_WIDTH-1:0] data_2_in1;
  input wire [`NUM_REGISTERS_LOG2-1:0] reg_dst_result_in1;
  input wire [`JUMP_BITS-1:0] jop_in1;
  input wire [`MEM_OP_BITS-1:0] mem_op_in1;
  input wire mem_to_reg_in1;
  input wire reg_write_in1;
  input wire [`ADDR_WIDTH-1:0] address_in1;
  input wire [`ADDR_WIDTH-1:0] address_src_result_in1;
  input wire [`INST_WIDTH-1:0] instruction_in1;

  output reg [`DATA_WIDTH-1:0] alu_result_out0;
  output reg [`DATA_WIDTH-1:0] data_1_out0;
  output reg [`DATA_WIDTH-1:0] data_2_out0;
  output reg [`NUM_REGISTERS_LOG2-1:0] reg_dst_result_out0;
  output reg [`JUMP_BITS-1:0] jop_out0;
  output reg [`MEM_OP_BITS-1:0] mem_op_out0;
  output reg mem_to_reg_out0;
  output reg reg_write_out0;
  output reg [`ADDR_WIDTH-1:0] address_out0;
  output reg [`ADDR_WIDTH-1:0] address_src_result_out0;
  output reg [`INST_WIDTH-1:0] instruction_out0;

  output reg [`DATA_WIDTH-1:0] alu_result_out1;
  output reg [`DATA_WIDTH-1:0] data_1_out1;
  output reg [`DATA_WIDTH-1:0] data_2_out1;
  output reg [`NUM_REGISTERS_LOG2-1:0] reg_dst_result_out1;
  output reg [`JUMP_BITS-1:0] jop_out1;
  output reg [`MEM_OP_BITS-1:0] mem_op_out1;
  output reg mem_to_reg_out1;
  output reg reg_write_out1;
  output reg [`ADDR_WIDTH-1:0] address_out1;
  output reg [`ADDR_WIDTH-1:0] address_src_result_out1;
  output reg [`INST_WIDTH-1:0] instruction_out1;

  initial begin
    alu_result_out0 <= 0;
    data_1_out0 <= 0;
    data_2_out0 <= 0;
    reg_dst_result_out0 <= 0;
    jop_out0 <= 0;
    mem_op_out0 <= 0;
    mem_to_reg_out0 <= 0;
    reg_write_out0 <= 0;
    address_out0 <= 0;
    address_src_result_out0 <= 0;
    instruction_out0 <= 0;

    alu_result_out1 <= 0;
    data_1_out1 <= 0;
    data_2_out1 <= 0;
    reg_dst_result_out1 <= 0;
    jop_out1 <= 0;
    mem_op_out1 <= 0;
    mem_to_reg_out1 <= 0;
    reg_write_out1 <= 0;
    address_out1 <= 0;
    address_src_result_out1 <= 0;
    instruction_out1 <= 0;
  end

  always @(posedge clk) begin

    if(flush) begin
      alu_result_out0 <= 0;
      data_1_out0 <= 0;
      data_2_out0 <= 0;
      reg_dst_result_out0 <= 0;
      jop_out0 <= 0;
      mem_op_out0 <= 0;
      mem_to_reg_out0 <= 0;
      reg_write_out0 <= 0;
      address_out0 <= 0;
      address_src_result_out0 <= 0;
      instruction_out0 <= 0;

      alu_result_out1 <= 0;
      data_1_out1 <= 0;
      data_2_out1 <= 0;
      reg_dst_result_out1 <= 0;
      jop_out1 <= 0;
      mem_op_out1 <= 0;
      mem_to_reg_out1 <= 0;
      reg_write_out1 <= 0;
      address_out1 <= 0;
      address_src_result_out1 <= 0;
      instruction_out1 <= 0;
    end else begin
      alu_result_out0 <= alu_result_in0;
      data_1_out0 <= data_1_in0;
      data_2_out0 <= data_2_in0;
      reg_dst_result_out0 <= reg_dst_result_in0;
      jop_out0 <= jop_in0;
      mem_op_out0 <= mem_op_in0;
      mem_to_reg_out0 <= mem_to_reg_in0;
      reg_write_out0 <= reg_write_in0;
      address_out0 <= address_in0;
      address_src_result_out0 <= address_src_result_in0;
      instruction_out0 <= instruction_in0;

      alu_result_out1 <= alu_result_in1;
      data_1_out1 <= data_1_in1;
      data_2_out1 <= data_2_in1;
      reg_dst_result_out1 <= reg_dst_result_in1;
      jop_out1 <= jop_in1;
      mem_op_out1 <= mem_op_in1;
      mem_to_reg_out1 <= mem_to_reg_in1;
      reg_write_out1 <= reg_write_in1;
      address_out1 <= address_in1;
      address_src_result_out1 <= address_src_result_in1;
      instruction_out1 <= instruction_in1;
    end
  
  end

endmodule

module mem_wb_register(
  clk,

  mem_to_reg_in,
  ram_read_data_in,
  alu_result_in,
  reg_dst_result_in,
  reg_write_in,
  instruction_in,

  mem_to_reg_out,
  ram_read_data_out,
  alu_result_out,
  reg_dst_result_out,
  reg_write_out,
  instruction_out,
  );

  input wire clk;

  input wire mem_to_reg_in;
  input wire [`DATA_WIDTH-1:0] ram_read_data_in;
  input wire [`DATA_WIDTH-1:0] alu_result_in;
  input wire [`NUM_REGISTERS_LOG2-1:0] reg_dst_result_in;
  input wire reg_write_in;
  input wire [`INST_WIDTH-1:0] instruction_in;

  output reg mem_to_reg_out;
  output reg [`DATA_WIDTH-1:0] ram_read_data_out;
  output reg [`DATA_WIDTH-1:0] alu_result_out;
  output reg [`NUM_REGISTERS_LOG2-1:0] reg_dst_result_out;
  output reg reg_write_out;
  output reg [`INST_WIDTH-1:0] instruction_out;

  initial begin
    mem_to_reg_out <= 0;
    ram_read_data_out <= 0;
    alu_result_out <= 0;
    reg_dst_result_out <= 0;
    reg_write_out <= 0;
    instruction_out <= 0;
  end

  always @(posedge clk) begin

    mem_to_reg_out <= mem_to_reg_in;
    ram_read_data_out <= ram_read_data_in;
    alu_result_out <= alu_result_in;
    reg_dst_result_out <= reg_dst_result_in;
    reg_write_out <= reg_write_in;
    instruction_out <= instruction_in;

  end

endmodule
