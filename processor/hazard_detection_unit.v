`timescale 1ns / 1ps

`include "defines.vh"

module hazard_detection_unit(

  load_instruction,
  mem_op,
  instruction0,
  instruction1,
  first,

/*
  id_ex_mem_op,
  id_ex_rt,

  if_id_opcode0,
  if_id_opcode1,

  if_id_rs0,
  if_id_rt0,
  if_id_rd0,

  if_id_rs1,
  if_id_rt1,
  if_id_rd1,
*/

  stall0,
  nop0,

  stall1,
  nop1,

  flush0,
  flush1
  );

  input wire [`INST_WIDTH-1:0] load_instruction;
  input wire [`MEM_OP_BITS-1:0] mem_op;
  input wire [`INST_WIDTH-1:0] instruction0;
  input wire [`INST_WIDTH-1:0] instruction1;
  input wire first;

/*
  input wire [`MEM_OP_BITS-1:0] id_ex_mem_op;
  input wire [`NUM_REGISTERS_LOG2-1:0] id_ex_rt;

  input wire [`OP_CODE_BITS-1:0] if_id_opcode0;
  input wire [`OP_CODE_BITS-1:0] if_id_opcode1;

  input wire [`NUM_REGISTERS_LOG2-1:0] if_id_rs0;
  input wire [`NUM_REGISTERS_LOG2-1:0] if_id_rt0;
  input wire [`NUM_REGISTERS_LOG2-1:0] if_id_rd0;

  input wire [`NUM_REGISTERS_LOG2-1:0] if_id_rs1;
  input wire [`NUM_REGISTERS_LOG2-1:0] if_id_rt1;
  input wire [`NUM_REGISTERS_LOG2-1:0] if_id_rd1;
*/

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

  wire [`OP_CODE_BITS-1:0] opcode0;
  wire [`NUM_REGISTERS_LOG2-1:0] rs0;
  wire [`NUM_REGISTERS_LOG2-1:0] rt0;
  wire [`NUM_REGISTERS_LOG2-1:0] rd0;

  wire [`OP_CODE_BITS-1:0] opcode1;
  wire [`NUM_REGISTERS_LOG2-1:0] rs1;
  wire [`NUM_REGISTERS_LOG2-1:0] rt1;
  wire [`NUM_REGISTERS_LOG2-1:0] rd1;

  wire [`NUM_REGISTERS_LOG2-1:0] load_rt;

  assign opcode0 = instruction0[`OPCODE_MSB:`OPCODE_LSB];
  assign rs0 =     instruction0[`REG_RS_MSB:`REG_RS_LSB];
  assign rt0 =     instruction0[`REG_RT_MSB:`REG_RT_LSB];
  assign rd0 =     instruction0[`REG_RD_MSB:`REG_RD_LSB];

  assign opcode1 = instruction1[`OPCODE_MSB:`OPCODE_LSB];
  assign rs1 =     instruction1[`REG_RS_MSB:`REG_RS_LSB];
  assign rt1 =     instruction1[`REG_RT_MSB:`REG_RT_LSB];
  assign rd1 =     instruction1[`REG_RD_MSB:`REG_RD_LSB];

  assign load_rt = load_instruction[`REG_RT_MSB:`REG_RT_LSB];

  initial begin
    stall0 <= 0;
    nop0 <= 0;
    stall1 <= 0;
    nop1 <= 0;
    flush0 <= 0;
    flush1 <= 0;
  end

/*
  always @(*) begin
    if (load_stall) begin
    end else if (split_stall) begin
    end else if (steer_stall) begin
    end
  end
*/

  always @(*) begin

    casex(opcode0)
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
        if(opcode0 == `OP_CODE_LW) begin
          src_mask0 <= `REG_MASK_RS;
          dst_mask0 <= `REG_MASK_RT;
        end else if(opcode0 == `OP_CODE_SW) begin
          src_mask0 <= `REG_MASK_RS | `REG_MASK_RT;
          dst_mask0 <= 0;
        end else if(opcode0 == `OP_CODE_LA) begin
          src_mask0 <= 0;
          dst_mask0 <= `REG_MASK_RT;
        end else if(opcode0 == `OP_CODE_SA) begin
          src_mask0 <= `REG_MASK_RT;
          dst_mask0 <= 0;
        end
      end
      6'b11????: begin // jmp, jo, je ...
        src_mask0 <= 0;
        dst_mask0 <= 0;
      end
    endcase

    casex(opcode1)
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
        if(opcode1 == `OP_CODE_LW) begin
          src_mask1 <= `REG_MASK_RS;
          dst_mask1 <= `REG_MASK_RT;
        end else if(opcode1 == `OP_CODE_SW) begin
          src_mask1 <= `REG_MASK_RS | `REG_MASK_RT;
          dst_mask1 <= 0;
        end else if(opcode1 == `OP_CODE_LA) begin
          src_mask1 <= 0;
          dst_mask1 <= `REG_MASK_RT;
        end else if(opcode1 == `OP_CODE_SA) begin
          src_mask1 <= `REG_MASK_RT;
          dst_mask1 <= 0;
        end
      end
      6'b11????: begin // jmp, jo, je ...
        src_mask1 <= 0;
        dst_mask1 <= 0;
      end
    endcase

    // lol we stall even if we are not dependent.
    // dont even care what instruction it is...
    // thats bad.

    // well that needs to be fixed.
    if((rs0 == load_rt || rt0 == load_rt) && (mem_op == `MEM_OP_READ)) begin
      
      stall0 <= `PIPE_REG_PC | `PIPE_REG_IF_ID;
      flush0 <= `PIPE_REG_ID_EX;

      stall1 <= `PIPE_REG_PC | `PIPE_REG_IF_ID;
      flush1 <= `PIPE_REG_ID_EX;

    end else if((rs1 == load_rt || rt1 == load_rt) && (mem_op == `MEM_OP_READ)) begin
      
      stall0 <= `PIPE_REG_PC | `PIPE_REG_IF_ID;
      flush0 <= `PIPE_REG_ID_EX;

      stall1 <= `PIPE_REG_PC | `PIPE_REG_IF_ID;
      flush1 <= `PIPE_REG_ID_EX;

    end else begin

      if (first) begin

        casex( {src_mask0, dst_mask1} )

          {`REG_MASK_RS | `REG_MASK_RT, `REG_MASK_RT}: begin
            if (rs0 == rt1 || rt0 == rt1) begin
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
            if (rs0 == rd1 || rt0 == rd1) begin
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
            if (rs0 == rt1) begin
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
            if (rs0 == rd1) begin
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
            if (rt0 == rt1) begin
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
            if (rt0 == rd1) begin
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
            if (rs1 == rt0 || rt1 == rt0) begin
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
            if (rs1 == rd0 || rt1 == rd0) begin
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
            if (rs1 == rt0) begin
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
            if (rs1 == rd0) begin
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
            if (rt1 == rt0) begin
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
            if (rt1 == rd0) begin
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
