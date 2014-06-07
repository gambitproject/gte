/**
 * \file gequilibrium.c
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

#define GLEMKE

#include "rat.h"
#include "equilibrium.h"


#define Z(i) (i)
#define W(i,n) (i+n)
#define RHS(n)  (n+1)                   /*  q-column of tableau    */

Equilibrium createEquilibrium(gmpt** A, gmpt* scfa, gmpt det, int* bascobas, int* whichvar, int n, int nrows, int ncols)
{
	Equilibrium eq;
	
	T2ALLOC (eq.A, n, n+2, gmpt);
	G2INIT (eq.A, n, n+2);
    eq.scfa = TALLOC (n+2, gmpt);
    eq.bascobas = TALLOC(2*n+1, int);
	eq.whichvar = TALLOC(2*n+1, int);
	
	int i, j;
	for(i = 0; i < n; ++i)
	{
		for(j = 0; j < n+2; ++j)
		{
			gset(eq.A[i][j], A[i][j]);
		}
	}
	
	for(i = 0; i < n+2; ++i)
	{
		gset(eq.scfa[i], scfa[i]);
	}
	
	for(i = 0; i < 2*n+1; ++i)
	{
		eq.bascobas[i] = bascobas[i];
		eq.whichvar[i] = whichvar[i];
	}
	ginit(eq.det);
	gset(eq.det, det);
	
	eq.lcpdim = n;
    eq.nrows = nrows;
    eq.ncols = ncols;
	
	return eq;
}

void freeEquilibrium(Equilibrium eq)
{
    G2CLEAR(eq.A, eq.lcpdim, eq.lcpdim+2)
	FREE2(eq.A, eq.lcpdim);
	free(eq.scfa);
	free(eq.bascobas);
	free(eq.whichvar);
}

Rat* getStrategies(Equilibrium eq)
{	
	int n = eq.lcpdim;
	
	Rat* strat;
	strat = malloc((n) * sizeof(Rat));
	
	int i, row;
	gmpt num, den;
	ginit(num);
	ginit(den);
	
	for (i=1; i<=n; i++) 
    {
		if((row = eq.bascobas[Z(i)]) < n) /* If Z(i) is basic */
		{	
            /* value of  Z(i):  scfa[Z(i)]*rhs[row] / (scfa[RHS]*det)   */
        	gmulint(eq.scfa[Z(i)], eq.A[row][RHS(n)], num);
			gmulint(eq.det, eq.scfa[RHS(n)], den);
            greduce(num, den);
			strat[i-1] = ratinit();
			gset(strat[i-1].num, num);
			gset(strat[i-1].den, den);
		}
		else if((row = eq.bascobas[W(i,n)]) < n)
		{
			strat[i-1] = ratfromi(0);
			/* value of  W(i-n)  is  rhs[row] / (scfa[RHS]*det)         
        	copy(num, eq.A[row][RHS(n)]);
			mulint(eq.det, eq.scfa[RHS(n)], den);
            reduce(num, den);
			copy(strat[i-1].num, num);
			copy(strat[i-1].den, den);*/
		}
		else
		{
			strat[i-1] = ratfromi(0);
		}
    }   /* end of  for (i=...)          */
	gclear(num);
	gclear(den);
	return strat;
}

void colprEquilibrium(Equilibrium eq)
{
    char smp [2*DIG2DEC(MAX_DIGITS) + 4];
    
    int i;
    int n = eq.lcpdim;
    
    Rat *rats = getStrategies(eq);
    
    colpr("P1:");
	for(i = 2; i < eq.nrows + 2; ++i)
	{
		rattoa(rats[i], smp);
		colpr(smp);
	}
	
    colpr("P2:");
    for(; i < n; ++i)
    {
    	rattoa(rats[i], smp);
    	colpr(smp);
    }
}

void printEquilibrium(Equilibrium eq)
{
    int n = eq.lcpdim;
    colset(n+2);    /* column printing to see complementarity of  w  and  z */
    colprEquilibrium(eq);
    colout();
}

/* Checks the two equlibria are equal */
int equilibriumisEqual(Equilibrium e1, Equilibrium e2)
{
	int i;
	int result = 1;
	int n = e1.lcpdim;
	
	Rat* strat1 = getStrategies(e1);
	Rat* strat2 = getStrategies(e2);
	
	/* Check the two strategies are equal represented by the equlibrium
	 * Ignore the payoff variables when checking equality */
	for(i = 2; i < n; ++i)
	{
		if(!(result = ratiseq(strat1[i], strat2[i])))
		{
			break;
		}
	}
	
	free(strat1);
	free(strat2);
	return result;
}