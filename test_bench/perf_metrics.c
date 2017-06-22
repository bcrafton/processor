
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

void dump_perf_metrics(char* out_dir)
{  
  FILE *file;
  file = fopen(out_dir, "w");
  if(file == NULL)
  {
    fprintf(stderr, "could not find %s\n", out_dir);
    assert(0);
  }

  fprintf(file, "ipc = %f\n", p.ipc);
  fprintf(file, "instructions = %lu\n", p.instruction_count);
  fprintf(file, "run time = %lu\n", p.run_time);
  fprintf(file, "flushes = %u\n", p.flush_count);
  fprintf(file, "load stalls = %u\n", p.load_stall_count);
  fprintf(file, "split stalls = %u\n", p.split_stall_count);
  fprintf(file, "steer stalls = %u\n", p.steer_stall_count);
  fprintf(file, "branch count = %u\n", p.jump_count);
  fprintf(file, "unique branch count = %u\n", p.unique_jump_count);
  fprintf(file, "branch predict percent = %f\n", p.branch_predict_percent);

  fclose(file);
}





