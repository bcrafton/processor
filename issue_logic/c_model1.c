
#include <stdio.h>

int depends [3 * 16];

int main()
{
  int i;
  for(i=0; i<3*16; i++)
  {
    depends[i] = i;
  }

  for(i=0; i<8; i++)
  {
    // gives us valid nums
    //int a = i * 3 + 3 - 1;
    //int b = i * 3;

    // more valids
    // int a = (i*2) * 3 - 3 - 1;
    // int b = (i*2) * 3 - 3 - 1;

    //int a = ((i+1)*2) * 3 - 3 - 1;
    //int b = (i*2) * 3;

    //int a = 6 * i + 3 - 1;
    //int b = 6 * i;

    //int a = 6 * i + 3 - 1;
    //int b = 6 * i;

    int a = 2*3*i + 3 - 1;
    int b = 2*3*i;

    printf("0 : %d:%d\n", a, b);
  }

  for(i=0; i<8; i++)
  {
    //int a = ((i+1)*2) * 3 - 1;
    //int b = ((i+1)*2) * 3 - 3;

    //int a = 6 * i + 6 - 1;
    //int b = 6 * i + 6 - 3;

    int a = 2*3*i + 6 - 1;
    int b = 2*3*i + 3;

    printf("1 : %d:%d\n", a, b);
  }

}

// 6*i 
// 6*i + 3 - 1
// 6*i + 3
// 6*i + 6 - 1

// 0 3 6 9 12 15
// 0 3     12 15
// 3 9 15

// we need to go up by 6 at a time.
// think of the sequence we are trying to create 1 at a time
// its not that hard

