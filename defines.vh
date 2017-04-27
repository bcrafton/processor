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
`define ALU_OP_ASSIGN     4'b0111
`define ALU_OP_ASSIGN     4'b1000

`define MEM_OP_NOP        2'b00
`define MEM_OP_READ       2'b01
`define MEM_OP_WRITE      2'b10
`define MEM_OP_NOP2       2'b11

`endif
