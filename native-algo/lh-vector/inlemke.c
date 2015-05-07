/* inlemke.c
 * Lemke direct
 * 16 Apr 2000
 * options:
 *      -i      run pivoting interactively, suggested with  '-v'
 *      -v      verbose: output tableau at every pivoting step
 * Author: Bernhard von Stengel  stengel@maths.lse.ac.uk
 */

#include <stdio.h>
#include <stdlib.h>
        /*  atoi        */
#include <string.h>
	/*  strlen	*/
#include <getopt.h>
        /* getopt(), optarg, optopt     */

#include "alloc.h"
#include "col.h"
#include "rat.h"

#include "lemke.h"
       /* for lemke.h  */ 

static int n; 	/* LCP dimension here */

/* max no of characters + 1 (for terminating '\0') 
 * of a string  s  declared as  char s[MAXSTR] 
 * to be read from stdin by readstr
 */
#define MAXSTR 100  

/*------------------ error message ----------------*/
void notimpl (char *info)
{
    fflush(stdout);
    fprintf(stderr, "Program terminated with error. %s\n", info);
    exit(1);
}

/*------------------ read-in routines --------------------------*/
/* reads string  s  from stdin, to fit  char s[MAXSTR]
 * if length >= MAXSTR-1  a warning is sent to stderr
 * returns EOF if EOF encountered, then  s  undefined
 */
int readstr (char *s)        
{
    int tmp;
    char fs[10];    /* MAXSTR must not exceed 7 decimal digits      */
    sprintf (fs, "%%%ds",MAXSTR-1);        /* generate format str   */
    tmp = scanf (fs, s);
    if (strlen(s)==MAXSTR-1)
        {
        fprintf(stderr, "Warning: input string\n%s\n", s);
        fprintf(stderr, 
        "has max length %d, probably read incompletely\n", MAXSTR-1);
        }
    return tmp;     /* is EOF if scanf encounters EOF               */
}

/* s  is a string of nonblank chars, which have to
 * match in that order the next nonblank  stdin  chars
 * readconf  complains and terminates if not
 */
void readconf (const char *s)
{
    int i, len = strlen(s);
    char a[MAXSTR];
    for (i=0; i<len; i++)
        {
        if (scanf("%1s", &a[i])==EOF)
            /* make sure something is in  a  for error report       */
            a[i] = '\0';
        if (a[i] != s[i])
            /* the chars in  a  from stdin do not match those in s  */
            {
            fprintf(stderr, "\"%s\"  required from input, found \"%s\"\n",
                    s, a);
            notimpl("");
            }
        }
}

/* reads  n  rationals into the array  v  of rationals 
 * terminates with error if EOF encountered earlier
 * info  denotes name of array for error information
 * array indices in error info called  1...n
 */
void readnrats (Rat *v, const char *info)
{
    char srat[MAXSTR], snum[MAXSTR], sden[MAXSTR];
    int j ;
    int num,den;
    
    for (j=0; j<n; j++)
        {
        if(readstr(srat)==EOF)
            {
            fprintf(stderr, "Missing input of %s[%d]\n", info, j+1);
            notimpl("");
            }
        atoaa(srat, snum, sden);
        num = atoi(snum);
        if (sden[0]=='\0') 
            den = 1;
        else
            {
            den = atoi(sden);
            if (den<1)
                {
                fprintf(stderr, "Warning: Denominator "); 
                fprintf(stderr, "%d of %s[%d] set to 1 since not positive\n", 
                        den, info, j+1);
                den = 1;  
                }
            }
        v[j].num = num ;
        v[j].den = den ;
        } 
}   /* end of readnrats  */

void readMqd (void)
        /* reads LCP data  M, q, d  from stdin          */
        /* storage is already allocated                 */
{
    /* read in  M   */
    int i;
    char info[10];  /*  n  has at most 6 digits     */
    readconf("M=");
    
    for (i=0; i<n; i++)
        /* read row  i  of  M       */
        {
        sprintf(info, "M[%d]", i+1);
        readnrats(lcpM[i], info);
        }   
    
    /* read in  q   */
    readconf("q=");
    readnrats(rhsq, "q");
    
    /* read in  d   */
    readconf("d=");
    readnrats(vecd, "d");
}       /* end of  readMqd   */

void readlcp (void)
        /* reads LCP data  n, M, q, d  from stdin       */
{
    /* get problem dimension */
    readconf("n=");
    scanf("%d", &n);  
    
    setlcp(n);
    readMqd();
}       /* end of reading in LCP data   */

/* ---------------------- main ------------------------ */       
int main(int argc, char *argv[])
{
    int c;
    Flagsrunlemke flags;

    flags.maxcount   = 0;
    flags.bdocupivot = 1;
    flags.binitabl   = 1;
    flags.bouttabl   = 0;
    flags.boutsol    = 1;
    flags.binteract  = 0;
    flags.blexstats  = 1;

    /* parse options    */
    while ( (c = getopt (argc, argv, "iv")) != -1)
        switch (c)
            {
            case 'i':
                flags.binteract  = 1;
                printf("Interactive flag set.\n");
                break;
            case 'v':
                flags.bouttabl   = 1;
                printf("Verbose tableau output.\n");
                break;
            case '?':
                if (isprint (optopt))
                    fprintf (stderr, "Unknown option `-%c'.\n", optopt);
                else
                    fprintf (stderr,
                             "Unknown option character `\\x%x'.\n",
                              optopt);
                return 1;
            default:
                abort ();
            }
    /* options are parsed and flags set */

    readlcp();
    runlemke(flags); 
    return 0;
}
