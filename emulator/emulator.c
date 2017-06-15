
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <assert.h>
#include <stdbool.h>

#include "emulator.h"

typedef unsigned int WORD;
typedef unsigned int REGISTER;
typedef unsigned int INSTRUCTION;
typedef unsigned long TIME;
typedef unsigned char BYTE;
typedef unsigned char BOOL;

#define LAST(k,n) ((k) & ((1<<(n))-1))
#define MID(k,m,n) LAST((k)>>(m),((n)-(m)))

#define DMEMORY_SIZE 1024
#define DATA_WIDTH 32

#define IMEMORY_SIZE 256
#define INST_WIDTH 32

#define ADDRESS_WIDTH 16

#define REGFILE_SIZE 32
#define REG_WIDTH 32

#define BITS_IN_INT 32

WORD dmemory[DMEMORY_SIZE];
REGISTER regfile[REGFILE_SIZE];
INSTRUCTION imemory[IMEMORY_SIZE];

typedef struct instruction{
  unsigned int opcode;
  unsigned int rs;
  unsigned int rt;
  unsigned int rd;
  unsigned int immediate;
} instruction_t;

// is this really what we want to do here?
// no this is dumb
// no need to go through each case
// not useful at all.
// 
instruction_t* to_instruction(INSTRUCTION i, instruction_t* is)
{}

void load_program()
{
  char buffer[100];
  sprintf(buffer, "code.hex");

  FILE *file;
  file = fopen(buffer, "r");
  if(file == NULL)
  {
    fprintf(stderr, "could not find %s\n", buffer);
    assert(0);
  }

  // assert if we are too big
  int i;
  for(i=0; i<IMEMORY_SIZE; i++)
  {
    if(!fscanf(file, "%x", &imemory[i]))
    {
      break;
    }
  }
}

// make a function thats like
// get bits from here to here/
// 26:21
// dont work because of 31 case ...

/*
static inline unsigned int bit_select(INSTRUCTION i, unsigned int msb, unsigned int lsb)
{
  unsigned int mask, masked, bits;
  if (msb == 31) {
    mask = 0xffffffff;
  }
  else {
    mask = (1 << (msb+1)) - 1;
  }  
  masked = i & mask;
  bits = masked >> lsb;
  return bits;
}
*/

// https://stackoverflow.com/questions/10090326/how-to-extract-specific-bits-from-a-number-in-c
static inline unsigned int bit_select(INSTRUCTION i, unsigned int msb, unsigned int lsb)
{
  unsigned int mask = ~(~0 << (msb - lsb + 1));
  unsigned int value = (i >> lsb) & mask;
  return value;
}

static inline unsigned int opcode_of(INSTRUCTION i)
{
  return bit_select(i, OPCODE_MSB, OPCODE_LSB);
}

static inline unsigned int rs_of(INSTRUCTION i)
{
  return bit_select(i, REG_RS_MSB, REG_RS_LSB);
}

static inline unsigned int rt_of(INSTRUCTION i)
{
  return bit_select(i, REG_RT_MSB, REG_RT_LSB);
}

static inline unsigned int rd_of(INSTRUCTION i)
{
  return bit_select(i, REG_RD_MSB, REG_RD_LSB);
}

static inline unsigned int imm_of(INSTRUCTION i)
{
  return bit_select(i, IMM_MSB, IMM_LSB);
}

void execute_instruction(INSTRUCTION i)
{
  unsigned int opcode = opcode_of(i);
  unsigned int rs = rs_of(i);
  unsigned int rt = rt_of(i);
  unsigned int rd = rd_of(i);
  unsigned int imm = imm_of(i);

  switch (opcode) {
    // 6'b00xxxx
    case OP_CODE_ADD:
    case OP_CODE_SUB:
    case OP_CODE_NOT:
    case OP_CODE_AND:
    case OP_CODE_OR:
    case OP_CODE_NAND:
    case OP_CODE_NOR:
    case OP_CODE_MOV:
    case OP_CODE_SAR:
    case OP_CODE_SHR:
    case OP_CODE_SHL:
    case OP_CODE_XOR:
    case OP_CODE_TEST:
    case OP_CODE_CMP:
      printf("%x %x %x %x\n", opcode, rs, rt, rd);
      break;

    // 6'b01xxxx
    case OP_CODE_ADDI:
    case OP_CODE_SUBI:
    case OP_CODE_NOTI:
    case OP_CODE_ANDI:
    case OP_CODE_ORI:
    case OP_CODE_NANDI:
    case OP_CODE_NORI:
    case OP_CODE_MOVI:
    case OP_CODE_SARI:
    case OP_CODE_SHRI:
    case OP_CODE_SHLI:
    case OP_CODE_XORI:
    case OP_CODE_TESTI:
    case OP_CODE_CMPI:
      printf("%x %x %x %x\n", opcode, rs, rt, imm);
      break;

    // 6'b10xxxx
    case OP_CODE_LW:
    case OP_CODE_SW:
    case OP_CODE_LA:
    case OP_CODE_SA:
      printf("%x %x %x %x\n", opcode, rs, rt, imm);
      break;

    // 6'b11xxxx
    case OP_CODE_JMP:
    case OP_CODE_JO:
    case OP_CODE_JE:
    case OP_CODE_JNE:
    case OP_CODE_JL:
    case OP_CODE_JLE:
    case OP_CODE_JG:
    case OP_CODE_JGE:
    case OP_CODE_JZ:
    case OP_CODE_JNZ:
    case OP_CODE_JR:
      printf("%x %x\n", opcode, imm);
      break;

    default:
      printf("invalid instruction!");
  }
}

int main()
{
  load_program();

  int i;
  for(i=0; i<IMEMORY_SIZE; i++)
  {
    //printf("%x\n", opcode_of(imemory[i]));
    if (imemory[i] != 0)
      execute_instruction(imemory[i]);
  }
}








