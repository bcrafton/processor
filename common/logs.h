#ifndef LOGS_H
#define LOGS_H

#include "defines.h"

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

void dump_instruction_logs(char* out_dir);
void clear_instruction_logs();
void instruction_log(instruction_log_t* log);

#endif
