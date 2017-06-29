
#ifndef TEST_BENCH_H
#define TEST_BENCH_H

#include "../common/defines.h"
#include "../common/logs.h"
#include "../common/instruction.h"
#include <glib.h>
//#include "../emulator/emulator.h"

///////////////////////////////////////////

typedef enum test_type{
  BINARY_TEST,
  CODE_TEST,
  ASM_TEST,
} test_type_t;

typedef enum run_type{
  EMU,
  SIM,
} run_type_t;

typedef struct test{
  char name[25];
  test_type_t test_type;
  int ans;
  unsigned int sim_time;
} test_t;

typedef struct run{
  test_t test;
  run_type_t run_type;
  char program_dir[100];
  char out_dir[100];  
} run_t;

///////////////////////////////////////////

bool check();
bool check_code(test_t* test);
bool check_asm();
bool check_binary();
bool next_test();

///////////////////////////////////////////

#endif












