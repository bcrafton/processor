
#include "test_bench.h"

WORD dmemory[DMEMORY_SIZE];
REGISTER regfile[REGFILE_SIZE];
INSTRUCTION imemory[IMEMORY_SIZE];

PLI_INT32 mem_read(char* user_data)
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

    unsigned int rd_data;
    switch(memory_id)
    {
      case DMEM_ID:
        if (rd_address >= DMEMORY_SIZE || rd_address < 0)
        {
          assert(0);
        }
        else
        {
          rd_data = dmemory[rd_address];
        }
        break;
      case IMEM_ID:
        if (rd_address >= IMEMORY_SIZE) 
        {
          rd_data = 0;
        }
        else
        {
          rd_data = imemory[rd_address];
        }
        break;
      case REGFILE_ID:
        if (rd_address >= REGFILE_SIZE || rd_address < 0)
        {
          assert(0);
        }
        else
        {
          rd_data = regfile[rd_address];
        }
        break;
      default:
        assert(0);
    }

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

PLI_INT32 mem_write(char* user_data)
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

    switch(memory_id)
    {
      case DMEM_ID:
        if (wr_address >= DMEMORY_SIZE || wr_address < 0)
        {
          fprintf(stderr, "dmemory write out of bounds %d\n", wr_address);
          assert(0);
        }
        else
        {
          dmemory[wr_address] = wr_data;
        }
        break;
      case IMEM_ID:
        fprintf(stderr, "cannot write to i memory\n");
        assert(0);
        break;
      case REGFILE_ID:
        if (wr_address >= REGFILE_SIZE || wr_address < 0)
        {
          fprintf(stderr, "reg file write out of bounds %d\n", wr_address);
          assert(0);
        }
        else
        {
          regfile[wr_address] = wr_data;
        }
        break;
    }
    
    return 0; 
}


