`timescale 1ns / 1ps

`include "defines.vh"

module program_counter(
  clk,
  reset, 
  opcode0,
  address0,
  opcode1,
  address1,
  branch_address,
  pc,
  stall,
  flush,
  nop,
  );

  input wire clk;
  input wire reset;

  input wire [`OP_CODE_BITS-1:0] opcode0;
  input wire [`ADDR_WIDTH-1:0] address0;

  input wire [`OP_CODE_BITS-1:0] opcode1;
  input wire [`ADDR_WIDTH-1:0] address1;

  input wire [`ADDR_WIDTH-1:0] branch_address; // instruction memory address

  output reg [`ADDR_WIDTH-1:0] pc; // instruction memory address

  input wire flush;
  input wire stall;
  input wire nop;

  initial begin
    pc = 0;
  end

  always @(posedge clk) begin

    if(flush) begin
      pc <= branch_address;
    end else if(!stall) begin
      if(reset) begin
        pc <= 0;
      end else if(opcode1 == `OP_CODE_JMP) begin
        pc <= address1;
      end else if(opcode0 == `OP_CODE_JMP) begin
        pc <= address0;
      end else begin
        pc <= pc + 2;
      end
    end

  end

endmodule
