
#ifndef TEST_BENCH_H
#define TEST_BENCH_H

#include "defines.h"

///////////////////////////////////////////

typedef enum test_type{
  BINARY_TEST,
  CODE_TEST,
  ASM_TEST,
} test_type_t;

typedef struct test{
  char name[25];
  test_type_t test_type;
  int ans;
  unsigned int sim_time;
} test_t;

///////////////////////////////////////////

bool check();
bool check_code(test_t* test);
bool check_asm();
bool check_binary();
bool next_test();

///////////////////////////////////////////

#endif












