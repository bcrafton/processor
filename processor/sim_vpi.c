
#include "sim_vpi.h"

static char in_dir[100];
static char out_dir[100];

PLI_INT32 init(char* user_data)
{    
    assert(user_data == NULL);
    vpiHandle vhandle, iterator, arg;
    vhandle = vpi_handle(vpiSysTfCall, NULL);

    s_vpi_value inval;

    iterator = vpi_iterate(vpiArgument, vhandle);

    arg = vpi_scan(iterator);
    inval.format = vpiStringVal;
    vpi_get_value(arg, &inval);
    strcpy(in_dir, inval.value.str);
    assert(in_dir != NULL);

    arg = vpi_scan(iterator);
    inval.format = vpiStringVal;
    vpi_get_value(arg, &inval);
    strcpy(out_dir, inval.value.str);
    assert(out_dir != NULL);

    load_program(in_dir);

    return 0; 
}

PLI_INT32 dump(char* user_data)
{    
    assert(user_data == NULL);
    vpiHandle vhandle, iterator, arg;
    vhandle = vpi_handle(vpiSysTfCall, NULL);

    s_vpi_value inval;

    iterator = vpi_iterate(vpiArgument, vhandle);

    arg = vpi_scan(iterator);
    inval.format = vpiTimeVal;
    vpi_get_value(arg, &inval);
    
    dump_memory(out_dir);
    dump_perf_metrics(out_dir);
    dump_instruction_logs(out_dir);

    return 0; 
}

PLI_INT32 sim_mem_read(char* user_data)
{    
    assert(user_data == NULL);
    vpiHandle vhandle, iterator, arg;
    vhandle = vpi_handle(vpiSysTfCall, NULL);

    s_vpi_value inval;
    
    unsigned int rd_address;
    unsigned int memory_id;

    iterator = vpi_iterate(vpiArgument, vhandle);

    arg = vpi_scan(iterator);
    inval.format = vpiVectorVal;
    vpi_get_value(arg, &inval);
    rd_address = inval.value.vector[0].aval;
    if(inval.value.vector[0].bval > 0)
    {
      return 0;
    }

    arg = vpi_scan(iterator);
    inval.format = vpiIntVal;
    vpi_get_value(arg, &inval);
    memory_id = inval.value.integer;

    WORD rd_data = mem_read(rd_address, memory_id);

    unsigned long bus_out;
    bus_out = rd_data;

    s_vpi_value out;
    out.format = vpiVectorVal;
    out.value.vector = (s_vpi_vecval*) malloc(sizeof(s_vpi_vecval) * 2);
    out.value.vector[0].aval = bus_out;
    out.value.vector[0].bval = 0;
    out.value.vector[1].aval = bus_out >> 32;
    out.value.vector[1].bval = 0;

    vpi_put_value(vhandle, &out, NULL, vpiNoDelay);

    return 0; 
}

PLI_INT32 sim_mem_write(char* user_data)
{    
    assert(user_data == NULL);
    vpiHandle vhandle, iterator, arg;
    vhandle = vpi_handle(vpiSysTfCall, NULL);

    s_vpi_value inval;
    
    unsigned int wr_address;
    unsigned int wr_data;
    unsigned int memory_id;

    iterator = vpi_iterate(vpiArgument, vhandle);
    
    arg = vpi_scan(iterator);
    inval.format = vpiVectorVal;
    vpi_get_value(arg, &inval);
    wr_address = inval.value.vector[0].aval;
    if(inval.value.vector[0].bval > 0)
    {
      return 0;
    }

    arg = vpi_scan(iterator);
    inval.format = vpiVectorVal;
    vpi_get_value(arg, &inval);
    wr_data = inval.value.vector[0].aval;
    if(inval.value.vector[0].bval > 0)
    {
      return 0;
    }

    arg = vpi_scan(iterator);
    inval.format = vpiIntVal;
    vpi_get_value(arg, &inval);
    memory_id = inval.value.integer;

    mem_write(wr_address, wr_data, memory_id);
    
    return 0; 
}

PLI_INT32 sim_instruction_log(char* user_data)
{    
  assert(user_data == NULL);
  vpiHandle vhandle, iterator, arg;
  vhandle = vpi_handle(vpiSysTfCall, NULL);

  s_vpi_value inval;

  unsigned int time_h;
  unsigned int time_l;
  unsigned long current_time;

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
    mem_wb_pc0 = inval.value.vector[0].aval;
  }
  else {
    mem_wb_pc0 = 0;
  }

  arg = vpi_scan(iterator);
  inval.format = vpiVectorVal;
  vpi_get_value(arg, &inval);
  if (inval.value.vector[0].bval == 0) {
    mem_wb_pc1 = inval.value.vector[0].aval;
  }
  else {
    mem_wb_pc1 = 0;
  }

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

  arg = vpi_scan(iterator);
  inval.format = vpiVectorVal;
  vpi_get_value(arg, &inval);
  if (inval.value.vector[0].bval == 0) {
    mem_wb_read_data0_0 = inval.value.vector[0].aval;
  }
  else {
    mem_wb_read_data0_0 = 0;
  }

  arg = vpi_scan(iterator);
  inval.format = vpiVectorVal;
  vpi_get_value(arg, &inval);
  if (inval.value.vector[0].bval == 0) {
    mem_wb_read_data0_1 = inval.value.vector[0].aval;
  }
  else {
    mem_wb_read_data0_1 = 0;
  }

  arg = vpi_scan(iterator);
  inval.format = vpiVectorVal;
  vpi_get_value(arg, &inval);
  if (inval.value.vector[0].bval == 0) {
    mem_wb_read_data1_0 = inval.value.vector[0].aval;
  }
  else {
    mem_wb_read_data1_0 = 0;
  }

  arg = vpi_scan(iterator);
  inval.format = vpiVectorVal;
  vpi_get_value(arg, &inval);
  if (inval.value.vector[0].bval == 0) {
    mem_wb_read_data1_1 = inval.value.vector[0].aval;
  }
  else {
    mem_wb_read_data1_1 = 0;
  }

  arg = vpi_scan(iterator);
  inval.format = vpiVectorVal;
  vpi_get_value(arg, &inval);
  if (inval.value.vector[0].bval == 0) {
    mem_wb_write_data0 = inval.value.vector[0].aval;
  }
  else {
    mem_wb_write_data0 = 0;
  }

  arg = vpi_scan(iterator);
  inval.format = vpiVectorVal;
  vpi_get_value(arg, &inval);
  if (inval.value.vector[0].bval == 0) {
    mem_wb_write_data1 = inval.value.vector[0].aval;
  }
  else {
    mem_wb_write_data1 = 0;
  }

  instruction_log_t* log0 = (instruction_log_t*) malloc(sizeof(instruction_log_t));
  instruction_log_t* log1 = (instruction_log_t*) malloc(sizeof(instruction_log_t));

  log0->timestamp = current_time;
  log1->timestamp = current_time;

  log0->pc = mem_wb_pc0;
  log1->pc = mem_wb_pc1;

  log0->instruction = mem_wb_instruction0;
  log1->instruction = mem_wb_instruction1;

  log0->reg_read_data0 = mem_wb_read_data0_0;
  log1->reg_read_data0 = mem_wb_read_data0_1;

  log0->reg_read_data1 = mem_wb_read_data1_0;
  log1->reg_read_data1 = mem_wb_read_data1_1;

  log0->reg_write_data = mem_wb_write_data0;
  log1->reg_write_data = mem_wb_write_data1;

  if(log0->pc < log1->pc)
  {
    instruction_log(log0);
    instruction_log(log1);
  }
  else
  {
    instruction_log(log1);
    instruction_log(log0);
  }

  return 0;
}

PLI_INT32 sim_perf_metrics(char* user_data)
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

  // probably need to half this ... meaning give pipe 0 and 1 their own struct
  // shud not combine to same.
  // take that back would be way to annoying to fix this.
  perf_log_t* log = (perf_log_t*) malloc(sizeof(perf_log_t));

  log->timestamp = current_time;

  log->stall0 = stall0;
  log->stall1 = stall1;
  log->steer_stall = steer_stall;

  log->flush = flush;

  log->mem_wb_instruction0 = mem_wb_instruction0;
  log->mem_wb_instruction1 = mem_wb_instruction1;

  log->id_ex_jop = id_ex_jop;
  log->id_ex_pc = id_ex_pc;

  perf_metrics(log);

  return 0;
}

void mem_read_register(void)
{
    s_vpi_systf_data tf_data;
    tf_data.type        = vpiSysFunc;
    tf_data.sysfunctype = vpiIntFunc;
    tf_data.tfname    = "$mem_read";
    tf_data.calltf    = sim_mem_read;
    tf_data.compiletf = 0;
    tf_data.sizetf    = 0;
    tf_data.user_data = 0;
    vpi_register_systf(&tf_data);
}

void mem_write_register(void)
{
    s_vpi_systf_data tf_data;
    tf_data.type        = vpiSysFunc;
    tf_data.sysfunctype = vpiIntFunc;
    tf_data.tfname    = "$mem_write";
    tf_data.calltf    = sim_mem_write;
    tf_data.compiletf = 0;
    tf_data.sizetf    = 0;
    tf_data.user_data = 0;
    vpi_register_systf(&tf_data);
}

void init_register(void)
{
    s_vpi_systf_data tf_data;
    tf_data.type        = vpiSysFunc;
    tf_data.sysfunctype = vpiIntFunc;
    tf_data.tfname    = "$init";
    tf_data.calltf    = init;
    tf_data.compiletf = 0;
    tf_data.sizetf    = 0;
    tf_data.user_data = 0;
    vpi_register_systf(&tf_data);
}

void dump_register(void)
{
    s_vpi_systf_data tf_data;
    tf_data.type        = vpiSysFunc;
    tf_data.sysfunctype = vpiIntFunc;
    tf_data.tfname    = "$dump";
    tf_data.calltf    = dump;
    tf_data.compiletf = 0;
    tf_data.sizetf    = 0;
    tf_data.user_data = 0;
    vpi_register_systf(&tf_data);
}

void perf_metrics_register(void)
{
    s_vpi_systf_data tf_data;
    tf_data.type        = vpiSysFunc;
    tf_data.sysfunctype = vpiIntFunc;
    tf_data.tfname    = "$perf_metrics";
    tf_data.calltf    = sim_perf_metrics;
    tf_data.compiletf = 0;
    tf_data.sizetf    = 0;
    tf_data.user_data = 0;
    vpi_register_systf(&tf_data);
}

void instruction_log_register(void)
{
    s_vpi_systf_data tf_data;
    tf_data.type        = vpiSysFunc;
    tf_data.sysfunctype = vpiIntFunc;
    tf_data.tfname    = "$instruction_log";
    tf_data.calltf    = sim_instruction_log;
    tf_data.compiletf = 0;
    tf_data.sizetf    = 0;
    tf_data.user_data = 0;
    vpi_register_systf(&tf_data);
}

void (*vlog_startup_routines[])() = {
    mem_read_register,
    mem_write_register,
    init_register,
    dump_register,
    perf_metrics_register,
    instruction_log_register,
    0
};

