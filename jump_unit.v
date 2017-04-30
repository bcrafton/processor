`timescale 1ns / 1ps

`include "defines.vh"

module jump_unit(
  opcode,
  address,
  jump,
  jump_address
  );

  input wire  [`OP_CODE_BITS-1:0] opcode;
  input wire  [`ADDR_WIDTH-1:0]   address;
  output reg                      jump;
  output reg  [`ADDR_WIDTH-1:0]   jump_address;

  always @(*) begin

    if(opcode == `OP_CODE_JUMP) begin
      jump <= 1;
      jump_address <= address;
    end else begin
      jump <= 0;
      jump_address = 0;
    end

  end

endmodule
