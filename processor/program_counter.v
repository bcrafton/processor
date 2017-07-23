`timescale 1ns / 1ps

`include "defines.vh"

module program_counter(
  clk,
  reset, 
  free,

  stall,

  flush, // mispredict
  branch_address, // where we need to reset to

  take_branch, // should we take the branch predict 
  branch_predict, // the address to branch to

  //////////////

  branch_taken0, // did we take the branch
  branch_taken_address0, // the address we took

  branch_taken1, // did we take the branch
  branch_taken_address1, // the address we took

  pc0,
  pc1,
  blt_pc,

  id0, // used for logging
  id1, // used for logging

  instruction0,
  instruction1,

  push0,
  push1
  );

  input wire clk;
  input wire reset;
  input wire [3:0] free;

  input wire stall;

  input wire flush;
  input wire [`ADDR_WIDTH-1:0] branch_address;

  input wire take_branch;
  input wire [`ADDR_WIDTH-1:0] branch_predict;

  //////////////

  output wire [`ADDR_WIDTH-1:0] pc0;
  output wire [`ADDR_WIDTH-1:0] pc1;
  output wire [`ADDR_WIDTH-1:0] blt_pc;
  reg         [`ADDR_WIDTH-1:0] next_pc;

  output wire [`INSTRUCTION_ID_WIDTH-1:0] id0;
  output wire [`INSTRUCTION_ID_WIDTH-1:0] id1;

  output reg branch_taken0;
  output reg [`ADDR_WIDTH-1:0] branch_taken_address0;
  output wire [`INST_WIDTH-1:0] instruction0;

  output reg branch_taken1;
  output reg [`ADDR_WIDTH-1:0] branch_taken_address1;
  output wire [`INST_WIDTH-1:0] instruction1;

  output wire push0;
  output wire push1;

  //////////////

  reg [`ADDR_WIDTH-1:0] pc;
  reg [`INSTRUCTION_ID_WIDTH-1:0] instruction_counter;

  wire [`OP_CODE_BITS-1:0] opcode0 = instruction0[`OPCODE_MSB:`OPCODE_LSB];
  wire [`ADDR_WIDTH-1:0] address0 = instruction0[`IMM_MSB:`IMM_LSB];

  wire [`OP_CODE_BITS-1:0] opcode1 = instruction1[`OPCODE_MSB:`OPCODE_LSB];
  wire [`ADDR_WIDTH-1:0] address1 = instruction1[`IMM_MSB:`IMM_LSB];

  assign pc0 = pc;
  assign pc1 = pc + 1;
  assign blt_pc = branch0 ? pc0 : pc1;

  assign id0 = instruction_counter;
  assign id1 = instruction_counter + 1;

  // we get log diffs if we dont issue the jump
  //assign push0 = !jump0; 
  //assign push1 = !jump0 && !branch_taken0 && !jump1;
  assign push0 = (instruction0 != `NOP_INSTRUCTION) ? 1                          : 0;
  assign push1 = (instruction1 != `NOP_INSTRUCTION) ? (!jump0 && !branch_taken0) : 0;

  wire branch0 = ((opcode0 & 6'b110000) == 6'b110000) && (opcode0 != `OP_CODE_JMP);
  wire branch1 = ((opcode1 & 6'b110000) == 6'b110000) && (opcode1 != `OP_CODE_JMP);

  wire jump0 = opcode0 == `OP_CODE_JMP;
  wire jump1 = opcode1 == `OP_CODE_JMP;

  //////////////

  instruction_memory im(
  .pc(pc), 
  .instruction0(instruction0),
  .instruction1(instruction1)
  );

  initial begin
    pc = 0;
    instruction_counter = 1; // needs to be one because everything else in pipeline to start =0.

    branch_taken0 = 0;
    branch_taken_address0 = 0;

    branch_taken1 = 0;
    branch_taken_address1 = 0;

    next_pc = 0;
  end

/*
  always @(*) begin
  
    if (branch0 & take_branch) begin

      branch_taken0 <= 1;
      branch_taken1 <= 0;
      branch_taken_address0 <= branch_predict;

    end else if (branch1 & take_branch && free >= 2) begin

      branch_taken0 <= 0;
      branch_taken1 <= 1;
      branch_taken_address1 <= branch_predict;

    end else begin

      branch_taken0 <= 0;
      branch_taken1 <= 0;

    end

  end
*/

  always @(posedge clk) begin
    if(flush) begin
      instruction_counter = instruction_counter + 2;
      pc <= next_pc;
    end else if(!stall) begin
      instruction_counter = instruction_counter + 2;
      pc <= next_pc;
    end
  end

  always @(*) begin

    if(reset) begin
      next_pc = 0;
      branch_taken0 = 0;
      branch_taken1 = 0;

    end else if(flush) begin
      next_pc = branch_address;
      branch_taken0 = 0;
      branch_taken1 = 0;

    // before there was a "if !stall" here.

    end else if(opcode0 == `OP_CODE_JMP) begin
      next_pc = address0;
      branch_taken0 = 0;
      branch_taken1 = 0;

    end else if (branch0 & take_branch) begin
      next_pc = branch_predict;
      branch_taken_address0 = branch_predict;

      branch_taken0 = 1;
      branch_taken1 = 0;

    //////////////////////////////////////////

    end else if(opcode1 == `OP_CODE_JMP && free >= 2) begin
      next_pc = address1;
      branch_taken0 = 0;
      branch_taken1 = 0;

    end else if (branch1 & take_branch && free >= 2) begin
      next_pc = branch_predict;
      branch_taken_address1 = branch_predict;

      branch_taken0 = 0;
      branch_taken1 = 1;

    end else begin
      if (free == 1) begin
        next_pc = pc + 1;
      end else begin
        next_pc = pc + 2;
      end
      branch_taken0 = 0;
      branch_taken1 = 0;
    end


  end

endmodule
