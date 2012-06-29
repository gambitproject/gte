/* lpdemo.c     lrslib lp demo code                  */
/* last modified: June 20, 2001                          */
/* Copyright: David Avis 2001, avis@cs.mcgill.ca         */

/* Demo driver for lp code using lrs                 */
/* This program does lps on a set of generated cubes */

#include <stdio.h>
#include <string.h>
#include "lrslib.h"

#define MAXCOL 1000     /* maximum number of colums */

long num[MAXCOL];
long den[MAXCOL];
void makecube (lrs_dic *P, lrs_dat *Q);

int
main (int argc, char *argv[])

{
  lrs_dic *P;	/* structure for holding current dictionary and indices  */
  lrs_dat *Q;	/* structure for holding static problem data             */
  lrs_mp_vector output;	/* one line of output:ray,vertex,facet,linearity */

  long i;
  long m;       /* number of constraints in the problem          */
  long n;       /* number of variables in the problem + 1        */
  long col;	/* output column index for dictionary            */

/* Global initialization - done once */

  if ( !lrs_init ("\n*lpdemo:"))
    return 1;

/* generate cubes with dimension d */

  for(i=1;i<=2;i++)
  {
    n=10;
    m=18;               /* number of rows for cube dimension d */

/* allocate and init structure for static problem data */

    Q = lrs_alloc_dat ("LRS globals");
    if (Q == NULL)
       return 1;

    Q->m=m;  Q->n=n;

    Q->lponly=TRUE;      /* we do not want all vertices generated!   */

    output = lrs_alloc_mp_vector (Q->n);

    P = lrs_alloc_dic (Q);   /* allocate and initialize lrs_dic      */
    if (P == NULL)
        return 1;

/* Build polyhedron: constraints and objective */ 

    makecube(P,Q);
/* Solve the LP  */

   if (!lrs_solve_lp(P,Q))
      return 1;

/* Print output */

   prat ("\nObjective value = ", Q->objnum, Q->objden);

   for (col = 0; col < Q->n; col++)
     if (lrs_getsolution (P, Q, output, col))
       lrs_printoutput (Q, output);

/* free space : do not change order of next lines! */
   lrs_clear_mp_vector (output, Q->n);
   lrs_free_dic (P,Q);         /* deallocate lrs_dic */
   lrs_free_dat (Q);           /* deallocate lrs_dat */

  }    /* end of loop for i=1 ...  */
 
 lrs_close ("lpdemo:");

 printf("\n");
 return 0;
}  /* end of main */

/* code to generate unit cube and objective function */

void
makecube (lrs_dic *P, lrs_dat *Q)
/* generate H-representation of a unit hypercube */
/* with dimension n-1                            */
{
long num[MAXCOL];
long den[MAXCOL];
long row, j;
long m=Q->m;
long n=Q->n;

for (row=1;row<=m;row++)
    { /* set up a cube */
  
      for(j=0;j<n;j++)
          { num [j] = 0;
            den [j] = 1;
          }
       if (row < n)
          { num[0] = 1;
            num[row] = -1;
          }
       else
          { num[0] = 0;
            num[row+1-n] = 1;   
          }  
       lrs_set_row(P,Q,row,num,den,GE);
     }
/* set up some objective function */
 printf("\n\nObjective function: ");
  
 for(j=0;j<n;j++)
    { num [j] = j*(j-6);
      den [j] = 1;
      lprat(" ",num[j],den[j]);
    }
  lrs_set_obj(P,Q,num,den,MAXIMIZE);

}

