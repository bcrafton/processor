#ifndef LIST_H_
#define LIST_H_

#include <stdio.h>
#include <stdlib.h>
#include <assert.h>

typedef void* LIST_TYPE;
typedef struct List List;
typedef struct Node Node;

struct Node {
	LIST_TYPE value;
	Node* next;
	Node* prev;
};

struct List{
	Node* head;
	Node* tail;
};

Node* node_constructor(LIST_TYPE value);
List* list_constructor();
void list_append(LIST_TYPE value, List* list);

#endif
