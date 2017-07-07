`timescale 1ns / 1ps

`include "defines.vh"

module program_counter(
  clk,
  reset, 

  opcode, // should we jump
  address, // where to

  stall,

  flush, // mispredict
  branch_address, // where we need to reset to

  take_branch, // should we take the branch predict 
  branch_predict, // the address to branch to

  hazard_flush0, // supposed to be new nop
  hazard_flush1, // supposed to be new nop

  nop, // not used.

  //////////////

  branch_taken, // did we take the branch
  branch_taken_address, // the address we took

  pc0,
  pc1,

  id0, // used for logging
  id1, // used for logging

  instruction0,
  instruction1,
  );

  input wire clk;
  input wire reset;

  input wire [`OP_CODE_BITS-1:0] opcode;
  input wire [`ADDR_WIDTH-1:0] address;

  input wire stall;

  input wire flush;
  input wire [`ADDR_WIDTH-1:0] branch_address;

  input wire take_branch;
  input wire [`ADDR_WIDTH-1:0] branch_predict;

  input wire hazard_flush0;
  input wire hazard_flush1;

  input wire nop;

  //////////////

  output reg branch_taken;
  output reg [`ADDR_WIDTH-1:0] branch_taken_address;

  output wire [`ADDR_WIDTH-1:0] pc0;
  output wire [`ADDR_WIDTH-1:0] pc1;

  output wire [`INSTRUCTION_ID_WIDTH-1:0] id0;
  output wire [`INSTRUCTION_ID_WIDTH-1:0] id1;

  output wire [`INST_WIDTH-1:0] instruction0;
  output wire [`INST_WIDTH-1:0] instruction1;

  //////////////

  reg [`ADDR_WIDTH-1:0] pc;
  reg [`INSTRUCTION_ID_WIDTH-1:0] cycle_count;

  wire [`INST_WIDTH-1:0] im_instruction0;
  wire [`INST_WIDTH-1:0] im_instruction1;

  wire [`NUM_BITS_PIPE_ID-1:0] tag0 = `PIPE_ID1; // this is unnecessary, but moving from steer
  wire [`NUM_BITS_PIPE_ID-1:0] tag1 = `PIPE_ID2; // this is unnecessary, but moving from steer

  assign pc0 = pc;
  assign pc1 = pc + 1;

  assign id0 = (cycle_count << `NUM_BITS_PIPE_ID) | tag0;
  assign id1 = (cycle_count << `NUM_BITS_PIPE_ID) | tag1;

  assign instruction0 = hazard_flush0 ? 0 : im_instruction0;
  assign instruction1 = hazard_flush1 ? 0 : im_instruction1;

  wire branch = ((opcode & 6'b110000) == 6'b110000) && (opcode != `OP_CODE_JMP);

  //////////////

  instruction_memory im(
  .pc(pc), 
  .instruction0(im_instruction0),
  .instruction1(im_instruction1)
  );

  initial begin
    pc = 0;
    cycle_count = 0;

    branch_taken = 0;
    branch_taken_address = 0;
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
