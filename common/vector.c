#include "vector.h"

// this is a list, so it uses list behavior on insertions, sets, and removes.
// shud these methods be booleans? so as to return true if it was done correctly.

static void set_null(VECTOR_TYPE *array, int capacity);
static int print(VECTOR_TYPE v, Vector *vector);
static int compare(VECTOR_TYPE v1, VECTOR_TYPE v2, Vector *vector);

//code reuse of the defualt constructor here, was not tested ... may cause bugs
Vector* vector_constructor(){
	Vector *newVector = malloc(sizeof(Vector));
	newVector->capacity = 10;
	newVector->next = 0;
	newVector->array = malloc(newVector->capacity * sizeof(VECTOR_TYPE));
	set_null(newVector->array, newVector->capacity);
	newVector->vector_print_function = NULL;
	newVector->vector_compare_function = NULL;
	return newVector;
}

Vector* vector_constructor_print(void (*vector_print_function)(void*)){
	Vector *newVector = vector_constructor();
	newVector->vector_print_function = vector_print_function;
	return newVector;
}

Vector* vector_constructor_capacity(int capacity){
	Vector *newVector = malloc(sizeof(Vector));
	newVector->capacity = capacity;
	newVector->next = 0;
	newVector->array = malloc(newVector->capacity * sizeof(VECTOR_TYPE));
	set_null(newVector->array, newVector->capacity);
	newVector->vector_print_function = NULL;
	newVector->vector_compare_function = NULL;
	return newVector;
}

Vector* vector_constructor_compare( void (*vector_print_function)(void*), int (*vector_compare_function)(void*, void*) ){
	Vector *newVector = vector_constructor();
	newVector->vector_print_function = vector_print_function;
	newVector->vector_compare_function = vector_compare_function;
	return newVector;
}

void vector_resize(Vector *vector){
	vector->capacity = vector->capacity * 2;
	VECTOR_TYPE *newArray = malloc(vector->capacity * sizeof(VECTOR_TYPE));
	set_null(newArray, vector->capacity);
	int indexCounter;
	for(indexCounter = 0; indexCounter < vector->next; indexCounter++){
		newArray[indexCounter] = vector->array[indexCounter];
	}
	vector->array = newArray;
}

void vector_add(VECTOR_TYPE value, Vector *vector){
	if(vector->next >= vector->capacity){
		vector_resize(vector);
	}
	vector->array[vector->next] = value;
	vector->next++;
}

void vector_print(Vector *vector){
	int indexCounter;
	for(indexCounter = 0; indexCounter < vector->next; indexCounter++){
		print(vector->array[indexCounter], vector);
		printf("|");
	}
	printf("[%d]\n", vector->next);
}

VECTOR_TYPE vector_get(int index, Vector *vector){
	return vector->array[index];
}

void vector_removeIndex(int index, Vector *vector){
	if(index >= vector->next || index < 0){
		printf("index is out of bounds.\n");
		assert(0);
		return;
	}

	int indexCounter;
	for(indexCounter = index; indexCounter < vector->next-1; indexCounter++){
		vector->array[indexCounter] = vector->array[indexCounter+1];
	}
	vector->array[vector->next] = NULL;
	vector->next--;
}

void vector_insert(int index, VECTOR_TYPE value, Vector *vector){
	if(index > vector->next || index < 0){
		printf("index is out of bounds.\n");
		assert(0);
		return;
	}
	if(vector->next >= vector->capacity){vector_resize(vector);}
	int indexCounter;
	for(indexCounter = vector->next; indexCounter >= index; indexCounter--){
		vector->array[indexCounter] = vector->array[indexCounter-1];
	}
	vector->array[index] = value;
	vector->next++;
}

void vector_set(int index, VECTOR_TYPE value, Vector *vector){
	if(index >= vector->next || index < 0){
		printf("index is out of bounds.\n");
		assert(0);
		return;
	}
	vector->array[index] = value;
}

void vector_swap(int index1, int index2, Vector *vector){
	VECTOR_TYPE temp = vector->array[index1];
	vector->array[index1] = vector->array[index2];
	vector->array[index2] = temp;
}

int vector_size(Vector *vector){
	return vector->next;
}

VECTOR_TYPE linear_search(VECTOR_TYPE value, Vector *vector){
	int indexCounter = 0;
	for(indexCounter = 0; indexCounter < vector_size(vector); indexCounter++){
		if( compare(value, vector_get(indexCounter, vector), vector) == 0 ){
			return vector_get(indexCounter, vector);
		}
	}
  return NULL;
}

static void set_null(VECTOR_TYPE *array, int capacity){
	int indexCounter = 0;
	for(indexCounter = 0; indexCounter < capacity; indexCounter++){
		array[indexCounter] = NULL;
	}
}

static int print(VECTOR_TYPE v, Vector *vector){
	(*(vector->vector_print_function))(v);
  return 0;
}

static int compare(VECTOR_TYPE v1, VECTOR_TYPE v2, Vector *vector){
	return (*(vector->vector_compare_function))(v1, v2);
}
