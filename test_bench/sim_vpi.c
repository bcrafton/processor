
#include "sim_vpi.h"

static char test_name[100];
static char program_dir[100];
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
    strcpy(test_name, inval.value.str);
    assert(test_name != NULL);

    arg = vpi_scan(iterator);
    inval.format = vpiStringVal;
    vpi_get_value(arg, &inval);
    strcpy(program_dir, inval.value.str);
    assert(program_dir != NULL);

    arg = vpi_scan(iterator);
    inval.format = vpiStringVal;
    vpi_get_value(arg, &inval);
    strcpy(out_dir, inval.value.str);
    assert(out_dir != NULL);

    load_program(program_dir, test_name);

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
    
    dump_memory(out_dir, test_name);
    dump_perf_metrics(out_dir, test_name);

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
    tf_data.calltf    = perf_metrics;
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
    0
};

