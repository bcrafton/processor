`timescale 1ns / 1ps

`include "defines.vh"

/*
thinking about the stalling must be abstracted away

if something is at the output
it is going to flop

u can change the value inside if u flush but at the rising clock edge its value is the output
also ur using the value of the wire
and the wire only switches after a flop

so basically
if we read from the output of if id 
and we see our match
we shud stall if id and id ex
that will stall read nad thing after write

*/


module hazard_detection_unit(
  id_ex_mem_op,
  id_ex_rt, // the place we are loading to.

  first,

  if_id_opcode0,
  if_id_opcode1,

  if_id_rs0,
  if_id_rt0,
  if_id_rd0,

  if_id_rs1,
  if_id_rt1,
  if_id_rd1,

  stall,
  nop
  );

  input wire [`MEM_OP_BITS-1:0] id_ex_mem_op;
  input wire [`NUM_REGISTERS_LOG2-1:0] id_ex_rt;

  input wire first;

  input wire [`OP_CODE_BITS-1:0] if_id_opcode0;
  input wire [`OP_CODE_BITS-1:0] if_id_opcode1;

  input wire [`NUM_REGISTERS_LOG2-1:0] if_id_rs0;
  input wire [`NUM_REGISTERS_LOG2-1:0] if_id_rt0;
  input wire [`NUM_REGISTERS_LOG2-1:0] if_id_rd0;

  input wire [`NUM_REGISTERS_LOG2-1:0] if_id_rs1;
  input wire [`NUM_REGISTERS_LOG2-1:0] if_id_rt1;
  input wire [`NUM_REGISTERS_LOG2-1:0] if_id_rd1;

  output reg [`NUM_PIPE_MASKS-1:0] stall;
  output reg [`NUM_PIPE_MASKS-1:0] nop;

  reg [2:0] src_mask0;
  reg [2:0] dst_mask0;

  reg [2:0] src_mask1;
  reg [2:0] dst_mask1;

  always @(*) begin

    casex(if_id_opcode0)
     `OP_CODE_NOP: begin
        src_mask0 <= 0;
        dst_mask0 <= 0;
      end
      `OP_CODE_JR: begin
        src_mask0 <= 3'b100;
        dst_mask0 <= 0;
      end
      6'b00????: begin // add, sub...
        src_mask0 <= 3'b110;
        dst_mask0 <= 3'b001;
      end
      6'b01????: begin // addi, subi...
        src_mask0 <= 3'b100;
        dst_mask0 <= 3'b010;
      end
      6'b10????: begin // lw, sw, la, sa
        if(if_id_opcode0 == `OP_CODE_LW) begin
          src_mask0 <= 3'b100;
          dst_mask0 <= 3'b010;
        end else if(if_id_opcode0 == `OP_CODE_SW) begin
          src_mask0 <= 3'b110;
          dst_mask0 <= 0;
        end else if(if_id_opcode0 == `OP_CODE_LA) begin
          src_mask0 <= 0;
          dst_mask0 <= 3'b010;
        end else if(if_id_opcode0 == `OP_CODE_SA) begin
          src_mask0 <= 3'b010;
          dst_mask0 <= 0;
        end
      end
      6'b11????: begin // jmp, jo, je ...
        src_mask0 <= 0;
        dst_mask0 <= 0;
      end
    endcase

    casex(if_id_opcode1)
     `OP_CODE_NOP: begin
        src_mask1 <= 0;
        dst_mask1 <= 0;
      end
      `OP_CODE_JR: begin
        src_mask1 <= 3'b100;
        dst_mask1 <= 0;
      end
      6'b00????: begin // add, sub...
        src_mask1 <= 3'b110;
        dst_mask1 <= 3'b001;
      end
      6'b01????: begin // addi, subi...
        src_mask1 <= 3'b100;
        dst_mask1 <= 3'b010;
      end
      6'b10????: begin // lw, sw, la, sa
        if(if_id_opcode1 == `OP_CODE_LW) begin
          src_mask1 <= 3'b100;
          dst_mask1 <= 3'b010;
        end else if(if_id_opcode1 == `OP_CODE_SW) begin
          src_mask1 <= 3'b110;
          dst_mask1 <= 0;
        end else if(if_id_opcode1 == `OP_CODE_LA) begin
          src_mask1 <= 0;
          dst_mask1 <= 3'b010;
        end else if(if_id_opcode1 == `OP_CODE_SA) begin
          src_mask1 <= 3'b010;
          dst_mask1 <= 0;
        end
      end
      6'b11????: begin // jmp, jo, je ...
        src_mask1 <= 0;
        dst_mask1 <= 0;
      end
    endcase

    if((if_id_rs0 == id_ex_rt || if_id_rt0 == id_ex_rt) && (id_ex_mem_op == `MEM_OP_READ)) begin
      
      stall <= `PIPE_REG_PC | `PIPE_REG_IF_ID | `PIPE_REG_ID_EX;
      nop <= `PIPE_REG_ID_EX;

    end else begin

      if (first) begin

        casex( {src_mask0, dst_mask1} )
          {3'b1??, 3'b?1?}: begin
            if (if_id_rs0 == if_id_rt1 && first) begin
              stall <= `PIPE_REG_PC | `PIPE_REG_IF_ID | `PIPE_REG_ID_EX;
              nop <= `PIPE_REG_ID_EX;
            end
          end
          {3'b1??, 3'b??1}: begin
            if (if_id_rs0 == if_id_rd1 && first) begin
              stall <= `PIPE_REG_PC | `PIPE_REG_IF_ID | `PIPE_REG_ID_EX;
              nop <= `PIPE_REG_ID_EX;
            end
          end
          {3'b?1?, 3'b?1?}: begin
            if (if_id_rt0 == if_id_rt1 && first) begin
              stall <= `PIPE_REG_PC | `PIPE_REG_IF_ID | `PIPE_REG_ID_EX;
              nop <= `PIPE_REG_ID_EX;
            end
          end
          {3'b?1?, 3'b??1}: begin
            if (if_id_rt0 == if_id_rd1 && first) begin
              stall <= `PIPE_REG_PC | `PIPE_REG_IF_ID | `PIPE_REG_ID_EX;
              nop <= `PIPE_REG_ID_EX;
            end
          end
          default: begin
            stall <= 0;
            nop <= 0;
          end
        endcase

      end else begin

        casex( {src_mask1, dst_mask0} )
          {3'b1??, 3'b?1?}: begin
            if (if_id_rs1 == if_id_rt0 && !first) begin
              stall <= `PIPE_REG_PC | `PIPE_REG_IF_ID;
              nop <= `PIPE_REG_IF_ID;
            end
          end
          {3'b1??, 3'b??1}: begin
            if (if_id_rs1 == if_id_rd0 && !first) begin
              stall <= `PIPE_REG_PC | `PIPE_REG_IF_ID;
              nop <= `PIPE_REG_IF_ID;
            end
          end
          {3'b?1?, 3'b?1?}: begin
            if (if_id_rt1 == if_id_rt0 && !first) begin
              stall <= `PIPE_REG_PC | `PIPE_REG_IF_ID;
              nop <= `PIPE_REG_IF_ID;
            end
          end
          {3'b?1?, 3'b??1}: begin
            if (if_id_rt1 == if_id_rd0 && !first) begin
              stall <= `PIPE_REG_PC | `PIPE_REG_IF_ID;
              nop <= `PIPE_REG_IF_ID;
            end
          end
          default: begin
            stall <= 0;
            nop <= 0;
          end
        endcase

      end
    end
  end

endmodule
