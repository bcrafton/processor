
#include "memory_simulator.h"

#define TEST_DURATION 1000

typedef enum test_type{
  BINARY_TEST,
  CODE_TEST,
} test_type_t;

typedef struct test{
  char name[25];
  test_type_t test_type;

} test_t;

static void dump_memory(int memory_id, const char* test_name);
static void load_program(test_t* t);
static void clear_memory(int memory_id);
static bool check(test_t* t);
static bool check_binary(const char* test_name);
static bool check_code();


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

{"fn_add", BINARY_TEST},

{"if_true", BINARY_TEST},
{"if_false", BINARY_TEST},
{"addi", BINARY_TEST},
{"subi", BINARY_TEST},
{"andi", BINARY_TEST},

{"ori", BINARY_TEST},
{"nandi", BINARY_TEST},
{"nori", BINARY_TEST},
{"movi", BINARY_TEST},
{"sari", BINARY_TEST},

{"shri", BINARY_TEST},
{"shli", BINARY_TEST},
{"xori", BINARY_TEST},
{"add", BINARY_TEST},
{"sub", BINARY_TEST},

{"and", BINARY_TEST},
{"or", BINARY_TEST},
{"nand", BINARY_TEST},
{"nor", BINARY_TEST},
{"mov", BINARY_TEST},

{"sar", BINARY_TEST},
{"shr", BINARY_TEST},
{"shl", BINARY_TEST},
{"xor", BINARY_TEST},
{"lw", BINARY_TEST},

{"sw", BINARY_TEST},
{"la", BINARY_TEST},
{"sa", BINARY_TEST},
{"jmp", BINARY_TEST},
{"jo", BINARY_TEST},

{"je", BINARY_TEST},
{"jne", BINARY_TEST},
{"jl", BINARY_TEST},
{"jle", BINARY_TEST},
{"jg", BINARY_TEST},

{"jge", BINARY_TEST},
{"jz", BINARY_TEST},
{"jnz", BINARY_TEST},
{"jr", BINARY_TEST},

{"if_true", CODE_TEST},
{"if_false", CODE_TEST},

};


static int program_number;
static int num_programs = sizeof(tests)/sizeof(test_t);

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
        rd_data = imemory[rd_address];
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

    program_number = 0;

    load_program(&(tests[program_number]));

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

      bool pass = check(&(tests[program_number]));
      if(pass)
      {
        printf("Test %s: Passed\n", tests[program_number].name);
      }
      else
      {
        printf("Test %s: Failed\n", tests[program_number].name);
      }

      // dump memory
      dump_memory(DMEM_ID, tests[program_number].name);
      dump_memory(REGFILE_ID, tests[program_number].name);

      // reset = 1
      reset = 1;

      // clear memory
      clear_memory(DMEM_ID);
      clear_memory(IMEM_ID);
      clear_memory(REGFILE_ID);

      // reset start time
      test_start_time = current_time;

      program_number++;

      if(program_number < num_programs)
      {
        load_program(&(tests[program_number]));
      }
      else
      {
        complete = 1;
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

static void dump_memory(int memory_id, const char* test_name)
{
  if(memory_id == DMEM_ID)
  {
    sprintf(buffer, "%s%s.mem", actual_path, test_name);
    
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
    sprintf(buffer, "%s%s.reg", actual_path, test_name);
    
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

static void load_program(test_t* t)
{
  switch(t->test_type)
  {
    case BINARY_TEST:
      sprintf(buffer, "%s%s.hex", binary_program_path, t->name);
      break;
    case CODE_TEST:
      sprintf(buffer, "%s%s.bc.s.hex", code_program_path, t->name);
      break;
    default:
      fprintf(stderr, "invalid enum %s = %d\n", t->name, t->test_type);
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

static bool check(test_t *t)
{
  switch(t->test_type)
  {
    case BINARY_TEST:
      return check_binary(t->name);
      break;
    case CODE_TEST:
      return check_code();
      break;
    default:
      fprintf(stderr, "invalid enum %d\n", t->test_type);
      assert(0);
  }
}

static bool check_code(int test_number)
{
  REGISTER eax = 0x14;

  if(regfile[0] != eax)
  {
    return false;
  }

  return true;
}

static bool check_binary(const char* test_name)
{

  WORD mem_val;
  REGISTER reg_val;
  int i;
  FILE *file;
  
  /////////////////

  sprintf(buffer, "%smem/%s.mem.expected", expected_path, test_name); 
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
  
  sprintf(buffer, "%sreg/%s.reg.expected", expected_path, test_name);  
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






