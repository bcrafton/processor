
#include <vpi_user.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <assert.h>

///////////////////////////////////////////

#define DMEMORY_SIZE 1024
#define DATA_WIDTH 32

#define IMEMORY_SIZE 256
#define INST_WIDTH 16

#define ADDRESS_WIDTH 16

#define REGFILE_SIZE 32
#define REG_WIDTH 32

#define BITS_IN_INT 32

///////////////////////////////////////////

#define DMEM_ID 0
#define IMEM_ID 1
#define REGFILE_ID 2

///////////////////////////////////////////

typedef unsigned int WORD;
typedef unsigned int REGISTER;
typedef unsigned short INSTRUCTION;
typedef unsigned long TIME;
typedef unsigned char BYTE;
typedef unsigned char BOOL;

///////////////////////////////////////////

int time_compare(void *o1, void *o2);
int address_compare(void *o1, void *o2);







