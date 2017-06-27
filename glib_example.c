
#include <glib.h>
#include <stdlib.h>

// sudo apt-get update
// sudo apt-get upgrade
// sudo apt-get install -f
// sudo apt-get install libglib2.0-dev
// gcc glib_example.c `pkg-config --cflags --libs glib-2.0`

// https://developer.gnome.org/glib/stable/glib-Balanced-Binary-Trees.html

int compare (gconstpointer a, gconstpointer b)
{
  return *(int*)a > *(int*)b;
}


int main()
{

  int x = 10;
  int y = 5;
  GTree* t = g_tree_new(&compare);
  g_tree_insert(t, &x, &y);
  int* val = g_tree_lookup(t, &x);
  printf("%d\n", *val);

}
