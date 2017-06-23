#include "list.h"

Node* node_constructor(LIST_TYPE value){
	Node *node = malloc(sizeof(Node));
	node->next = NULL;
	node->prev = NULL;
	node->value = value;
  return node;
}

List* list_constructor(){
	List *list = malloc(sizeof(List));
	list->head = NULL;
	list->tail = NULL;
	return list;
}

void list_append(LIST_TYPE value, List* list){
	Node* newNode = node_constructor(value);
	if(list->head == NULL && list->tail == NULL){
		list->head = newNode;
		list->tail = newNode;
	}
	else{
		list->tail->next = newNode;
		newNode->prev = list->tail;
		list->tail = newNode;
	}
}
