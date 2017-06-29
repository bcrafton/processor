
#ifndef HEADERS_H
#define HEADERS_H

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <assert.h>
#include <stdbool.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>

typedef unsigned int   uint32_t;
typedef unsigned short uint16_t;
typedef unsigned char  uint8_t;

typedef unsigned int WORD;
typedef unsigned int REGISTER;
typedef unsigned int INSTRUCTION;
typedef unsigned long TIME;
typedef unsigned char BYTE;
typedef unsigned char BOOL;

#define DMEMORY_SIZE 1024
#define DATA_WIDTH 32

#define IMEMORY_SIZE 256
#define INST_WIDTH 32

#define ADDRESS_WIDTH 16

#define REGFILE_SIZE 32
#define REG_WIDTH 32

#define BITS_IN_INT 32

#define DMEM_ID 0
#define IMEM_ID 1
#define REGFILE_ID 2

#define PC_MASK     0x01
#define IF_ID_MASK  0x02
#define ID_EX_MASK  0x04
#define EX_MEM_MASK 0x08
#define MEM_WB_MASK 0x10

#define FLUSH_MASK        (EX_MEM_MASK | ID_EX_MASK | IF_ID_MASK | PC_MASK)
#define STALL_LOAD_MASK   (IF_ID_MASK | PC_MASK)
#define STALL_FIRST_MASK  PC_MASK
#define STALL_SECOND_MASK (IF_ID_MASK | PC_MASK)

#define BINARY_PROGRAM_PATH   "../test_bench/programs/bin/"
#define CODE_PROGRAM_PATH     "../test_bench/programs/code/bin/"
#define ASM_PROGRAM_PATH      "../test_bench/programs/asm/bin/"

#define ACTUAL_PATH           "../test_bench/actual/"
#define EXPECTED_PATH         "../test_bench/expected/"

#define PERF_PATH             "../test_bench/performance/"

#endif
