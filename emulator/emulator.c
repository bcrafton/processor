
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

typedef struct program_state{
  unsigned int pc;
  unsigned int zero;
  unsigned int less;
  unsigned int greater;
} program_state_t;

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

void execute_instruction(INSTRUCTION i, program_state_t* p)
{
  unsigned int opcode = opcode_of(i);
  unsigned int rs = rs_of(i);
  unsigned int rt = rt_of(i);
  unsigned int rd = rd_of(i);
  unsigned int imm = imm_of(i);
  unsigned int address;

  switch (opcode) {
    // 6'b00xxxx
    case OP_CODE_ADD:
      regfile[rd] = regfile[rs] + regfile[rt];
      p->pc++;
      break;
    case OP_CODE_SUB:
      regfile[rd] = regfile[rs] - regfile[rt];
      p->pc++;
      break;
    case OP_CODE_NOT:
      printf("not implemented yet: not\n");
      break;
    case OP_CODE_AND:
      regfile[rd] = regfile[rs] & regfile[rt];
      p->pc++;
      break;
    case OP_CODE_OR:
      regfile[rd] = regfile[rs] | regfile[rt];
      p->pc++;
      break;
    case OP_CODE_NAND:
      regfile[rd] = ~(regfile[rs] & regfile[rt]);
      p->pc++;
      break;
    case OP_CODE_NOR:
      regfile[rd] = ~(regfile[rs] | regfile[rt]);
      p->pc++;
      break;
    case OP_CODE_MOV:
      regfile[rd] = regfile[rt];
      p->pc++;
      break;
    case OP_CODE_SAR:
      // there is no sar in c ...
      regfile[rd] = regfile[rs] >> regfile[rt];
      p->pc++;
      break;
    case OP_CODE_SHR:
      regfile[rd] = regfile[rs] >> regfile[rt];
      p->pc++;
      break;
    case OP_CODE_SHL:
      regfile[rd] = regfile[rs] << regfile[rt];
      p->pc++;
      break;
    case OP_CODE_XOR:
      regfile[rd] = regfile[rs] ^ regfile[rt];
      p->pc++;
      break;
    case OP_CODE_TEST:
      p->pc++;
      p->zero = (regfile[rs] & regfile[rt]) == 0;
      p->less = (regfile[rs] < regfile[rt]);
      p->greater = (regfile[rs] > regfile[rt]);
      break;
    case OP_CODE_CMP:
      p->pc++;
      p->zero = (regfile[rs] - regfile[rt]) == 0;
      p->less = (regfile[rs] < regfile[rt]);
      p->greater = (regfile[rs] > regfile[rt]);
      break;

    // 6'b01xxxx
    case OP_CODE_ADDI:
      regfile[rd] = regfile[rs] + imm;
      p->pc++;
      break;
    case OP_CODE_SUBI:
      regfile[rd] = regfile[rs] - imm;
      p->pc++;
      break;
    case OP_CODE_NOTI:
      printf("not implemented yet: noti\n");
      break;
    case OP_CODE_ANDI:
      regfile[rd] = regfile[rs] & imm;
      p->pc++;
      break;
    case OP_CODE_ORI:
      regfile[rd] = regfile[rs] | imm;
      p->pc++;
      break;
    case OP_CODE_NANDI:
      regfile[rd] = ~(regfile[rs] & imm);
      p->pc++;
      break;
    case OP_CODE_NORI:
      regfile[rd] = ~(regfile[rs] | imm);
      p->pc++;
      break;
    case OP_CODE_MOVI:
      regfile[rd] = imm;
      p->pc++;
      break;
    case OP_CODE_SARI:
      // there is no sar in c ...
      regfile[rd] = regfile[rs] >> imm;
      p->pc++;
      break;
    case OP_CODE_SHRI:
      regfile[rd] = regfile[rs] >> imm;
      p->pc++;
      break;
    case OP_CODE_SHLI:
      regfile[rd] = regfile[rs] << imm;
      p->pc++;
      break;
    case OP_CODE_XORI:
      regfile[rd] = regfile[rs] ^ imm;
      p->pc++;
      break;
    case OP_CODE_TESTI:
      p->pc++;
      p->zero = (regfile[rs] & imm) == 0;
      p->less = (regfile[rs] < imm);
      p->greater = (regfile[rs] > imm);
      break;
    case OP_CODE_CMPI:
      p->pc++;
      p->zero = (regfile[rs] - imm) == 0;
      p->less = (regfile[rs] < imm);
      p->greater = (regfile[rs] > imm);
      break;

    // 6'b10xxxx
    case OP_CODE_LW:
      address = regfile[rs] + imm;
      regfile[rt] = dmemory[address];
      p->pc++;
      break;
    case OP_CODE_SW:
      address = regfile[rs] + imm;
      dmemory[address] = regfile[rt];
      p->pc++;
      break;
    case OP_CODE_LA:
      break;
    case OP_CODE_SA:
      break;

    // 6'b11xxxx
    case OP_CODE_JMP:
      p->pc = imm;
      break;
    case OP_CODE_JO:
      printf("not implemented yet: jo\n");
      break;
    case OP_CODE_JE:
      if (p->zero) p->pc = imm;
      break;
    case OP_CODE_JNE:
      if (!p->zero) p->pc = imm;
      break;
    case OP_CODE_JL:
      if (p->less) p->pc = imm;
      break;
    case OP_CODE_JLE:
      if (p->less || p->zero) p->pc = imm;
      break;
    case OP_CODE_JG:
      if (p->greater) p->pc = imm;
      break;
    case OP_CODE_JGE:
      if (p->greater || p->zero) p->pc = imm;
      break;
    case OP_CODE_JZ:
      if (p->zero) p->pc = imm;
      break;
    case OP_CODE_JNZ:
      if (!p->zero) p->pc = imm;
      break;
    case OP_CODE_JR:
      p->pc = regfile[rs];
      break;

    default:
      printf("invalid instruction!\n");
  }
}

int main()
{
  load_program();

  program_state_t p;
  p.pc = 0;

  int i;
  for(i=0; i<100; i++)
  {
    //printf("%d\n", imemory[i]);
    printf("instruction: %x pc: %d\n", imemory[p.pc], p.pc);
    if (p.pc > IMEMORY_SIZE)
    {
      printf("invalid instruction address %d\n", p.pc);
      break;
    }
    execute_instruction(imemory[p.pc], &p);
  }
  for(i=0; i<REGFILE_SIZE; i++)
  {
    printf("%x\n", regfile[i]);
  }
}








