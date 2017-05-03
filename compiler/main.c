#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int our_code_starts_here() asm("our_code_starts_here");
extern int print(int val) asm("print");

const int ERR_COMP_NOT_NUM   = 0;
const int ERR_ARITH_NOT_NUM  = 1;
const int ERR_LOGIC_NOT_BOOL = 2;
const int ERR_IF_NOT_BOOL    = 3;
const int ERR_OVERFLOW       = 4;

int print(int val) 
{
  if (val == 0xFFFFFFFF)
  {
    printf("true\n");
  }
  else if (val == 0x7FFFFFFF)
  {
    printf("false\n");
  }
  else if ((val & 0x00000001) == 0x00000000)
  {
    printf("%d\n", val >> 1);
  }
  else
  {
    printf("Unknown value: %#010x\n", val);
  }
  return val;
}

void error(int errorCode) {
  fprintf(stdout, "%d\n", errorCode);
  switch(errorCode) {
    case ERR_ARITH_NOT_NUM:
      fprintf(stderr, "arithmetic expected a number");
      break;
    case ERR_COMP_NOT_NUM:
      fprintf(stderr, "comparison expected a number");
      break;
    case ERR_OVERFLOW:
      fprintf(stderr, "overflow");
      break;
    case ERR_IF_NOT_BOOL:
      fprintf(stderr, "if expected a boolean");
      break;
    case ERR_LOGIC_NOT_BOOL:
      fprintf(stderr, "logic expected a boolean");
      break;
    default:
      fprintf(stderr, "Unknown error");
      break;
  }
  exit(1);
}

// main should remain unchanged
int main(int argc, char** argv) {
  int result = our_code_starts_here();
  print(result);
  return 0;
}
