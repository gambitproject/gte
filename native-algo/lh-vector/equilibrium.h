/**
 * \file equilibrium.h
 *
 * Storing tableaus representing equilibrium, and computing the equilibrium.
 * This structure is mainly used by the list (list.h) to store the bi-partite
 * graph of equilibria found. The tableau information of the equilibrium is 
 * stored, because the equilibrium can be computed from it, and if we want to
 * restart from a given equilibrium, the tableau can simply be copied from this
 * structure into the variables used for pivoting, initialised and the Lemke's
 * algorithm runs to compute a new equilibrium.
 *
 * Author: Tobenna Peter, Igwe  ptigwe@gmail.com  August, 2012
 */
 
/* Include rat.h before this file */
#ifndef EQUILIBRIUM_H
#define EQUILIBRIUM_H

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "alloc.h"
#include "col.h"
#include "rat.h"

#ifdef GLEMKE
#include "gmp.h"
#include "gmpwrap.h"
#else
#include "mp.h"
#endif

/**
 * An equilibrium structure which represents a computed
 * equilibrium. This stores the tableau representing an
 * equilibrium, in such a way that it can be easily copied
 * and initialised for the Lemke's algorithm.
 */
typedef struct equilibrium
{
	#ifndef GLEMKE
	mp** A;     /**< The tableau matrix */
	mp *scfa;   /**< The scale factors for the TABCOLs */
	mp det;     /**< The determinant of the tableau */
	#else
	gmpt** A;   /**< The tableau matrix */
	gmpt* scfa; /**< The scale factors for the TABCOLs */
	gmpt det;   /**< The determinant of the tableau */
	#endif
	
	int* bascobas;  /**< VARS  -> ROWCOL */
	int* whichvar;  /**< ROWCOL -> VARS, inverse of bascobas  */
	int lcpdim;     /**< Dimensions of the LCP */
    int nrows;
    int ncols;
}Equilibrium;

#ifndef GLEMKE
/**
 * Creates an equilibrium structure given the information of the tableau.
 */
Equilibrium createEquilibrium(mp** A, mp* scfa, mp det, int* bascobas, int* whichvar, int dim, int nrows, int ncols);
#else
/**
 * Creates an equilibrium structure given the information of the tableau.
 */
Equilibrium createEquilibrium(gmpt** A, gmpt* scfa, gmpt det, int* bascobas, int* whichvar, int dim, int nrows, int ncols);
#endif

/**
 * Frees the memory allocated to the various members
 * of the given equilibrium.
 *
 * \param eq Equilibrium to be released from memory.
 * \sa createEquilibrium
 */
void freeEquilibrium(Equilibrium eq);

void colprEquilibrium(Equilibrium eq);

/**
 * Prints the specifie equilibrium.
 *
 * \param eq Equilibrium to be printed to the standard output.
 */
void printEquilibrium(Equilibrium eq);

/**
 * Returns the strategy represented by the given equilibrium. The array
 * of rational numbers which are returned consist of player 1's
 * strategies, followed by player 2's strategies.
 *
 * \param eq The tableau representation
 * \returns  An array of rational numbers representing the equilibrium
 */
Rat* getStrategies(Equilibrium eq);

/**
 * Returns an integer value representing TRUE or FALSE if both
 * e1 and e2 are equal or not.
 *
 * \returns 1 if e1 and e2 are equal and 0 if e1 and e2 are not
 * equal.
 */
int equilibriumisEqual(Equilibrium e1, Equilibrium e2);

#endif