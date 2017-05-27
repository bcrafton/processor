
#include "test_bench.h"

extern WORD dmemory[DMEMORY_SIZE];
extern REGISTER regfile[REGFILE_SIZE];
extern INSTRUCTION imemory[IMEMORY_SIZE];

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

{"fn_add", BINARY_TEST, 0, 1000},
{"if_true", BINARY_TEST, 0, 1000},
{"if_false", BINARY_TEST, 0, 1000},

{"a", CODE_TEST, 60, 10000},
{"b", CODE_TEST, 60, 10000},
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

{"to_10", CODE_TEST, 20, 10000},

{"mov", ASM_TEST, 0, 1000},
{"push", ASM_TEST, 100, 1000},
{"pop", ASM_TEST, 100, 1000},
{"push1", ASM_TEST, 100, 1000},

};

static TIME test_start_time;
static int test_counter = 0;
static int num_programs = sizeof(tests)/sizeof(test_t);
static test_t* current_test = NULL;

PLI_INT32 init(char* user_data)
{    
    assert(user_data == NULL);
    vpiHandle vhandle, iterator, arg;
    vhandle = vpi_handle(vpiSysTfCall, NULL);

    s_vpi_value inval;
    
    unsigned int memory_id;
    unsigned int time_h;
    unsigned int time_l;
    unsigned long current_time;

    iterator = vpi_iterate(vpiArgument, vhandle);

    arg = vpi_scan(iterator);
    inval.format = vpiIntVal;
    vpi_get_value(arg, &inval);
    memory_id = inval.value.integer;
    assert(memory_id == IMEM_ID);

    arg = vpi_scan(iterator);
    inval.format = vpiTimeVal;
    vpi_get_value(arg, &inval);
    time_h = inval.value.time->high;
    time_l = inval.value.time->low;
    
    current_time = time_h;
    current_time = (current_time << BITS_IN_INT) | time_l;

    test_start_time = current_time;

    next_test();
    load_program();

    return 0; 
}

PLI_INT32 update(char* user_data)
{    
    assert(user_data == NULL);
    vpiHandle vhandle, iterator, arg;
    vhandle = vpi_handle(vpiSysTfCall, NULL);

    s_vpi_value inval;
    
    unsigned int time_h;
    unsigned int time_l;
    unsigned long current_time;

    int reset = 0;
    int complete = 0;

    iterator = vpi_iterate(vpiArgument, vhandle);

    arg = vpi_scan(iterator);
    inval.format = vpiTimeVal;
    vpi_get_value(arg, &inval);
    time_h = inval.value.time->high;
    time_l = inval.value.time->low;
    
    current_time = time_h;
    current_time = (current_time << BITS_IN_INT) | time_l;

    if(current_time - test_start_time > current_test->sim_time)
    {

      bool pass = check();
      if(pass)
      {
        printf("Test %s: Passed\n", current_test->name);
      }
      else
      {
        printf("Test %s: Failed\n", current_test->name);
      }

      // dump memory
      dump_memory(DMEM_ID);
      dump_memory(REGFILE_ID);

      // reset = 1
      reset = 1;

      // clear memory
      clear_memory(DMEM_ID);
      clear_memory(IMEM_ID);
      clear_memory(REGFILE_ID);

      // reset start time
      test_start_time = current_time;

      if(!next_test())
      {
        complete = 1;
      }
      else
      {
        load_program();
      }
    }

    unsigned long bus_out;
    bus_out = reset;
    bus_out = (bus_out << 1) | complete;

    s_vpi_value out;
    out.format = vpiVectorVal;
    out.value.vector = (s_vpi_vecval*) malloc(sizeof(s_vpi_vecval));
    out.value.vector[0].aval = bus_out;
    out.value.vector[0].bval = 0;

    vpi_put_value(vhandle, &out, NULL, vpiNoDelay);

    return 0; 
}

void dump_memory(int memory_id)
{
  char buffer[100];
  if(memory_id == DMEM_ID)
  {
    sprintf(buffer, "%s%s.mem", ACTUAL_PATH, current_test->name);
    
    FILE *file;
    file = fopen(buffer, "w");
    if(file == NULL)
    {
      fprintf(stderr, "could not find %s\n", buffer);
      assert(0);
    }
    
    int i;
    for(i=0; i<DMEMORY_SIZE; i++)
    {
        fprintf(file, "%08x\n", dmemory[i]);
    }

    fclose(file);
  }
  else if(memory_id == REGFILE_ID)
  {
    sprintf(buffer, "%s%s.reg", ACTUAL_PATH, current_test->name);
    
    FILE *file;
    file = fopen(buffer, "w");
    if(file == NULL)
    {
      fprintf(stderr, "could not find %s\n", buffer);
      assert(0);
    }

    int i;
    for(i=0; i<REGFILE_SIZE; i++)
    {
        fprintf(file, "%08x\n", regfile[i]);
    }

    fclose(file);
  }
  else
  {
    assert(0);
  }
}

void load_program()
{
  char buffer[100];
  switch(current_test->test_type)
  {
    case BINARY_TEST:
      sprintf(buffer, "%s%s.hex", BINARY_PROGRAM_PATH, current_test->name);
      break;
    case CODE_TEST:
      sprintf(buffer, "%s%s.bc.s.hex", CODE_PROGRAM_PATH, current_test->name);
      break;
    case ASM_TEST:
      sprintf(buffer, "%s%s.s.hex", ASM_PROGRAM_PATH, current_test->name);
      break;
    default:
      fprintf(stderr, "invalid enum %s = %d\n", current_test->name, current_test->test_type);
      assert(0);
  }
  
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

void clear_memory(int memory_id)
{
  switch(memory_id)
  {
    case DMEM_ID:
      memset(&dmemory[0], 0, DMEMORY_SIZE * sizeof(WORD));
      break;
    case IMEM_ID:
      memset(&imemory[0], 0, IMEMORY_SIZE * sizeof(INSTRUCTION));
      break;
    case REGFILE_ID:
      memset(&regfile[0], 0, REGFILE_SIZE * sizeof(REGISTER));
      break;
    default:
      assert(0);
  }
}

bool check()
{
  switch(current_test->test_type)
  {
    case BINARY_TEST:
      //printf("%d\n", check_binary());
      return check_binary();
      break;
    case CODE_TEST:
      return check_code();
      break;
    case ASM_TEST:
      return check_asm();
      break;
    default:
      fprintf(stderr, "invalid enum %d\n", current_test->test_type);
      assert(0);
  }
  fprintf(stderr, "impossible");
  assert(0);
}

bool check_code()
{
  REGISTER ans = current_test->ans;

  if(regfile[0] != ans)
  {
    return false;
  }

  return true;
}

bool check_asm()
{
  REGISTER ans = current_test->ans;

  if(regfile[0] != ans)
  {
    return false;
  }

  return true;
}

bool check_binary()
{
  WORD mem_val;
  REGISTER reg_val;
  int i;
  FILE *file;
  char buffer[100];
  
  /////////////////

  sprintf(buffer, "%smem/%s.mem.expected", EXPECTED_PATH, current_test->name); 
  //printf("%s\n", buffer);
  file = fopen(buffer, "r");
  if(file == NULL)
  {
    fprintf(stderr, "could not find %s\n", buffer);
    assert(0);
  }
  
  for(i=0; i<DMEMORY_SIZE; i++)
  {
    if(!fscanf(file, "%x", &mem_val))
    {
      fprintf(stderr, "file does not contain enough words");
      assert(0);
    }
    if(mem_val != dmemory[i])
    {
      return false;
    }
  }
  fclose(file);

  /////////////////
  
  sprintf(buffer, "%sreg/%s.reg.expected", EXPECTED_PATH, current_test->name);  
  //printf("%s\n", buffer);
  file = fopen(buffer, "r");
  if(file == NULL)
  {
    fprintf(stderr, "could not find %s\n", buffer);
    assert(0);
  }

  for(i=0; i<REGFILE_SIZE; i++)
  {
    if(!fscanf(file, "%x", &reg_val))
    {
      fprintf(stderr, "file does not contain enough words");
      assert(0);
    }
    if(reg_val != regfile[i])
    {
      return false;
    }
  }
  fclose(file);

  /////////////////

  return true;

}

bool next_test()
{
  if(test_counter == 0 && current_test == NULL)
  {
    current_test = &tests[test_counter];
    return true;
  }
  test_counter++;
  if(test_counter == num_programs)
  {
    return false;
  }
  current_test = &tests[test_counter];
  return true;
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

void update_register(void)
{
    s_vpi_systf_data tf_data;
    tf_data.type        = vpiSysFunc;
    tf_data.sysfunctype = vpiIntFunc;
    tf_data.tfname    = "$update";
    tf_data.calltf    = update;
    tf_data.compiletf = 0;
    tf_data.sizetf    = 0;
    tf_data.user_data = 0;
    vpi_register_systf(&tf_data);
}

void (*vlog_startup_routines[])() = {
    mem_read_register,
    mem_write_register,
    init_register,
    update_register,
    0
};






