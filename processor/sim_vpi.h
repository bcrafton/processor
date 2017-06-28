#ifndef SIM_VPI_H
#define SIM_VPI_H

#include <vpi_user.h>
#include "../common/memory.h"
#include "../common/defines.h"
#include "../common/logs.h"

PLI_INT32 sim_mem_read(char* user_data);
PLI_INT32 sim_mem_write(char* user_data);
PLI_INT32 init(char* user_data);
PLI_INT32 dump(char* user_data);

PLI_INT32 sim_perf_metrics(char* user_data);

#endif
