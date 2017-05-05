`timescale 1ns / 1ps

module branch_unit(
  zero,
  less,
  greater,
  jop,
  flush
  );

  input wire zero;
  input wire less;
  input wire greater;
  input wire [`JUMP_BITS-1:0] jop;
  output reg flush;

  always@(*) begin
  
    case(jop)
      `JMP_OP_NOP: flush <= 0;
      `JMP_OP_J:   flush <= 0;

      `JMP_OP_JEQ: flush <= zero == 1;
      `JMP_OP_JNE: flush <= zero == 0;

      `JMP_OP_JL:  flush <= less == 1;
      `JMP_OP_JLE: flush <= less == 1 && zero == 1;

      `JMP_OP_JG:  flush <= greater == 1;
      `JMP_OP_JGE: flush <= greater == 1 && zero == 1;

      `JMP_OP_JZ:  flush <= zero == 1;
      `JMP_OP_JNZ: flush <= zero == 0;

      `JMP_OP_JO:  flush <= zero == 1;
    endcase

  end

endmodule
