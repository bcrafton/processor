
#include "test_bench.h"

extern WORD dmemory[DMEMORY_SIZE];
extern REGISTER regfile[REGFILE_SIZE];
extern INSTRUCTION imemory[IMEMORY_SIZE];
/*
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
*/

static TIME test_start_time;
static char test_name[100];
static char program_dir[100];
static char out_dir[100];

PLI_INT32 init(char* user_data)
{    
    assert(user_data == NULL);
    vpiHandle vhandle, iterator, arg;
    vhandle = vpi_handle(vpiSysTfCall, NULL);

    s_vpi_value inval;

    unsigned int time_h;
    unsigned int time_l;
    unsigned long current_time;

    iterator = vpi_iterate(vpiArgument, vhandle);

    arg = vpi_scan(iterator);
    inval.format = vpiStringVal;
    vpi_get_value(arg, &inval);
    strcpy(test_name, inval.value.str);
    assert(test_name != NULL);

    arg = vpi_scan(iterator);
    inval.format = vpiStringVal;
    vpi_get_value(arg, &inval);
    strcpy(program_dir, inval.value.str);
    assert(program_dir != NULL);

    arg = vpi_scan(iterator);
    inval.format = vpiStringVal;
    vpi_get_value(arg, &inval);
    strcpy(out_dir, inval.value.str);
    assert(out_dir != NULL);

    arg = vpi_scan(iterator);
    inval.format = vpiTimeVal;
    vpi_get_value(arg, &inval);
    time_h = inval.value.time->high;
    time_l = inval.value.time->low;
    
    current_time = time_h;
    current_time = (current_time << BITS_IN_INT) | time_l;

    test_start_time = current_time;

    load_program(program_dir, test_name);

    return 0; 
}

PLI_INT32 dump(char* user_data)
{    
    assert(user_data == NULL);
    vpiHandle vhandle, iterator, arg;
    vhandle = vpi_handle(vpiSysTfCall, NULL);

    s_vpi_value inval;

    unsigned int time_h;
    unsigned int time_l;
    unsigned long current_time;

    iterator = vpi_iterate(vpiArgument, vhandle);

    arg = vpi_scan(iterator);
    inval.format = vpiTimeVal;
    vpi_get_value(arg, &inval);
    time_h = inval.value.time->high;
    time_l = inval.value.time->low;
    
    dump_memory();
    dump_perf_metrics();

    return 0; 
}

void dump_memory()
{
  int i;
  char buffer[100];
  FILE *file;

  sprintf(buffer, "%s%s.mem", out_dir, test_name);
  printf("%s\n", buffer);
  file = fopen(buffer, "w");
  if(file == NULL)
  {
    fprintf(stderr, "could not find %s\n", buffer);
    assert(0);
  }
  

  for(i=0; i<DMEMORY_SIZE; i++)
  {
      fprintf(file, "%08x\n", dmemory[i]);
  }

  fclose(file);

  sprintf(buffer, "%s%s.reg", out_dir, test_name);
  
  file = fopen(buffer, "w");
  if(file == NULL)
  {
    fprintf(stderr, "could not find %s\n", buffer);
    assert(0);
  }

  for(i=0; i<REGFILE_SIZE; i++)
  {
      fprintf(file, "%08x\n", regfile[i]);
  }

  fclose(file);
}

void load_program()
{
  char buffer[100];
  sprintf(buffer, "%s%s", program_dir, test_name);
  
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
      break;
  }
}

void dump_perf_metrics()
{
  perf_metrics_t* p = get_perf_metrics();
  
  char buffer[100];
  sprintf(buffer, "%s%s.perf", out_dir, test_name);
  
  FILE *file;
  file = fopen(buffer, "w");
  if(file == NULL)
  {
    fprintf(stderr, "could not find %s\n", buffer);
    assert(0);
  }

  fprintf(file, "ipc = %f\n", p->ipc);
  fprintf(file, "instructions = %lu\n", p->instruction_count);
  fprintf(file, "run time = %lu\n", p->run_time);
  fprintf(file, "flushes = %u\n", p->flush_count);
  fprintf(file, "load stalls = %u\n", p->load_stall_count);
  fprintf(file, "split stalls = %u\n", p->split_stall_count);
  fprintf(file, "steer stalls = %u\n", p->steer_stall_count);
  fprintf(file, "branch count = %u\n", p->jump_count);
  fprintf(file, "unique branch count = %u\n", p->unique_jump_count);
  fprintf(file, "branch predict percent = %f\n", p->branch_predict_percent);

  fclose(file);
}

void mem_read_register(void)
{
    s_vpi_systf_data tf_data;
    tf_data.type        = vpiSysFunc;
    tf_data.sysfunctype = vpiIntFunc;
    tf_data.tfname    = "$mem_read";
    tf_data.calltf    = mem_read;
    tf_data.compiletf = 0;
    tf_data.sizetf    = 0;
    tf_data.user_data = 0;
    vpi_register_systf(&tf_data);
}

void mem_write_register(void)
{
    s_vpi_systf_data tf_data;
    tf_data.type        = vpiSysFunc;
    tf_data.sysfunctype = vpiIntFunc;
    tf_data.tfname    = "$mem_write";
    tf_data.calltf    = mem_write;
    tf_data.compiletf = 0;
    tf_data.sizetf    = 0;
    tf_data.user_data = 0;
    vpi_register_systf(&tf_data);
}

void init_register(void)
{
    s_vpi_systf_data tf_data;
    tf_data.type        = vpiSysFunc;
    tf_data.sysfunctype = vpiIntFunc;
    tf_data.tfname    = "$init";
    tf_data.calltf    = init;
    tf_data.compiletf = 0;
    tf_data.sizetf    = 0;
    tf_data.user_data = 0;
    vpi_register_systf(&tf_data);
}

void dump_register(void)
{
    s_vpi_systf_data tf_data;
    tf_data.type        = vpiSysFunc;
    tf_data.sysfunctype = vpiIntFunc;
    tf_data.tfname    = "$dump";
    tf_data.calltf    = dump;
    tf_data.compiletf = 0;
    tf_data.sizetf    = 0;
    tf_data.user_data = 0;
    vpi_register_systf(&tf_data);
}

void perf_metrics_register(void)
{
    s_vpi_systf_data tf_data;
    tf_data.type        = vpiSysFunc;
    tf_data.sysfunctype = vpiIntFunc;
    tf_data.tfname    = "$perf_metrics";
    tf_data.calltf    = perf_metrics;
    tf_data.compiletf = 0;
    tf_data.sizetf    = 0;
    tf_data.user_data = 0;
    vpi_register_systf(&tf_data);
}

void (*vlog_startup_routines[])() = {
    mem_read_register,
    mem_write_register,
    init_register,
    dump_register,
    perf_metrics_register,
    0
};






