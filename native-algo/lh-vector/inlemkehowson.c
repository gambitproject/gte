/**
 * \mainpage Lemke-Howson with Covering Vectors
 *
 * ##Download##
 * The source from this project can be gotten from the repository
 * http://www.github.com/ptigwe/lh-vector
 *
 * ##Compile##
 * The program has been written to be compiled with GNUMP, a multiple
 * point integer precision library, but this requires the library to
 * be installed for the program to compile successfully. An alternative
 * for the GNUMP has been provided along with the code in the files
 * mp.h and mp.c. It is suggested to use the GNUMP version of the code,
 * as it supports integers of arbitrary length, where as the mp.h version
 * supports integers of a fixed number of digits. Due to the two different
 * representations of multiple point precision integers, some code which
 * depends on the definition of these integers have two different files,
 * one which supports the GNUMP format, and a second which supports the 
 * mp format, for example for the main Lemke code defined in lemke.h,
 * the implementation is in glemke.c supports the GNUMP format, and the
 * lemke.c supports the mp format.
 *
 * To compile the code using the GNUMP format, the make rule 'inglh' is
 * used, and for compilation using the mp format the make rule 'inlh' is
 * used.
 * 
 * ###Rules:###
 * - 'make inlh': Compiles the code with mp support
 * - 'make inglh': Compiles the code with GNUMP support
 * - 'make subdir': Compiles the code for running tests
 *
 *
 * ##Running##
 * ./inlh [-aiI:f:vm]
 *
 * ###Flags:###
 * - '-a' Print out the value of invAB for every equilibrium once its being
 *    found.
 * - '-i' Allows for the user to specify the leaving variable at each point
 *      while pivoting. Suggest using -v whenever using -i.
 * - '-I n' Allows the user to specify the maximum number of interactive pivots n
 *        which the user is allowed to enter. Once the user enters the first n
 *        leaving variables, the program completes the remaining until it finds
 *        an equilibrium, this happens for every missing label being tested at a
 *        given equilibrium. n <= 0 is equivalent to -i flag.
 * - '-f filename' Prints out the equivalent LCP for the game input into filename
 * - '-v'  For a verbose output, which output the tableau information after every pivot
 * - '-m'  By default methpd 1 for initialising the LH-path is used, this flag sets
 *       method 2 to be used for initialisation.
 * 
 * ###Input:###
 * The program takes its input in the following format:
 *
 * m= ?
 *
 * n= ?
 *
 * A= ? 
 *
 * B= ?
 *
 * where m is the number of rows,
 * n is the number of columns,
 * A is the first players payoff matrix and
 * B is the second players payoff matrix
 */
/**
 * \file inlemkehowson.c
 *
 * Lemke Howson main file.
 * This file serves as the starting point for the program, and ties
 * everything together.
 * 
 * ./inlh [-aiI:f:vm]
 *
 * ###Flags:###
 * '-a' Print out the value of invAB for every equilibrium once its being
 *    found.
 *
 * '-i' Allows for the user to specify the leaving variable at each point
 *      while pivoting. Suggest using -v whenever using -i.
 *
 * '-I n' Allows the user to specify the maximum number of interactive pivots n
 *        which the user is allowed to enter. Once the user enters the first n
 *        leaving variables, the program completes the remaining until it finds
 *        an equilibrium, this happens for every missing label being tested at a
 *        given equilibrium. n <= 0 is equivalent to -i flag.
 *
 * '-f filename' Prints out the equivalent LCP for the game input into filename
 *
 * '-v'  For a verbose output, which output the tableau information after every pivot
 *
 * '-m'  By default methpd 1 for initialising the LH-path is used, this flag sets
 *       method 2 to be used for initialisation.
 *
 * Author:Tobenna Peter, Igwe  ptigwe@gmail.com  August, 2012
 */

#include <math.h>
#include <ctype.h>
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

static int n; 	/**< LCP dimension */

int m;  /**< Number of rows in input matrix */
int n1; /**< Number of columns in input matrix */

FILE* lcpout; /**< File to store the equivalent LCP */

/** max no of characters + 1 (for terminating '\0') 
* of a string  s  declared as  char s[MAXSTR] 
* to be read from stdin by readstr
*/
#define MAXSTR 100  

/*------------------ error message ----------------*/
/**
 * Prints out a message and exits the program.
 *
 * \param info A string containing the error message.
 */
void notimpl (char *info)
{
    fflush(stdout);
    fprintf(stderr, "Program terminated with error. %s\n", info);
    exit(1);
}

/*------------------ read-in routines --------------------------*/
/** 
 * Reads in a string from the standard input.
 * Reads string  s  from stdin, to fit  char s[MAXSTR]
 * if length >= MAXSTR-1  a warning is sent to stderr
 * returns EOF if EOF encountered, then  s  undefined.
 *
 * \param s The string to be read in to from the stdin
 * \returns EOF if EOF was encountered otherwise same return value as scanf
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

/** 
 * Reads in a specific string.
 * The input string is a string of nonblank chars which have to
 * match in that order the next nonblank  stdin  chars otherwise
 * readconf  complains and terminates.
 *
 * \param s The string to be read and matched
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

/**
 * Reads n rationals into the array of rationals. 
 * Terminates with error if EOF encountered earlier.
 * Array indices in error info called  1...n
 *
 * \param v     The array the ratinoals should be stored in
 * \param info  denotes name of array for error information
 */
void readnrats (Rat *v, const char *info)
{
    char srat[MAXSTR];
    int j ;
    /*int num,den;*/

    for (j=0; j<n; j++)
    {
        if(readstr(srat)==EOF)
        {
            fprintf(stderr, "Missing input of %s[%d]\n", info, j+1);
            notimpl("");
        }
        v[j] = ratfroma(srat, info, j);
    } 
}   /* end of readnrats  */

/** 
 * Allocate memory for the payoff matrices.
 *
 * \param m Number of rows in the payoff matrix
 * \param n Number of columns in the payoff matrix
 */
void setmatrices(int m, int n)
{
    T2ALLOC(payoffA, m, n, Rat);
    T2ALLOC(payoffB, m, n, Rat);
}

/**
 * Free the memory used by the payoff matrices
 *
 * \param m Number of rows in the payoff matrix
 */
void freematrices(int m)
{
    FREE2(payoffA, m);
    FREE2(payoffB, m);
}

/** 
 * Read the payoff Matrices A and B from the standard input.
 */
void readMatrices()
{
    /* read in  M   */
    int i;
    char info[10];

    readconf("A=");

    for (i=0; i<m; ++i)
    {
        sprintf(info, "A[%d]", i+1);
        n = n1;
        readnrats(payoffA[i], info);
    }

    readconf("B=");

    for (i=0; i<m; ++i)
    {
        sprintf(info, "B[%d]", i+1);
        n = n1;
        readnrats(payoffB[i], info);
    }
}

/**
 * Reads the game input. This includes the size of the game,
 * and the two payoff matrices.
 */
void readGame ()
        /* reads LCP data  n, M, q, d  from stdin       */
{
    /* get problem dimension */
    readconf("m=");
    scanf("%d", &m);
    readconf("n=");
    scanf("%d", &n1);

    setmatrices(m, n1);
    readMatrices();
}       /* end of reading in LCP data   */

/**
 * Calculate the complement (-mat) of the matrix given the maximum of
 * the matrix. This computation is done as mat[i][j] = -(mat[i][j] - rat).
 *
 * \param mat The matrix to be complemented
 * \param rat The ceiling of the maximum value of the matrix (rat = ceil(max(mat))).
 *            If max(mat) is an integer, then 1 is added to the computed value of rat.
 * \param m   The number of rows in mat
 * \param n   The number of columns in mat
 */
void complementMatrix(Rat** mat, Rat rat, int m, int n)
{
    int i;
    rat = ratneg(rat);
    for (i = 0; i < m; i++)
    {
        int j;
        for(j = 0; j < n; ++j)
        {
            mat[i][j] = ratneg(ratadd(mat[i][j], rat));
        }
    }
}

/**
 * Convert the matrices to the LCP matrix M. 
 */
void convertlcpM()
{	
    n = m+n1+2;
    setlcp(n);
    int i;

    lcpM[0][0] = lcpM[0][1] = ratfromi(0);
    for(i = 0; i < m; ++i)
    {
        lcpM[0][i+2] = ratfromi(1);
    }
    for(i = 0; i < n1; ++i)
    {
        lcpM[0][i+2+m] = ratfromi(0);
    }

    lcpM[1][0] = lcpM[1][1] = ratfromi(0);
    for(i = 0; i < m; ++i)
    {
        lcpM[1][i+2] = ratfromi(0);
    }
    for(i = 0; i < n1; ++i)
    {
        lcpM[1][i+2+m] = ratfromi(1);
    }

    for(i = 0; i < m; ++i)
    {
        int j;
        for(j = 0; j < 2+m+n1; ++j)
        {
            if(j == 0)
            {
                lcpM[i+2][j] = ratfromi(-1);
            }
            else if (j > m+1)
            {
                lcpM[i+2][j] = payoffA[i][j - (m+2)];
            }
            else
            {
                lcpM[i+2][j] = ratfromi(0);
            }
        }
    }

    for(i = 0; i < n1; ++i)
    {
        int j;
        for(j = 0; j < 2+m+n1; ++j)
        {
            if(j == 1)
            {
                lcpM[i+2+m][j] = ratfromi(-1);
            }
            else if (j > 1 && j < 2+m)
            {
                lcpM[i+2+m][j] = payoffB[j - 2][i];
            }
            else
            {
                lcpM[i+2+m][j] = ratfromi(0);
            }
        }
    }
}

/**
 * Computes the LCP q vector
 */
void convertq()
{
    rhsq[0] = rhsq[1] = ratfromi(-1);
    int i;
    for(i = 0; i < m+n1; i++)
    {
        rhsq[i+2] = ratfromi(0);
    }
}

/**
 * Compute the value of LCP d-vector
 */
void convertd()
{
    int i;
    for(i = 0; i < 2+m+n1; i++)
    {
        if(i == k+1)
        {
            vecd[i] = ratfromi(0);
        }
        else
        {
            vecd[i] = ratfromi(1);
        }
    }
}

/** 
 * Prints the lcpM to the output file lcpout
 */
void printlcpM()
{
    fprintf(lcpout, "n= %d\nM=\n", n);
    int i;
    for(i = 0; i < n; i++)
    {
        int j;
        for(j = 0; j < n; j++)
        {
            char str[MAXSTR];
            rattoa(lcpM[i][j], str);
            fprintf(lcpout, "%s ", str);
        }
        fprintf(lcpout, "\n");
    }
}

/** 
 * Prints the RHS to the output file lcpout
 */
void printlcpq()
{
    fprintf(lcpout, "q= ");
    int i;
    for(i = 0; i < n; i++)
    {
        char str[MAXSTR];
        rattoa(rhsq[i], str);
        fprintf(lcpout, "%s ", str);
    }
}

/** 
 * Prints the vecd to the output file lcpout
 */
void printlcpd()
{
    fprintf(lcpout, "\nd= ");
    int i;
    for(i = 0; i < n; i++)
    {
        char str[MAXSTR];
        rattoa(vecd[i], str);
        fprintf(lcpout, "%s ", str);
    }
}

/** 
 * Prints the LCP to the output file lcpout 
 */
void printLCP()
{
    printlcpM();
    printlcpq();
    printlcpd();
    fclose(lcpout);
}

/** 
 * Converts the game to an equivalent LCP.
 */
void convert()
{	
    /* Find the value of -A and -B using the method
    * described in the report */
    Rat o = ratfromi(1);

    Rat ma = maxMatrix(payoffA, m, n1);
    Rat a = ratfromi((int)ceil(rattodouble(ma)));
    a = (ratiseq(a, ma)) ? ratadd(a, o) : a;

    o = ratfromi(1);
    Rat mb = maxMatrix(payoffB, m, n1);
    Rat b = ratfromi((int)ceil(rattodouble(mb)));
    b = (ratiseq(b, mb)) ? ratadd(b, o) : b;

    complementMatrix(payoffA, a, m, n1);
    complementMatrix(payoffB, b, m, n1);
    nrows = m;
    ncols = n1;
    convertlcpM();
    convertq();
    convertd();
}

/* ---------------------- main ------------------------ */  
/**
 * The main program.
 * Reads in arguments from argv, and sets the flags for the
 * Lemke-Howson algorithim accordingly. Reads the game from
 * stdin, converts it to an equivalent LCP, and computes all
 * reachable Nash Equilibria.
 */
int main(int argc, char *argv[])
{
    int c;
    k2 = 0;
    Flagsrunlemke flags;

    flags.maxcount   = 0;
    flags.bdocupivot = 1;
    flags.binitabl   = 0;
    flags.bouttabl   = 0;
    flags.boutsol    = 0;
    flags.binteract  = 0;
    flags.blexstats  = 0;
    flags.bouteq = 0;
    flags.interactcount = 0;
    flags.binitmethod = 1;
    flags.boutinvAB = 0;
    flags.boutpiv = 0;
    flags.bisArtificial = 1;
    /* parse options    */
    while ( (c = getopt (argc, argv, "if:vVI:maep")) != -1)
        switch (c)
        {
            case 'a':
                flags.boutinvAB = 1;
                break;
            case 'e':
                flags.bouteq = 1;
                break;
            case 'I':
                flags.interactcount = atoi(optarg);
            case 'i':
                flags.binteract  = 1;
                printf("Interactive flag set.\n");
                break;
            case 'f':
                lcpout = fopen(optarg, "w+");
                break;
            case 'V':
                flags.bouttabl = 1;
                flags.blexstats  = 1;
                printf("Verbose tableau output.\n");
            case 'v':
                flags.binitabl   = 1;
                flags.boutpiv = 1;
                flags.boutsol = 1;
                flags.bouteq = 0;
                break;
            case 'm':
                flags.binitmethod = 0;
                break;
            case 'p':
                flags.boutpath = 1;
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

    readGame();
    k = 1;
    convert();
    if(lcpout != NULL)
    {
        printLCP();
    }
    computeEquilibria(flags); 
    freematrices(m);
    return 0;
}
