
#include "memory_simulator.h"

#define TEST_DURATION 1000

static void dump_memory(int memory_id, const char* test_name);
static void load_program(char* filename);
static void clear_memory(int memory_id);
static bool check(const char* test_name);

static WORD dmemory[DMEMORY_SIZE];
static REGISTER regfile[REGFILE_SIZE];
static INSTRUCTION imemory[IMEMORY_SIZE];

static TIME test_start_time;

static char buffer[100];
const char* program_path = "../test/programs/binary/src/";
const char* actual_path = "../test/actual/";
const char* expected_path = "../test/expected/";

const char* tests[] = {

"fn_add",
"if_true",
"if_false",

"addi",
"subi",
//"noti",
"andi",
"ori",
"nandi",
"nori",
"movi",
"sari",
"shri",
"shli",
"xori",

"add",
"sub",
//"not",
"and",
"or",
"nand",
"nor",
"mov",
"sar",
"shr",
"shl",
"xor",

"lw",
"sw",
"la",

"sa",
"jmp",
"jo",
"je",
"jne",
"jl",
"jle",
"jg",
"jge",
"jz",
"jnz",
"jr",



};


static int program_number;
static int num_programs = sizeof(tests)/sizeof(const char*);

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

    // load program
    sprintf(buffer, "%s%s.hex", program_path, tests[program_number]);
    load_program(buffer);

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

      bool pass = check(tests[program_number]);
      if(pass)
      {
        printf("Test %s: Passed\n", tests[program_number]);
      }
      else
      {
        printf("Test %s: Failed\n", tests[program_number]);
      }

      // dump memory
      dump_memory(DMEM_ID, tests[program_number]);
      dump_memory(REGFILE_ID, tests[program_number]);

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
        // load next program
        sprintf(buffer, "%s%s.hex", program_path, tests[program_number]);
        load_program(buffer);
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

static void load_program(char* filename)
{
  FILE *file;
  file = fopen(filename, "r");
  if(file == NULL)
  {
    fprintf(stderr, "could not find %s\n", filename);
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

static bool check(const char* test_name)
{

  WORD mem_val;
  REGISTER reg_val;
  int i;
  FILE *file;
  
  /////////////////

  sprintf(buffer, "%s/mem/%s.mem.expected", expected_path, test_name);  
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
  
  sprintf(buffer, "%s/reg/%s.reg.expected", expected_path, test_name);  
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






