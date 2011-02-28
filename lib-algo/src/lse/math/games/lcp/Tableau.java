package lse.math.games.lcp;

import java.math.BigInteger;

import lse.math.games.BigIntegerUtils;
import lse.math.games.Rational;
import lse.math.games.io.ColumnTextWriter;
import static lse.math.games.Rational.*;

// TODO: try to keep all row/col logic encapsulated.
// Users deal just with vars
// TODO: decouple the LCP specifics
// TODO: better constructor, make sure scalefactors are correct
public class Tableau 
{
    private BigInteger[][] A;        
    private int ncols;
    private int nrows;

    private BigInteger det;     /* determinant                  */

    /* scale factors for variables z
     * scfa[Z(0)]   for  d,  scfa[RHS] for  q
     * scfa[Z(1..n)] for cols of  M
     * result variables to be multiplied with these
     */
    private BigInteger[] scfa;

    /*  v in VARS, v cobasic:  TABCOL(v) is v's tableau col */
    /*  v  basic:  TABCOL(v) < 0,  TABCOL(v)+n   is v's row */
    private TableauVariables vars;


    public int RHS() { return ncols - 1; }                        /*  q-column of tableau    */
    public TableauVariables vars() { return vars; }    


    //region Init

    /* VARS   = 0..2n = Z(0) .. Z(n) W(1) .. W(n)           */
    /* ROWCOL = 0..2n,  0 .. n-1: tabl rows (basic vars)    */
    /*                  n .. 2n:  tabl cols  0..n (cobasic) */
    public Tableau(int sizeBasis)
    {
        this.nrows = sizeBasis;
        this.ncols = sizeBasis + 2;
        
        A = new BigInteger[nrows][ncols];
        scfa = new BigInteger[ncols];

        vars = new TableauVariables(nrows);

        det = BigInteger.valueOf(-1); // TODO: how do I know this? Specific to LCP?
    }

    /* fill tableau from  M, q, d   */
    /* TODO: decouple Tableau from LCP... have LCP return the Tableau
     * constructor for Tableau should be of lhs and rhs? 
     */
    public void fill(Rational[][] M, Rational[] q, Rational[] d)
    {
        if (M.length != q.length || M.length != d.length || (M.length > 1 && M.length != M[0].length))
            throw new RuntimeException("LCP components not consistent dimension"); //TODO

        if (M.length != nrows)
        	throw new RuntimeException("LCP dimension does not fit in Tableau size"); //TODO
        
        for (int j = 0; j < ncols; ++j)
        {                
            BigInteger scaleFactor = ComputeScaleFactor(j, M, q, d);
            scfa[j] = scaleFactor;

            /* fill in col  j  of  A    */
            for (int i = 0; i < nrows; ++i)
            {
                Rational rat = RatForRowCol(i, j, M, q, d);                    

                /* cols 0..n of  A  contain LHS cobasic cols of  Ax = b     */
                /* where the system is here         -Iw + dz_0 + Mz = -q    */
                /* cols of  q  will be negated after first min ratio test   */
                /* A[i][j] = num * (scfa[j] / den),  fraction is integral       */

                A[i][j] = (scaleFactor.divide(rat.den)).multiply(rat.num);
            }
        }   /* end of  for(j=...)   */
    }       /* end of filltableau()         */


    /* compute lcm  of denominators for  col  j  of  A                   */
    /* Necessary for converting fractions to integers and back again    */
    private BigInteger ComputeScaleFactor(int col, Rational[][] M, Rational[] q, Rational[] d)
    {
        BigInteger lcm = BigInteger.valueOf(1);
        for (int i = 0; i < nrows; ++i)
        {
        	BigInteger den = RatForRowCol(i, col, M, q, d).den;

            lcm = BigIntegerUtils.lcm(lcm, den);

            // TODO
            //if (col == 0 && lcm.GetType() == typeof(DefaultMP)) 
            //    record_sizeinbase10 = (int)MP.SizeInBase(lcm, 10) /* / 4*/;
        }
        return lcm;
    }

    private Rational RatForRowCol(int row, int col, Rational[][] M, Rational[] q, Rational[] d)
    {
        return  (col == 0) ? d[row] :
                (col == ncols - 1) ? q[row] : 
                M[row][col - 1];            
    }


    //region Pivot
    /* --------------- pivoting and related routines -------------- */ 
    
    /**
     * Pivot tableau on the element  A[row][col] which must be nonzero
     * afterwards tableau normalized with positive determinant
     * and updated tableau variables
     * @param leave (r) VAR defining row of pivot element
     * @param enter (s) VAR defining col of pivot element
     */
    public void pivot(int leave, int enter)
    {
        int row = vars.row(leave);
        int col = vars.col(enter);
        vars.swap(enter, leave, row, col);          /* update tableau variables                                     */
        pivotOnRowCol(row, col); 
    }
       
    private void pivotOnRowCol(int row, int col)
    {
        BigInteger pivelt = A[row][col];             /* pivelt anyhow later new determinant  */

        if (pivelt.compareTo(BigInteger.ZERO) == 0) 
        	throw new RuntimeException("Trying to pivot on a zero"); //TODO

        boolean negpiv = false;
        if (pivelt.compareTo(BigInteger.ZERO) < 0) {
            negpiv = true;
            pivelt = pivelt.negate();
        }

        for (int i = 0; i < nrows; i++) {
        	if (i != row)                           /*  A[row][..]  remains unchanged       */
        	{
                BigInteger aicol = A[i][col];       //TODO: better name for this variable
                boolean nonzero = (aicol.compareTo(BigInteger.ZERO) != 0);
                for (int j = 0; j < ncols; j++) {
                    if (j != col) {
                        BigInteger tmp1 = A[i][j].multiply(pivelt);
                        if (nonzero) {
                            BigInteger tmp2 = aicol.multiply(A[row][j]);
                            if (negpiv) {
                                tmp1 = tmp1.add(tmp2);
                            } else {
                                tmp1 = tmp1.subtract(tmp2);
                            }
                        }
                        A[i][j] = tmp1.divide(det);           /*  A[i,j] = (A[i,j] A[row,col] - A[i,col] A[row,j])/ det     */
                        //A[i,j] = (A[i,j] * A[row,col] - A[i,col] * A[row,j]) / det; 
                    }
                }
        	    if (nonzero && !negpiv) {
                    A[i][col] = aicol.negate();                 /* row  i  has been dealt with, update  A[i][col]  safely   */
        	    }
        	}
        }
        
        A[row][col] = det;
        if (negpiv)
    	    negRow(row);
        det = pivelt;                                   /* by construction always positive      */
    }


    /* negate tableau row.  Used in  pivot()        */
    private void negRow(int row)
    {
        for (int j = 0; j < ncols; ++j)
            if (A[row][j].compareTo(BigInteger.ZERO) != 0)	//non-zero
                A[row][j] = A[row][j].negate(); 			// a = -a
    }


    /* negate tableau column  col   */
    public void negCol(int col)
    {
        for (int i = 0; i < nrows; ++i)
            A[i][col] = A[i][col].negate();					// a = -a
    }

    //region Results
    public Rational result(int var)
    {
        Rational rv;
        if (vars.isBasic(var))                                      /*  var  is a basic variable */
        {
            int row = vars.row(var);
            BigInteger scaleFactor = BigInteger.valueOf(1);
            int scaleIdx = vars.rowVar(row);
            if (scaleIdx >= 0 && scaleIdx < scfa.length - 1)        /* Z(i):  scfa[i]*rhs[row] / (scfa[RHS]*det)         */
            {
                scaleFactor = scfa[scaleIdx];
            }
            //else                                                  /* W(i):  rhs[row] / (scfa[RHS]*det)     */

            BigInteger num = scaleFactor.multiply(A[row][RHS()]);
            BigInteger den = det.multiply(scfa[RHS()]);
            Rational birat = new Rational(num, den);
            
            try {
                rv = new Rational(birat.num.longValue(), birat.den.longValue());
            } catch (Exception ex) {
                String error = String.format(
                    "Fraction too large for basic variable %s: %s/%s",
                    vars.toString(var), num.toString(), den.toString());
                throw new RuntimeException(error, ex); //TODO
                //Console.Out.WriteLine(error);
            }
        } else { // i is non-basic
            rv = ZERO;
        }
        return rv;
    }


    /**
     * Lex helper to encapsulate BigInteger.
     * 
     * @return 
     * sign of  A[a,testcol] / A[a,col] - A[b,testcol] / A[b,col]
     * (assumes only positive entries of col are considered)         
     */
    public int ratioTest(int rowA, int rowB, int col, int testcol)
    {
        return 	A[rowA][testcol].multiply(A[rowB][col]).compareTo(
        		A[rowB][testcol].multiply(A[rowA][col]));
    }


    //region Info

    public boolean isPositive(int row, int col)
    {
        return A[row][col].compareTo(BigInteger.ZERO) > 0;
    }

    public boolean isZero(int row, int col)
    {
        return A[row][col].compareTo(BigInteger.ZERO) == 0;
    }

    public String valToString(int row, int col)
    {
        BigInteger value = A[row][col];
        return (value.compareTo(BigInteger.ZERO) == 0) ? "." : value.toString();
    }

    public String detToString() { return det.toString(); }      // what does this even mean when the matrix is not square?

    public String scaleToString(int scaleIdx) { return scfa[scaleIdx].toString(); }
    

    //only used for tests...
    public long get(int row, int col)
    {
        return A[row][col].longValue();
    }
    
    public void set(int row, int col, long value)
    {
    	A[row][col] = BigInteger.valueOf(value);
    }
    
    @Override
    public String toString()
    {           
    	StringBuilder sb = new StringBuilder();
        sb.append(String.format("Determinant: %s", detToString()));        
        
        ColumnTextWriter colpp = new ColumnTextWriter();
        colpp.endRow();
        colpp.writeCol("var");        
        colpp.alignLeft();
        
        /* headers describing variables */
        for (int j = 0; j <= RHS(); j++)
        {
            if (j == RHS()) {
                colpp.writeCol("RHS");
            } else {
                String var = vars().toString(vars().colVar(j));
                colpp.writeCol(var);
            }
        }
        colpp.endRow();
        colpp.writeCol("scfa");                          /* scale factors                */
        for (int j = 0; j <= RHS(); j++)
        {
            String scfa;
            if (j == RHS() || vars().isZVar(vars().colVar(j))) {      /* col  j  is some  Z or RHS:  scfa    */
                scfa = scaleToString(j);                
            } else {                                                   /* col  j  is some  W           */
                scfa = "1";
            }
            colpp.writeCol(scfa);
        }
        colpp.endRow();
        for (int i = 0; i < vars().size(); i++)                           /* print row  i                 */
        {
            String var = vars().toString(vars().rowVar(i));
            colpp.writeCol(var);
            for (int j = 0; j <= RHS(); j++)
            {
                String value = valToString(i, j);
                colpp.writeCol(value);
            }
	    colpp.endRow();
        }
        colpp.endRow();
        sb.append(colpp.toString());
        return sb.toString();
    }
}
