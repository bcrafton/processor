`timescale 1ns / 1ps

`include "defines.vh"

module hazard_detection_unit(
  id_ex_mem_op,
  id_ex_rt,

  first,

  if_id_opcode0,
  if_id_opcode1,

  if_id_rs0,
  if_id_rt0,
  if_id_rd0,

  if_id_rs1,
  if_id_rt1,
  if_id_rd1,

  stall0,
  nop0,

  stall1,
  nop1,

  flush0,
  flush1
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

  output reg [`NUM_PIPE_MASKS-1:0] stall0;
  output reg [`NUM_PIPE_MASKS-1:0] nop0;

  output reg [`NUM_PIPE_MASKS-1:0] stall1;
  output reg [`NUM_PIPE_MASKS-1:0] nop1;

  output reg [`NUM_PIPE_MASKS-1:0] flush0;
  output reg [`NUM_PIPE_MASKS-1:0] flush1;

  reg [`NUM_REG_MASKS-1:0] src_mask0;
  reg [`NUM_REG_MASKS-1:0] dst_mask0;

  reg [`NUM_REG_MASKS-1:0] src_mask1;
  reg [`NUM_REG_MASKS-1:0] dst_mask1;

  initial begin
    stall0 <= 0;
    nop0 <= 0;
    stall1 <= 0;
    nop1 <= 0;
    flush0 <= 0;
    flush1 <= 0;
  end

  always @(*) begin

    casex(if_id_opcode0)
     `OP_CODE_NOP: begin
        src_mask0 <= 0;
        dst_mask0 <= 0;
      end
      `OP_CODE_JR: begin
        src_mask0 <= `REG_MASK_RS;
        dst_mask0 <= 0;
      end
      6'b00????: begin // add, sub...
        src_mask0 <= `REG_MASK_RS | `REG_MASK_RT;
        dst_mask0 <= `REG_MASK_RD;
      end
      6'b01????: begin // addi, subi...
        src_mask0 <= `REG_MASK_RS;
        dst_mask0 <= `REG_MASK_RT;
      end
      6'b10????: begin // lw, sw, la, sa
        if(if_id_opcode0 == `OP_CODE_LW) begin
          src_mask0 <= `REG_MASK_RS;
          dst_mask0 <= `REG_MASK_RT;
        end else if(if_id_opcode0 == `OP_CODE_SW) begin
          src_mask0 <= `REG_MASK_RS | `REG_MASK_RT;
          dst_mask0 <= 0;
        end else if(if_id_opcode0 == `OP_CODE_LA) begin
          src_mask0 <= 0;
          dst_mask0 <= `REG_MASK_RT;
        end else if(if_id_opcode0 == `OP_CODE_SA) begin
          src_mask0 <= `REG_MASK_RT;
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
        src_mask1 <= `REG_MASK_RS;
        dst_mask1 <= 0;
      end
      6'b00????: begin // add, sub...
        src_mask1 <= `REG_MASK_RS | `REG_MASK_RT;
        dst_mask1 <= `REG_MASK_RD;
      end
      6'b01????: begin // addi, subi...
        src_mask1 <= `REG_MASK_RS;
        dst_mask1 <= `REG_MASK_RT;
      end
      6'b10????: begin // lw, sw, la, sa
        if(if_id_opcode1 == `OP_CODE_LW) begin
          src_mask1 <= `REG_MASK_RS;
          dst_mask1 <= `REG_MASK_RT;
        end else if(if_id_opcode1 == `OP_CODE_SW) begin
          src_mask1 <= `REG_MASK_RS | `REG_MASK_RT;
          dst_mask1 <= 0;
        end else if(if_id_opcode1 == `OP_CODE_LA) begin
          src_mask1 <= 0;
          dst_mask1 <= `REG_MASK_RT;
        end else if(if_id_opcode1 == `OP_CODE_SA) begin
          src_mask1 <= `REG_MASK_RT;
          dst_mask1 <= 0;
        end
      end
      6'b11????: begin // jmp, jo, je ...
        src_mask1 <= 0;
        dst_mask1 <= 0;
      end
    endcase

    if((if_id_rs0 == id_ex_rt || if_id_rt0 == id_ex_rt) && (id_ex_mem_op == `MEM_OP_READ)) begin
      
      stall0 <= `PIPE_REG_PC | `PIPE_REG_IF_ID;
      flush0 <= `PIPE_REG_ID_EX;

      stall1 <= `PIPE_REG_PC | `PIPE_REG_IF_ID;
      flush1 <= `PIPE_REG_ID_EX;

    end else if((if_id_rs1 == id_ex_rt || if_id_rt1 == id_ex_rt) && (id_ex_mem_op == `MEM_OP_READ)) begin
      
      stall0 <= `PIPE_REG_PC | `PIPE_REG_IF_ID;
      flush0 <= `PIPE_REG_ID_EX;

      stall1 <= `PIPE_REG_PC | `PIPE_REG_IF_ID;
      flush1 <= `PIPE_REG_ID_EX;

    end else begin

      if (first) begin

        casex( {src_mask0, dst_mask1} )

          {`REG_MASK_RS | `REG_MASK_RT, `REG_MASK_RT}: begin
            if (if_id_rs0 == if_id_rt1 || if_id_rt0 == if_id_rt1) begin
              stall0 <= `PIPE_REG_PC | `PIPE_REG_IF_ID;
              flush0 <= `PIPE_REG_ID_EX;

              stall1 <= `PIPE_REG_PC;
              flush1 <= `PIPE_REG_IF_ID;
            end else begin
              stall0 <= 0;
              flush0 <= 0;

              stall1 <= 0;
              flush1 <= 0;
            end
          end
          {`REG_MASK_RS | `REG_MASK_RT, `REG_MASK_RD}: begin
            if (if_id_rs0 == if_id_rd1 || if_id_rt0 == if_id_rd1) begin
              stall0 <= `PIPE_REG_PC | `PIPE_REG_IF_ID;
              flush0 <= `PIPE_REG_ID_EX;

              stall1 <= `PIPE_REG_PC;
              flush1 <= `PIPE_REG_IF_ID;
            end else begin
              stall0 <= 0;
              flush0 <= 0;

              stall1 <= 0;
              flush1 <= 0;
            end
          end

          {`REG_MASK_RS, `REG_MASK_RT}: begin
            if (if_id_rs0 == if_id_rt1) begin
              stall0 <= `PIPE_REG_PC | `PIPE_REG_IF_ID;
              flush0 <= `PIPE_REG_ID_EX;

              stall1 <= `PIPE_REG_PC;
              flush1 <= `PIPE_REG_IF_ID;
            end else begin
              stall0 <= 0;
              flush0 <= 0;

              stall1 <= 0;
              flush1 <= 0;
            end
          end
          {`REG_MASK_RS, `REG_MASK_RD}: begin
            if (if_id_rs0 == if_id_rd1) begin
              stall0 <= `PIPE_REG_PC | `PIPE_REG_IF_ID;
              flush0 <= `PIPE_REG_ID_EX;

              stall1 <= `PIPE_REG_PC;
              flush1 <= `PIPE_REG_IF_ID;
            end else begin
              stall0 <= 0;
              flush0 <= 0;

              stall1 <= 0;
              flush1 <= 0;
            end
          end
          {`REG_MASK_RT, `REG_MASK_RT}: begin
            if (if_id_rt0 == if_id_rt1) begin
              stall0 <= `PIPE_REG_PC | `PIPE_REG_IF_ID;
              flush0 <= `PIPE_REG_ID_EX;

              stall1 <= `PIPE_REG_PC;
              flush1 <= `PIPE_REG_IF_ID;
            end else begin
              stall0 <= 0;
              flush0 <= 0;

              stall1 <= 0;
              flush1 <= 0;
            end
          end
          {`REG_MASK_RT, `REG_MASK_RD}: begin
            if (if_id_rt0 == if_id_rd1) begin
              stall0 <= `PIPE_REG_PC | `PIPE_REG_IF_ID;
              flush0 <= `PIPE_REG_ID_EX;

              stall1 <= `PIPE_REG_PC;
              flush1 <= `PIPE_REG_IF_ID;
            end else begin
              stall0 <= 0;
              flush0 <= 0;

              stall1 <= 0;
              flush1 <= 0;
            end
          end
          default: begin
            stall0 <= 0;
            flush0 <= 0;

            stall1 <= 0;
            flush1 <= 0;
          end
        endcase

      end else begin

        casex( {src_mask1, dst_mask0} )

          {`REG_MASK_RS | `REG_MASK_RT, `REG_MASK_RT}: begin
            if (if_id_rs1 == if_id_rt0 || if_id_rt1 == if_id_rt0) begin
              stall1 <= `PIPE_REG_PC | `PIPE_REG_IF_ID;
              flush1 <= `PIPE_REG_ID_EX;

              stall0 <= `PIPE_REG_PC;
              flush0 <= `PIPE_REG_IF_ID;
            end else begin
              stall0 <= 0;
              flush0 <= 0;

              stall1 <= 0;
              flush1 <= 0;
            end
          end
          {`REG_MASK_RS | `REG_MASK_RT, `REG_MASK_RD}: begin
            if (if_id_rs1 == if_id_rd0 || if_id_rt1 == if_id_rd0) begin
              stall1 <= `PIPE_REG_PC | `PIPE_REG_IF_ID;
              flush1 <= `PIPE_REG_ID_EX;

              stall0 <= `PIPE_REG_PC;
              flush0 <= `PIPE_REG_IF_ID;
            end else begin
              stall0 <= 0;
              flush0 <= 0;

              stall1 <= 0;
              flush1 <= 0;
            end
          end

          {`REG_MASK_RS, `REG_MASK_RT}: begin
            if (if_id_rs1 == if_id_rt0) begin
              stall1 <= `PIPE_REG_PC | `PIPE_REG_IF_ID;
              flush1 <= `PIPE_REG_ID_EX;

              stall0 <= `PIPE_REG_PC;
              flush0 <= `PIPE_REG_IF_ID;
            end else begin
              stall0 <= 0;
              flush0 <= 0;

              stall1 <= 0;
              flush1 <= 0;
            end
          end
          {`REG_MASK_RS, `REG_MASK_RD}: begin
            if (if_id_rs1 == if_id_rd0) begin
              stall1 <= `PIPE_REG_PC | `PIPE_REG_IF_ID;
              flush1 <= `PIPE_REG_ID_EX;

              stall0 <= `PIPE_REG_PC;
              flush0 <= `PIPE_REG_IF_ID;
            end else begin
              stall0 <= 0;
              flush0 <= 0;

              stall1 <= 0;
              flush1 <= 0;
            end
          end
          {`REG_MASK_RT, `REG_MASK_RT}: begin
            if (if_id_rt1 == if_id_rt0) begin
              stall1 <= `PIPE_REG_PC | `PIPE_REG_IF_ID;
              flush1 <= `PIPE_REG_ID_EX;

              stall0 <= `PIPE_REG_PC;
              flush0 <= `PIPE_REG_IF_ID;
            end else begin
              stall0 <= 0;
              flush0 <= 0;

              stall1 <= 0;
              flush1 <= 0;
            end
          end
          {`REG_MASK_RT, `REG_MASK_RD}: begin
            if (if_id_rt1 == if_id_rd0) begin
              stall1 <= `PIPE_REG_PC | `PIPE_REG_IF_ID;
              flush1 <= `PIPE_REG_ID_EX;

              stall0 <= `PIPE_REG_PC;
              flush0 <= `PIPE_REG_IF_ID;
            end else begin
              stall0 <= 0;
              flush0 <= 0;

              stall1 <= 0;
              flush1 <= 0;
            end
          end
          default: begin
            stall0 <= 0;
            flush0 <= 0;

            stall1 <= 0;
            flush1 <= 0;
          end
        endcase

      end
    end
  end

endmodule
