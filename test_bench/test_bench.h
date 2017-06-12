
#ifndef MEMORY_SIMULATOR_H
#define MEMORY_SIMULATOR_H

#include <vpi_user.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <assert.h>
#include <stdbool.h>

///////////////////////////////////////////

#define DMEMORY_SIZE 1024
#define DATA_WIDTH 32

#define IMEMORY_SIZE 256
#define INST_WIDTH 32

#define ADDRESS_WIDTH 16

#define REGFILE_SIZE 32
#define REG_WIDTH 32

#define BITS_IN_INT 32

///////////////////////////////////////////

#define DMEM_ID 0
#define IMEM_ID 1
#define REGFILE_ID 2

///////////////////////////////////////////

typedef unsigned int WORD;
typedef unsigned int REGISTER;
typedef unsigned int INSTRUCTION;
typedef unsigned long TIME;
typedef unsigned char BYTE;
typedef unsigned char BOOL;

///////////////////////////////////////////

#define PC_MASK     0x01
#define IF_ID_MASK  0x02
#define ID_EX_MASK  0x04
#define EX_MEM_MASK 0x08
#define MEM_WB_MASK 0x10

#define FLUSH_MASK        (EX_MEM_MASK | ID_EX_MASK | IF_ID_MASK | PC_MASK)
#define STALL_LOAD_MASK   (IF_ID_MASK | PC_MASK)
#define STALL_FIRST_MASK  PC_MASK
#define STALL_SECOND_MASK (IF_ID_MASK | PC_MASK)

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

typedef struct perf_metrics_t{
  float ipc;
  float branch_predict_percent;

  unsigned int flush_count;
  unsigned long int instruction_count;
  unsigned long int run_time;

  unsigned int load_stall_count;
  unsigned int split_stall_count;
  unsigned int steer_stall_count;

  unsigned int jump_count;

} perf_metrics_t;

///////////////////////////////////////////

PLI_INT32 mem_read(char* user_data);
PLI_INT32 mem_write(char* user_data);
PLI_INT32 init(char* user_data);
PLI_INT32 update(char* user_data);

PLI_INT32 perf_metrics(char* user_data);

///////////////////////////////////////////

void dump_memory(int memory_id);
void load_program();
void clear_memory(int memory_id);
perf_metrics_t* get_perf_metrics();
void clear_perf_metrics();
void dump_perf_metrics();

///////////////////////////////////////////

bool check();
bool check_code();
bool check_asm();
bool check_binary();
bool next_test();

///////////////////////////////////////////

#define BINARY_PROGRAM_PATH   "../test_bench/programs/bin/"
#define CODE_PROGRAM_PATH     "../test_bench/programs/code/bin/"
#define ASM_PROGRAM_PATH      "../test_bench/programs/asm/bin/"

#define ACTUAL_PATH           "../test_bench/actual/"
#define EXPECTED_PATH         "../test_bench/expected/"

#define PERF_PATH             "../test_bench/performance/"

///////////////////////////////////////////



#endif












