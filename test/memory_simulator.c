
#include "memory_simulator.h"

int time_compare(void *o1, void *o2){
	return *((unsigned long*)o1) - *((unsigned long*)o2);
}

int address_compare(void *o1, void *o2){
	return *((WORD*)o1) - *((WORD*)o2);
}
