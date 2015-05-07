/**
 * \file lemke.h
 * Declarations for lcp solver.
 *
 * 16 Apr 2000
 * Author: Bernhard von Stengel  stengel@maths.lse.ac.uk
 *
 * Edited: Tobenna Peter, Igwe  ptigwe@gmail.com  August, 2012
 */

/* #include before:  rat.h       */
#include "list.h"
#include "rat.h"
#ifndef LEMKE_H
#define LEMKE_H

#define MAXLCPDIM 2000       /**< max LCP dimension                       */
#define INFOSTRINGLENGTH 8   /**< string naming vars, e.g. "z0", "w187"   */
#define LCPSTRL  60          /**< length of string containing LCP entry   */

/* LCP input data                                               */
extern  Rat **lcpM;             /**< LCP Matrix                   */
extern  Rat *rhsq;              /**< right hand side  q           */
extern  Rat *vecd;              /**< LCP covering vector  d       */
extern  int lcpdim;             /**< LCP dimension                */

/* LCP result data                                              */
extern  Rat  *solz;             /**< LCP solution  z  vector      */
/** Number of Lemke pivot iterations, including the first to pivot z0 in    */
extern  int  pivotcount;

/*GSOC12*/
/** Number of rows in the input matrix game */
extern int nrows;
/** Number of columns in the input matrix game */
extern int ncols;
/** The missing label from the artificial equilibrium */
extern int k;
/** The missing label when restarting from a computed equilibrium */
extern int k2;
/** The payoff matrix for player 1 */
extern Rat** payoffA;
/** The payoff matrix for player 2 */
extern Rat** payoffB;

/** The list of negatively indexed equilibria*/
extern node* neg;  
/** The list of positively indexed equilibria*/
extern node* pos;

int vartoa(int v, char s[]);

/**
 * Allocate and initialise the LCP.
 * Allocate and initialise with zero entries an LCP of dimension  n
 * this is the only method changing  lcpdim  
 * exit with error if fails, e.g. if  n  not sensible
 */
void setlcp(int n);

/** Output the LCP as given      */
void outlcp (void);

/** Flags for  runlemke  */
typedef struct
{
    int   maxcount  ;   /**< Maximum number of iterations, infinity if 0         */
    int   bdocupivot;   /**< Y/N  document pivot step                     */
    int   binitabl ;    /**< Y/N  output entire tableau at beginning/end  */
    int   boutpiv  ;    /**< Y/N  output current pivot step */
    int   bouttabl  ;   /**< Y/N  output entire tableau at each step      */
    int   boutsol   ;   /**< Y/N  output solution                         */
    int   binteract ;   /**< Y/N  interactive pivoting                    */
    int   blexstats ;   /**< Y/N  statistics on lexminratio tests         */
    int   bouteq;       /**< Y/N  Immediately output equilibrium */
    int   boutpath;     /**< Y/N  output the LH path */
    int   interactcount;/**< Number of interactive entries                *//* GSoC12: Tobenna Peter, Igwe */
	int   binitmethod;  /**< Used to select the initialisation method     *//* GSoC12: Tobenna Peter, Igwe */
    int   boutinvAB;	/**< Y/N  output inverse of A_B                   *//* GSoC12: Tobenna Peter, Igwe */
	int   bisArtificial;/**< If the current equilibrium is artificial     *//* GSoC12: Tobenna Peter, Igwe */
}Flagsrunlemke;

/** 
 * Solve LCP via Lemke's algorithm.
 * Solution is stored in  solz [0..lcpdim-1], exit with error if ray termination.
 * This code initialises the tableau with prior pivots to ensure the
 * Lemke-Howson path.
 *
 * \param flags The flags for running Lemke's algorithm.
 */
int runlemke(Flagsrunlemke flags);

/** 
 * Compute all equilibria reachable by the Lemke-Howson algorithm.
 * The complete bi-partite graph of reachable equilibria from the
 * artificial equilibrium is stored in neg and pos, which represent
 * the two different partitions of the graph.
 *
 * \param flags The flags for running Lemke's algorithm.
 */
/* GSoC12: Tobenna Peter, Igwe */
void computeEquilibria(Flagsrunlemke flags);

#endif