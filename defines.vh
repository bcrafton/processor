`ifndef _defines_vh_
`define _defines_vh_

`define DATA_WIDTH 16

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
`define MEM_OP_BITS       2//$bits(MEM_OP_READ)

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

`endif


