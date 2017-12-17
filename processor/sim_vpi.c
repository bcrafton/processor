
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

PLI_INT32 sim_log_id_ex(char* user_data)
{    
  assert(user_data == NULL);
  vpiHandle vhandle, iterator, arg;
  vhandle = vpi_handle(vpiSysTfCall, NULL);

  s_vpi_value inval;

  unsigned int id_h;
  unsigned int id_l;
  unsigned long id;

  unsigned int mem_wb_read_data0;
  unsigned int mem_wb_read_data1;

  unsigned int alu_in0;
  unsigned int alu_in1;

  //unsigned int branch_pc; this shud be implicit

  unsigned int branch_taken;
  unsigned int branch_taken_address;
  unsigned int branch_imm_address;
  unsigned int branch_reg_address;

  iterator = vpi_iterate(vpiArgument, vhandle);

  arg = vpi_scan(iterator);
  inval.format = vpiVectorVal;
  vpi_get_value(arg, &inval);

  if (inval.value.vector[0].bval == 0 && inval.value.vector[1].bval == 0) {
    // we had these in the wrong order. was overflowing.
    id_l = inval.value.vector[0].aval;
    id_h = inval.value.vector[1].aval;
    id = id_h;
    id = (id << BITS_IN_INT) | id_l;
  }
  else {
    id = 0;
  }
  
  //printf("%lx\n", id);

  arg = vpi_scan(iterator);
  inval.format = vpiVectorVal;
  vpi_get_value(arg, &inval);
  if (inval.value.vector[0].bval == 0) {
    mem_wb_read_data0 = inval.value.vector[0].aval;
  }
  else {
    mem_wb_read_data0 = 0;
  }

  arg = vpi_scan(iterator);
  inval.format = vpiVectorVal;
  vpi_get_value(arg, &inval);
  if (inval.value.vector[0].bval == 0) {
    mem_wb_read_data1 = inval.value.vector[0].aval;
  }
  else {
    mem_wb_read_data1 = 0;
  }

  arg = vpi_scan(iterator);
  inval.format = vpiVectorVal;
  vpi_get_value(arg, &inval);
  if (inval.value.vector[0].bval == 0) {
    alu_in0 = inval.value.vector[0].aval;
  }
  else {
    alu_in0 = 0;
  }

  arg = vpi_scan(iterator);
  inval.format = vpiVectorVal;
  vpi_get_value(arg, &inval);
  if (inval.value.vector[0].bval == 0) {
    alu_in1 = inval.value.vector[0].aval;
  }
  else {
    alu_in1 = 0;
  }

  arg = vpi_scan(iterator);
  inval.format = vpiVectorVal;
  vpi_get_value(arg, &inval);
  if (inval.value.vector[0].bval == 0) {
    branch_taken = inval.value.vector[0].aval;
  }
  else {
    branch_taken = 0;
  }

  arg = vpi_scan(iterator);
  inval.format = vpiVectorVal;
  vpi_get_value(arg, &inval);
  if (inval.value.vector[0].bval == 0) {
    branch_taken_address = inval.value.vector[0].aval;
  }
  else {
    branch_taken_address = 0;
  }

  arg = vpi_scan(iterator);
  inval.format = vpiVectorVal;
  vpi_get_value(arg, &inval);
  if (inval.value.vector[0].bval == 0) {
    branch_imm_address = inval.value.vector[0].aval;
  }
  else {
    branch_imm_address = 0;
  }

  arg = vpi_scan(iterator);
  inval.format = vpiVectorVal;
  vpi_get_value(arg, &inval);
  if (inval.value.vector[0].bval == 0) {
    branch_reg_address = inval.value.vector[0].aval;
  }
  else {
    branch_reg_address = 0;
  }

  instruction_log_t* log = get_instruction_log(&id);
  if(log == NULL)
  {
    instruction_log_t* new_log = new_instruction_log();

    new_log->id = id;
    new_log->reg_read_data0 = mem_wb_read_data0;
    new_log->reg_read_data1 = mem_wb_read_data1;

    new_log->alu_in0 = alu_in0;
    new_log->alu_in1 = alu_in1;


    new_log->branch_taken = branch_taken;
    new_log->branch_taken_address = branch_taken_address;
    new_log->branch_imm_address = branch_imm_address;
    new_log->branch_reg_address = branch_reg_address;

    instruction_log(new_log);
  }
  else
  {
    log->reg_read_data0 = mem_wb_read_data0;
    log->reg_read_data1 = mem_wb_read_data1;

    log->alu_in0 = alu_in0;
    log->alu_in1 = alu_in1;


    log->branch_taken = branch_taken;
    log->branch_taken_address = branch_taken_address;
    log->branch_imm_address = branch_imm_address;
    log->branch_reg_address = branch_reg_address;
  }

  return 0;
}

PLI_INT32 sim_log_ex_mem(char* user_data)
{    
  assert(user_data == NULL);
  vpiHandle vhandle, iterator, arg;
  vhandle = vpi_handle(vpiSysTfCall, NULL);

  s_vpi_value inval;

  unsigned int id_h;
  unsigned int id_l;
  unsigned long id;

  unsigned int mem_read_data;
  unsigned int mem_write_data;

  iterator = vpi_iterate(vpiArgument, vhandle);

  arg = vpi_scan(iterator);
  inval.format = vpiVectorVal;
  vpi_get_value(arg, &inval);

  if (inval.value.vector[0].bval == 0 && inval.value.vector[1].bval == 0) {
    // we had these in the wrong order. was overflowing.
    id_l = inval.value.vector[0].aval;
    id_h = inval.value.vector[1].aval;
    id = id_h;
    id = (id << BITS_IN_INT) | id_l;
  }
  else {
    id = 0;
  }

  arg = vpi_scan(iterator);
  inval.format = vpiVectorVal;
  vpi_get_value(arg, &inval);
  if (inval.value.vector[0].bval == 0) {
    mem_read_data = inval.value.vector[0].aval;
  }
  else {
    mem_read_data = 0;
  }

  arg = vpi_scan(iterator);
  inval.format = vpiVectorVal;
  vpi_get_value(arg, &inval);
  if (inval.value.vector[0].bval == 0) {
    mem_write_data = inval.value.vector[0].aval;
  }
  else {
    mem_write_data = 0;
  }

  instruction_log_t* log = get_instruction_log(&id);
  if(log == NULL)
  {
    instruction_log_t* new_log = (instruction_log_t*) malloc(sizeof(instruction_log_t));

    new_log->id = id;
    new_log->mem_read_data = mem_read_data;
    new_log->mem_write_data = mem_write_data;

    instruction_log(new_log);
  }
  else
  {
    log->mem_read_data = mem_read_data;
    log->mem_write_data = mem_write_data;
  }

  return 0;
}

PLI_INT32 sim_log_mem_wb(char* user_data)
{    
  assert(user_data == NULL);
  vpiHandle vhandle, iterator, arg;
  vhandle = vpi_handle(vpiSysTfCall, NULL);

  s_vpi_value inval;

  unsigned int id_h;
  unsigned int id_l;
  unsigned long id;

  unsigned int time_h;
  unsigned int time_l;
  unsigned long current_time;

  unsigned int mem_wb_pc;
  unsigned int mem_wb_instruction;

  unsigned int reg_write_data;

  iterator = vpi_iterate(vpiArgument, vhandle);

  arg = vpi_scan(iterator);
  inval.format = vpiVectorVal;
  vpi_get_value(arg, &inval);

  if (inval.value.vector[0].bval == 0 && inval.value.vector[1].bval == 0) {
    // we had these in the wrong order. was overflowing.
    id_l = inval.value.vector[0].aval;
    id_h = inval.value.vector[1].aval;
    id = id_h;
    id = (id << BITS_IN_INT) | id_l;
  }
  else {
    id = 0;
  }
  
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
    mem_wb_pc = inval.value.vector[0].aval;
  }
  else {
    mem_wb_pc = 0;
  }

  arg = vpi_scan(iterator);
  inval.format = vpiVectorVal;
  vpi_get_value(arg, &inval);
  if (inval.value.vector[0].bval == 0) {
    mem_wb_instruction = inval.value.vector[0].aval;
  }
  else {
    mem_wb_instruction = 0;
  }

  arg = vpi_scan(iterator);
  inval.format = vpiVectorVal;
  vpi_get_value(arg, &inval);
  if (inval.value.vector[0].bval == 0) {
    reg_write_data = inval.value.vector[0].aval;
  }
  else {
    reg_write_data = 0;
  }

  instruction_log_t* log = get_instruction_log(&id);
  if(log == NULL)
  {
    instruction_log_t* new_log = (instruction_log_t*) malloc(sizeof(instruction_log_t));

    new_log->id = id;
    new_log->pc = mem_wb_pc;
    new_log->instruction = mem_wb_instruction;
    new_log->timestamp = current_time;
    new_log->reg_write_data = reg_write_data;

    instruction_log(new_log);
  }
  else
  {
    log->pc = mem_wb_pc;
    log->instruction = mem_wb_instruction;
    log->timestamp = current_time;
    log->reg_write_data = reg_write_data;
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

void log_id_ex_register(void)
{
    s_vpi_systf_data tf_data;
    tf_data.type        = vpiSysFunc;
    tf_data.sysfunctype = vpiIntFunc;
    tf_data.tfname    = "$log_id_ex";
    tf_data.calltf    = sim_log_id_ex;
    tf_data.compiletf = 0;
    tf_data.sizetf    = 0;
    tf_data.user_data = 0;
    vpi_register_systf(&tf_data);
}

void log_ex_mem_register(void)
{
    s_vpi_systf_data tf_data;
    tf_data.type        = vpiSysFunc;
    tf_data.sysfunctype = vpiIntFunc;
    tf_data.tfname    = "$log_ex_mem";
    tf_data.calltf    = sim_log_ex_mem;
    tf_data.compiletf = 0;
    tf_data.sizetf    = 0;
    tf_data.user_data = 0;
    vpi_register_systf(&tf_data);
}

void log_mem_wb_register(void)
{
    s_vpi_systf_data tf_data;
    tf_data.type        = vpiSysFunc;
    tf_data.sysfunctype = vpiIntFunc;
    tf_data.tfname    = "$log_mem_wb";
    tf_data.calltf    = sim_log_mem_wb;
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
    log_id_ex_register,
    log_ex_mem_register,
    log_mem_wb_register,
    0
};

