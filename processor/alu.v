`timescale 1ns / 1ps

// this was causing issues, even though probably shouldnt be
// anyways, this parameter thing is actually better i think
// module level assings, versus processor level
// debatable which is better.
//`include "defines.vh"

module alu
  (
  alu_op,
  data1,
  data2,
  zero,
  less,
  greater, 
  alu_result,
  );

  input wire [`ALU_OP_BITS-1:0] alu_op;
  input wire [`DATA_WIDTH-1:0] data1;
  input wire [`DATA_WIDTH-1:0] data2;

  output reg zero;
  output reg less;
  output reg greater;

  output reg [`DATA_WIDTH-1:0] alu_result;

  initial begin
    zero <= 0;
    less <= 0;
    greater <= 0;
  end

  always @(*) begin

    case(alu_op)
      `ALU_OP_ADD: alu_result = data1 + data2; // ADD
      `ALU_OP_SUB: alu_result = data1 - data2; // SUB
      `ALU_OP_NOT: alu_result = ~data1; // NOT
      `ALU_OP_AND: alu_result = data1 & data2; // AND
      `ALU_OP_OR: alu_result = data1 | data2; // OR
      `ALU_OP_NAND: alu_result = ~(data1 & data2); // NAND
      `ALU_OP_NOR: alu_result = ~(data1 | data2); // NOR

      // both MOVI and MOV do the same thing. assign to data2
      `ALU_OP_MOV: alu_result = data2;

      `ALU_OP_SAR: alu_result = data1 >>> data2;
      `ALU_OP_SHR: alu_result = data1 >> data2;
      `ALU_OP_SHL: alu_result = data1 << data2;
      `ALU_OP_XOR: alu_result = data1 ^ data2;
      `ALU_OP_CMP: begin
          zero <= ((data1 - data2) == 0) ? 1'b1 : 1'b0;
          less <= (data1 < data2) ? 1'b1 : 1'b0;
          greater <= (data1 > data2) ? 1'b1 : 1'b0;
      end
      `ALU_OP_TEST: begin
          zero <= ((data1 & data2) == 0) ? 1'b1 : 1'b0;
          less <= (data1 < data2) ? 1'b1 : 1'b0;
          greater <= (data1 > data2) ? 1'b1 : 1'b0;
      end
      `ALU_OP_NOP: alu_result = `GARBAGE;
      default: alu_result = `GARBAGE;
    endcase


  end

endmodule
