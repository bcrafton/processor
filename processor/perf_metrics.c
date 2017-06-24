
#include "perf_metrics.h"

static unsigned long start_time;
static unsigned long last_vld_time;

static unsigned int instruction_counter;
static unsigned int flush_counter;

static unsigned int load_stall_counter;
static unsigned int split_stall_counter;
static unsigned int steer_stall_counter;

static unsigned int jump_counter;

static unsigned int jumps[100];
static unsigned int next_jump_idx;

static perf_metrics_t p;

static bool contains(unsigned int pc)
{
  int i;
  for(i=0; i<100; i++) {
    if(jumps[i] == pc){
      return true;
    }
  }
  return false;
}

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

  unsigned int id_ex_jop;
  unsigned int id_ex_pc;

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

  arg = vpi_scan(iterator);
  inval.format = vpiVectorVal;
  vpi_get_value(arg, &inval);
  if (inval.value.vector[0].bval == 0) {
    id_ex_jop = inval.value.vector[0].aval;
  }
  else {
    id_ex_jop = 0;
  }

  arg = vpi_scan(iterator);
  inval.format = vpiVectorVal;
  vpi_get_value(arg, &inval);
  if (inval.value.vector[0].bval == 0) {
    id_ex_pc = inval.value.vector[0].aval;
  }
  else {
    id_ex_pc = 0;
  }

/*
  if (id_ex_jop != 0 && ((flush & FLUSH_MASK) == FLUSH_MASK) )
    printf("%d %d\n", id_ex_pc, id_ex_jop);
*/

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

  if ((flush & FLUSH_MASK) == FLUSH_MASK)
  {
    flush_counter++;
  }

  if ( ((stall0 & STALL_LOAD_MASK) == STALL_LOAD_MASK) && ((stall1 & STALL_LOAD_MASK) == STALL_LOAD_MASK) )
  {
    load_stall_counter++;
  }
  else if ( ( ((stall0 & STALL_SECOND_MASK) == STALL_SECOND_MASK) && ((stall1 & STALL_FIRST_MASK) == STALL_FIRST_MASK) ) || 
            ( ((stall1 & STALL_SECOND_MASK) == STALL_SECOND_MASK) && ((stall0 & STALL_FIRST_MASK) == STALL_FIRST_MASK) ) )
  {
    split_stall_counter++;
  }
  else if(steer_stall == 1)
  {
    steer_stall_counter++;
  }

  if(id_ex_jop != 0 && id_ex_jop != 1)
  {
    jump_counter++;

    if(!contains(id_ex_pc))
    {
      jumps[next_jump_idx] = id_ex_pc;
      next_jump_idx++;
    }
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
  p.split_stall_count = split_stall_counter;
  p.steer_stall_count = steer_stall_counter;

  p.flush_count = flush_counter;

  p.jump_count = jump_counter;
  p.unique_jump_count = next_jump_idx;

  p.ipc =  (float)p.instruction_count / p.run_time;

  if(p.jump_count > 0) {
    p.branch_predict_percent = 1.0 - ((float)p.flush_count / p.jump_count);
  }
  else {
    p.branch_predict_percent = 0;
  }

  return &p;
}

void clear_perf_metrics()
{
  start_time = 0;
  last_vld_time = 0;

  instruction_counter = 0;

  load_stall_counter = 0;
  split_stall_counter = 0;
  steer_stall_counter = 0;

  flush_counter = 0;
  jump_counter = 0;

  int i;
  for(i=0; i<100; i++) {
    jumps[i] = 0;
  }

  next_jump_idx = 0;
}

void dump_perf_metrics(char* out_dir)
{  
  perf_metrics_t* perf = get_perf_metrics();

  FILE *file;
  char filepath[100];

  sprintf(filepath, "%s/perf", out_dir);

  file = fopen(filepath, "w");
  if(file == NULL)
  {
    fprintf(stderr, "could not find %s\n", filepath);
    assert(0);
  }

  fprintf(file, "ipc = %f\n", perf->ipc);
  fprintf(file, "instructions = %lu\n", perf->instruction_count);
  fprintf(file, "run time = %lu\n", perf->run_time);
  fprintf(file, "flushes = %u\n", perf->flush_count);
  fprintf(file, "load stalls = %u\n", perf->load_stall_count);
  fprintf(file, "split stalls = %u\n", perf->split_stall_count);
  fprintf(file, "steer stalls = %u\n", perf->steer_stall_count);
  fprintf(file, "branch count = %u\n", perf->jump_count);
  fprintf(file, "unique branch count = %u\n", perf->unique_jump_count);
  fprintf(file, "branch predict percent = %f\n", perf->branch_predict_percent);

  fclose(file);
}





