
#include "test_bench.h"

#define RUN_SIM "vvp -M. -m ../processor/sim_vpi ../processor/sim_vpi.vvp +test_name=%s +run_time=%d +program_dir=%s +out_dir=%s"

static test_t tests[] = {
{"addi", BINARY_TEST, 0, 1000},
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
};

static int num_programs = sizeof(tests)/sizeof(test_t);

void get_program_filepath(test_t* test, char filepath[])
{
  switch(test->test_type)
  {
    case CODE_TEST:
      sprintf(filepath, "../test_bench/programs/code/bin/%s.bc.s.hex", test->name);
      break;
    case ASM_TEST:
      sprintf(filepath, "../test_bench/programs/asm/bin/%s.s.hex", test->name);
      break;
    case BINARY_TEST:
      sprintf(filepath, "../test_bench/programs/bin/%s.hex", test->name);
      break;
    default:
      fprintf(stderr, "invalid test type: %d", test->test_type);
      assert(0);
  }
}

void get_out_filepath(test_t* test, char* run_type, char filepath[])
{
  switch(test->test_type)
  {
    case CODE_TEST:
      sprintf(filepath, "../test_bench/out/%s/%s.bc.s.hex", run_type, test->name);
      break;
    case ASM_TEST:
      sprintf(filepath, "../test_bench/out/%s/%s.s.hex", run_type, test->name);
      break;
    case BINARY_TEST:
      sprintf(filepath, "../test_bench/out/%s/%s.hex", run_type, test->name);
      break;
    default:
      fprintf(stderr, "invalid test type: %d", test->test_type);
      assert(0);
  }
}

void execute_sim(char* in_path, char* out_path, uint32_t run_time)
{
  const char* sim_cmd = "vvp -M. -m ../processor/sim_vpi ../processor/sim_vpi.vvp +run_time=%d +in_path=%s +out_path=%s";
  char cmd[200];
  sprintf(cmd, sim_cmd, run_time, in_path, out_path);
  int ret = system(cmd);
}

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
    
    //sprintf(command, RUN_SIM, test_name, tests[i].sim_time, program_dir, "../test_bench/out/");
    //int ret = system(command);
    char emu_outpath[200];
    char sim_outpath[200];
    char inpath[200];
    get_out_filepath(&tests[i], "emu", emu_outpath);
    get_out_filepath(&tests[i], "sim", sim_outpath);
    get_program_filepath(&tests[i], inpath);
    struct stat st = {0};

    if (stat(emu_outpath, &st) == -1) {
        mkdir(emu_outpath, 0700);
    }

    if (stat(sim_outpath, &st) == -1) {
        mkdir(sim_outpath, 0700);
    }

    execute_program(inpath, emu_outpath, tests[i].sim_time/10);
    execute_sim(inpath, sim_outpath, tests[i].sim_time);
  }

  bool result;
  for(i=0; i<num_programs; i++)
  {
    switch(tests[i].test_type)
    {
      case CODE_TEST:
        result = check_code(&tests[i]);
        if (result) printf("Test: %s Passed.\n", tests[i].name);
        else printf("Test: %s Failed.\n", tests[i].name);
        break;
      case ASM_TEST:
        result = check_asm(&tests[i]);
        if (result) printf("Test: %s Passed.\n", tests[i].name);
        else printf("Test: %s Failed.\n", tests[i].name);
        break;
      case BINARY_TEST:
        result = check_binary(&tests[i]);
        if (result) printf("Test: %s Passed.\n", tests[i].name);
        else printf("Test: %s Failed.\n", tests[i].name);
        break;
      default:
        fprintf(stderr, "invalid test type: %d", tests[i].test_type);
        assert(0);
    }
  }
}

void load_memory(char* dir, char* filename, char* ext, WORD memory[], uint32_t size)
{

  char filepath[100];
  sprintf(filepath, "%s%s%s", dir, filename, ext);

  FILE *file;
  file = fopen(filepath, "r");
  if(file == NULL)
  {
    fprintf(stderr, "could not find %s\n", filepath);
    assert(0);
  }

  int i;
  for(i=0; i<size; i++)
  {
    if(!fscanf(file, "%x", &memory[i]))
    {
      fprintf(stderr, "file does not contain enough words");
      assert(0);
    }
  }
  fclose(file);
}

bool diff_memory(WORD* mem1, WORD* mem2, uint32_t mem_size)
{
  int i;
  for(i=0; i<mem_size; i++)
  {
    if(mem1[i] != mem2[i])
    {
      return false;
    }
  }
  return true;
}

bool check_code(test_t* test)
{
  REGISTER reg_sim[REGFILE_SIZE];
  WORD mem_sim[DMEMORY_SIZE];

  REGISTER reg_emu[REGFILE_SIZE];
  WORD mem_emu[DMEMORY_SIZE];

  char sim_out_path[200];
  char emu_out_path[200];

  get_out_filepath(test, "sim", sim_out_path);
  get_out_filepath(test, "emu", emu_out_path);
  
  load_memory(sim_out_path, "/reg", "", reg_sim, REGFILE_SIZE);
  load_memory(sim_out_path, "/mem", "", mem_sim, DMEMORY_SIZE);

  load_memory(emu_out_path, "/reg", "", reg_emu, REGFILE_SIZE);
  load_memory(emu_out_path, "/mem", "", mem_emu, DMEMORY_SIZE);

  bool diff = (reg_emu[0] == test->ans);
  diff = diff && diff_memory(reg_sim, reg_emu, REGFILE_SIZE);
  diff = diff && diff_memory(mem_sim, mem_emu, DMEMORY_SIZE);

  return diff;
}

bool check_asm(test_t* test)
{
  REGISTER reg_sim[REGFILE_SIZE];
  WORD mem_sim[DMEMORY_SIZE];

  REGISTER reg_emu[REGFILE_SIZE];
  WORD mem_emu[DMEMORY_SIZE];

  char sim_out_path[200];
  char emu_out_path[200];

  get_out_filepath(test, "sim", sim_out_path);
  get_out_filepath(test, "emu", emu_out_path);
  
  load_memory(sim_out_path, "/reg", "", reg_sim, REGFILE_SIZE);
  load_memory(sim_out_path, "/mem", "", mem_sim, DMEMORY_SIZE);

  load_memory(emu_out_path, "/reg", "", reg_emu, REGFILE_SIZE);
  load_memory(emu_out_path, "/mem", "", mem_emu, DMEMORY_SIZE);

  bool diff = (reg_emu[0] == test->ans);
  diff = diff && diff_memory(reg_sim, reg_emu, REGFILE_SIZE);
  diff = diff && diff_memory(mem_sim, mem_emu, DMEMORY_SIZE);

  return diff;
}

bool check_binary(test_t* test)
{
  REGISTER reg_exp[REGFILE_SIZE];
  WORD mem_exp[DMEMORY_SIZE];

  REGISTER reg_sim[REGFILE_SIZE];
  WORD mem_sim[DMEMORY_SIZE];

  REGISTER reg_emu[REGFILE_SIZE];
  WORD mem_emu[DMEMORY_SIZE];

  char sim_out_path[200];
  char emu_out_path[200];

  get_out_filepath(test, "sim", sim_out_path);
  get_out_filepath(test, "emu", emu_out_path);
  
  load_memory(sim_out_path, "/reg", "", reg_sim, REGFILE_SIZE);
  load_memory(sim_out_path, "/mem", "", mem_sim, DMEMORY_SIZE);

  load_memory(emu_out_path, "/reg", "", reg_emu, REGFILE_SIZE);
  load_memory(emu_out_path, "/mem", "", mem_emu, DMEMORY_SIZE);

  load_memory("../test_bench/expected/reg/", test->name, ".reg.expected", reg_exp, REGFILE_SIZE);
  load_memory("../test_bench/expected/mem/", test->name, ".mem.expected", mem_exp, DMEMORY_SIZE);

  bool diff = diff_memory(reg_exp, reg_emu, REGFILE_SIZE);
  diff = diff && diff_memory(mem_exp, mem_emu, DMEMORY_SIZE);

  diff = diff && diff_memory(reg_sim, reg_emu, REGFILE_SIZE);
  diff = diff && diff_memory(mem_sim, mem_emu, DMEMORY_SIZE);

  return diff;
}

/*
void load_memory(char* dir, char* filename, char* ext, WORD memory[], uint32_t size)
{

  char filepath[100];
  sprintf(filepath, "%s%s%s", dir, filename, ext);

  FILE *file;
  file = fopen(filepath, "r");
  if(file == NULL)
  {
    fprintf(stderr, "could not find %s\n", filepath);
    assert(0);
  }

  int i;
  for(i=0; i<size; i++)
  {
    if(!fscanf(file, "%x", &memory[i]))
    {
      fprintf(stderr, "file does not contain enough words");
      assert(0);
    }
  }
  fclose(file);
}


bool check_code(test_t* test)
{
  REGISTER result_regfile[REGFILE_SIZE];
  
  load_memory("../test_bench/out/", test->name, ".bc.s.hex.reg", result_regfile, REGFILE_SIZE);

  if(result_regfile[0] != test->ans)
  {
    return false;
  }

  return true;
}

bool check_asm(test_t* test)
{
  REGISTER result_regfile[REGFILE_SIZE];

  load_memory("../test_bench/out/", test->name, ".s.hex.reg", result_regfile, REGFILE_SIZE);

  if(result_regfile[0] != test->ans)
  {
    return false;
  }

  return true;
}

bool check_binary(test_t* test)
{
  REGISTER result_regfile[REGFILE_SIZE];
  WORD result_memory[DMEMORY_SIZE];

  REGISTER expected_regfile[REGFILE_SIZE];
  WORD expected_memory[DMEMORY_SIZE];

  load_memory("../test_bench/out/", test->name, ".hex.reg", result_regfile, REGFILE_SIZE);
  load_memory("../test_bench/out/", test->name, ".hex.mem", result_memory, DMEMORY_SIZE);

  load_memory("../test_bench/expected/reg/", test->name, ".reg.expected", expected_regfile, REGFILE_SIZE);
  load_memory("../test_bench/expected/mem/", test->name, ".mem.expected", expected_memory, DMEMORY_SIZE);

  int i;
  for(i=0; i<REGFILE_SIZE; i++)
  {
    if(result_regfile[i] != expected_regfile[i])
    {
      return false;
    }
  }

  for(i=0; i<DMEMORY_SIZE; i++)
  {
    if(result_memory[i] != expected_memory[i])
    {
      return false;
    }
  }

  return true;
}
*/




