/**
 * \file glemke.c
 * 
 * LCP solver with GNU Multi Precision arithmetic
 *
 * Author: Bernhard von Stengel  stengel@maths.lse.ac.uk 14 July 2000
 */

/* GSoC12: Tobenna Peter, Igwe */
#define GLEMKE

#include <stdio.h>
#include <stdlib.h>
    /* free()       */ 
#include <string.h>
    /*  strcpy      */

#include "alloc.h"
#include "col.h"

#include "lemke.h"

#include "gmp.h"
#include "gmpwrap.h"
#include "equilibrium.h"


long record_digits;	/* not in the gmp package	*/

/* used for tableau:    */
#define Z(i) (i)
#define W(i) (i+n)
    /* VARS   = 0..2n = Z(0) .. Z(n) W(1) .. W(n)           */
    /* ROWCOL = 0..2n,  0 .. n-1: tabl rows (basic vars)    */
    /*                  n .. 2n:  tabl cols  0..n (cobasic) */
#define RHS  (n+1)                   /*  q-column of tableau    */
#define TABCOL(v)  (bascobas[v]-n)   
    /*  v in VARS, v cobasic:  TABCOL(v) is v's tableau col */
    /*  v  basic:  TABCOL(v) < 0,  TABCOL(v)+n   is v's row */

/* LCP input    */
Rat **lcpM;
Rat *rhsq; 
Rat *vecd; 
int lcpdim = 0; /* set in setlcp                */
static int n;   /* LCP dimension as used here   */

/* LCP result   */
Rat  *solz; 
int  pivotcount;

/* tableau:    */
static  gmpt **A;                 /**< tableau                              */
static  int *bascobas;          /**< VARS  -> ROWCOL                      */
static  int *whichvar;          /**< ROWCOL -> VARS, inverse of bascobas  */

/** scale factors for variables z.
* scfa[Z(0)]   for  d,  scfa[RHS] for  q
* scfa[Z(1..n)] for cols of  M
* result variables to be multiplied with these
*/
static  gmpt *scfa;

static  gmpt det;                         /**< determinant                  */

static  int *lextested, *lexcomparisons;/**< statistics for lexminvar     */

static  int *leavecand;
    /* should be local to lexminvar but defined globally for economy    */


/* GSoC12: Tobenna Peter, Igwe */
/* User input */
int nrows;     /* The number of rows in the payoff matrix */
int ncols;     /* The number of columns in the payoff matrix */
int k;         /* The missing label */
int k2;
Rat** payoffA; /* The payoff matrix A */
Rat** payoffB; /* The payoff matrix B */
gmpt** invAB; /**< Represents the inverse of AB */
node* neg;    /* The negative indexed equilibria */
node* pos;    /* The positive indexed equilibria */

/*------------------ error message ----------------*/
/** 
 * Prints out an error message and exits.
 *
 * \param info The error message 
 */
void errexit (char *info)
{
    fflush(stdout);
    fprintf(stderr, "Error: %s\n", info);
    fprintf(stderr, "Lemke terminated unsuccessfully.\n");
    exit(1);
}

/* declares */
int assertbasic (int v, const char *info);

/*------------------ memory allocation -------------------------*/
/**
 * Allocates memory for the LCP given its dimensions.
 * If the LCP has been previously allocated, it frees the memory and
 * reallocates it. If the dimension given for the LCP is < 0 or 
 * > MAXLCPDIM then it exits with an error.
 *
 * \param newn The dimension of the LCP.
 */
void setlcp (int newn)
{
    if (newn < 1 || newn > MAXLCPDIM)
    {
        fprintf(stderr, "Problem dimension  n= %d not allowed.  ", newn);
        fprintf(stderr, "Minimum  n  is 1, maximum %d.\n", MAXLCPDIM);
        exit(1);
    }
    if (lcpdim > 0)             /* free previously used space   */
    {
        FREE2(lcpM, lcpdim); 
        free(rhsq);
        free(vecd);
        free(solz);

        G2CLEAR(A, lcpdim, lcpdim + 2);
        FREE2(A, lcpdim); 
        GCLEAR(scfa, lcpdim + 2);
        free(scfa);

        free(bascobas);
        free(whichvar);
        free(leavecand);

        gclear(det);

        G2CLEAR(invAB, lcpdim, lcpdim);
        FREE2(invAB, lcpdim);
    }
    n = lcpdim = newn;
    /* LCP input/output data    */
    T2ALLOC (lcpM, n, n, Rat);
    rhsq = TALLOC(n, Rat);
    vecd = TALLOC(n, Rat);
    solz = TALLOC(n, Rat);
    /* tableau          */

    T2ALLOC (A, n, n+2, gmpt);
    G2INIT  (A, n, n+2);
    scfa = TALLOC (n+2, gmpt);
    GINIT   (scfa, n+2);
    ginit(det); 

    bascobas = TALLOC(2*n+1, int);
    whichvar = TALLOC(2*n+1, int);
    lextested = TALLOC(n+1, int);
    lexcomparisons = TALLOC(n+1, int);
    leavecand = TALLOC(n, int);
    /* should be local to lexminvar but allocated here for economy  */
    /* initialize all LCP entries to zero       */
    {
        int i,j;
        Rat nix = ratfromi(0);
        for (i=0; i<n; i++)
        {
            for (j=0; j<n; j++)
                lcpM [i] [j] = nix;
            vecd [i] = rhsq [i] = nix;
        }
    }

    T2ALLOC(invAB, n, n, gmpt);
    G2INIT(invAB, n, n);
} /* end of  setlcp(newn)       */

/**
* Checks that the values for q and d are valid.
* Asserts that  d >= 0  and not  q >= 0  (o/w trivial sol) 
* and that q[i] < 0  implies  d[i] > 0
*/
void isqdok (void)
{
    int i;
    int isqpos = 1;
    for (i=0; i<n; i++)
    {
        if (gnegative(vecd[i].num))
        {
            char str[MAXSTR];
            rattoa(vecd[i], str);
            fprintf(stderr, "Covering vector  d[%d] = %s negative\n",
                i+1, str);
            errexit("Cannot start Lemke.");
        }
        else if (gnegative(rhsq[i].num))
        {
            isqpos = 0;
            if (gzero(vecd[i].num))
            {
                char str[MAXSTR];
                rattoa(rhsq[i], str);
                fprintf(stderr, "Covering vector  d[%d] = 0  ", i+1);
                fprintf(stderr, "where  q[%d] = %s  is negative.\n",
                    i+1, str);
                errexit("Cannot start Lemke.");
            }
        }
    }   /* end of  for(i=...)   */
    if (isqpos)
    {
        printf("No need to start Lemke since  q>=0. ");
        printf("Trivial solution  z=0.\n");
        exit(0);
    }
}       /* end of  isqdok()     */

/* ------------------- tableau setup ------------------ */

/** 
 * Initialise tableau variables.
 * Z(0)...Z(n)  nonbasic,  W(1)...W(n) basic    
 */
void inittablvars (void)
{
    int i;
    for (i=0; i<=n; i++)
    {
        bascobas[Z(i)] = n+i;
        whichvar[n+i]  = Z(i);
    }
    for (i=1; i<=n; i++)
    {
        bascobas[W(i)] = i-1;
        whichvar[i-1]  = W(i);
    }
}       /* end of inittablvars()        */

/**
 * Fill tableau from  M, q, d
 */
void filltableau (void)
{
    int i,j;
    gmpt den, num;
    gmpt tmp, tmp2; 

    ginit(tmp); ginit(tmp2); 
    ginit(den); ginit(num);
    for (j=0; j<=n+1; j++)
    {
        /* compute lcm  scfa[j]  of denominators for  col  j  of  A         */
        gitomp(1, scfa[j]);
        for (i=0; i<n; i++)
        {
            /*den = (j==0) ? vecd[i].den :
            (j==RHS) ? rhsq[i].den : lcpM[i][j-1].den ;*/
            if(j == 0)
            {
                gset(den, vecd[i].den);
            }
            else if(j == RHS)
            {
                gset(den, rhsq[i].den);
            }
            else
            {
                gset(den, lcpM[i][j-1].den);
            }

            gset(tmp, den);
            glcm(scfa[j], tmp);

            if (j == 0)
                record_digits = mpz_sizeinbase( scfa[j], 10)/4 ;
        }
        /* fill in col  j  of  A    */
        for (i=0; i<n; i++)
        {
            /*den = (j==0) ? vecd[i].den :
            (j==RHS) ? rhsq[i].den : lcpM[i][j-1].den ;*/
            if(j == 0)
            {
                gset(den, vecd[i].den);
            }
            else if(j == RHS)
            {
                gset(den, rhsq[i].den);
            }
            else
            {
                gset(den, lcpM[i][j-1].den);
            }
            /*num = (j==0) ? vecd[i].num :
            (j==RHS) ? rhsq[i].num : lcpM[i][j-1].num ;*/
                if(j == 0)
            {
                gset(num, vecd[i].num);
            }
            else if(j == RHS)
            {
                gset(num, rhsq[i].num);
            }
            else
            {
                gset(num, lcpM[i][j-1].num);
            }
            /* cols 0..n of  A  contain LHS cobasic cols of  Ax = b     */
            /* where the system is here         -Iw + dz_0 + Mz = -q    */
            /* cols of  q  will be negated after first min ratio test   */
            /* A[i][j] = num * (scfa[j] / den),  fraction is integral       */
            /*gitomp (den, tmp);*/
            gset(tmp, den);
            gexactdivint(scfa[j], tmp, tmp2);   
            /*gitomp (num, tmp);*/
            gset(tmp, num);
            gmulint(tmp2, tmp, A[i][j]);
        }
    }   /* end of  for(j=...)   */
    inittablvars();
    gitomp (-1, det);
    gclear(tmp); gclear(tmp2); 
    gclear(num); gclear(den);
}       /* end of filltableau()         */

/* ---------------- output routines ------------------- */

/**
 * Prints the LCP to the standard output
 */
void outlcp (void)
{
    int i,j ;
    Rat a;
    char s[LCPSTRL];

    printf("LCP dimension: %d\n", n);
    colset(n + 2);
    for (j=0; j<n; j++)
        colpr("");
    colpr("d");
    colpr("q");
    colnl();
    for (i=0; i<n; i++)
    {
        for (j=0; j<n; j++)
        {
            a = lcpM [i] [j];
            if (gzero(a.num))
                colpr(".");
            else
            {
                rattoa(a, s);
                colpr(s);
            }
        }
        rattoa( vecd [i], s);
        colpr(s);
        rattoa( rhsq [i], s);
        colpr(s);
    }
    colout();
}

/**
 * Create a string s representing v in VARS, e.g. "w2"
 *
 * \param v Variable to be converted
 * \param s String to be created
 * \returns length of string s
 */
int vartoa(int v, char s[])
{
    if (v > n)
        return sprintf(s, "w%d", v-n);
    else
        return sprintf(s, "z%d", v);
}

/**
 * Output the current tableau, column-adjusted
 */
void outtabl (void)
{
    int i, j;
    char s[INFOSTRINGLENGTH];
    char smp [MAXGMPCHARS];       /* string to print  mp  into    */
    gmptoa (det, smp);
    printf("Determinant: %s\n", smp);                
    colset(n+3);
    colleft(0);
    colpr("var");                   /* headers describing variables */
    for (j=0; j<=n+1; j++)
    {
        if (j==RHS)
            colpr("RHS");
        else
        {
            vartoa(whichvar[j+n], s);
            colpr(s);
        } 
    }
    colpr("scfa");                  /* scale factors                */
    for (j=0; j<=n+1; j++)
    {
        if (j==RHS)
            gmptoa(scfa[RHS], smp);
        else if (whichvar[j+n] > n) /* col  j  is some  W           */
            sprintf(smp, "1");
        else                        /* col  j  is some  Z:  scfa    */
            gmptoa( scfa[whichvar[j+n]], smp);
        colpr(smp);
    }
    colnl();
    for (i=0; i<n; i++)             /* print row  i                 */
    {
        vartoa(whichvar[i], s);
        colpr(s);
        for (j=0; j<=n+1; j++)
        {
            gmptoa( A[i][j], smp);
            if (strcmp(smp, "0")==0)
                colpr(".");
            else
                colpr(smp);
        }
    }
    colout();
    printf("-----------------end of tableau-----------------\n");
}       /* end of  outtabl()                                    */

/**
 * Output the current basic solution 
 */
void outsol (void)
{
    char s[INFOSTRINGLENGTH];
    char smp [2*MAXGMPCHARS+2];       /* string to print  mp  into    */
        /* string to print 2 mp's  into                 */
    int i, row, pos;
    gmpt num, den;

    ginit(num); ginit(den); 
    colset(n+2);    /* column printing to see complementarity of  w  and  z */

    colpr("basis=");
    for (i=0; i<=n; i++) 
    {
        if (bascobas[Z(i)]<n)
        /*  Z(i) is a basic variable        */
            vartoa(Z(i), s);
        else if (i>0 && bascobas[W(i)]<n)
        /*  Z(i) is a basic variable        */
            vartoa(W(i), s);
        else
            strcpy (s, "  ");
        colpr(s);
    }

    colpr("z=");
    for (i=0; i<=2*n; i++) 
    {
        if ( (row = bascobas[i]) < n)  /*  i  is a basic variable           */
        {
            if (i<=n)       /* printing Z(i)        */
        /* value of  Z(i):  scfa[Z(i)]*rhs[row] / (scfa[RHS]*det)   */
                gmulint(scfa[Z(i)], A[row][RHS], num);
            else            /* printing W(i-n)      */
        /* value of  W(i-n)  is  rhs[row] / (scfa[RHS]*det)         */
                gset(num, A[row][RHS]);
            gmulint(det, scfa[RHS], den);
            greduce(num, den);
            gmptoa(num, smp);
            pos = strlen(smp);
            if ( !gone(den))  /* add the denominator  */
            {
                sprintf(&smp[pos], "/");
                gmptoa(den, &smp[pos+1]);
            }
            colpr(smp);
        }
        else            /* i is nonbasic    */
            colpr("0");
        if (i==n)       /* new line since printing slack vars  w  next      */
        {
            colpr("w=");
            colpr("");  /* for complementarity in place of W(0)             */
        }
    }   /* end of  for (i=...)          */
    colout();
    printf("\n Number of pivots: %d\n", pivotcount);
    gclear(num); gclear(den);
}       /* end of outsol                */

/**
 * Current basic solution turned into  solz [0..n-1].
 * Note that Z(1)..Z(n)  become indices  0..n-1.
 *
 * \returns 0
 */
Bool notokcopysol (void)
{
    Bool notok = 0;
    int i, row;
    gmpt num, den;
    ginit(num); ginit(den);

    for (i=1; i<=n; i++) 
        if ( (row = bascobas[i]) < n)  /*  i  is a basic variable */
    {
        /* value of  Z(i):  scfa[Z(i)]*rhs[row] / (scfa[RHS]*det)   */
        gmulint(scfa[Z(i)], A[row][RHS], num);
        gmulint(det, scfa[RHS], den);
        greduce(num, den);
        /*
        if ( gmptoi(num, &(solz[i-1].num), 1) )
        {
        printf("(Numerator of z%d overflown)\n", i);
        notok = 1;
        }
        if ( gmptoi(den, &(solz[i-1].den), 1) )
        {
        printf("(Denominator of z%d overflown)\n", i);
        notok = 1;
        }*/
            gset(solz[i-1].num, num);
        gset(solz[i-1].den, den);
    }
    else            /* i is nonbasic    */
        solz[i-1] = ratfromi(0);
    gclear(num); gclear(den);
    return notok;
} /* end of copysol                     */

/* --------------- test output and exception routines ---------------- */ 
/**
 * Assert that  v  in VARS is a basic variable.
 * If v is not basic, then the program terminates with an error message
 *
 * \param v    The variable to be asserted
 * \param info Part of the error message.
 */    
int assertbasic (int v, const char *info)
{
    char s[INFOSTRINGLENGTH];
    if (bascobas[v] >= n)   
    {
        vartoa(v, s);
        fprintf(stderr, "%s: Cobasic variable %s should be basic.\n", info, s);
        /*errexit("");*/
        return -1;
    }
    return 0;
}

/**
 * Assert that  v  in VARS is a cobasic variable.
 * If v is not cobasic, the program terminates with an error message
 *
 * \param v     The variable to be asserted
 * \param info  Part of the error message
 */
int assertcobasic (int v, char *info)
{
    char s[INFOSTRINGLENGTH];
    if (TABCOL(v) < 0)   
    {
        /*
        vartoa(v, s);
        fprintf(stderr, "%s: Basic variable %s should be cobasic.\n", info, s);
        errexit("");*/
        return -1;
    }
    return 1;
}

/**
 * Document the current pivot.
 * Asserts  leave  is basic and  enter is cobasic, and
 * print the current pivot
 *
 * \param leave The leaving variable
 * \param enter The entering variable
 */
int docupivot (int leave, int enter, Flagsrunlemke flags)
{
    char s[INFOSTRINGLENGTH];

    if (assertbasic(leave, "docupivot") < 0)
        return -1;
    if (assertcobasic(enter, "docupivot") < 0)
        return -1;
    
    if(flags.boutpiv)
    {
        vartoa(leave, s);
        printf("leaving: %-4s ", s);
        vartoa(enter, s);
        printf("entering: %s\n", s);
    }
    return 0;
}       /* end of  docupivot    */

/**
 * Outputs an error message and exits when a ray termination
 * occurs while trying to pivot in the entering variable.
 *
 * \param enter The entering variable.
 */
void raytermination (int enter)
{
    char s[INFOSTRINGLENGTH];
    vartoa(enter, s);
    fprintf(stderr, "Ray termination when trying to enter %s\n", s);
    outtabl();
    printf("Current basis, not an LCP solution:\n");
    outsol();
    errexit("");
}

/**
 * Tests the tableau variables. If the tableau variables are wrong,
 * output error and continue.
 */
void testtablvars(void)
{
    int i, j;
    for (i=0; i<=2*n; i++)  /* check if somewhere tableauvars wrong */
        if (bascobas[whichvar[i]]!=i || whichvar[bascobas[i]]!=i)
        /* found an inconsistency, print everything             */
        {
            printf("Inconsistent tableau variables:\n");
            for (j=0; j<=2*n; j++)
            {
                printf("var j:%3d bascobas:%3d whichvar:%3d ",
                    j, bascobas[j], whichvar[j]);
                printf(" b[w[j]]==j: %1d  w[b[j]]==j: %1d\n",
                    bascobas[whichvar[j]]==j, whichvar[bascobas[j]]==j);
            }
            break;          
        }
}
/* --------------- pivoting and related routines -------------- */

/**
 * Complement of  v  in VARS. Error if  v==Z(0).
 * This is  W(i) for Z(i)  and vice versa, i=1...n.
 *
 * \param v The variable
 * \returns The complement of v. Z(i) if v is W(i) and vice versa.
 */
int complement (int v)
{
    if (v==Z(0))
        errexit("Attempt to find complement of z0.");
    return (v > n) ? Z(v-n) : W(v) ;
}       /* end of  complement (v)     */

/**
 * Initialize statistics for minimum ratio test
 */
void initstatistics(void)
{
    int i;
    for (i=0; i<=n; i++)
        lextested[i] = lexcomparisons[i] = 0;
}

/**
 * Output statistics of minimum ratio test
 */
void outstatistics(void)
{
    int i;
    char s[LCPSTRL];

    colset(n+2);
    colleft(0);
    colpr("lex-column");
    for (i=0; i<=n; i++)
        colipr(i);
    colnl();
    colpr("times tested");
    for (i=0; i<=n; i++)
        colipr(lextested[i]);
    colpr("% times tested");
    if (lextested[0] > 0)
    {
        colpr("100");
        for (i=1; i<=n; i++)
        {
            sprintf(s, "%2.0f",
                (double) lextested[i] * 100.0 / (double) lextested[0]);
            colpr(s);
        }
    }
    else
        colnl();
    colpr("avg comparisons");
    for (i=0; i<=n; i++)
        if (lextested[i] > 0)
    {
        sprintf(s, "%1.1f",
            (double) lexcomparisons[i] / (double) lextested[i]);
        colpr(s);
    }
    else
        colpr("-");
    colout();
}

/**
 * Returns the leaving variable in  VARS. This is given by lexmin row, 
 * when  enter  in VARS is entering variable
 * only positive entries of entering column tested
 * boolean  *z0leave  indicates back that  z0  can leave the
 * basis, but the lex-minratio test is performed fully,
 * so the returned value might not be the index of  z0.
 *
 * \param enter   The entering variable
 * \param z0leave Stores a boolean value stating if z0 can leave.
 * \returns       The leaving variable
 */
int lexminvar (int enter, int *z0leave)
{                                                       
    int col, i, j, testcol;
    int numcand;
    gmpt tmp1, tmp2;

    ginit(tmp1); ginit(tmp2); 
    assertcobasic(enter, "Lexminvar");
    col = TABCOL(enter);
    numcand = 0;
        /* leavecand [0..numcand-1] = candidates (rows) for leaving var */
    /* start with  leavecand = { i | A[i][col] > 0 }                        */
    for (i=0; i<n; i++)
        if (gpositive (A[i][col]))
        leavecand[numcand++] = i;
    if (numcand==0) 
        return -1;
        /*raytermination(enter);*/
    if (numcand==1)
    {
        lextested[0]      += 1 ;
        lexcomparisons[0] += 1 ;
        *z0leave = (leavecand[0] == bascobas[Z(0)]);
    }
    for (j = 0; numcand > 1; j++)
        /* as long as there is more than one leaving candidate perform
        * a minimum ratio test for the columns of  j  in RHS, W(1),... W(n)
        * in the tableau.  That test has an easy known result if
        * the test column is basic or equal to the entering variable.
        */
    {
        if (j>n)    /* impossible, perturbed RHS should have full rank  */
            errexit("lex-minratio test failed");
        lextested[j]      += 1 ;
        lexcomparisons[j] += numcand ;

        testcol = (j==0) ? RHS : TABCOL(W(j)) ;
        if (testcol != col)       /* otherwise nothing will change      */
        {
            if (testcol >= 0)
            /* not a basic testcolumn: perform minimum ratio tests          */
            {
                int sgn;
                int newnum = 0; 
                /* leavecand[0..newnum]  contains the new candidates    */
                for (i=1; i < numcand; i++)
                /* investigate remaining candidates                         */
                {
                    gmulint(A[leavecand[0]][testcol], A[leavecand[i]][col], tmp1);
                    gmulint(A[leavecand[i]][testcol], A[leavecand[0]][col], tmp2);
                    gsub (tmp1, tmp1, tmp2) ;
                    sgn = gsgn(tmp1) ;
                    /* sign of  A[l_0,t] / A[l_0,col] - A[l_i,t] / A[l_i,col]   */
                    /* note only positive entries of entering column considered */
                    if (sgn==0)         /* new ratio is the same as before      */
                        leavecand[++newnum] = leavecand[i];
                    else if (sgn==1)    /* new smaller ratio detected           */
                        leavecand[newnum=0] = leavecand[i];
                }
                numcand = newnum+1;
            }
            else
            /* testcol < 0: W(j) basic, Eliminate its row from leavecand    */
            /* since testcol is the  jth  unit column                       */
                for (i=0; i < numcand; i++)
                    if (leavecand[i] == bascobas[W(j)])
                    {
                        leavecand[i] = leavecand[--numcand];
                        /* shuffling of leavecand allowed       */
                        break;
                    }
        }   /* end of  if(testcol != col)                           */

    }       /* end of  for ( ... numcand > 1 ... )   */
    gclear(tmp1); gclear(tmp2); 
    *z0leave = (leavecand[0] == bascobas[Z(0)]);
    return whichvar[leavecand[0]];
}       /* end of lexminvar (col, *z0leave);                        */

/**
 * Returns the leaving variable in  VARS  as entered by user.
 * When  enter  in VARS is entering variable
 * only nonzero entries of entering column admitted
 * boolean  *z0leave  indicates back that  z0  has been
 * entered as leaving variable, and then
 * the returned value is the index of  z0.
 *
 * \param enter   The entering variable
 * \param z0leave Stores a boolean value stating if z0 can leave.
 * \returns       The leaving variable
 */
int interactivevar (int enter, int *z0leave)
{                                                       
    char s[INFOSTRINGLENGTH], instring[2];

    int inp, col, var;
    int breject = 1;
    assertcobasic(enter, "interactivevar");
    col = TABCOL(enter);

    vartoa(enter, s);
    printf("   Entering variable (column): %s\n", s);
    while (breject)
    {
        printf("   Leaving row (basic variable z.. or w..), ");
        printf("or 't' for tableau:\n");
        strcpy(instring, "?");
        if (scanf("%1s", instring)==EOF)
        {
            printf ("Input terminated too early with EOF\n");
            exit(1);
        }
        if ( instring[0] == 't')
        {
            printf("\n");
            outtabl();
            vartoa(enter, s);
            printf("   Entering variable (column): %s\n", s);
            continue;
        }
        scanf("%d", &inp);
        printf("   You typed %s%d\n", instring, inp);
        if ( (inp < 0) || (inp > n))
        {
            printf("Variable index %d outside 0..n=%d\n",
                inp, n);
            continue;
        }
        if ( instring[0] == 'w')
        {
            if (inp == 0)
            {
                printf("Variable w0 not allowed\n");
                continue;
            }
            var = inp + n;
        }
        else if ( instring[0] == 'z')
            var = inp;
        else 
        {
            printf("Variable not starting with  z  or  w\n");
            continue;
        }
    /* var == variable in VARS giving what has been input   */
        if ( bascobas[var] >= n)
        {
            vartoa (var, s);
            printf("Variable %s not basic\n", s);
            continue;
        }
        if ( gzero( A [bascobas[var]] [col] ) )
        {
            vartoa (var, s);
            printf("Row %s has zero pivot element, not allowed\n", s);
            continue;
        }
        breject = 0;    /* now everything ok            */
    }       /* end of  while (breject) for input    */
    *z0leave = (var == Z(0));
    return var;
}   /* end of  interactivevar (col, *z0leave);          */

/**
 * Negates tableau column  col
 * \param col The column of the tableau to be negated.
 */
void negcol(int col)
{
    int i;
    for (i=0; i<n; i++)
        gchangesign(A[i][col]);
}

/**
 * Negate tableau row.  Used in  pivot().
 * \param row The row of the tableau to be negated.
 */
void negrow(int row)
{
    int j;
    for (j=0; j<=n+1; j++)
        if (!gzero(A[row][j]))
        gchangesign(A[row][j]);
}

/**
 * Pivots the tableau given the entering and leaving variable.
 * leave, enter in  VARS  defining  row, col  of  A
 * pivot tableau on the element  A[row][col] which must be nonzero
 * afterwards tableau normalized with positive determinant
 * and updated tableau variables
 *
 * \param leave The leaving variable
 * \param enter The entering variable
 */
void pivot (int leave, int enter)
{
    int row, col, i, j;
    Bool nonzero, negpiv;
    gmpt pivelt, tmp1, tmp2;

    ginit(pivelt); ginit(tmp1); ginit(tmp2);
    row = bascobas[leave];
    col = TABCOL(enter);

    gset (pivelt, A[row][col]);     /* pivelt anyhow later new determinant  */
    negpiv = gnegative (pivelt);
    if (negpiv)
        gchangesign(pivelt);
    for (i=0; i<n; i++)
        if (i != row)               /*  A[row][..]  remains unchanged       */
        {
            nonzero = !gzero(A[i][col]);
            for (j=0; j<=n+1; j++)      /*  assume here RHS==n+1        */
                if (j != col)
                /*  A[i,j] =
                (A[i,j] A[row,col] - A[i,col] A[row,j])/ det     */
            {
                gmulint (A[i][j], pivelt, tmp1);
                if (nonzero)
                {
                    gmulint(A[i][col], A[row][j], tmp2);
                    if (negpiv)
                        gadd(tmp1, tmp1, tmp2);
                    else
                        gsub(tmp1, tmp1, tmp2);
                }
                gexactdivint (tmp1, det, A[i][j]);
            }
            /* row  i  has been dealt with, update  A[i][col]  safely   */
            if (nonzero && !negpiv)
                gchangesign (A[i][col]);
        }       /* end of  for (i=...)                              */
    gset(A[row][col], det);
    if (negpiv)
        negrow(row);
    gset(det, pivelt);      /* by construction always positive      */

    /* update tableau variables                                     */
    bascobas[leave] = col+n;        whichvar[col+n] = leave;
    bascobas[enter] = row;          whichvar[row]   = enter;

    gclear(pivelt); gclear(tmp1); gclear(tmp2);
}       /* end of  pivot (leave, enter)                         */

/**
 * Returns the best response of a given strategy.
 * 
 * \param l A players strategy such that 1 <= l <= m+n
 * \returns The opponents best response strategy
 */
/* GSoC12: Tobenna Peter, Igwe */
int bestResponse(int l)
{
    /* m is the best response */
    int m = 0;

    if(l > nrows) /* if l is p2's strategy*/
    {
        /* m < l <= m+n */
        l -= (nrows + 1);
        int i;
        /* The best response to l is the row with min value for the lth column
        * because payoffA is -A.
        */
        for(i = 1; i < nrows; ++i)
        {
            if(ratgreat(payoffA[m][l], payoffA[i][l]))
                m = i;
            if(ratiseq(payoffA[m][l], payoffA[i][l])) /* Due to lexmin ratio */
                m = i;
        }
        /* Converts m to p1's strategy */
        m += 1;
    }
    else /* if l is p1's strategy */
    {
        /* 1 <= l <= m */
        l -= 1;
        int i;
        /* The best response to l is the column with min value for the lth row
        * because payoffB is -B.
        */
        for(i = 1; i < ncols; ++i)
        {
            if(ratgreat(payoffB[l][m], payoffB[l][i]))
                m = i;
            if(ratiseq(payoffB[l][m], payoffB[l][i])) /* Due to lexmin ratio */
                m = i;
        }
        /* Converts m to p2's strategy */
        m += (nrows + 1);
    }

    return m;
}

/**
* Pivots the tableau given the values for the leaving
* and entering variables, and outputs data based on the
* flags.
*
* \param leave The leaving variable
* \param enter The entering variable
* \param flags The flags for running Lemke's algorithm
*/
/* GSoC12: Tobenna Peter, Igwe */
int fpivot(int leave, int enter, Flagsrunlemke flags)
{
    testtablvars();
    if (flags.bdocupivot)
    {
        if(docupivot (leave, enter, flags) < 0)
            return -1;
    }
    pivot (leave, enter);
    if (flags.bouttabl)
        outtabl();
    pivotcount++;
    return 0;
}

/**
 * Initialise the LH algorithm with the first
 * three pivots of method 1 as explained in the report.
 */
/* GSoC12: Tobenna Peter, Igwe */
    int initLH1(Flagsrunlemke flags)
{
    int enter, leave;

    enter = Z(0);
    leave = (k > nrows) ? W(1) : W(2);

    fpivot(leave, enter, flags);

    enter = complement(leave);
    leave = W(bestResponse(k) + 2);

    fpivot(leave, enter, flags);

    enter = complement(leave);
    leave = (k > nrows) ? W(2) : W(1);

    fpivot(leave, enter, flags);

    enter = complement(leave);
    leave = W(k + 2);
    fpivot(leave, enter, flags);
    
    return leave;
}

/**
 * Initialise the LH algorithm with the first
 * three pivots of method 1 as explained in the report.
 */
/* GSoC12: Tobenna Peter, Igwe */
int initLH2(Flagsrunlemke flags)
{
    int enter, leave;

    enter = Z(0);
    leave = (k > nrows) ? W(2) : W(1);

    fpivot(leave, enter, flags);

    enter = complement(leave);
    leave = W(k + 2);

    fpivot(leave, enter, flags);

    enter = complement(leave);
    leave = (k > nrows) ? W(1) : W(2);

    fpivot(leave, enter, flags);

    enter = complement(leave);
    leave = W(bestResponse(k) + 2);

    fpivot(leave, enter, flags);

    return leave;
}

/**
 * Initialise the LH pivots given the flags.
 * It chooses to initialise the LH pivots using either
 * method 1 or 2 as specified by the user in flags.
 *
 * \param flags The flags for running Lemke's algorithm
 */
/* GSoC12: Tobenna Peter, Igwe */
int initLH(Flagsrunlemke flags)
{
    if(flags.bisArtificial)
        return flags.binitmethod ? complement(initLH2(flags)) : complement(initLH1(flags));
    else
        return Z(0);
}

/**
 * Computes the inverse of A_B.
 */
/* GSoC12: Tobenna Peter, Igwe */
void getinvAB(int verbose)
{
    int i;

    for(i = 0; i < n; ++i)
    {
        if(bascobas[W(i + 1)] < n) /* If W(i) is basic */
        {
            int j = bascobas[W(i + 1)];
            int k;
            for(k = 0; k < n; ++k)
            {
                if(k == j) /* The jth row of the ith column is 1 other rows are 0 */
                {
                    gset(invAB[k][i], det);
                }
                else
                {
                    gitomp(0, invAB[k][i]);
                }
            }
        }
        else /* If W(i) is non-basic */
        {
            int j = TABCOL(W(i + 1));
            int k;
            for(k = 0; k < n; ++k) /* copy the column representing W(i) into the ith column */
            {
                gset(invAB[k][i], A[k][j]);
                /*copy(invAB[k][i], A[k][j]);*/
            }
        }
    }

    if(verbose)
    {
        colset(n);
        printf("\nz0= ");
        for(i = 0; i < n; ++i)
        {
            char str[MAXSTR];
            gmptoa(A[i][TABCOL(Z(0))], str);
            printf("%s ", str);
        }
        colout();

        printf("\nPrinting invAB:\n");
        colset(n);

        for(i = 0; i < n; ++i)
        {
            int j;
            for(j = 0; j < n; ++j)
            {
                char str[MAXSTR];
                gmptoa(invAB[i][j], str);
                colpr(str);
            }
        }
        colout();
    }
}

/* ------------------------------------------------------------ */ 
int runlemke(Flagsrunlemke flags)
{
    int leave, enter, z0leave;

    pivotcount = 1;
    initstatistics();

    if (flags.binitabl)
    {
        printf("After filltableau:\n");
        outtabl();
    }

    /* now give the entering q-col its correct sign if it is from the artificial*/
    if(flags.bisArtificial)/* GSOC */
    {
        negcol (RHS);
    }

    if (flags.bouttabl) 
    {
        printf("After negcol:\n");
        outtabl();
    }

    /* z0 enters the basis to obtain lex-feasible solution, or use the initialization  */
    /*enter = Z(0)*/ /*GSOC*/
    enter = flags.binteract ? Z(0) : initLH(flags);                                                   
    leave = flags.binteract ? interactivevar(enter, &z0leave) : lexminvar(enter, &z0leave) ;
    
    if(leave < 0)
        return -1;

    while (1)       /* main loop of complementary pivoting                  */
    {
        if(flags.interactcount)
            flags.binteract = --flags.interactcount ? 1 : 0;
        testtablvars();
        if (flags.bdocupivot)
        {
            if(docupivot (leave, enter, flags) < 0)
                return -1;
        }
        pivot (leave, enter);
        if (z0leave)
            break;  /* z0 will have value 0 but may still be basic. Amend?  */
        if (flags.bouttabl) 
            outtabl();
        enter = complement(leave);
        leave = flags.binteract ? interactivevar(enter, &z0leave) : lexminvar(enter, &z0leave) ;
        
        if (leave < 0)
            return -1;
        
        if (pivotcount++ == flags.maxcount)
        {
            printf("------- stop after %d pivoting steps --------\n", 
                flags.maxcount);
            break;
        }
    }

    if (flags.binitabl)
    {
        printf("Final tableau:\n");
        outtabl();
    }
    if (flags.boutsol)
        outsol();
    if (flags.blexstats)
        outstatistics();

    notokcopysol();
    
    /*GSOC: For test purpose only */
    if(flags.boutinvAB)
        getinvAB(flags.boutinvAB);
    
    return 0;
} 

/**
 * Copy the tableau from the given equilibrium to be
 * used for computation.
 */
/* GSoC12: Tobenna Peter, Igwe */
void copyEquilibrium(Equilibrium eq)
{
    int i, j;
    for(i = 0; i < n; ++i)
    {
        for(j = 0; j < n+2; ++j)
        {
            gset(A[i][j], eq.A[i][j]);
        }
    }

    for(i = 0; i < n+2; ++i)
    {
        gset(scfa[i], eq.scfa[i]);
    }

    for(i = 0; i < 2*n+1; ++i)
    {
        bascobas[i] = eq.bascobas[i];
        whichvar[i] = eq.whichvar[i];
    }
    gset(det, eq.det);
}

/**
 * Setup the covering vector for the Artificial Equilibrium.
 * Calculates the new covering vector for the missing label k
 * from the artificial equilibrium, and substitutes that in the 
 * tableau.
 */
/* GSoC12: Tobenna Peter, Igwe */
void setupArtificial()
{
    int i;
    /* Copy the new covering vector into the tableau */
    for(i = 0; i < n; ++i)
    {
        gmpt tmp;
        ginit(tmp);
        if(i == k+1)
        {
            gitomp(0, tmp);
        }
        else
        {
            gitomp(1, tmp);
        }
        gset(A[i][TABCOL(Z(0))], tmp);
        gclear(tmp);
    }
}

/**
 * Setup the tableau from the current equilibrium using k2 as the missing label.
 * This involves calculating the inverse of A_B to find the new covering vector,
 * and replacing it in the tableau.
 */
/* GSoC12: Tobenna Peter, Igwe */
void setupEquilibrium(Flagsrunlemke flags)
{
    getinvAB(flags.boutinvAB);
    /* vecd2 represents the covering vector when k2 is the missing label */
    gmpt* vecd2 = TALLOC(n, gmpt);
    GINIT(vecd2, n);
    int i;
    for(i = 0; i < n; ++i)
    {
        if(i == (k2 + 1))
        {
            gitomp(0, vecd2[i]);
        }
        else
        {
            gitomp(1, vecd2[i]);
        }
    }

    /* sol represents the computed covering vector by multiplying
    * invAB with vecd2, and multiplying the result by -1 */
        gmpt* sol = TALLOC(n, gmpt);
    GINIT(sol, n);
    for(i = 0; i < n; ++i)
    {
        int j;
        gmpt sum;
        ginit(sum);
        gitomp(0, sum);
        for(j = 0; j < n; ++j)
        {
            gmpt tmp;
            ginit(tmp);
            gmulint(invAB[i][j], vecd2[j], tmp);
            gadd(sum, tmp, sum);
            /*sum = ratadd(sum, tmp);*/
        }
        gchangesign(sum);
        gset(sol[i], sum);
    }
    /* Copy the new covering vector into the tableau */
    for(i = 0; i < n; ++i)
    {
       /*A[i][TABCOL(Z(0))] = sol[i];*/
        gset(A[i][TABCOL(Z(0))], sol[i]);
    }
    
    if(flags.binitabl)
    {
        printf("\nTableau with new covering vector\n");
        outtabl();
        printf("\nRestarting with missing label: %d\n", k2);
    }
}

/**
 * Compute the equilibria from the specified node.
 * This computes all the equiibria directly reachable by
 * dropping labels which do not have any equilibrium linked
 * with from the current equilibrium.
 *
 * \param i     Index position of the current equilibrium in the list
 * \param isneg Boolean value indicating if the current equilibrium is
 *              a negatively indexed equilibrium.
 * \param flags Flags for tunning Lemke's algorithm.
 */
/* GSoC12: Tobenna Peter, Igwe */
void computeEquilibriafromnode(int i, int isneg, Flagsrunlemke flags)
{
    node* cur = (isneg) ? neg : pos;
    node* res = (isneg) ? pos : neg;

    cur = getNodeat(cur, i);
    Equilibrium eq;
    int maxk = nrows + ncols;
    for(k2 = 1; k2 <= maxk; ++k2)
    {
        if(cur->link[k2-1] != -1)
            continue;

        copyEquilibrium(cur->eq);
        if(flags.bisArtificial)
        {
            k = k2;
            setupArtificial();
        }
        else
        {
            setupEquilibrium(flags);
        }
        int err = runlemke(flags);
        
        if (err < 0)
            continue;
        /* Create the equilibrium and add it to the list */
        eq = createEquilibrium(A, scfa, det, bascobas, whichvar, n, nrows, ncols);
        int plength = listlength(res);
        /* The equilibrium is at the index j in the list */
        int j = addEquilibrium(res, eq);
        /* Label k links both equilibria together */
        cur->link[k2-1] = j;
        node* p = getNodeat(res, j);
        p->link[k2-1] = i;
        
        if(flags.bouteq && plength != listlength(res))
        {
            colprEquilibrium(eq);
        }
        
        if(flags.boutsol)
        {
            printEquilibrium(eq);
        }
    }
}

/* Compute all equilibrium */
/* GSoC12: Tobenna Peter, Igwe */
void computeEquilibria(Flagsrunlemke flags)
{
    int maxk = nrows + ncols;
    int negi, posi;

    neg = newnode(n - 2);
    pos = newnode(n - 2);


    initstatistics();

    isqdok();
    colset(n);
    /*  printf("LCP seems OK.\n");      */
    filltableau();
    /*  printf("Tableau filled.\n");    */

    /* Store the artificial equilibrium */
    Equilibrium eq =  createEquilibrium(A, scfa, det, bascobas, whichvar, n, nrows, ncols);
    neg->eq = eq;

    /* Compute and store the first equilibrium */
    runlemke(flags);
    eq = createEquilibrium(A, scfa, det, bascobas, whichvar, n, nrows, ncols);
    pos->eq = eq;
    
    if(flags.bouteq)
    {
        colprEquilibrium(eq);
    }
    if(flags.boutsol)
    {
        printEquilibrium(eq);
    }

    /* Label 1 links the first equilibrium from both list */
    neg->link[0] = 0;
    pos->link[0] = 0;
    /* All labels for the artificial equilibrium */
    
    computeEquilibriafromnode(0, 1, flags);

    flags.bisArtificial = 0;
    negi = 1;
    posi = 0;
    int isneg = 0;

    while(1)
    {
        if(isneg)
        {
            while(negi < listlength(neg))
            {
                computeEquilibriafromnode(negi, isneg, flags);
                negi++;
            }
        }
        else
        {
            while(posi < listlength(pos))
            {
                computeEquilibriafromnode(posi, isneg, flags);
                posi++;
            }
        }
        isneg = !isneg;
        if((negi == listlength(neg)) && (posi == listlength(pos)))
            break;
    }
    
    colout();
    if(flags.boutpath)
    {
        colset(n + 1);
        int i;
        for(i = 0; i < n + 1; ++i)
        {
            colleft(i);
        }
        char smp [2*DIG2DEC(MAX_DIGITS) + 4];
        
        printf("\nEquilibria discovered: %d\n", (listlength(neg) - 1 + listlength(pos)));
        sprintf(smp, "\n%d-ve index:", negi);
        colpr(smp);
        colnl();
        printlist(neg, 'N');
        sprintf(smp, "\n%d+ve index:", posi);
        colpr(smp);
        colnl();
        printlist(pos, 'P');
        colout();
    }
}

