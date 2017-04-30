`timescale 1ns / 1ps

module if_id_register(
  clk,
  stall,

  instruction_in, 
  instruction_out
  );

  input wire clk;
  input wire stall;

  input wire [`INST_WIDTH-1:0] instruction_in;
  output reg [`INST_WIDTH-1:0] instruction_out;

  initial begin
    instruction_out <= 0;
  end

  always @(*) begin

    if(!stall) begin
      instruction_out <= instruction_in;
    end

  end

endmodule

module id_ex_register(
  clk,
  stall,
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
  address_src_in,

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
  bne_out,
  address_src_out
  );

  input wire clk;
  input wire flush;
  input wire stall;

  input wire [`NUM_REGISTERS_LOG2-1:0] rs_in;
  input wire [`NUM_REGISTERS_LOG2-1:0] rt_in;
  input wire [`NUM_REGISTERS_LOG2-1:0] rd_in;
  input wire [`DATA_WIDTH-1:0] reg_read_data_1_in;
  input wire [`DATA_WIDTH-1:0] reg_read_data_2_in;
  input wire [`IMM_WIDTH-1:0] immediate_in;
  input wire [`ADDR_WIDTH-1:0] address_in;
  input wire reg_dst_in;
  input wire mem_to_reg_in;
  input wire [`ALU_OP_BITS-1:0] alu_op_in;
  input wire [`MEM_OP_BITS-1:0] mem_op_in;
  input wire alu_src_in;
  input wire reg_write_in;
  input wire beq_in;
  input wire bne_in;
  input wire address_src_in;

  output reg [`NUM_REGISTERS_LOG2-1:0] rs_out;
  output reg [`NUM_REGISTERS_LOG2-1:0] rt_out;
  output reg [`NUM_REGISTERS_LOG2-1:0] rd_out;
  output reg [`DATA_WIDTH-1:0] reg_read_data_1_out;
  output reg [`DATA_WIDTH-1:0] reg_read_data_2_out;
  output reg [`IMM_WIDTH-1:0] immediate_out;
  output reg [`ADDR_WIDTH-1:0] address_out;
  output reg reg_dst_out;
  output reg mem_to_reg_out;
  output reg [`ALU_OP_BITS-1:0] alu_op_out;
  output reg [`MEM_OP_BITS-1:0] mem_op_out;
  output reg alu_src_out;
  output reg reg_write_out;
  output reg beq_out;
  output reg bne_out;
  output reg address_src_out;

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
    address_src_out <= 0;
  end

  always @(posedge clk) begin

    if(flush || stall) begin
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
      address_src_out <= 0;
    end else begin	
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
      address_src_out <= address_src_in;
    end

  end

endmodule

module ex_mem_register(
  clk,
  flush,

  alu_result_in,
  data_1_in,
  data_2_in,
  reg_dst_result_in,
  beq_in,
  bne_in,
  mem_op_in,
  mem_to_reg_in,
  reg_write_in,
  compare_in,
  address_in,
  address_src_in,

  alu_result_out,
  data_1_out,
  data_2_out,
  reg_dst_result_out,
  beq_out,
  bne_out,
  mem_op_out,
  mem_to_reg_out,
  reg_write_out,
  compare_out,
  address_out,
  address_src_out
  );

  input wire clk;
  input wire flush;

  input wire [`DATA_WIDTH-1:0] alu_result_in;
  input wire [`DATA_WIDTH-1:0] data_1_in;
  input wire [`DATA_WIDTH-1:0] data_2_in;
  input wire [`NUM_REGISTERS_LOG2-1:0] reg_dst_result_in;
  input wire beq_in;
  input wire bne_in;
  input wire [`MEM_OP_BITS-1:0] mem_op_in;
  input wire mem_to_reg_in;
  input wire reg_write_in;
  input wire compare_in;
  input wire [`ADDR_WIDTH-1:0] address_in;
  input wire address_src_in;

  output reg [`DATA_WIDTH-1:0] alu_result_out;
  output reg [`DATA_WIDTH-1:0] data_1_out;
  output reg [`DATA_WIDTH-1:0] data_2_out;
  output reg [`NUM_REGISTERS_LOG2-1:0] reg_dst_result_out;
  output reg beq_out;
  output reg bne_out;
  output reg [`MEM_OP_BITS-1:0] mem_op_out;
  output reg mem_to_reg_out;
  output reg reg_write_out;
  output reg compare_out;
  output reg [`ADDR_WIDTH-1:0] address_out;
  output reg address_src_out;

  initial begin
    alu_result_out <= 0;
    data_1_out <= 0;
    data_2_out <= 0;
    reg_dst_result_out <= 0;
    beq_out <= 0;
    bne_out <= 0;
    mem_op_out <= 0;
    mem_to_reg_out <= 0;
    reg_write_out <= 0;
    compare_out <= 0;
    address_out <= 0;
    address_src_out <= 0;
  end

  always @(posedge clk) begin

    if(flush) begin
      alu_result_out <= 0;
      data_1_out <= 0;
      data_2_out <= 0;
      reg_dst_result_out <= 0;
      beq_out <= 0;
      bne_out <= 0;
      mem_op_out <= 0;
      mem_to_reg_out <= 0;
      reg_write_out <= 0;
      compare_out <= 0;
      address_out <= 0;
      address_src_out <= 0;
    end else begin
      alu_result_out <= alu_result_in;
      data_1_out <= data_1_in;
      data_2_out <= data_2_in;
      reg_dst_result_out <= reg_dst_result_in;
      beq_out <= beq_in;
      bne_out <= bne_in;
      mem_op_out <= mem_op_in;
      mem_to_reg_out <= mem_to_reg_in;
      reg_write_out <= reg_write_in;
      compare_out <= compare_in;
      address_out <= address_in;
      address_src_out <= address_src_in;
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

  mem_to_reg_out,
  ram_read_data_out,
  alu_result_out,
  reg_dst_result_out,
  reg_write_out
  );

  input wire clk;

  input wire mem_to_reg_in;
  input wire [`DATA_WIDTH-1:0] ram_read_data_in;
  input wire [`DATA_WIDTH-1:0] alu_result_in;
  input wire [`NUM_REGISTERS_LOG2-1:0] reg_dst_result_in;
  input wire reg_write_in;

  output reg mem_to_reg_out;
  output reg [`DATA_WIDTH-1:0] ram_read_data_out;
  output reg [`DATA_WIDTH-1:0] alu_result_out;
  output reg [`NUM_REGISTERS_LOG2-1:0] reg_dst_result_out;
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
