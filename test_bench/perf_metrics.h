#ifndef PERF_METRICS_H
#define PERF_METRICS_H

#include "defines.h"
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

PLI_INT32 perf_metrics(char* user_data);
void dump_perf_metrics(char* out_dir);

#endif
