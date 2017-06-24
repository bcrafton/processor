#ifndef PERF_METRICS_H
#define PERF_METRICS_H

#include "../common/defines.h"
#include <vpi_user.h>

typedef struct perf_metrics_t{
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

typedef struct instructon_log {
  unsigned long timestamp;

  unsigned int mem_wb_pc0;
  unsigned int mem_wb_pc1;

  unsigned int mem_wb_instruction0;
  unsigned int mem_wb_instruction1;

  unsigned int mem_wb_read_data0_0;
  unsigned int mem_wb_read_data0_1;
  unsigned int mem_wb_read_data1_0;
  unsigned int mem_wb_read_data1_1;

  unsigned int mem_wb_write_data0;
  unsigned int mem_wb_write_data1;
} instruction_log_t;

PLI_INT32 perf_metrics(char* user_data);
void dump_perf_metrics(char* out_dir);

#endif
