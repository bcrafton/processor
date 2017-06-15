
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

static inline unsigned int opcode_of(INSTRUCTION i)
{
  unsigned int opcode = (i >> 26);
  return opcode;
}

void execute_instruction(INSTRUCTION i)
{
  unsigned int opcode = opcode_of(i);
  switch (opcode) {
    case OP_CODE_MOVI:
      printf("got an movi\n");
    default:
      printf("got something else: %d\n", opcode);
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








