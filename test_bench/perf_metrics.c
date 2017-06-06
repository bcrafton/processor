
#include "test_bench.h"

static unsigned long start_time;
static unsigned long last_vld_time;

static unsigned int instruction_counter;
static unsigned int flush_counter;

static unsigned int load_stall_counter;
static unsigned int steer_stall_counter;
static unsigned int split_stall_counter;

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

  unsigned int stall0;
  unsigned int stall1;
  unsigned int steer_stall;

  unsigned int flush;

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
  if (inval.value.vector[0].bval == 0) {
    stall0 = inval.value.vector[0].aval;
  }
  else {
    stall0 = 0;
  }

  arg = vpi_scan(iterator);
  inval.format = vpiVectorVal;
  vpi_get_value(arg, &inval);
  if (inval.value.vector[0].bval == 0) {
    stall1 = inval.value.vector[0].aval;
  }
  else {
    stall1 = 0;
  }

  arg = vpi_scan(iterator);
  inval.format = vpiVectorVal;
  vpi_get_value(arg, &inval);
  if (inval.value.vector[0].bval == 0) {
    steer_stall = inval.value.vector[0].aval;
  }
  else {
    steer_stall = 0;
  }

  arg = vpi_scan(iterator);
  inval.format = vpiVectorVal;
  vpi_get_value(arg, &inval);
  if (inval.value.vector[0].bval == 0) {
    flush = inval.value.vector[0].aval;
  }
  else {
    flush = 0;
  }

  // inval.value.vector[0].aval will be considered signed for instructions with bit in 1
  // so that means just need to check to make sure its not 0.
  arg = vpi_scan(iterator);
  inval.format = vpiVectorVal;
  vpi_get_value(arg, &inval);
  if (inval.value.vector[0].bval == 0) {
    mem_wb_instruction0 = inval.value.vector[0].aval;
  }
  else {
    mem_wb_instruction0 = 0;
  }

  arg = vpi_scan(iterator);
  inval.format = vpiVectorVal;
  vpi_get_value(arg, &inval);
  if (inval.value.vector[0].bval == 0) {
    mem_wb_instruction1 = inval.value.vector[0].aval;
  }
  else {
    mem_wb_instruction1 = 0;
  }

  /////////////////////////////////////////////////////////

  if (mem_wb_instruction0 != 0)
  {
    instruction_counter++;
    last_vld_time = current_time;
  }
  if (mem_wb_instruction1 != 0)
  {
    instruction_counter++;
    last_vld_time = current_time;
  }

  if ((flush & 0xf) == 0xf)
  {
    flush_counter++;
  }

  if ( ((stall0 & 0x3) == 0x3) && ((stall1 & 0x3) == 0x3) )
  {
    load_stall_counter++;
  }
  else if ( (((stall0 & 0x3) == 0x3) && ((stall1 & 0x1) == 0x1)) || 
            (((stall1 & 0x3) == 0x3) && ((stall0 & 0x1) == 0x1)) )
  {
    split_stall_counter++;
  }
  else if(steer_stall == 1)
  {
    steer_stall_counter++;
  }

  /////////////////////////////////////////////////////////

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

  p.load_stall_count = load_stall_counter;
  p.steer_stall_count = steer_stall_counter;
  p.split_stall_count = split_stall_counter;

  p.flush_count = flush_counter;

  p.ipc =  (float)p.instruction_count / p.run_time;

  return &p;
}

void clear_perf_metrics()
{
  start_time = 0;
  last_vld_time = 0;

  instruction_counter = 0;

  load_stall_counter = 0;
  steer_stall_counter = 0;
  split_stall_counter = 0;

  flush_counter = 0;
}






