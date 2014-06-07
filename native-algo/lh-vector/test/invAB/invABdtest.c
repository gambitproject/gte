/*
* invABdtest.c
* Used to test the validity of the computation of
* the inverse of A_B.
* Author: Tobenna Peter, Igwe
*/
#include <stdio.h>
#include <stdlib.h>
#include "../../mp.h"
#include "../../alloc.h"

#define MAXSTR 100

int n;
mp* vecd;
mp* sol;
mp** invAB;

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
void readnmps (mp *v, const char *info)
{
    char srat[MAXSTR];
    int j ;

    for (j=0; j<n; j++)
    {
        if(readstr(srat)==EOF)
        {
            fprintf(stderr, "Missing input of %s[%d]\n", info, j+1);
            notimpl("");
        }

        atomp(srat, v[j]);
    } 
}   /* end of readnrats  */

void readinvAB()
{
    T2ALLOC(invAB, n, n, mp);
    int i;
    for(i = 0; i < n; ++i)
    {
        readnmps(invAB[i], "invAB");
    }
}

void gend(int k)
{
    vecd = TALLOC(n, mp);
    int i;
    for(i = 0; i < n; ++i)
    {
        if(i == (k + 1))
        {
            itomp(0, vecd[i]);
        }
        else
        {
            itomp(1, vecd[i]);
        }
    }
}

void runtest()
{
    sol = TALLOC(n, mp);
    int i;
    for(i = 0; i < n; ++i)
    {
        int j;
        mp sum;
        itomp(0, sum);
        for(j = 0; j < n; ++j)
        {
            mp tmp;
            mulint(invAB[i][j], vecd[j], tmp);
            linint(sum, 1, tmp, 1);
        /*sum = ratadd(sum, tmp);*/
        }
        copy(sol[i], sum);
    }
    printf("z0= ");
    for(i = 0; i < n; ++i)
    {
        char str[MAXSTR];
        mp tmp;
        itomp(0, tmp);
        changesign(sol[i]);
        linint(sol[i], 1, tmp, 1);
        mptoa(sol[i], str);
    /*rattoa(ratadd(ratneg(sol[i]), tmp), str);*/
        printf("%s ", str);
    }
    printf("\n");
}

int main(int argc, char** argv)
{
    int k;
    readconf("n=");
    scanf("%d", &n);
    readconf("k=");
    scanf("%d", &k);
    readconf("invAB=");
    readinvAB();
    gend(k);
    runtest();
    FREE2(invAB, n);
    return 0;
}
