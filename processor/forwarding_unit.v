`timescale 1ns / 1ps

`include "defines.vh"

// parameterize register value size?
// this feels like something that should be defined at processor level ...
module forwarding_unit(
  id_ex_rs,
  id_ex_rt,
  ex_mem_rd,
  mem_wb_rd,
  ex_mem_reg_write,
  mem_wb_reg_write,
  forward_a,
  forward_b
  );

  //parameter NUM_REGISTERS_LOG2 = $clog2(`NUM_REGISTERS);

  input wire [`NUM_REGISTERS_LOG2-1:0] id_ex_rs;
  input wire [`NUM_REGISTERS_LOG2-1:0] id_ex_rt;
  input wire [`NUM_REGISTERS_LOG2-1:0] ex_mem_rd;
  input wire [`NUM_REGISTERS_LOG2-1:0] mem_wb_rd;
  input wire ex_mem_reg_write;
  input wire mem_wb_reg_write;

  // know these have to do with stage we are forwarding to.
  output reg [`FORWARD_BITS-1:0] forward_a;
  output reg [`FORWARD_BITS-1:0] forward_b;

  always @(*) begin

    if(ex_mem_reg_write && (id_ex_rs == ex_mem_rd)) begin
      forward_a <= `FORWARD_EX_MEM;
    end else if(mem_wb_reg_write && (id_ex_rs == mem_wb_rd)) begin
      forward_a <= `FORWARD_MEM_WB;
    end else begin
      forward_a <= `NO_FORWARD;
    end

    if(ex_mem_reg_write && (id_ex_rt == ex_mem_rd)) begin
      forward_b <= `FORWARD_EX_MEM;
    end else if(mem_wb_reg_write && (id_ex_rt == mem_wb_rd)) begin
      forward_b <= `FORWARD_MEM_WB;
    end else begin
      forward_b <= `NO_FORWARD;
    end

  end
endmodule
