
#ifndef INSTRUCTION_H
#define INSTRUCTION_H

#include "../common/defines.h"

#define OP_CODE_NOP       0x00

// 6'b00xxxx
#define OP_CODE_ADD       0x01
#define OP_CODE_SUB       0x02
#define OP_CODE_NOT       0x03
#define OP_CODE_AND       0x04
#define OP_CODE_OR        0x05
#define OP_CODE_NAND      0x06
#define OP_CODE_NOR       0x07
#define OP_CODE_MOV       0x08
#define OP_CODE_SAR       0x09
#define OP_CODE_SHR       0x0a
#define OP_CODE_SHL       0x0b
#define OP_CODE_XOR       0x0c
#define OP_CODE_TEST      0x0d
#define OP_CODE_CMP       0x0e

// 6'b01xxxx
#define OP_CODE_ADDI      0x10
#define OP_CODE_SUBI      0x11
#define OP_CODE_NOTI      0x12
#define OP_CODE_ANDI      0x13
#define OP_CODE_ORI       0x14
#define OP_CODE_NANDI     0x15
#define OP_CODE_NORI      0x16
#define OP_CODE_MOVI      0x17
#define OP_CODE_SARI      0x18
#define OP_CODE_SHRI      0x19
#define OP_CODE_SHLI      0x1a
#define OP_CODE_XORI      0x1b
#define OP_CODE_TESTI     0x1c
#define OP_CODE_CMPI      0x1d

// 6'b10xxxx
#define OP_CODE_LW        0x20
#define OP_CODE_SW        0x21
#define OP_CODE_LA        0x22
#define OP_CODE_SA        0x23

// 6'b11xxxx
#define OP_CODE_JMP       0x30
#define OP_CODE_JO        0x31
#define OP_CODE_JE        0x32
#define OP_CODE_JNE       0x33
#define OP_CODE_JL        0x34
#define OP_CODE_JLE       0x35
#define OP_CODE_JG        0x36
#define OP_CODE_JGE       0x37
#define OP_CODE_JZ        0x38
#define OP_CODE_JNZ       0x39
#define OP_CODE_JR        0x3a

#define OP_CODE_BITS      6 //$bits(OP_CODE_ADD)

#define NUM_REGISTERS       32
#define NUM_REGISTERS_LOG2  5 // $clog2(`NUM_REGISTERS)

#define OPCODE_MSB 31
#define OPCODE_LSB 26

#define REG_RS_MSB 25
#define REG_RS_LSB 21

#define REG_RT_MSB 20
#define REG_RT_LSB 16

// R-TYPE
#define REG_RD_MSB 15
#define REG_RD_LSB 11

// can only shift 31 times.
#define SHAMT_MSB  10
#define SHAMT_LSB  6
#define SHAMT_BITS 5

// I-TYPE
#define IMM_MSB 15
#define IMM_LSB 0

unsigned int bit_select(INSTRUCTION i, unsigned int msb, unsigned int lsb);
unsigned int opcode_of(INSTRUCTION i);
unsigned int rs_of(INSTRUCTION i);
unsigned int rt_of(INSTRUCTION i);
unsigned int rd_of(INSTRUCTION i);
unsigned int imm_of(INSTRUCTION i);

#endif
