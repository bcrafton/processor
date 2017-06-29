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

  take_branch,
  branch_predict,
  branch_taken,
  branch_taken_address,

  cycle_count
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

  input wire take_branch;
  input wire [`ADDR_WIDTH-1:0] branch_predict;

  output reg branch_taken;
  output reg [`ADDR_WIDTH-1:0] branch_taken_address;

  wire branch = ((opcode & 6'b110000) == 6'b110000) && (opcode != `OP_CODE_JMP);

  output reg [`INSTRUCTION_ID_WIDTH-1:0] cycle_count;

  initial begin
    pc = 0;
    branch_taken = 0;
    branch_taken_address = 0;
    cycle_count = 0;
  end

  always @(posedge clk) begin

    cycle_count = cycle_count + 1;

    if(flush) begin
      pc <= branch_address;
      branch_taken <= 0;
    end else if(!stall) begin
      if(reset) begin
        pc <= 0;
        branch_taken <= 0;
      end else if(opcode == `OP_CODE_JMP) begin // double jump/branch can happen. not steered yet.
        pc <= address;
        branch_taken <= 0;
      end else if (branch & take_branch) begin
        //$display("%x %x\n", branch_predict, address);
        pc <= branch_predict;
        branch_taken <= 1;
        branch_taken_address <= branch_predict;
      end else begin
        pc <= pc + 2;
        branch_taken <= 0;
      end
    end

  end

endmodule
