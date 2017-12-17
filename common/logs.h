#ifndef LOGS_H
#define LOGS_H

#include "defines.h"
#include <glib.h>

typedef struct instructon_log {
  // do we want to include all addresses.

  // we can order the instructions by commited timestamp
  // all we have to do is put timestamp in whenever instruction is commited.
  unsigned long timestamp;
  unsigned long id;

  unsigned int pc; // already got it.

  unsigned int instruction; // already got it

  unsigned int immediate; // ex_mem, mem_wb

  unsigned int reg_read_data0; // ex_mem, mem_wb
  unsigned int reg_read_data1; // ex_mem, mem_wb
  unsigned int reg_write_data; // ex_mem, mem_wb

  unsigned int mem_read_data; // already got it.
  unsigned int mem_write_data; // mem_wb

  unsigned int alu_in0; // mem_wb
  unsigned int alu_in1; // mem_wb
  unsigned int alu_out; // already got it

  unsigned int zero; // ex_mem, mem_wb
  unsigned int greater; // ex_mem, mem_wb
  unsigned int less; // ex_mem, mem_wb


  unsigned int branch_taken; 
  unsigned int branch_taken_address;
  unsigned int branch_imm_address;
  unsigned int branch_reg_address;

} instruction_log_t;

/*
So realized
We needed to maek the instruction log
On a per instruction basis
Not have 2 of everything

For perf log
We need to have all of them to get the conds
So I think 
This must change
We want to keep this log general
So that means
Insead of sending over all the values
We shud just send the metrics over
And let the sim convert it to the correct format

That way it stays general.
*/

typedef struct perf_log {

  unsigned long timestamp;

  unsigned int stall0;
  unsigned int stall1;
  unsigned int steer_stall;

  unsigned int flush;

  unsigned int mem_wb_instruction0;
  unsigned int mem_wb_instruction1;

  unsigned int id_ex_jop;
  unsigned int id_ex_pc;

} perf_log_t;

typedef struct perf_metrics{
  float ipc;
  float branch_predict_percent;

  uint32_t flush_count;
  unsigned long int instruction_count;
  unsigned long int run_time;

  uint32_t load_stall_count;
  uint32_t split_stall_count;
  uint32_t steer_stall_count;

  uint32_t jump_count;
  uint32_t unique_jump_count;

} perf_metrics_t;

void dump_instruction_logs(char* out_dir);
void clear_instruction_logs();
void instruction_log(instruction_log_t* log);
instruction_log_t* get_instruction_log(void *key);

instruction_log_t* new_instruction_log();

void dump_perf_metrics(char* out_dir);
void clear_perf_metrics();
void perf_metrics(perf_log_t* log);

#endif
