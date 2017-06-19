#ifndef MEMORY_H
#define MEMORY_H

#include "defines.h"

void dump_memory(char* out_dir, char* test_name);
void load_program(char* program_dir, char* test_name);
WORD mem_read(WORD address, uint8_t memory_id);
WORD mem_write(WORD address, WORD data, uint8_t memory_id);
void memory_clear();

#endif
