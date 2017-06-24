#ifndef VECTOR_H_
#define VECTOR_H_

#include <stdio.h>
#include <stdlib.h>
#include <assert.h>

typedef void* VECTOR_TYPE;
typedef struct Vector Vector;

struct Vector{
	int next;
	int capacity;
	VECTOR_TYPE *array;
	void (*vector_print_function)(void*);
	int (*vector_compare_function)(void*, void*);
};


// make sure not code breaks, after changing size to capacity.
// next should be kept, so the next location to enter data in.
// but calling vector_size() shud return the current number of non-null elements in the vector.

Vector* vector_constructor_print( void (*vector_print_function)(void*) );;
Vector* vector_constructor();
Vector* vector_constructor_capacity(int capacity);
Vector* vector_constructor_compare( void (*vector_print_function)(void*), int (*vector_compare_function)(void*, void*) );
void  vector_resize(Vector *vector);
void vector_add(VECTOR_TYPE value, Vector *vector);
void vector_print(Vector *vector);
VECTOR_TYPE vector_get(int index, Vector *vector);
void vector_removeIndex(int index, Vector *vector);
void vector_insert(int index, VECTOR_TYPE value, Vector *vector);
void vector_swap(int index1, int index2, Vector *vector);
int vector_size(Vector *vector);
VECTOR_TYPE linear_search(VECTOR_TYPE value, Vector *vector);
void vector_set(int index, VECTOR_TYPE value, Vector *vector);

#endif
