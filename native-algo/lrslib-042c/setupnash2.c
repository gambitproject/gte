#include <stdio.h>
#include <string.h>
#include "lrslib.h"
#define MAXLINE 1000

/* Usage: setupnash2 game game1.ine game2.ine  */
/* Reads input file game containing            */
/* m n                                         */
/* A matrix        (m by n rationals )         */ 
/* B matrix        (m by n rationals )         */ 
/* Outputs: two files game1.ine game2.ine      */
/* that are used by nash                       */

/* This program builds polytope form:          */
/* Bx<=1, x>=0;  Ay <=1, y>=0                  */
/* MATRICES SHOULD HAVE POSITIVE ENTRIES       */

int
main (int argc, char *argv[])

{
  long m,n,i,j;
  long Anum[100][100], Bnum[100][100];
  long Aden[100][100], Bden[100][100];

  if ( argc < 3 )
    {
      printf ("\nUsage: setupnash2 infile outfile1 outfile2\n");
      return(FALSE);
     }


  if ((lrs_ifp = fopen (argv[1], "r")) == NULL)
        {
          printf ("\nBad input file name\n");
          return (FALSE);
        }
      else
        printf ("\n*Input taken from file %s", argv[1]);

  if(fscanf(lrs_ifp,"%ld %ld",&m,&n)==EOF)
     { printf("\nInvalid m,n");
       return(FALSE);
     } 


  if( m > 1000 || n > 1000)
     {
        printf ("\nm=%ld n=%ld",m,n);
        printf ("\nBoth m and n must be at most 1000\n");
        return(FALSE);
     }


/* process input file */
/* read A matrix      */

  for (i=0;i<m;i++)
     for (j=0;j<n;j++)
       lreadrat(&Anum[i][j],&Aden[i][j]);

   
/* read B matrix      */

  for (i=0;i<m;i++)
     for (j=0;j<n;j++)
       lreadrat(&Bnum[i][j],&Bden[i][j]);

/* write first output file */ 

  if ((lrs_ofp = fopen (argv[2], "w")) == NULL)
        {
          printf ("\nBad output file name\n");
          return (FALSE);
        }
      else
        printf ("\n*Output one sent to file %s\n", argv[2]);

  fprintf(lrs_ofp,"*%s: player 1",argv[1]);
  fprintf(lrs_ofp,"\nH-representation"); 
  fprintf(lrs_ofp,"\nbegin"); 
  fprintf(lrs_ofp,"\n%ld %ld rational",m+n,m+1);
  for (i=0;i<m;i++)
    {
     fprintf(lrs_ofp,"\n0 ");
     for (j=0;j<m;j++)
       {
         if ( i == j )
            fprintf(lrs_ofp,"1 ");
         else
            fprintf(lrs_ofp,"0 ");
       }
     }

  for (i=0;i<n;i++)
    {
     fprintf(lrs_ofp,"\n1 ");
     for (j=0;j<m;j++)
        lprat("",-Bnum[j][i],Bden[j][i]);
     }

  fprintf(lrs_ofp,"\nend"); 
  fprintf(lrs_ofp,"\n");
  fclose(lrs_ofp);

/* output file 2  */

  if ((lrs_ofp = fopen (argv[3], "w")) == NULL)
        {
          printf ("\nBad output file name\n");
          return (FALSE);
        }
      else
        printf ("\n*Output two sent to file %s\n", argv[3]);

  fprintf(lrs_ofp,"*%s: player 2",argv[1]);
  fprintf(lrs_ofp,"\nH-representation");
  fprintf(lrs_ofp,"\nbegin");
  fprintf(lrs_ofp,"\n%ld %ld rational",m+n,n+1);

  for (i=0;i<m;i++)
    {
     fprintf(lrs_ofp,"\n1 ");
     for (j=0;j<n;j++)
        lprat("",-Anum[i][j],Aden[i][j]);
     }

  for (i=0;i<n;i++)
    {
     fprintf(lrs_ofp,"\n0 ");
     for (j=0;j<n;j++)
       {
         if ( i == j )
            fprintf(lrs_ofp,"1 ");
         else
            fprintf(lrs_ofp,"0 ");
       }
     }

  fprintf(lrs_ofp,"\nend");
  fprintf(lrs_ofp,"\n");
  fclose(lrs_ofp);

  return(TRUE);
}
