`timescale 1ns / 1ps

`include "defines.vh"

module program_counter(
  clk,
  if_id_opcode,
  if_id_address,
  branch_address,
  pc,
  stall,
  flush
  );

  input wire clk;

  input wire [`OP_CODE_BITS-1:0] if_id_opcode;
  input wire [`ADDR_WIDTH-1:0] if_id_address;

  input wire [`ADDR_WIDTH-1:0] branch_address; // instruction memory address

  output reg [`ADDR_WIDTH-1:0] pc; // instruction memory address

  input wire flush;
  input wire stall;
  
  wire jump;
  assign jump = if_id_opcode == `OP_CODE_JUMP;

  initial begin
    pc = 0;
  end

  always @(posedge clk) begin

    if(!stall) begin
      if(flush) begin
        pc <= branch_address;
      end else if(jump) begin
        pc <= if_id_address;
      end else begin
        pc <= pc + 1'b1;
      end
    end

  end

endmodule
