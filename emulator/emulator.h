
#ifndef EMULATOR_H
#define EMULATOR_H

#include "../common/defines.h"
#include "../common/instruction.h"
#include "../common/memory.h"
#include "../common/logs.h"

typedef struct program_state{
  uint32_t pc;
  uint8_t zero;
  uint8_t less;
  uint8_t greater;
  uint32_t instruction_count;
} program_state_t;

void execute_program(char* program_path, char* out_path, uint32_t run_time);

#endif
