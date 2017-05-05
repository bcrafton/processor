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
  address_src,
  jop,
  );

  input wire clk;
  input wire [`OP_CODE_BITS-1:0] opcode;
  output reg reg_dst;
  output reg [`MEM_OP_BITS-1:0] mem_op;
  output reg mem_to_reg;
  output reg [`ALU_OP_BITS-1:0] alu_op;
  output reg alu_src;
  output reg reg_write;
  output reg [`JUMP_BITS-1:0] jop;
  output reg address_src;

  always @(*) begin

    casex(opcode)
      6'b00????: begin // add, subi...
        reg_dst <= 1;
        mem_op <= `MEM_OP_NOP;
        alu_src <= 0;
        mem_to_reg <= 0;
        reg_write <= 1;
        address_src <= 0;
        jop <= `JMP_OP_NOP;
      end
      6'b01????: begin // addi, subi...
        reg_dst <= 0;
        mem_op <= `MEM_OP_NOP;
        alu_src <= 1;
        mem_to_reg <= 0;
        reg_write <= 1;
        address_src <= 0;
        jop <= `JMP_OP_NOP;
      end
      6'b10????: begin // lw, sw, la, sa
        reg_dst <= 0;
        alu_src <= 0;
        mem_to_reg <= 1;
        reg_write <= 1;
        jop <= `JMP_OP_NOP;
      end
      6'b11????: begin // jmp, jo, je ...
        mem_op <= `MEM_OP_NOP;
        alu_src <= 0;
        reg_write <= 0;
        address_src <= 0;
      end
    endcase

    case(opcode)
      `OP_CODE_LW: begin
        address_src <= 0;
        mem_op = `MEM_OP_READ;
      end
      `OP_CODE_SW: begin
        address_src <= 0;
        mem_op = `MEM_OP_WRITE;
      end
      `OP_CODE_LA: begin
        address_src <= 1;
        mem_op = `MEM_OP_READ;
      end
      `OP_CODE_SA: begin
        address_src <= 1;
        mem_op = `MEM_OP_WRITE;
      end
    endcase

    case(opcode)
      `OP_CODE_ADD: alu_op <= `OP_CODE_ADD;
      `OP_CODE_SUB: alu_op <= `OP_CODE_SUB;
      `OP_CODE_NOT: alu_op <= `OP_CODE_NOT;
      `OP_CODE_AND: alu_op <= `OP_CODE_AND;
      `OP_CODE_OR: alu_op <= `OP_CODE_OR;
      `OP_CODE_NAND: alu_op <= `OP_CODE_NAND;
      `OP_CODE_NOR: alu_op <= `OP_CODE_NOR;
      `OP_CODE_MOV: alu_op <= `OP_CODE_MOV;
      `OP_CODE_SAR: alu_op <= `OP_CODE_SAR;
      `OP_CODE_SHR: alu_op <= `OP_CODE_SHR;
      `OP_CODE_SHL: alu_op <= `OP_CODE_SHL;
      `OP_CODE_XOR: alu_op <= `OP_CODE_XOR;
      `OP_CODE_TEST: alu_op <= `OP_CODE_TEST;
      `OP_CODE_CMP: alu_op <= `OP_CODE_CMP;

      `OP_CODE_ADDI: alu_op <= `OP_CODE_ADD;
      `OP_CODE_SUBI: alu_op <= `OP_CODE_SUB;
      `OP_CODE_NOTI: alu_op <= `OP_CODE_NOT;
      `OP_CODE_ANDI: alu_op <= `OP_CODE_AND;
      `OP_CODE_ORI: alu_op <= `OP_CODE_OR;
      `OP_CODE_NANDI: alu_op <= `OP_CODE_NAND;
      `OP_CODE_NORI: alu_op <= `OP_CODE_NOR;
      `OP_CODE_MOVI: alu_op <= `OP_CODE_MOV;
      `OP_CODE_SARI: alu_op <= `OP_CODE_SAR;
      `OP_CODE_SHRI: alu_op <= `OP_CODE_SHR;
      `OP_CODE_SHLI: alu_op <= `OP_CODE_SHL;
      `OP_CODE_XORI: alu_op <= `OP_CODE_XOR;
      `OP_CODE_TESTI: alu_op <= `OP_CODE_TEST;
      `OP_CODE_CMPI: alu_op <= `OP_CODE_CMP;
    endcase 

    case(opcode)
      `OP_CODE_JMP: jop <=    `JMP_OP_J;
      `OP_CODE_JE:  jop <=    `JMP_OP_JEQ;
      `OP_CODE_JNE: jop <=    `JMP_OP_JNE;
      `OP_CODE_JL:  jop <=    `JMP_OP_JL;
      `OP_CODE_JLE: jop <=    `JMP_OP_JLE;
      `OP_CODE_JG:  jop <=    `JMP_OP_JG;
      `OP_CODE_JGE: jop <=    `JMP_OP_JGE;
      `OP_CODE_JZ:  jop <=    `JMP_OP_JZ;
      `OP_CODE_JNZ: jop <=    `JMP_OP_JNZ;
      `OP_CODE_JO:  jop <=    `JMP_OP_JO;
    endcase

  end

endmodule
