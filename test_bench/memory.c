
#include "memory.h"

WORD dmemory[DMEMORY_SIZE];
REGISTER regfile[REGFILE_SIZE];
INSTRUCTION imemory[IMEMORY_SIZE];

WORD mem_read(WORD address, uint8_t memory_id)
{    
  WORD data;
  switch(memory_id)
  {
    case DMEM_ID:
      if (address >= DMEMORY_SIZE || address < 0)
      {
        fprintf(stderr, "dmemory read out of bounds %d\n", address);
        assert(0);
      }
      else
      {
        data = dmemory[address];
      }
      break;
    case IMEM_ID:
      if (address >= IMEMORY_SIZE) 
      {
        data = 0;
      }
      else
      {
        data = imemory[address];
      }
      break;
    case REGFILE_ID:
      if (address >= REGFILE_SIZE || address < 0)
      {
        fprintf(stderr, "reg read out of bounds %d\n", address);
        assert(0);
      }
      else
      {
        data = regfile[address];
      }
      break;
    default:
      fprintf(stderr, "invalid memory id: %d", memory_id);
      assert(0);
  }
  return data;
}

WORD mem_write(WORD address, WORD data, uint8_t memory_id)
{    
  switch(memory_id)
  {
    case DMEM_ID:
      if (address >= DMEMORY_SIZE || address < 0)
      {
        fprintf(stderr, "dmemory write out of bounds %d\n", address);
        assert(0);
      }
      else
      {
        dmemory[address] = data;
      }
      break;
    case IMEM_ID:
      fprintf(stderr, "cannot write to i memory\n");
      assert(0);
      break;
    case REGFILE_ID:
      if (address >= REGFILE_SIZE || address < 0)
      {
        fprintf(stderr, "reg file write out of bounds %d\n", address);
        assert(0);
      }
      else
      {
        regfile[address] = data;
      }
      break;
    default:
      fprintf(stderr, "invalid memory id: %d", memory_id);
      assert(0);
  }
  return 0;
}

void dump_memory(char* out_dir, char* test_name)
{
  int i;
  char buffer[100];
  FILE *file;

  sprintf(buffer, "%s%s.mem", out_dir, test_name);
  file = fopen(buffer, "w");
  if(file == NULL)
  {
    fprintf(stderr, "could not find %s\n", buffer);
    assert(0);
  }

  for(i=0; i<DMEMORY_SIZE; i++)
  {
      fprintf(file, "%08x\n", dmemory[i]);
  }

  fclose(file);

  sprintf(buffer, "%s%s.reg", out_dir, test_name);
  
  file = fopen(buffer, "w");
  if(file == NULL)
  {
    fprintf(stderr, "could not find %s\n", buffer);
    assert(0);
  }

  for(i=0; i<REGFILE_SIZE; i++)
  {
      fprintf(file, "%08x\n", regfile[i]);
  }

  fclose(file);
}

void load_program(char* program_dir, char* test_name)
{
  char buffer[100];
  sprintf(buffer, "%s%s", program_dir, test_name);

  FILE *file;
  file = fopen(buffer, "r");
  if(file == NULL)
  {
    fprintf(stderr, "could not find %s\n", buffer);
    assert(0);
  }

  // assert if we are too big
  int i;
  for(i=0; i<IMEMORY_SIZE; i++)
  {
    if(!fscanf(file, "%x", &imemory[i]))
      break;
  }
}

void memory_clear()
{
  memset(dmemory, 0, sizeof(WORD) * DMEMORY_SIZE);
  memset(regfile, 0, sizeof(REGISTER) * REGFILE_SIZE);
  memset(imemory, 0, sizeof(INSTRUCTION) * IMEMORY_SIZE);
}


