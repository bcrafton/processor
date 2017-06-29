`ifndef _defines_vh_
`define _defines_vh_

`define IMEMORY_SIZE 256
`define DMEMORY_SIZE 1024
`define BLT_SIZE 32
`define BLT_SIZE_LOG2 5

`define DMEM_ID 0
`define IMEM_ID 1
`define REGFILE_ID 2

`define GARBAGE           32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
`define NOP_INSTRUCTION   32'b00000000000000000000000000000000

`define INSTRUCTION_ID_WIDTH 64

`define PIPE_ID1          64'h0000000000000001  
`define PIPE_ID2          64'h0000000000000002
`define NUM_BITS_PIPE_ID  4

`define PIPE_REG_PC       5'b00001
`define PIPE_REG_IF_ID    5'b00010
`define PIPE_REG_ID_EX    5'b00100
`define PIPE_REG_EX_MEM   5'b01000
`define PIPE_REG_MEM_WB   5'b10000
`define NUM_PIPE_MASKS    5 //$bits(MEM_OP_READ)

`define TAKE_BRANCH2      4'b0001
`define TAKE_BRANCH1      4'b0010
`define DONT_TAKE_BRANCH1 4'b0100
`define DONT_TAKE_BRANCH2 4'b1000
`define NUM_BRANCH_MASKS  4 //$bits(TAKE_BRANCH2)

`define PC_MASK_INDEX     0
`define IF_ID_MASK_INDEX  1
`define ID_EX_MASK_INDEX  2
`define EX_MEM_MASK_INDEX 3
`define MEM_WB_MASK_INDEX 4

`define REG_MASK_RS       3'b100
`define REG_MASK_RT       3'b010
`define REG_MASK_RD       3'b001
`define NUM_REG_MASKS     3 // //$bits(REG_MASK_RS)

`define MEM_OP_NOP        2'b00
`define MEM_OP_READ       2'b01
`define MEM_OP_WRITE      2'b10
`define MEM_OP_NOP2       2'b11
`define MEM_OP_BITS       2 //$bits(MEM_OP_READ)

`define JMP_OP_NOP        4'b0000
`define JMP_OP_J          4'b0001
`define JMP_OP_JEQ        4'b0010
`define JMP_OP_JNE        4'b0011
`define JMP_OP_JL         4'b0100
`define JMP_OP_JLE        4'b0101
`define JMP_OP_JG         4'b0110
`define JMP_OP_JGE        4'b0111
`define JMP_OP_JZ         4'b1000
`define JMP_OP_JNZ        4'b1001
`define JMP_OP_JO         4'b1010
`define JMP_OP_JR         4'b1011 // jump to a register
`define JUMP_BITS         4 // $bits(JMP_OP_NOP)

`define NO_FORWARD         3'b000
`define FORWARD_MEM_WB0    3'b001
`define FORWARD_EX_MEM0    3'b010
`define FORWARD_MEM_WB1    3'b011
`define FORWARD_EX_MEM1    3'b100
`define FORWARD_BITS       3 // $bits(FORWARD_EX_MEM0)

`define PIPE_BRANCH        2'b00
`define PIPE_MEMORY        2'b01
`define PIPE_DONT_CARE     2'b10
`define PIPE_BITS          2 // $bits(PIPE_BRANCH)

`define DATA_WIDTH 32
`define INST_WIDTH 32
`define ADDR_WIDTH 16 
`define IMM_WIDTH  16 

`define ALU_OP_NOP        4'b0000
`define ALU_OP_ADD        4'b0001
`define ALU_OP_SUB        4'b0010
`define ALU_OP_NOT        4'b0011
`define ALU_OP_AND        4'b0100
`define ALU_OP_OR         4'b0101
`define ALU_OP_NAND       4'b0110
`define ALU_OP_NOR        4'b0111

// both MOVI and MOV do the same thing. assign to data2
`define ALU_OP_MOV        4'b1000

`define ALU_OP_SAR        4'b1001
`define ALU_OP_SHR        4'b1010
`define ALU_OP_SHL        4'b1011
`define ALU_OP_XOR        4'b1100

`define ALU_OP_CMP        4'b1101
`define ALU_OP_TEST       4'b1110


`define ALU_OP_BITS       4 //$bits(ALU_OP_ADD)


`define OP_CODE_NOP       6'b000000 //0x00

// 6'b00xxxx
`define OP_CODE_ADD       6'b000001 //0x04
`define OP_CODE_SUB       6'b000010 //0x08
`define OP_CODE_NOT       6'b000011 //0x0C
`define OP_CODE_AND       6'b000100 //0x10
`define OP_CODE_OR        6'b000101 //0x14
`define OP_CODE_NAND      6'b000110 //0x18
`define OP_CODE_NOR       6'b000111 //0x1C
`define OP_CODE_MOV       6'b001000 //0x20
`define OP_CODE_SAR       6'b001001 //0x24
`define OP_CODE_SHR       6'b001010 //0x28
`define OP_CODE_SHL       6'b001011 //0x2c
`define OP_CODE_XOR       6'b001100 //0x30
`define OP_CODE_TEST      6'b001101 //0x34
`define OP_CODE_CMP       6'b001110 //0x38

// 6'b01xxxx
`define OP_CODE_ADDI      6'b010000 //0x40
`define OP_CODE_SUBI      6'b010001 //0x44
`define OP_CODE_NOTI      6'b010010 //0x48
`define OP_CODE_ANDI      6'b010011 //0x4C
`define OP_CODE_ORI       6'b010100 //0x50
`define OP_CODE_NANDI     6'b010101 //0x54
`define OP_CODE_NORI      6'b010110 //0x58
`define OP_CODE_MOVI      6'b010111 //0x5C
`define OP_CODE_SARI      6'b011000 //0x60
`define OP_CODE_SHRI      6'b011001 //0x64
`define OP_CODE_SHLI      6'b011010 //0x68
`define OP_CODE_XORI      6'b011011 //0x6C
`define OP_CODE_TESTI     6'b011100 //0x70
`define OP_CODE_CMPI      6'b011101 //0x74

// 6'b10xxxx
`define OP_CODE_LW        6'b100000 //0x80
`define OP_CODE_SW        6'b100001 //0x84
`define OP_CODE_LA        6'b100010 //0x88
`define OP_CODE_SA        6'b100011 //0x8C

// 6'b11xxxx
`define OP_CODE_JMP       6'b110000 //0xC0
`define OP_CODE_JO        6'b110001 //0xC4
`define OP_CODE_JE        6'b110010 //0xC8
`define OP_CODE_JNE       6'b110011 //0xCC
`define OP_CODE_JL        6'b110100 //0xD0
`define OP_CODE_JLE       6'b110101 //0xD4
`define OP_CODE_JG        6'b110110 //0xD8
`define OP_CODE_JGE       6'b110111 //0xDC
`define OP_CODE_JZ        6'b111000 //0xE0
`define OP_CODE_JNZ       6'b111001 //0xE4
`define OP_CODE_JR        6'b111010 //0xE8

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















