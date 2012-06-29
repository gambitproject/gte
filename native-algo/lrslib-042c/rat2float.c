/*
 * Reads a polyhedron file on stdin , with rationals and outputs 
 * an approximation in decimal floating point
 * 
 * David Bremner. bremner@cs.mcgill.ca
 *
 */
/*  Hacked by DA, April 20 2006  
 *  
 *  first argument overides stdin
 *  if column 0=0 then first non zero column scaled to +/-1   (otherwise big ugly integers come out)
*/

static char rcsid[]="$Id: rat2float.c,v 1.2 2006/04/04 12:33:38 bremner Exp $";

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <float.h>

FILE *lrs_ifp;                  /* input file pointer       */

#define DOCSTRING "\n\
$Id: rat2float.ds,v 1.3 2006/04/04 12:34:35 bremner Exp $ \n\
\n\
float takes a polytope file with rational or integer coefficents, \n\
and outputs an approximately equivelent one with floating point \n\
coefficents.\n\
\n\
WARNING: Assumes that numerator and denominator will fit  in long integer,\n\
unless compiled with multiprecision support.\n\
\n\
\n\
\n\
"

int usage(){ fprintf(stderr,"\n%s\n",rcsid);fprintf(stderr,DOCSTRING);  exit(1);        }
#define CHECK_HELP   if (argc > 1 && argv[1][0]=='-' && argv[1][1]=='h') usage();

#ifdef LRSMP
#include "lrsmp.h"
#endif

#ifndef LRSMP
typedef  long integer_t;
#define zero(n) (n==0)
#define one(n) (n==1)
#define pmp(s,n) printf("%s %d ",s,n)
#define readrat(n,d) my_readrat(&n,&d);

void my_readrat(long *num_p, long * denom_p) {

  char  buf[BUFSIZ];
  char *p;

  fscanf(lrs_ifp,"%s",buf);
  
  if (p=index(buf,'/')){
    *p=0;
    *denom_p=atol(&p[1]);
  } else {
    *denom_p=1;
  }
  
  *num_p=atol(buf);

}
void rattodouble(integer_t num, integer_t denom, double *out_p){
  *out_p=(double)num/(double)denom;
}
#else
typedef  lrs_mp integer_t;
#define MP_DIGITS 1000L
#endif





int main(argc,argv)
	 int argc;
	 char **argv;
{
  long int  n;
  int j;
  integer_t num,denom,sdenom;
  double out;
  int scale;     /* if column 0 is zero, scale column 1 to 1 */
  
  
  char format[BUFSIZ];
  char  buf[BUFSIZ];
  char  inputm[BUFSIZ];

  
  CHECK_HELP;
  if(argc > 1 )
                       /* command line argument overides stdin   */
    {
      if ((lrs_ifp = fopen (argv[1], "r")) == NULL)
        {
          printf ("\nBad input file name\n");
          return(1);
        }
    }
   else
       lrs_ifp=stdin;


#ifdef LRSMP
  lrs_mp_init (MP_DIGITS,lrs_ifp,stdout);   
#endif
  sprintf(format,"%%.%dlf ",DBL_DIG);
  while ( fgets(buf,BUFSIZ,lrs_ifp) !=NULL )
    {
      fputs(buf,stdout);
      if (strncmp(buf,"begin",5)==0) break;
    }

/* in lrs output m is undefined */
  
  if (fscanf(lrs_ifp,"%s %ld %s",inputm,&n,buf)==EOF){
    fprintf(stderr,"No begin line");
    exit(1);
  }

  printf("%s %ld real\n",inputm,n);
     
  
/*  for (i=0;i<m;i++)    for filtering lrs output we do not know m */


    while (readrat(num,denom)!=999L)
    {
/* If column zero is zero lrs output is integer, so we scale by number in column one */
      if (zero(num))
         scale=TRUE;
      else
         scale=FALSE;

      pmp("",num);

  /* read in numbers */

      for(j=1;j<n;j++)
	{
          readrat(num,denom);
          if((scale==TRUE) && ( j==1) )
             {
               copy(sdenom,num);
               storesign(sdenom,POS);      /* or else inequality is reversed .... */
             }

	  if (zero(num)) {
	    printf(" 0 ");
	  } else {
	    if (one(denom)){
              if (scale==TRUE)
                 {
                   rattodouble(num,sdenom,&out);
                   printf(format, out);
                 }
              else
	          pmp("",num);
	    } else {
	      rattodouble(num,denom,&out);
	      printf(format, out);
	    }

	  }
	}
      fputs("\n",stdout);
    }
  fputs("end\n",stdout);
  fgets(buf,BUFSIZ,lrs_ifp);  /* clean off last line */
  
  while (fgets(buf,BUFSIZ,lrs_ifp) !=NULL )
    {
      fputs(buf,stdout);
    }
return 0;
}






