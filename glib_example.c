
#include <glib.h>
#include <stdlib.h>
#include <stdio.h>

// sudo apt-get update
// sudo apt-get upgrade
// sudo apt-get install -f
// sudo apt-get install libglib2.0-dev
// gcc glib_example.c `pkg-config --cflags --libs glib-2.0`

// https://developer.gnome.org/glib/stable/glib-Balanced-Binary-Trees.html

int compare (gconstpointer a, gconstpointer b)
{
  return *((int*)a) > *((int*)b);
}

gboolean traverse(void* key, void* value, void* data)
{
  printf("%d\n", *((int*)value)); 
  return FALSE;
}

int main()
{

  int a = 1;
  int b = 2;
  int c = 3;
  int d = 4;
  int e = 5;
  int f = 6;

  GTree* t = g_tree_new(&compare);

  g_tree_insert(t, &a, &a);
  g_tree_insert(t, &b, &b);
  g_tree_insert(t, &c, &c);
  g_tree_insert(t, &d, &d);
  g_tree_insert(t, &e, &e);

  //int* val = g_tree_lookup(t, &x);
  //printf("%d\n", *val);

  g_tree_foreach(t, &traverse, NULL);

}
