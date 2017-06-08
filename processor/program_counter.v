`timescale 1ns / 1ps

`include "defines.vh"

module program_counter(
  clk,
  reset, 
  opcode,
  address,
  branch_address,
  pc,
  stall,
  flush,
  nop,
  );

  input wire clk;
  input wire reset;

  input wire [`OP_CODE_BITS-1:0] opcode;
  input wire [`ADDR_WIDTH-1:0] address;

  input wire [`ADDR_WIDTH-1:0] branch_address; // instruction memory address

  output reg [`ADDR_WIDTH-1:0] pc; // instruction memory address

  input wire flush;
  input wire stall;
  input wire nop;

  wire branch = ((opcode & 6'b110000) == 6'b110000) && (opcode != OP_CODE_JMP);

  initial begin
    pc = 0;
  end

  always @(posedge clk) begin

    if(flush) begin
      pc <= branch_address;
    end else if(!stall) begin
      if(reset) begin
        pc <= 0;
      end else if(opcode == `OP_CODE_JMP) begin // double jump/branch can happen. not steered yet.
        pc <= address;
      end else begin
        pc <= pc + 2;
      end
    end

  end

endmodule
