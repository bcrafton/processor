`ifndef _defines_vh_
`define _defines_vh_

`define PROCESSOR_32_BIT 0

`define IMEMORY_SIZE 128
`define DMEMORY_SIZE 1024

`define MEM_OP_NOP        2'b00
`define MEM_OP_READ       2'b01
`define MEM_OP_WRITE      2'b10
`define MEM_OP_NOP2       2'b11
`define MEM_OP_BITS       2 //$bits(MEM_OP_READ)

`define FORWARD_EX_MEM    2'b10
`define FORWARD_MEM_WB    2'b01
`define NO_FORWARD        2'b00
`define FORWARD_BITS      2 // $bits(FORWARD_EX_MEM)

`ifdef PROCESSOR_16_BIT

  `define DATA_WIDTH 16
  `define INST_WIDTH 16
  `define ADDR_WIDTH 16 
  `define IMM_WIDTH  16 

  `define ALU_OP_ADD        4'b0000
  `define ALU_OP_SUB        4'b0001
  `define ALU_OP_NOT        4'b0010
  `define ALU_OP_AND        4'b0011
  `define ALU_OP_OR         4'b0100
  `define ALU_OP_NAND       4'b0101
  `define ALU_OP_NOR        4'b0110
  `define ALU_OP_MOV        4'b0111
  `define ALU_OP_LI         4'b1000
  `define ALU_OP_BITS       4 //$bits(ALU_OP_ADD)

  `define OP_CODE_ADD       4'b0000
  `define OP_CODE_ADDI      4'b0001
  `define OP_CODE_SUB       4'b0010
  `define OP_CODE_SUBI      4'b0011
  `define OP_CODE_NOT       4'b0100
  `define OP_CODE_AND       4'b0101
  `define OP_CODE_OR        4'b0110
  `define OP_CODE_NAND      4'b0111
  `define OP_CODE_NOR       4'b1000
  `define OP_CODE_MOV       4'b1001
  `define OP_CODE_LI        4'b1010
  `define OP_CODE_LW        4'b1011
  `define OP_CODE_SW        4'b1100
  `define OP_CODE_BEQ       4'b1101
  `define OP_CODE_BNE       4'b1110
  `define OP_CODE_JUMP      4'b1111
  `define OP_CODE_BITS      4 //$bits(OP_CODE_ADD)

  `define NUM_REGISTERS       8
  `define NUM_REGISTERS_LOG2  3 // $clog2(`NUM_REGISTERS)

  `define OPCODE_MSB 15
  `define OPCODE_LSB 12

  `define REG_RS_MSB 11
  `define REG_RS_LSB 9

  `define REG_RT_MSB 8
  `define REG_RT_LSB 6

  // R-TYPE
  `define REG_RD_MSB 5
  `define REG_RD_LSB 3

  // I-TYPE
  `define IMM_MSB 5
  `define IMM_LSB 0

`else // it is 32 bit.

  `define DATA_WIDTH 32
  `define INST_WIDTH 32
  `define ADDR_WIDTH 16 
  `define IMM_WIDTH  16 

  `define ALU_OP_ADD        4'b0000
  `define ALU_OP_SUB        4'b0001
  `define ALU_OP_NOT        4'b0010
  `define ALU_OP_AND        4'b0011
  `define ALU_OP_OR         4'b0100
  `define ALU_OP_NAND       4'b0101
  `define ALU_OP_NOR        4'b0110
  `define ALU_OP_MOV        4'b0111
  `define ALU_OP_LI         4'b1000

  `define ALU_OP_SAR        4'b1001
  `define ALU_OP_SHR        4'b1010
  `define ALU_OP_SHL        4'b1011
  `define ALU_OP_XOR        4'b1100

  `define ALU_OP_BITS       4 //$bits(ALU_OP_ADD)

  `define OP_CODE_ADD       6'b000000
  `define OP_CODE_ADDI      6'b000001
  `define OP_CODE_SUB       6'b000010
  `define OP_CODE_SUBI      6'b000011
  `define OP_CODE_NOT       6'b000100
  `define OP_CODE_AND       6'b000101
  `define OP_CODE_OR        6'b000110
  `define OP_CODE_NAND      6'b000111
  `define OP_CODE_NOR       6'b001000
  `define OP_CODE_MOV       6'b001001
  `define OP_CODE_LI        6'b001010
  `define OP_CODE_LW        6'b001011
  `define OP_CODE_SW        6'b001100
  `define OP_CODE_BEQ       6'b001101
  `define OP_CODE_BNE       6'b001110
  `define OP_CODE_JUMP      6'b001111
  `define OP_CODE_SA        6'b010000
  `define OP_CODE_LA        6'b010001
  `define OP_CODE_SAR       6'b010010
  `define OP_CODE_SHR       6'b010011
  `define OP_CODE_SHL       6'b010100
  `define OP_CODE_XOR       6'b010101
  `define OP_CODE_TEST      6'b010110
  `define OP_CODE_CMP       6'b010111
  `define OP_CODE_JO        6'b011000
  `define OP_CODE_JE        6'b011001
  `define OP_CODE_JNE       6'b011010
  `define OP_CODE_JL        6'b011011
  `define OP_CODE_JLE       6'b011100
  `define OP_CODE_JG        6'b011101
  `define OP_CODE_JGE       6'b011110
  `define OP_CODE_JZ        6'b011111
  `define OP_CODE_JNZ       6'b100000
  `define OP_CODE_BITS      6 //$bits(OP_CODE_ADD)

  `define NUM_REGISTERS       32
  `define NUM_REGISTERS_LOG2  5 // $clog2(`NUM_REGISTERS)

  `define OPCODE_MSB 31
  `define OPCODE_LSB 26

  `define REG_RS_MSB 25
  `define REG_RS_LSB 21

  `define REG_RT_MSB 20
  `define REG_RT_LSB 16

  // R-TYPE
  `define REG_RD_MSB 15
  `define REG_RD_LSB 11

  // can only shift 31 times.
  `define SHAMT_MSB  10
  `define SHAMT_LSB  6
  `define SHAMT_BITS 5

  // I-TYPE
  `define IMM_MSB 15
  `define IMM_LSB 0

  // THERE IS NO JTYPE, jump = I-TYPE

`endif

`endif















