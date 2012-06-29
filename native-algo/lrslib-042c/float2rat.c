/*
 * Reads a polyhedron file on stdin with rationals and outputs 
 * an approximation in decimal floating point
 * 
 * David Bremner. bremner@cs.mcgill.ca
 *
 */
/*  Hacked by DA, April 20 2006
 *
 *  first argument overides stdin
 *  if column 0=0 then column 1 scaled to 1   (otherwise big ugly integers come out)
 *  since lrs does not define m (# of output lines) this is skipped
 *  lines are converted until "end" is read
*/


static char rcsid[]="$Id: float2rat.c,v 1.1.1.1 2006/04/03 20:42:10 bremner Exp $";

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <float.h>

FILE *lrs_ifp;                  /* input file pointer       */


#define DOCSTRING "\n\
$Id: float2rat.ds,v 1.2 2006/04/03 21:15:39 bremner Exp $\n\
\n\
Converts floating point coefficent $f$ to rational by the \n\
simple expedient of outputing 10^k*f/10^k for appropriate \n\
$k$. Does no reduction of numbers.  In particular this may cause overflow in \n\
old versions of lrs input (and I'm not about cdd).\n\
"

int usage(){ fprintf(stderr,"\n%s\n",rcsid);fprintf(stderr,DOCSTRING);  exit(1);        }
#define CHECK_HELP   if (argc > 1 && argv[1][0]=='-' && argv[1][1]=='h') usage();


int main(argc,argv)
	 int argc;
	 char **argv;
{
  long int  m,n;
  int i,j;
  
  long atol();
  
    char  buf[BUFSIZ];
  
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


  while ( fgets(buf,BUFSIZ,lrs_ifp) !=NULL )
    {
      fputs(buf,stdout);
      if (strncmp(buf,"begin",5)==0) break;
    }
  

  if (fscanf(lrs_ifp,"%ld %ld %s",&m,&n,buf)==EOF){
    fprintf(stderr,"No begin line");
    exit(1);
  }

  printf("%ld %ld rational\n",m,n);
     
  
  for (i=0;i<m;i++)   {
    for(j=0;j<n;j++)	{
      char *p;
      char *frac;
      int k;
      
      fscanf(lrs_ifp,"%s",buf);
      
      if ((p=strchr(buf,'.'))){
	*p=0;
	frac=&p[1];
        printf("%s%s/1",buf,frac);
        for (k=0; k<strlen(frac); k++)
	  putchar('0');
      } else {
	 printf("%s",buf);
      }
      
      putchar(' ');
	    
    }
    fputs("\n",stdout); 
  }

  fgets(buf,BUFSIZ,lrs_ifp);  /* clean off last line */
  
  while (fgets(buf,BUFSIZ,lrs_ifp) !=NULL )
    {
      fputs(buf,stdout);
    }
return 0;
}






