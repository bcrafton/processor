`timescale 1ns / 1ps

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

  input wire [15:0] alu_result_in;
  input wire [15:0] data_1_in;
  input wire [15:0] data_2_in;
  input wire [2:0] reg_dst_result_in;
  input wire beq_in;
  input wire bne_in;
  input wire [1:0] mem_op_in;
  input wire mem_to_reg_in;
  input wire reg_write_in;
  input wire compare_in;
  input wire [15:0] address_in;
  input wire address_src_in;

  output reg [15:0] alu_result_out;
  output reg [15:0] data_1_out;
  output reg [15:0] data_2_out;
  output reg [2:0] reg_dst_result_out;
  output reg beq_out;
  output reg bne_out;
  output reg [1:0] mem_op_out;
  output reg mem_to_reg_out;
  output reg reg_write_out;
  output reg compare_out;
  output reg [15:0] address_out;
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
