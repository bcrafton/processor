`timescale 1ns / 1ps

module branch_unit(
  beq,
  bne,
  compare,
  flush
  );

  input wire beq;
  input wire bne;
  input wire compare;
  output reg flush;

  always@(*) begin
  
    if((beq && compare) || (bne && !compare)) begin
      flush <= 1;
    end else begin
      flush <= 0;
    end

  end

endmodule
