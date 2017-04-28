`timescale 1ns / 1ps

// this was causing issues, even though probably shouldnt be
// anyways, this parameter thing is actually better i think
// module level assings, versus processor level
// debatable which is better.
//`include "defines.vh"

module alu
  (
  clk,
  alu_op,
  data1,
  data2,
  compare,
  alu_result
  );

  input wire clk;
  input wire [`ALU_OP_BITS-1:0] alu_op;
  input wire [`DATA_WIDTH-1:0] data1;
  input wire [`DATA_WIDTH-1:0] data2;
  output reg compare;
  output reg [`DATA_WIDTH-1:0] alu_result;

  always @(*) begin

    case(alu_op)
      0: alu_result = data1 + data2; // ADD
      1: alu_result = data1 - data2; // SUB
      2: alu_result = !data1; // NOT
      3: alu_result = data1 & data2; // AND
      4: alu_result = data1 | data2; // OR
      5: alu_result = ~(data1 & data2); // NAND
      6: alu_result = ~(data1 | data2); // NOR
      7: alu_result = data1;
      8: alu_result = data2;
    endcase

    if (data1 == data2) begin
      compare = 1'b1;
    end else begin
      compare = 1'b0;
    end

  end

endmodule
