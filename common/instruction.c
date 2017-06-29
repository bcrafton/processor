
#include "instruction.h"

// https://stackoverflow.com/questions/10090326/how-to-extract-specific-bits-from-a-number-in-c
unsigned int bit_select(INSTRUCTION i, unsigned int msb, unsigned int lsb)
{
  unsigned int mask = ~(~0 << (msb - lsb + 1));
  unsigned int value = (i >> lsb) & mask;
  return value;
}

unsigned int opcode_of(INSTRUCTION i)
{
  return bit_select(i, OPCODE_MSB, OPCODE_LSB);
}

unsigned int rs_of(INSTRUCTION i)
{
  return bit_select(i, REG_RS_MSB, REG_RS_LSB);
}

unsigned int rt_of(INSTRUCTION i)
{
  return bit_select(i, REG_RT_MSB, REG_RT_LSB);
}

unsigned int rd_of(INSTRUCTION i)
{
  return bit_select(i, REG_RD_MSB, REG_RD_LSB);
}

unsigned int imm_of(INSTRUCTION i)
{
  return bit_select(i, IMM_MSB, IMM_LSB);
}
