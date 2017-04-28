`timescale 1ns / 1ps

// for this module, need to define all the control values in defines.
// make it parameterizable based on the number of possible control values.
module control_unit(
  clk,
  opcode,
  reg_dst,
  mem_to_reg,
  alu_op,
  alu_src,
  reg_write,
  mem_op,
  beq,
  bne,
  address_src
  );

  input wire clk;
  input wire [OP_CODE_BITS-1:0] opcode;
  output reg reg_dst;
  output reg [MEM_OP_BITS-1:0] mem_op;
  output reg mem_to_reg;
  output reg [`ALU_OP_BITS-1:0] alu_op;
  output reg alu_src;
  output reg reg_write;
  output reg beq;
  output reg bne;
  output reg address_src;

  always @(*) begin

    case(opcode)
      0: begin // add
        reg_dst <= 1;
        mem_op <= 2'b00;
        alu_src <= 0;
        mem_to_reg <= 0;
        reg_write <= 1;
        alu_op <= 4'b0000;
        beq <= 1'b0;
        bne <= 1'b0;
        address_src <= 1'b0;
      end
      1: begin // addi
        reg_dst <= 0;
        mem_op <= 2'b00;
        alu_src <= 1; // want to load immediate not read_data_2
        mem_to_reg <= 0;
        reg_write <= 1;
        alu_op <= 4'b0000;
        beq <= 1'b0;
        bne <= 1'b0;
        address_src <= 1'b0;
      end
      2: begin // sub
        reg_dst <= 1; // want to write to third register
        mem_op <= 2'b00;
        alu_src <= 0;
        mem_to_reg <= 0;
        reg_write <= 1;
        alu_op <= 4'b0001;
        beq <= 1'b0;
        bne <= 1'b0;
        address_src <= 1'b0;
      end
      3: begin // subi
        reg_dst <= 0;
        mem_op <= 2'b00;
        alu_src <= 1; // want to load immediate not read_data_2
        mem_to_reg <= 0;
        reg_write <= 1;
        alu_op <= 4'b0001;
        beq <= 1'b0;
        bne <= 1'b0;
        address_src <= 1'b0;
      end
      4: begin // not
        reg_dst <= 1; // want to write to third register
        mem_op <= 2'b00;
        alu_src <= 0;
        mem_to_reg <= 0;
        reg_write <= 1;
        alu_op <= 4'b0010;
        beq <= 1'b0;
        bne <= 1'b0;
        address_src <= 1'b0;
      end
      5: begin // and
        reg_dst <= 1; // want to write to third register
        mem_op <= 2'b00;
        alu_src <= 0;
        mem_to_reg <= 0;
        reg_write <= 1;
        alu_op <= 4'b0011;
        beq <= 1'b0;
        bne <= 1'b0;
        address_src <= 1'b0;
      end
      6: begin // or
        reg_dst <= 1; // want to write to third register
        mem_op <= 2'b00;
        alu_src <= 0;
        mem_to_reg <= 0;
        reg_write <= 1;
        alu_op <= 4'b0100;
        beq <= 1'b0;
        bne <= 1'b0;
        address_src <= 1'b0;
      end
      7: begin // nand
        reg_dst <= 0;
        mem_op <= 2'b00;
        alu_src <= 1;
        mem_to_reg <= 0;
        reg_write <= 1;
        alu_op <= 4'b1000;
        beq <= 1'b0;
        bne <= 1'b0;
        address_src <= 1'b0;
      end
      8: begin // nor
        reg_dst <= 0;
        mem_op <= 2'b10;
        alu_src <= 0;
        mem_to_reg <= 0;
        reg_write <= 0;
        alu_op <= 4'b0000;
        beq <= 1'b0;
        bne <= 1'b0;
        address_src <= 1'b1;
      end
      9: begin // mov
        reg_dst <= 0; // want to write to third register
        mem_op <= 2'b00;
        alu_src <= 0;
        mem_to_reg <= 0;
        reg_write <= 1;
        alu_op <= 4'b0111;
        beq <= 1'b0;
        bne <= 1'b0;
        address_src <= 1'b0;
      end
      10: begin // li
        reg_dst <= 0;
        mem_op <= 2'b00;
        alu_src <= 1;
        mem_to_reg <= 0;
        reg_write <= 1;
        alu_op <= 4'b1000;
        beq <= 1'b0;
        bne <= 1'b0;
        address_src <= 1'b0;
      end
      11: begin // lw
        reg_dst <= 0; // want to write to third register
        mem_op <= 2'b01;
        alu_src <= 0;
        mem_to_reg <= 1;
        reg_write <= 1;
        alu_op <= 4'b0000;
        beq <= 1'b0;
        bne <= 1'b0;
        address_src <= 1'b0;
      end
      12: begin // sw
        reg_dst <= 0;
        mem_op <= 2'b10;
        alu_src <= 0;
        mem_to_reg <= 0;
        reg_write <= 0;
        alu_op <= 4'b0000;
        beq <= 1'b0;
        bne <= 1'b0;
        address_src <= 1'b0;
      end
      13: begin // beq
        mem_op <= 2'b00;
        alu_src <= 0;
        reg_write <= 0;
        beq <= 1'b1;
        bne <= 1'b0;
        address_src <= 1'b0;
      end
      14: begin // bne
        mem_op <= 2'b00;
        alu_src <= 0;
        reg_write <= 0;
        beq <= 1'b0;
        bne <= 1'b1;
        address_src <= 1'b0;
      end
      15: begin // jump
        mem_op <= 2'b00;
        reg_write <= 0;
        beq <= 1'b0;
        bne <= 1'b0;
        address_src <= 1'b0;
      end

    endcase

  end

endmodule
