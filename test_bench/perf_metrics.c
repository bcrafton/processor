
#include "test_bench.h"

static unsigned long start_time = 0;
static unsigned long last_vld_time = 0;

static unsigned int instruction_counter;
static unsigned int double_instruction_counter;
static unsigned int single_instruction_counter;
static unsigned int no_instruction_counter;
static unsigned int flush_counter = 0;
static unsigned int stall_counter = 0;

static perf_metrics_t p;

PLI_INT32 perf_metrics(char* user_data)
{    
  assert(user_data == NULL);
  vpiHandle vhandle, iterator, arg;
  vhandle = vpi_handle(vpiSysTfCall, NULL);

  s_vpi_value inval;

  unsigned int time_h;
  unsigned int time_l;
  unsigned long current_time;

  unsigned int pc_stall;
  unsigned int branch_flush;
  unsigned int instruction0;
  unsigned int instruction1;

  unsigned int mem_wb_instruction0;
  unsigned int mem_wb_instruction1;

  iterator = vpi_iterate(vpiArgument, vhandle);

  arg = vpi_scan(iterator);
  inval.format = vpiTimeVal;
  vpi_get_value(arg, &inval);
  time_h = inval.value.time->high;
  time_l = inval.value.time->low;
  current_time = time_h;
  current_time = (current_time << BITS_IN_INT) | time_l;
  
  arg = vpi_scan(iterator);
  inval.format = vpiVectorVal;
  vpi_get_value(arg, &inval);
  pc_stall = inval.value.vector[0].aval;
  if(( (pc_stall & 0x7) == 0x7))
  {
    stall_counter++;
  }

  arg = vpi_scan(iterator);
  inval.format = vpiVectorVal;
  vpi_get_value(arg, &inval);
  branch_flush = inval.value.vector[0].aval;
  if((branch_flush == 1) && (inval.value.vector[0].bval == 0))
  {
    flush_counter++;
  }

  arg = vpi_scan(iterator);
  inval.format = vpiVectorVal;
  vpi_get_value(arg, &inval);
  instruction0 = inval.value.vector[0].aval;
  if((instruction0 > 0) && (inval.value.vector[0].bval == 0))
  {
  }

  arg = vpi_scan(iterator);
  inval.format = vpiVectorVal;
  vpi_get_value(arg, &inval);
  instruction1 = inval.value.vector[0].aval;
  if((instruction1 > 0) && (inval.value.vector[0].bval == 0))
  {
  }

  // inval.value.vector[0].aval will be considered signed for instructions with bit in 1
  // so that means just need to check to make sure its not 0.
  arg = vpi_scan(iterator);
  inval.format = vpiVectorVal;
  vpi_get_value(arg, &inval);
  mem_wb_instruction0 = inval.value.vector[0].aval;
  if(mem_wb_instruction0 != 0)
  {
    last_vld_time = current_time;
    instruction_counter++;
  }

  arg = vpi_scan(iterator);
  inval.format = vpiVectorVal;
  vpi_get_value(arg, &inval);
  mem_wb_instruction1 = inval.value.vector[0].aval;
  if(mem_wb_instruction1 != 0)
  {
    last_vld_time = current_time;
    instruction_counter++;
  }

  if(mem_wb_instruction0 != 0 && mem_wb_instruction1 != 0)
  {
    double_instruction_counter++;
  }
  else if(mem_wb_instruction0 != 0 || mem_wb_instruction1 != 0)
  {
    single_instruction_counter++;
  }
  else
  {
    no_instruction_counter++;
  }

  if(start_time == 0)
  {
    start_time = current_time;
  }

  return 0;
}

perf_metrics_t* get_perf_metrics()
{
  p.run_time = (last_vld_time - start_time) / 10;
  p.instruction_count = instruction_counter;

  p.double_instruction = double_instruction_counter;
  p.single_instruction = single_instruction_counter;
  p.no_instruction = no_instruction_counter;

  p.stall_count = stall_counter;
  p.flush_count = flush_counter;

  p.ipc =  (float)p.instruction_count / p.run_time;
  
  return &p;
}

void clear_perf_metrics()
{
  start_time = 0;
  last_vld_time = 0;
  instruction_counter = 0;
  stall_counter = 0;
  flush_counter = 0;

  double_instruction_counter = 0;
  single_instruction_counter = 0;
  no_instruction_counter = 0;
}






