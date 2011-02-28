package lse.math.games.lcp;

import lse.math.games.lcp.LemkeAlgorithm.RayTerminationException;

// This class seems specific to the representation of the Tableau?
// See if I can decouple from specifics of Tableau
// See if I can decouple from LCP specifics (read: z0leave)
//
// This class takes an var to enter the basis and determines which
// var should leave.
//
// This needs to be split into two parts, one part belongs in Lemke, the other in Tableau
public class LexicographicMethod
{
    public int[] tested;        //TODO: make private
    public int[] comparisons;   //TODO: make private  
    private int[] leavecand;    /* leavecand [0..numcand-1] = candidates (rows) for leaving var */ 
    private LCP start;

    public LexicographicMethod(int basisSize, LCP start)
    {
	this.start = start;
        leavecand = new int[basisSize];
        InitStatistics(basisSize + 1);
    }

    //region Minimum Leaving Variable
    private boolean z0leave;
    
    /**
     * z0leave
     * ==========================================================
     * @return the state of the z0leave boolean following the 
     * last call to minVar().  Indicates that z0 can leave the
     * basis, but the lex-minratio test is performed fully,
     * so the returned value might not be the index of  z0.
     */
    public boolean z0leave() { return z0leave; }

    /** 
     * minVar
     * ===========================================================
     * @return the leaving variable in  VARS, given by lexmin row, 
     * when  enter  in VARS is entering variable
     * only positive entries of entering column tested
     * boolean  *z0leave  indicates back that  z0  can leave the
     * basis, but the lex-minratio test is performed fully,
     * so the returned value might not be the index of  z0
     */
    public int lexminratio(Tableau A, int enter)
    	throws RayTerminationException
    {
        z0leave = false;                                                
        
        // TODO: I think I can comment for perf... (but a unit test will fail)
        // I could pass in a cobasic index instead
        A.vars().assertNotBasic(enter);
        int col = A.vars().col(enter);
                      
        int numcand = 0;
        for (int i = 0; i < leavecand.length; i++) {                    /* start with  leavecand = { i | A[i][col] > 0 } */
            if (A.isPositive(i, col)) {
                leavecand[numcand++] = i;
            }
        }

        if (numcand == 0) {
            rayTermination(A, enter);
        } /*else if (numcand == 1) {
            RecordStats(0, numcand);
            z0leave = IsLeavingRowZ0(leavecand[0]);
        }*/ else {
            processCandidates(A, col, leavecand, numcand);
        }

        return A.vars().rowVar(leavecand[0]);
    }                                                                   /* end of lexminvar (col, *z0leave); */


    private boolean IsLeavingRowZ0(Tableau A, int row)
    {
        return A.vars().rowVar(row) == A.vars().z(0);
    }

    /**
     * processCandidates
     * ================================================================
     * as long as there is more than one leaving candidate perform
     * a minimum ratio test for the columns of  j  in RHS, W(1),... W(n)
     * in the tableau.  That test has an easy known result if
     * the test column is basic or equal to the entering variable.
     */
    private void processCandidates(Tableau A, int enterCol, int[] leavecand, int numcand)
    {
        numcand = ProcessRHS(A, enterCol, leavecand, numcand);
        for (int j = 1; numcand > 1; j++)
        {
            if (j >= A.RHS())                                             /* impossible, perturbed RHS should have full rank */
                throw new RuntimeException("lex-minratio test failed"); //TODO
            RecordStats(j, numcand);
            
            int var = A.vars().w(j);
            if (A.vars().isBasic(var))
            {                                  /* testcol < 0: W(j) basic, Eliminate its row from leavecand */
                int wRow = A.vars().row(var);
                numcand = removeRow(wRow, leavecand, numcand); // TODO: revmove r
            }
            else
            {                                                          				/* not a basic testcolumn: perform minimum ratio tests */
                int wCol = A.vars().col(var); // TODO: get s           				/* since testcol is the  jth  unit column                    */
                if (wCol != enterCol) {                                            	/* otherwise nothing will change */
                    numcand = minRatioTest(A, enterCol, wCol, leavecand, numcand);
                }
            }
        }
    }

    private int ProcessRHS(Tableau A, int enterCol, int[] leavecand, int numcand)
    {
        RecordStats(0, numcand);

        numcand = minRatioTest(A, enterCol, A.RHS(), leavecand, numcand);
        
        for (int i = 0; i < numcand; ++i) {            // seek  z0  among the first-col leaving candidates
            z0leave = IsLeavingRowZ0(A, leavecand[i]);
            if (z0leave) {
                break;
            }
            /* alternative, to force z0 leaving the basis:
             * return whichvar[leavecand[i]];
             */
        }            
        return numcand;
    }

    private int removeRow(int row, int[] candidates, int numCandidates)
    {
        for (int i = 0; i < numCandidates; i++) {
            if (candidates[i] == row) {
                candidates[i] = candidates[--numCandidates];        /* shuffling of leavecand allowed */
                break;
            }
        }
        return numCandidates;
    }

    //TODO: should this be package visible?  Better way to test this?
    int minRatioTest(Tableau A, int col, int testcol, int[] candidates, int numCandidates)
    {
        int newnum = 0;
        
        for (int i = 1; i < numCandidates; i++) {                       /* investigate remaining candidates                  */

            int sgn = A.ratioTest(                                      /* sign of  A[l_0,t] / A[l_0,col] - A[l_i,t] / A[l_i,col]   */
                candidates[0], candidates[i], col, testcol);            /* note only positive entries of entering column considered */
                                                                        
            if (sgn == 0) {                                             /* new ratio is the same as before                          */        
                ++newnum;
                candidates[newnum] = candidates[i];
            }
            else if (sgn == 1) {                                        /* new smaller ratio detected */
                newnum = 0;
                candidates[newnum] = candidates[i];
            }                
        }
        return newnum + 1;                                              /* leavecand[0..newnum]  contains the new candidates */
    }


    //region Statistics        

    /* 
     * initialize statistics for minimum ratio test
     */
    private void InitStatistics(int sizeBasisPlusZ0)
    {
        tested = new int[sizeBasisPlusZ0];
        comparisons = new int[sizeBasisPlusZ0];
        for (int i = 0; i < sizeBasisPlusZ0; i++)
            tested[i] = comparisons[i] = 0;
    }

    private void RecordStats(int idx, int numCandidates)
    {
        if (tested != null) tested[idx] += 1;
        if (comparisons != null) comparisons[idx] += numCandidates;
    }


    //region Exception Routines

    private void rayTermination(Tableau A, int enter)
    	throws RayTerminationException
    {
        String error = String.format("Ray termination when trying to enter %s", A.vars().toString(enter));
        throw new RayTerminationException(error, A, start);
    }
}
