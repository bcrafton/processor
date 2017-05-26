`timescale 1ns / 1ps

`include "defines.vh"

module hazard_detection_unit(
  id_ex_mem_op,
  id_ex_rt, // the place we are loading to.

  first,

  if_id_opcode0,
  if_id_opcode1,

  if_id_rs0,
  if_id_rt0,

  if_id_rs1,
  if_id_rt1,

  stall,
  nop
  );

  input wire [`MEM_OP_BITS-1:0] id_ex_mem_op;

  input wire [`OP_CODE_BITS-1:0] opcode0;
  input wire [`OP_CODE_BITS-1:0] opcode1;

  input wire [`NUM_REGISTERS_LOG2-1:0] if_id_rs0;
  input wire [`NUM_REGISTERS_LOG2-1:0] if_id_rt0;

  input wire [`NUM_REGISTERS_LOG2-1:0] if_id_rs1;
  input wire [`NUM_REGISTERS_LOG2-1:0] if_id_rt1;

  input wire [`NUM_REGISTERS_LOG2-1:0] id_ex_rt;

  output reg [`NUM_PIPE_MASKS-1:0] stall;
  output reg [`NUM_PIPE_MASKS-1:0] nop;

  wire write_after_read0;
  wire write_after_read1;

  assign write_after_read0 = !first && opcode0 = 

  // this is combinational logic
  always@(*) begin

    if((if_id_rs0 == id_ex_rt || if_id_rt0 == id_ex_rt) && (id_ex_mem_op == `MEM_OP_READ)) begin
      stall <= `PIPE_REG_PC | `PIPE_REG_IF_ID | `PIPE_REG_ID_EX;
      nop <= `PIPE_REG_ID_EX;
    end else if ()
    end else begin
      stall <= 0;
      nop <= 0;
    end

  end

endmodule
