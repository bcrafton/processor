`timescale 1ns / 1ps

module program_counter(
  clk,
  branch_address,
  jump_address,
  pc,
  stall,
  flush,
  jump
  );

  input wire clk;
  input wire [`ADDR_WIDTH-1:0] branch_address; // instruction memory address
  input wire [`ADDR_WIDTH-1:0] jump_address; // instruction memory address
  output reg [`ADDR_WIDTH-1:0] pc; // instruction memory address
  input wire flush;
  input wire stall;
  input wire jump;

  initial begin
    pc = 0;
  end

  always @(posedge clk) begin

    if(!stall) begin
      if(flush) begin
        pc <= branch_address;
      end else if(jump) begin
        pc <= jump_address;
      end else begin
        pc <= pc + 1'b1;
      end
    end

  end

endmodule
