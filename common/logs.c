
#include "logs.h"

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

static GTree* instruction_log_tree = NULL;

int compare (gconstpointer a, gconstpointer b)
{

  unsigned long num1 = *((unsigned long*)a);
  unsigned long num2 = *((unsigned long*)b);

  if( num1 > num2 )
  {
    return 1;
  }
  else if ( num1 < num2 )
  {
    return -1;
  }
  else
  {
    return 0;
  }
}

gboolean traverse(void* key, void* value, void* data)
{
  instruction_log_t* log = (instruction_log_t*) value;
  FILE* file = (FILE*) data;

  if (log->instruction != 0)
  {
    // dont really care about the rest of them right now.
    fprintf(file, "@%08lu 0x%08lx %03d 0x%08x 0x%04x 0x%04x %d %04x %04x %04x\n", 
      log->timestamp,
      log->id,
      log->pc,
      log->instruction,

      log->alu_in0,
      log->alu_in1,

      log->branch_taken,
      log->branch_taken_address,
      log->branch_imm_address,
      log->branch_reg_address

      );
  }
  return FALSE;
}

void dump_instruction_logs(char* out_dir)
{
  FILE *file;
  char filepath[100];
  //int i;

  sprintf(filepath, "%s/logs", out_dir);

  file = fopen(filepath, "w");
  if(file == NULL)
  {
    fprintf(stderr, "could not find %s\n", filepath);
    assert(0);
  }

  if (instruction_log_tree != NULL) {
    g_tree_foreach(instruction_log_tree, &traverse, file);
  }

  fclose(file);
}

void clear_instruction_logs()
{}

instruction_log_t* new_instruction_log()
{
  instruction_log_t* new_log = (instruction_log_t*) malloc(sizeof(instruction_log_t));
  new_log->timestamp = 0;
  new_log->id = 0;
  new_log->pc = 0;
  new_log->instruction = 0;
  new_log->immediate = 0;

  new_log->reg_read_data0 = 0;
  new_log->reg_read_data1 = 0;
  new_log->reg_write_data = 0;

  new_log->mem_read_data = 0;
  new_log->mem_write_data = 0;

  new_log->alu_in0 = 0;
  new_log->alu_in1 = 0;
  new_log->alu_out = 0;

  new_log->zero = 0;
  new_log->greater = 0;
  new_log->less = 0;

  new_log->branch_taken = 0;
  return new_log;
}

void instruction_log(instruction_log_t* log)
{
  if(instruction_log_tree == NULL)
  {
    instruction_log_tree = g_tree_new(&compare);
  }
  g_tree_insert(instruction_log_tree, &(log->id), log);
}

instruction_log_t* get_instruction_log(void *key)
{
  if (instruction_log_tree == NULL) {
    return NULL;
  }
  instruction_log_t* log = g_tree_lookup(instruction_log_tree, key);
  return log;
}

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

void perf_metrics(perf_log_t* log)
{
  if (log->mem_wb_instruction0 != 0)
  {
    instruction_counter++;
    last_vld_time = log->timestamp;
  }
  if (log->mem_wb_instruction1 != 0)
  {
    instruction_counter++;
    last_vld_time = log->timestamp;
  }

  if ((log->flush & FLUSH_MASK) == FLUSH_MASK)
  {
    flush_counter++;
  }

  if ( ((log->stall0 & STALL_LOAD_MASK) == STALL_LOAD_MASK) && ((log->stall1 & STALL_LOAD_MASK) == STALL_LOAD_MASK) )
  {
    load_stall_counter++;
  }
  else if ( ( ((log->stall0 & STALL_SECOND_MASK) == STALL_SECOND_MASK) && ((log->stall1 & STALL_FIRST_MASK) == STALL_FIRST_MASK) ) || 
            ( ((log->stall1 & STALL_SECOND_MASK) == STALL_SECOND_MASK) && ((log->stall0 & STALL_FIRST_MASK) == STALL_FIRST_MASK) ) )
  {
    split_stall_counter++;
  }
  else if(log->steer_stall == 1)
  {
    steer_stall_counter++;
  }

  if(log->id_ex_jop != 0 && log->id_ex_jop != 1)
  {
    jump_counter++;

    if(!contains(log->id_ex_pc))
    {
      jumps[next_jump_idx] = log->id_ex_pc;
      next_jump_idx++;
    }
  }

  if(start_time == 0)
  {
    start_time = log->timestamp;
  }
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
