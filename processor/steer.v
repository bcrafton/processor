`timescale 1ns / 1ps

module steer(
  instruction0_in,
  instruction1_in,

  instruction0_out,
  instruction1_out,

  stall,
  first,
  );


  input wire [`INST_WIDTH-1:0] instruction0_in;
  input wire [`INST_WIDTH-1:0] instruction1_in;

  output reg [`INST_WIDTH-1:0] instruction0_out;
  output reg [`INST_WIDTH-1:0] instruction1_out;

  output reg stall;
  output reg first;

  wire [`OP_CODE_BITS-1:0] opcode0;
  wire [`OP_CODE_BITS-1:0] opcode1;

  // A, B, X
  // pipe a, b, dont care.
  reg [`PIPE_BITS-1:0] instruction0_pipe;
  reg [`PIPE_BITS-1:0] instruction1_pipe;

  assign opcode0 = instruction0[`OPCODE_MSB:`OPCODE_LSB];
  assign opcode1 = instruction1[`OPCODE_MSB:`OPCODE_LSB];

  always @(*) begin

    casex(opcode0)
      6'b000000: begin
        instruction0_pipe = `PIPE_DONT_CARE;
      end
      6'b00????: begin // add, sub...
        if (opcode0 == `OP_CODE_CMP || opcode0 == `OP_CODE_TEST) begin
          instruction0_pipe = `PIPE_BRANCH;
        end else begin
          instruction0_pipe = `PIPE_DONT_CARE;
        end
      end
      6'b01????: begin // addi, subi...
        if (opcode0 == `OP_CODE_CMPI || opcode0 == `OP_CODE_TESTI) begin
          instruction0_pipe = `PIPE_BRANCH;
        end else begin
          instruction0_pipe = `PIPE_DONT_CARE;
        end        
      end
      6'b10????: begin // lw, sw, la, sa
        instruction0_pipe = `PIPE_MEMORY;
      end
      6'b11????: begin // jmp, jo, je ...
        instruction0_pipe = `PIPE_BRANCH;
      end
    endcase

    casex(opcode1)
      6'b000000: begin
        instruction1_pipe = `PIPE_DONT_CARE;
      end
      6'b00????: begin // add, sub...
        if (opcode1 == `OP_CODE_CMP || opcode1 == `OP_CODE_TEST) begin
          instruction0_pipe = `PIPE_BRANCH;
        end else begin
          instruction0_pipe = `PIPE_DONT_CARE;
        end
      end
      6'b01????: begin // addi, subi...
        if (opcode1 == `OP_CODE_CMPI || opcode1 == `OP_CODE_TESTI) begin
          instruction0_pipe = `PIPE_BRANCH;
        end else begin
          instruction0_pipe = `PIPE_DONT_CARE;
        end        
      end
      6'b10????: begin // lw, sw, la, sa
        instruction1_pipe = `PIPE_MEMORY;
      end
      6'b11????: begin // jmp, jo, je ...
        instruction1_pipe = `PIPE_BRANCH;
      end
    endcase

    case( {instruction0_pipe, instruction1_pipe} )
      {`PIPE_BRANCH, `PIPE_BRANCH}: begin
        if (stall == 0) begin
          instruction0_out = instruction0_in;
          instruction1_out = `NOP_INSTRUCTION;
          stall = 1;
          first = 0;
        end else begin
          instruction0_out = instruction1_in;
          instruction1_out = `NOP_INSTRUCTION;
          stall = 0;
          first = 0;
        end
      end
      {`PIPE_MEMORY, `PIPE_BRANCH}: begin
        instruction0_out = instruction1_in;
        instruction1_out = instruction0_in;
        stall = 0;
        first = 1;
      end
      {`PIPE_MEMORY, `PIPE_MEMORY}: begin
        if (stall == 0) begin
          instruction0_out = `NOP_INSTRUCTION;
          instruction1_out = instruction0_in;
          stall = 1;
          first = 1;
        end else begin
          instruction0_out = `NOP_INSTRUCTION;
          instruction1_out = instruction1_in;
          stall = 0;
          first = 1;
        end
      end
      {`PIPE_MEMORY, `PIPE_DONT_CARE}: begin
        instruction0_out = instruction1_in;
        instruction1_out = instruction0_in;
        stall = 0;
        first = 1;
      end
      {`PIPE_DONT_CARE, `PIPE_BRANCH}: begin
        instruction0_out = instruction1_in;
        instruction1_out = instruction0_in;
        stall = 0;
        first = 1;
      end
      default: begin
        instruction0_out = instruction0_in;
        instruction1_out = instruction1_in;
        stall = 0;
        first = 0;
      end
    endcase

  end

endmodule

