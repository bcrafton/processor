`timescale 1ns / 1ps

`include "defines.vh"

module program_counter(
  clk,
  reset, 
  prev_opcode0,
  prev_address0,
  prev_opcode1,
  prev_address1,
  branch_address,
  pc,
  stall,
  flush,
  nop,
  );

  input wire clk;
  input wire reset;

  input wire [`OP_CODE_BITS-1:0] prev_opcode0;
  input wire [`ADDR_WIDTH-1:0] prev_address0;

  input wire [`OP_CODE_BITS-1:0] prev_opcode1;
  input wire [`ADDR_WIDTH-1:0] prev_address1;

  input wire [`ADDR_WIDTH-1:0] branch_address; // instruction memory address

  output reg [`ADDR_WIDTH-1:0] pc; // instruction memory address

  input wire flush;
  input wire stall;
  input wire nop;
  
  wire jump;
  assign jump = prev_opcode == `OP_CODE_JMP;

  initial begin
    pc = 0;
  end

  always @(posedge clk) begin

    if(!stall) begin
      if(reset) begin
        pc <= 0;
      end else if(flush) begin
        pc <= branch_address;
      end else if(prev_opcode0 == `OP_CODE_JMP) begin
        pc <= prev_address0;
      end else if(prev_opcode1 == `OP_CODE_JMP) begin
        pc <= prev_address1;
      end else begin
        pc <= pc + 1;
      end
    end

  end

endmodule
