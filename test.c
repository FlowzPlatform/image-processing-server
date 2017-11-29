// #include<stdio.h>
// // function prototype, also called function declaration
// int *swap(int a, int b);
//
// int main()
// {
//     int m = 22, n = 44;
//     // calling swap function by value
//     printf(" values before swap  m = %d \nand n = %d", m, n);
//     swap(m, n);
// }
//
// int *swap(int a, int b)
// {
//     int tmp, ret[2];
//     tmp = a;
//     a = b;
//     b = tmp;
//     ret[0] = a;
//     ret[1] = b;
//
//     return ret;
//     // printf(" \nvalues after swap m = %d\n and n = %d", a, b);
// }


#include <stdio.h>

/* function to generate and return random numbers */
int * getRandom( ) {

   static int  r[10];
   int i;

   /* set the seed */
   srand( (unsigned)time( NULL ) );

   for ( i = 0; i < 10; ++i) {
      r[i] = rand();
      // printf( "r[%d] = %d\n", i, r[i]);
   }

   return r;
}

/* main function to call above defined function */
int main () {

   /* a pointer to an int */
   int *p;
   int i;

   p = getRandom();

   for ( i = 0; i < 10; i++ ) {
      printf( "*(p + %d) : %d\n", i, *(p + i));
   }

   return 0;
}
