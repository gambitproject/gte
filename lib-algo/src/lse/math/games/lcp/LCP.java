package lse.math.games.lcp;

import lse.math.games.Rational;
import lse.math.games.io.ColumnTextWriter;
import static lse.math.games.Rational.*;

/** 
 * Linear Complementarity Problem (aka. LCP)
 * =================================================================================
 * (1) Mz + q >= 0
 * (2) z >= 0
 * (3) z'(Mz + q) = 0
 * 
 * (1) and (2) are feasibility conditions.                
 * (3) is complementarity condition (also written as w = Mz + q where w and z are orthogonal)
 * Lemke algorithm takes this (M, q) and a covering vector (d) and outputs a solution
 */
public class LCP {
	private static int MAXLCPDIM = 2000;       /* max LCP dimension                       */ //MKE: Why do we need a max?

    // M and q define the LCP
    Rational[][] M;
    Rational[] q;
    
    // d vector for Lemke algo
    Rational[] d;

    /* allocate and initialize with zero entries an LCP of dimension  n
     * this is the only method changing  lcpdim  
     * exit with error if fails, e.g. if  n  not sensible
     */
    public LCP(int dimension)
    {
        if (dimension < 1 || dimension > MAXLCPDIM) {
            throw new RuntimeException(String.format( //TODO: RuntimeException not the cleanest thing to do here
                "Problem dimension  n=%d not allowed.  Minimum  n is 1, maximum %d.", 
                dimension, MAXLCPDIM));
        } 
       
        M = new Rational[dimension][dimension];
        q = new Rational[dimension];
        d = new Rational[dimension];
        
        for (int i = 0; i < M.length; i++) {
            for (int j = 0; j < M[i].length; j++) {
                M[i][j] = Rational.ZERO;
            }
            q[i] = Rational.ZERO;
            d[i] = Rational.ZERO;
        }
    }

    public boolean isTrivial()
    {
        boolean isQPos = true;
        for (int i = 0, len = q.length; i < len; ++i) {
            if (q[i].compareTo(0) < 0) {
                isQPos = false;
            }
        }
        return isQPos;
    }

    //when is negate false?
    // TODO: how do I consolidate the code in these two methods elegantly... delegate?
    // TODO: These methods do not really have anything to do with LCP...
    public void payratmatcpy(Rational[][] frommatr, boolean bnegate,
        boolean btranspfrommatr, int nfromrows, int nfromcols,
        int targrowoffset, int targcoloffset)
    {
        for (int i = 0; i < nfromrows; i++) {
            for (int j = 0; j < nfromcols; j++) {                    
                Rational value = (frommatr[i][j].isZero()) ? ZERO : (bnegate ? frommatr[i][j].negate() : frommatr[i][j]);
                SetMEntry(btranspfrommatr, targrowoffset, targcoloffset, i, j, value);
            }
        }
    }

    //integer to rational matrix copy
    public void intratmatcpy(int[][] frommatr, boolean bnegate,
        boolean btranspfrommatr, int nfromrows, int nfromcols,
        int targrowoffset, int targcoloffset)
    {
        for (int i = 0; i < nfromrows; i++) {
            for (int j = 0; j < nfromcols; j++) {
                Rational value = (frommatr[i][j] == 0) ? ZERO : (bnegate ? Rational.valueOf(-frommatr[i][j]) : Rational.valueOf(frommatr[i][j]));
                SetMEntry(btranspfrommatr, targrowoffset, targcoloffset, i, j, value);
            }
        }
    }

    private void SetMEntry(boolean btranspfrommatr, int targrowoffset, int targcoloffset, int i, int j, Rational value)
    {
        if (btranspfrommatr) {
            M[j + targrowoffset][i + targcoloffset] = value;
        } else {
            M[i + targrowoffset][j + targcoloffset] = value;
        }
    }

    public Rational[][] M() { return M; }
    public Rational M(int row, int col) { return M[row][col]; }
    public void setM(int row, int col, Rational value) { M[row][col] = value; }
    
    public Rational[] q() { return q; }
    public Rational q(int row) { return q[row]; }
    public void setq(int row, Rational value) { q[row] = value; }
    
    public Rational[] d() { return d; }
    public Rational d(int row) { return d[row]; }
    public void setd(int row, Rational value) { d[row] = value; }
    
    public int size() { return d.length; }
    
    @Override
    public String toString()
    {    	
    	final ColumnTextWriter colpp = new ColumnTextWriter();    	
    	colpp.writeCol("M");
    	for (int i = 1; i < size(); ++i) {
    		colpp.writeCol(""); 
    	}
    	colpp.writeCol("d");
    	colpp.writeCol("q");
    	colpp.endRow();
    	
		for (int i = 0; i < size(); ++i)
        {        	     	      
            for (int j = 0; j < M[i].length; j++)
            {
                //if (j > 0) output.append(", ");            	
                colpp.writeCol(M[i][j] == Rational.ZERO ? "." : M[i][j].toString());
            }            
            colpp.writeCol(d[i].toString());            
            colpp.writeCol(q[i].toString());            
            colpp.endRow();
        }
    	return colpp.toString();    	
    }
}
