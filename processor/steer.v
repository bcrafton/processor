`timescale 1ns / 1ps

module steer(
  instruction0_in,
  instruction1_in,

  instruction0_out,
  instruction1_out,

  stall,    
  );


  input wire [`INST_WIDTH-1:0] instruction0_in;
  input wire [`INST_WIDTH-1:0] instruction1_in;

  output reg [`INST_WIDTH-1:0] instruction0_out;
  output reg [`INST_WIDTH-1:0] instruction1_out;

  output reg stall;

  wire [`OP_CODE_BITS-1:0] opcode0;
  wire [`OP_CODE_BITS-1:0] opcode1;

  // A, B, X
  // pipe a, b, dont care.
  reg [1:0] instruction0_type;
  reg [1:0] instruction1_type;

  assign opcode0 = instruction0[`OPCODE_MSB:`OPCODE_LSB];
  assign opcode1 = instruction1[`OPCODE_MSB:`OPCODE_LSB];

  always @(*) begin

    casex(opcode0)
      6'b000000: begin
        instruction0_type = 2;
      end
      6'b00????: begin // add, sub...
        instruction0_type = 2;
      end
      6'b01????: begin // addi, subi...
        instruction0_type = 2;
      end
      6'b10????: begin // lw, sw, la, sa
        instruction0_type = 1;
      end
      6'b11????: begin // jmp, jo, je ...
        instruction0_type = 0;
      end
    endcase

    casex(opcode1)
      6'b000000: begin
        instruction1_type = 2;
      end
      6'b00????: begin // add, sub...
        instruction1_type = 2;
      end
      6'b01????: begin // addi, subi...
        instruction1_type = 2;
      end
      6'b10????: begin // lw, sw, la, sa
        instruction1_type = 1;
      end
      6'b11????: begin // jmp, jo, je ...
        instruction1_type = 0;
      end
    endcase

    case( {instruction0_type, instruction1_type} )
      {2'b00, 2'b00}: begin
        instruction0_out = instruction0_in;
        instruction1_out = `NOP_INSTRUCTION;
        stall = 1;
      end
      {2'b01, 2'b00}: begin
        instruction0_out = instruction1_in;
        instruction1_out = instruction0_in;
        stall = 0;
      end
      {2'b01, 2'b01}: begin
        instruction0_out = `NOP_INSTRUCTION;
        instruction1_out = instruction0_in;
        stall = 1;
      end
      {2'b01, 2'b10}: begin
        instruction0_out = instruction1_in;
        instruction1_out = instruction0_in;
        stall = 0;
      end
      {2'b10, 2'b00}: begin
        instruction0_out = instruction1_in;
        instruction1_out = instruction0_in;
        stall = 0;
      end
      default: begin
        instruction0_out = instruction0_in;
        instruction1_out = instruction1_in;
        stall = 0;
      end
    endcase

  end

endmodule

