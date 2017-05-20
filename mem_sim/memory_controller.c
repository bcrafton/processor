
#include "memory_simulator.h"

#define TEST_DURATION 500000

typedef enum test_type{
  BINARY_TEST,
  CODE_TEST,
  ASM_TEST,
} test_type_t;

typedef struct test{
  char name[25];
  test_type_t test_type;
  int ans;
} test_t;

static void dump_memory(int memory_id);
static void load_program();
static void clear_memory(int memory_id);
static bool check();
static bool check_binary();
static bool check_code();
static bool check_asm();
static bool next_test();


static WORD dmemory[DMEMORY_SIZE];
static REGISTER regfile[REGFILE_SIZE];
static INSTRUCTION imemory[IMEMORY_SIZE];

static TIME test_start_time;

static char buffer[100];

const char* binary_program_path = "../test/programs/bin/";
const char* code_program_path = "../test/programs/code/bin/";
const char* asm_program_path = "../test/programs/asm/bin/";

const char* actual_path = "../test/actual/";
const char* expected_path = "../test/expected/";

static test_t tests[] = {
/*
{"fn_add", BINARY_TEST, 0},

{"if_true", BINARY_TEST, 0},
{"if_false", BINARY_TEST, 0},
{"addi", BINARY_TEST, 0},
{"subi", BINARY_TEST, 0},
{"andi", BINARY_TEST, 0},

{"ori", BINARY_TEST, 0},
{"nandi", BINARY_TEST, 0},
{"nori", BINARY_TEST, 0},
{"movi", BINARY_TEST, 0},
{"sari", BINARY_TEST, 0},

{"shri", BINARY_TEST, 0},
{"shli", BINARY_TEST, 0},
{"xori", BINARY_TEST, 0},
{"add", BINARY_TEST, 0},
{"sub", BINARY_TEST, 0},

{"and", BINARY_TEST, 0},
{"or", BINARY_TEST, 0},
{"nand", BINARY_TEST, 0},
{"nor", BINARY_TEST, 0},
{"mov", BINARY_TEST, 0},

{"sar", BINARY_TEST, 0},
{"shr", BINARY_TEST, 0},
{"shl", BINARY_TEST, 0},
{"xor", BINARY_TEST, 0},
{"lw", BINARY_TEST, 0},

{"sw", BINARY_TEST, 0},
{"la", BINARY_TEST, 0},
{"sa", BINARY_TEST, 0},
{"jmp", BINARY_TEST, 0},
{"jo", BINARY_TEST, 0},

{"je", BINARY_TEST, 0},
{"jne", BINARY_TEST, 0},
{"jl", BINARY_TEST, 0},
{"jle", BINARY_TEST, 0},
{"jg", BINARY_TEST, 0},

{"jge", BINARY_TEST, 0},
{"jz", BINARY_TEST, 0},
{"jnz", BINARY_TEST, 0},
{"jr", BINARY_TEST, 0},

{"a", CODE_TEST, 60},
{"b", CODE_TEST, 60},
{"fn_add", CODE_TEST, 6},
{"if_false", CODE_TEST, 10},
{"if_true", CODE_TEST, 20},

{"fib0", CODE_TEST, 0},
{"fib1", CODE_TEST, 2},
{"fib2", CODE_TEST, 2},
{"fib3", CODE_TEST, 4},
{"fib4", CODE_TEST, 6},
{"fib5", CODE_TEST, 10},

{"to_10", CODE_TEST, 20},

{"mov", ASM_TEST, 0},
{"push", ASM_TEST, 100},
{"pop", ASM_TEST, 100},
{"push1", ASM_TEST, 100},

*/

{"fib4", CODE_TEST, 6},
{"fib5", CODE_TEST, 10},
{"fib10", CODE_TEST, 110},

};

static int test_counter = 0;
static int num_programs = sizeof(tests)/sizeof(test_t);
static test_t* current_test = NULL;

static PLI_INT32 mem_read(char* user_data)
{    
    assert(user_data == NULL);
    vpiHandle vhandle, iterator, arg;
    vhandle = vpi_handle(vpiSysTfCall, NULL);

    s_vpi_value inval;
    
    unsigned int rd_address;
    unsigned int memory_id;

    iterator = vpi_iterate(vpiArgument, vhandle);

    arg = vpi_scan(iterator);
    inval.format = vpiVectorVal;
    vpi_get_value(arg, &inval);
    rd_address = inval.value.vector[0].aval;
    if(inval.value.vector[0].bval > 0)
    {
      return 0;
    }

    arg = vpi_scan(iterator);
    inval.format = vpiIntVal;
    vpi_get_value(arg, &inval);
    memory_id = inval.value.integer;

    unsigned int rd_data;
    switch(memory_id)
    {
      case DMEM_ID:
        rd_data = dmemory[rd_address];
        break;
      case IMEM_ID:
        if (rd_address >= IMEMORY_SIZE) 
        {
          rd_data = 0;
        }
        else
        {
          rd_data = imemory[rd_address];
        }
        break;
      case REGFILE_ID:
        rd_data = regfile[rd_address];
        break;
      default:
        assert(0);
    }

    unsigned long bus_out;
    bus_out = rd_data;

    s_vpi_value out;
    out.format = vpiVectorVal;
    out.value.vector = (s_vpi_vecval*) malloc(sizeof(s_vpi_vecval) * 2);
    out.value.vector[0].aval = bus_out;
    out.value.vector[0].bval = 0;
    out.value.vector[1].aval = bus_out >> 32;
    out.value.vector[1].bval = 0;

    vpi_put_value(vhandle, &out, NULL, vpiNoDelay);

    return 0; 
}

static PLI_INT32 mem_write(char* user_data)
{    
    assert(user_data == NULL);
    vpiHandle vhandle, iterator, arg;
    vhandle = vpi_handle(vpiSysTfCall, NULL);

    s_vpi_value inval;
    
    unsigned int wr_address;
    unsigned int wr_data;
    unsigned int memory_id;

    iterator = vpi_iterate(vpiArgument, vhandle);
    
    arg = vpi_scan(iterator);
    inval.format = vpiVectorVal;
    vpi_get_value(arg, &inval);
    wr_address = inval.value.vector[0].aval;
    if(inval.value.vector[0].bval > 0)
    {
      return 0;
    }

    arg = vpi_scan(iterator);
    inval.format = vpiVectorVal;
    vpi_get_value(arg, &inval);
    wr_data = inval.value.vector[0].aval;
    if(inval.value.vector[0].bval > 0)
    {
      return 0;
    }

    arg = vpi_scan(iterator);
    inval.format = vpiIntVal;
    vpi_get_value(arg, &inval);
    memory_id = inval.value.integer;

    switch(memory_id)
    {
      case DMEM_ID:
        dmemory[wr_address] = wr_data;
        break;
      case IMEM_ID:
        imemory[wr_address] = wr_data;
        break;
      case REGFILE_ID:
        //printf("%x %x\n", wr_address, wr_data);
        regfile[wr_address] = wr_data;
        break;
    }
    
    return 0; 
}

static PLI_INT32 init(char* user_data)
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

static PLI_INT32 update(char* user_data)
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

    if(current_time - test_start_time > TEST_DURATION)
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

static void dump_memory(int memory_id)
{
  if(memory_id == DMEM_ID)
  {
    sprintf(buffer, "%s%s.mem", actual_path, current_test->name);
    
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
    sprintf(buffer, "%s%s.reg", actual_path, current_test->name);
    
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

static void load_program()
{
  switch(current_test->test_type)
  {
    case BINARY_TEST:
      sprintf(buffer, "%s%s.hex", binary_program_path, current_test->name);
      break;
    case CODE_TEST:
      sprintf(buffer, "%s%s.bc.s.hex", code_program_path, current_test->name);
      break;
    case ASM_TEST:
      sprintf(buffer, "%s%s.s.hex", asm_program_path, current_test->name);
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

static void clear_memory(int memory_id)
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

static bool check()
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

static bool check_code()
{
  REGISTER ans = current_test->ans;

  if(regfile[0] != ans)
  {
    return false;
  }

  return true;
}

static bool check_asm()
{
  REGISTER ans = current_test->ans;

  if(regfile[0] != ans)
  {
    return false;
  }

  return true;
}

static bool check_binary()
{

  WORD mem_val;
  REGISTER reg_val;
  int i;
  FILE *file;
  
  /////////////////

  sprintf(buffer, "%smem/%s.mem.expected", expected_path, current_test->name); 
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
  
  sprintf(buffer, "%sreg/%s.reg.expected", expected_path, current_test->name);  
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

static bool next_test()
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






