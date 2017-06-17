
#include "test_bench.h"

extern WORD dmemory[DMEMORY_SIZE];
extern REGISTER regfile[REGFILE_SIZE];
extern INSTRUCTION imemory[IMEMORY_SIZE];

#define RUN_SIM "vvp -M. -m ../processor/sim_vpi ../processor/sim_vpi.vvp"

static test_t tests[] = {

{"addi", BINARY_TEST, 0, 1000},
/*
{"subi", BINARY_TEST, 0, 1000},
{"andi", BINARY_TEST, 0, 1000},

{"ori", BINARY_TEST, 0, 1000},
{"nandi", BINARY_TEST, 0, 1000},
{"nori", BINARY_TEST, 0, 1000},
{"movi", BINARY_TEST, 0, 1000},
{"sari", BINARY_TEST, 0, 1000},

{"shri", BINARY_TEST, 0, 1000},
{"shli", BINARY_TEST, 0, 1000},
{"xori", BINARY_TEST, 0, 1000},
{"add", BINARY_TEST, 0, 1000},
{"sub", BINARY_TEST, 0, 1000},

{"and", BINARY_TEST, 0, 1000},
{"or", BINARY_TEST, 0, 1000},
{"nand", BINARY_TEST, 0, 1000},
{"nor", BINARY_TEST, 0, 1000},
{"mov", BINARY_TEST, 0, 1000},

{"sar", BINARY_TEST, 0, 1000},
{"shr", BINARY_TEST, 0, 1000},
{"shl", BINARY_TEST, 0, 1000},
{"xor", BINARY_TEST, 0, 1000},

{"lw", BINARY_TEST, 0, 1000},

{"sw", BINARY_TEST, 0, 1000},
{"la", BINARY_TEST, 0, 1000},
{"sa", BINARY_TEST, 0, 1000},

{"jmp", BINARY_TEST, 0, 1000},
{"jo", BINARY_TEST, 0, 1000},
{"je", BINARY_TEST, 0, 1000},
{"jne", BINARY_TEST, 0, 1000},
{"jl", BINARY_TEST, 0, 1000},
{"jle", BINARY_TEST, 0, 1000},
{"jg", BINARY_TEST, 0, 1000},
{"jge", BINARY_TEST, 0, 1000},
{"jz", BINARY_TEST, 0, 1000},
{"jnz", BINARY_TEST, 0, 1000},
{"jr", BINARY_TEST, 0, 1000},

{"mov", ASM_TEST, 0, 1000},
{"push", ASM_TEST, 100, 1000},
{"pop", ASM_TEST, 100, 1000},
{"push1", ASM_TEST, 100, 1000},

{"fn_add", CODE_TEST, 6, 10000},
{"if_false", CODE_TEST, 10, 10000},
{"if_true", CODE_TEST, 20, 10000},

{"fib0", CODE_TEST, 0, 10000},
{"fib1", CODE_TEST, 2, 10000},
{"fib2", CODE_TEST, 2, 10000},
{"fib3", CODE_TEST, 4, 100000},
{"fib4", CODE_TEST, 6, 100000},
{"fib5", CODE_TEST, 10, 100000},
//{"fib10", CODE_TEST, 110, 500000},

{"to_10", CODE_TEST, 20, 100000},

{"plus1", CODE_TEST, 4, 10000},
{"tuple1", CODE_TEST, 6, 10000},
{"tuple2", CODE_TEST, 6, 10000},
{"tuple3", CODE_TEST, 6, 10000},
{"nested_tuple", CODE_TEST, 202, 10000},
{"list", CODE_TEST, 6, 200000},
{"linked_list", CODE_TEST, 6, 200000},
*/
};

static int num_programs = sizeof(tests)/sizeof(test_t);

int main()
{
  int i;
  char test_name[200];
  char program_dir[200];
  char command[200];
  for(i=0; i<num_programs; i++)
  {
    switch(tests[i].test_type)
    {
      case CODE_TEST:
        sprintf(test_name, "%s.bc.s.hex", tests[i].name);
        sprintf(program_dir, "%s", "../test_bench/programs/code/bin/");
        break;
      case ASM_TEST:
        sprintf(test_name, "%s.s.hex", tests[i].name);
        sprintf(program_dir, "%s", "../test_bench/programs/asm/bin/");
        break;
      case BINARY_TEST:
        sprintf(test_name, "%s.hex", tests[i].name);
        sprintf(program_dir, "%s", "../test_bench/programs/bin/");
        break;
      default:
        fprintf(stderr, "invalid test type: %d", tests[i].test_type);
        assert(0);
    }
    
    sprintf(command, "%s +test_name=%s +run_time=%d +program_dir=%s +out_dir=%s", 
      RUN_SIM,
      test_name,
      tests[i].sim_time,
      program_dir,
      "../test_bench/out/"
      );

    int ret = system(command);
  }
}










