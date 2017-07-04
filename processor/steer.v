`timescale 1ns / 1ps

module steer(
  clk,
  stall,

  instruction0_in,
  instruction1_in,

  pc0_in,
  pc1_in,

  id0_in,
  id1_in,
  
  //////////////

  instruction0_out,
  instruction1_out,

  pc0_out,
  pc1_out,

  id0_out,
  id1_out,

  steer_stall,
  first
  );

  input wire clk;
  input wire stall;

  input wire [`ADDR_WIDTH-1:0] pc0_in;
  input wire [`ADDR_WIDTH-1:0] pc1_in;

  input wire [`INSTRUCTION_ID_WIDTH-1:0] id0_in;
  input wire [`INSTRUCTION_ID_WIDTH-1:0] id1_in;

  input wire [`INST_WIDTH-1:0] instruction0_in;
  input wire [`INST_WIDTH-1:0] instruction1_in;

  //////////////

  output reg [`ADDR_WIDTH-1:0] pc0_out;
  output reg [`ADDR_WIDTH-1:0] pc1_out;

  output reg [`INSTRUCTION_ID_WIDTH-1:0] id0_out;
  output reg [`INSTRUCTION_ID_WIDTH-1:0] id1_out;

  output reg [`INST_WIDTH-1:0] instruction0_out;
  output reg [`INST_WIDTH-1:0] instruction1_out;

  output reg steer_stall;
  output reg first;

  //////////////

  reg [`PIPE_BITS-1:0] instruction0_pipe;
  reg [`PIPE_BITS-1:0] instruction1_pipe;

  reg prev_stall;

  wire [`OP_CODE_BITS-1:0] opcode0 = instruction0_in[`OPCODE_MSB:`OPCODE_LSB];
  wire [`OP_CODE_BITS-1:0] opcode1 = instruction1_in[`OPCODE_MSB:`OPCODE_LSB];

  //////////////

  always @(posedge clk) begin
    if(stall == 0) begin
      prev_stall <= steer_stall;  
    end
  end

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
          instruction1_pipe = `PIPE_BRANCH;
        end else begin
          instruction1_pipe = `PIPE_DONT_CARE;
        end
      end
      6'b01????: begin // addi, subi...
        if (opcode1 == `OP_CODE_CMPI || opcode1 == `OP_CODE_TESTI) begin
          instruction1_pipe = `PIPE_BRANCH;
        end else begin
          instruction1_pipe = `PIPE_DONT_CARE;
        end        
      end
      6'b10????: begin // lw, sw, la, sa
        instruction1_pipe = `PIPE_MEMORY;
      end
      6'b11????: begin // jmp, jo, je ...
        // actually want to include jmp here.
        // actually ... it does cost you an instruction sometimes.
        // yeah but then will add logic for getting the next address.
        // yeah this and program counter is somewhere to look for a little perf boost.
        instruction1_pipe = `PIPE_BRANCH;
      end
    endcase

    case( {instruction0_pipe, instruction1_pipe} )
      {`PIPE_BRANCH, `PIPE_BRANCH}: begin
        if (prev_stall == 0) begin
          instruction0_out = instruction0_in;
          instruction1_out = `NOP_INSTRUCTION;
          pc0_out = pc0_in;
          pc1_out = 0;

          id0_out = id0_in;
          id1_out = 0;

          steer_stall = 1;
          first = 0;
        end else begin
          instruction0_out = instruction1_in;
          instruction1_out = `NOP_INSTRUCTION;
          pc0_out = pc1_in;
          pc1_out = 0;

          id0_out = id1_in;
          id1_out = 0;

          steer_stall = 0;
          first = 0;
        end
      end
      {`PIPE_MEMORY, `PIPE_BRANCH}: begin
        instruction0_out = instruction1_in;
        instruction1_out = instruction0_in;
        pc0_out = pc1_in;
        pc1_out = pc0_in;

        id0_out = id1_in;
        id1_out = id0_in;

        steer_stall = 0;
        first = 1;
      end
      {`PIPE_MEMORY, `PIPE_MEMORY}: begin
        if (prev_stall == 0) begin
          instruction0_out = `NOP_INSTRUCTION;
          instruction1_out = instruction0_in;
          pc0_out = 0;
          pc1_out = pc0_in;

          id0_out = 0;
          id1_out = id0_in;

          steer_stall = 1;
          first = 1;
        end else begin
          instruction0_out = `NOP_INSTRUCTION;
          instruction1_out = instruction1_in;
          pc0_out = 0;
          pc1_out = pc1_in;

          id0_out = 0;
          id1_out = id1_in;

          steer_stall = 0;
          first = 1;
        end
      end
      {`PIPE_MEMORY, `PIPE_DONT_CARE}: begin
        instruction0_out = instruction1_in;
        instruction1_out = instruction0_in;
        pc0_out = pc1_in;
        pc1_out = pc0_in;

        id0_out = id1_in;
        id1_out = id0_in;

        steer_stall = 0;
        first = 1;
      end
      {`PIPE_DONT_CARE, `PIPE_BRANCH}: begin
        instruction0_out = instruction1_in;
        instruction1_out = instruction0_in;
        pc0_out = pc1_in;
        pc1_out = pc0_in;

        id0_out = id1_in;
        id1_out = id0_in;

        steer_stall = 0;
        first = 1;
      end
      default: begin
        instruction0_out = instruction0_in;
        instruction1_out = instruction1_in;
        pc0_out = pc0_in;
        pc1_out = pc1_in;

        id0_out = id0_in;
        id1_out = id1_in;

        steer_stall = 0;
        first = 0;
      end
    endcase

  end

endmodule

