`ifndef _defines_vh_
`define _defines_vh_

`define DATA_WIDTH 16
`define INST_WIDTH 16

`define ADDR_WIDTH 16 
// data addresses need only be 16 bits
// this will be overkill for our instruction memory addresses
// but we will not be able to access imemory from our code.
// so this will serve as our pc size, even though we could make pc log2 imemory size.
// there will be many instruction memory addresses, jumps, branches ect

`define IMM_WIDTH  16 // immediates need only be 16 bits

`define IMEMORY_SIZE 128
`define DMEMORY_SIZE 1024

`define ALU_OP_ADD        4'b0000
`define ALU_OP_SUB        4'b0001
`define ALU_OP_NOT        4'b0010
`define ALU_OP_AND        4'b0011
`define ALU_OP_OR         4'b0100
`define ALU_OP_NAND       4'b0101
`define ALU_OP_NOR        4'b0110
`define ALU_OP_MOV        4'b0111
`define ALU_OP_LI         4'b1000
// can make this ceil(log(highest one))

// or can make nops for the rest, then just do the last nop.
// either way will get warnings and errors.

// nope we can use bits.
`define ALU_OP_BITS       4//$bits(ALU_OP_ADD)

`define MEM_OP_NOP        2'b00
`define MEM_OP_READ       2'b01
`define MEM_OP_WRITE      2'b10
//`define MEM_OP_NOP2       2'b11

// can make this ceil(log(highest one))
`define MEM_OP_BITS       2 //$bits(MEM_OP_READ)

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

`define OP_CODE_BITS      4

`define NUM_REGISTERS     8
`define NUM_REGISTERS_LOG2  3 //$clog2(`NUM_REGISTERS)

`define FORWARD_EX_MEM  2
`define FORWARD_MEM_WB  1
`define NO_FORWARD      0

`define FORWARD_BITS    2

/*
`define OPCODE_MSB INST_WIDTH-1
`define OPCODE_LSB OPCODE_MSB-OP_CODE_BITS+1

`define REG_RS_MSB OPCODE_LSB-1
`define REG_RS_LSB REG_RS_MSB-NUM_REGISTERS_LOG2+1

`define REG_RT_MSB REG_RS_LSB-1
`define REG_RT_LSB REG_RT_MSB-NUM_REGISTERS_LOG2+1

// R-TYPE
`define REG_RD_MSB REG_RT_LSB-1
`define REG_RD_LSB REG_RD_MSB-NUM_REGISTERS_LOG2+1

// I-TYPE
`define IMM_MSB REG_RT_LSB-1
`define IMM_LSB IMM_MSB-IMM_WIDTH+1
// THERE SHOULD BE AN ASSERTION HERE.

// THERE IS NO JTYPE, jump = I-TYPE
*/

/*
`define OPCODE_MSB 31
`define OPCODE_LSB 26

`define REG_RS_MSB 25
`define REG_RS_LSB 21

`define REG_RT_MSB 20
`define REG_RT_LSB 16

// R-TYPE
`define REG_RD_MSB 15
`define REG_RD_LSB 11

// I-TYPE
`define IMM_MSB 15
`define IMM_LSB 0

// THERE IS NO JTYPE, jump = I-TYPE
*/

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

// THERE IS NO JTYPE, jump = I-TYPE

`endif















