package lse.math.games.lrs;

import static lse.math.games.BigIntegerUtils.greater;
import static lse.math.games.BigIntegerUtils.negative;
import static lse.math.games.BigIntegerUtils.one;
import static lse.math.games.BigIntegerUtils.positive;
import static lse.math.games.BigIntegerUtils.zero;
import static java.math.BigInteger.*;

import lse.math.games.BigIntegerUtils;
import lse.math.games.Rational;
import lse.math.games.io.ColumnTextWriter;

import java.io.StringWriter;
import java.math.BigInteger;

public class Dictionary 
{
	/******************************************************************************/
	/*                   Indexing after initialization                            */
	/*               Basis                                    Cobasis             */
	/*   ---------------------------------------    ----------------------------- */
	/*  |  i  |0|1| .... |lastdv|lastdv+1|...|m|   | j  | 0 | 1 | ... |d-1|  d  | */
	/*  |-----|+|+|++++++|++++++|--------|---|-|   |----|---|---|-----|---|+++++| */
	/*  |B[i] |0|1| .... |lastdv|lastdv+1|...|m|   |C[j]|m+1|m+2| ... |m+d|m+d+1| */
	/*   -----|+|+|++++++|++++++|????????|???|?|    ----|???|???|-----|???|+++++| */
	/*                                                                            */
	/* Row[i] is row location for B[i]         Col[j] is column location for C[j] */
	/*  -----------------------------              -----------------------------  */
	/* |   i   |0|1| ..........|m-1|m|            | j    | 0 | 1 | ... |d-1| d  | */
	/* |-------|+|-|-----------|---|-|            |------|---|---|---  |---|++++| */
	/* |Row[i] |0|1|...........|m-1|m|            |Col[j]| 1 | 2 | ... | d |  0 | */
	/* --------|+|*|***********|***|*|             ------|***|***|*****|***|++++| */
	/*                                                                            */
	/*  + = remains invariant   * = indices may be permuted ? = swapped by pivot  */
	/*                                                                            */
	/*  m = number of input rows   n= number of input columns                     */
	/*  input dimension inputd = n-1 (H-rep) or n (V-rep)                         */
	/*  lastdv = inputd-nredundcol  (each redundant column removes a dec. var)    */
	/*  working dimension d=lastdv-nlinearity (an input linearity removes a slack) */
	/*  obj function in row 0, index 0=B[0]  col 0 has index m+d+1=C[d]           */
	/*  H-rep: b-vector in col 0, A matrix in columns 1..n-1                      */
	/*  V-rep: col 0 all zero, b-vector in col 1, A matrix in columns 1..n        */
	/******************************************************************************/

    BigInteger[][] A;		// TODO: do not allow interaction via row and cols, but through bas/cob indexes
    int d;					// A has d+1 columns, col 0 is b-vector
    int m;					// A has m+1 rows, row 0 is cost row        
    
    private boolean _lexflag;		// true if lexmin basis for this vertex    
     
    // basis, row location indices
    int[] B;
    int[] rows; // TODO: abstract away use of rows and cols... just interact via bas/cob indexes
    
    // cobasis, column location indices 
    int[] C;
    int[] cols;
    
    int lastdv;		/* index of last dec. variable after preproc    */
    
    private boolean nonnegative = true;
    private BigInteger _det;                 /* current determinant of basis                 */
    private BigInteger[] _gcd;		/* Gcd of each row of numerators               */
	private BigInteger[] _lcm;		/* Lcm for each row of input denominators      */
	//private long d_orig;					// value of d as A was allocated  (E.G.)
    private boolean homogeneous = true;
    private Rational obj;					// objective function value
	
//	List<Integer> linearities = new ArrayList<Integer>();
	
	private boolean lexmindirty = false;
	
    public Dictionary(HPolygon in, LrsAlgorithm Q)
    {
    	int m_A = in.getNumRows();
    	d = in.getDimension();
    	nonnegative = in.nonnegative;
    	
    	/* nonnegative flag set means that problem is d rows "bigger"     */
    	/* since nonnegative constraints are not kept explicitly          */
    	m = in.nonnegative ? m_A + d : m_A;

    	B = new int[m + 1];
    	rows = new int[m + 1];

    	C = new int[d + 1];
    	cols = new int[d + 1];

    	//d_orig = d;

    	A = new BigInteger[m_A + 1][d + 1];

    	/* Initializations */    	
    	_lexflag = true;
    	_det = ONE;
    	obj = Rational.ZERO;	    	  

    	/*m+d+1 is the number of variables, labelled 0,1,2,...,m+d  */
    	/*  initialize array to zero   */
    	for (int i = 0; i <= m_A; ++i) {
    		for (int j = 0; j <= d; ++j) {
    			A[i][j] = ZERO;
    		}
    	}

    	//Q.facet = new long[d + 1];
    	//this.redundcol = new long[d + 1];

    	
    	_gcd = new BigInteger[m + 1];
    	_lcm = new BigInteger[m + 1];
    	Q.saved_C = new long[d + 1];

    	lastdv = d;      /* last decision variable may be decreased */
    	/* if there are redundant columns          */

    	/*initialize basis and co-basis indices, and row col locations */
    	/*if nonnegative, we label differently to avoid initial pivots */
    	/* set basic indices and rows */
    	if (nonnegative) {
    		for (int i = 0; i <= m; ++i) {
    			B[i] = i;
    			if (i <= d) {
    				rows[i] = 0; /* no row for decision variables */
    			} else { 
    				rows[i] = i - d;
    			}
    		}
    	} else {
    		for (int i = 0; i <= m; ++i) {
    			if (i == 0) {
    				B[0]=0;
    			} else {
    				B[i] = d + i;
    			}
    			rows[i] = i;
    		}
    	}
    	for (int j = 0; j < d; ++j) {
    		if(nonnegative) {
    			C[j] = m + j + 1;
    		} else {
    			C[j] = j + 1;
    		}
    		cols[j] = j + 1;
    	}
    	C[d] = m + d + 1;
    	cols[d] = 0;

    	readDic(0, in.matrix, Q.verbose);
    }
    
    public Dictionary(Dictionary src)
    {
    	copy(src);
    }
    
    
    public BigInteger det() { return _det; }
    public BigInteger gcd(int i) { return _gcd[i]; }
    public BigInteger lcm(int i) { return _lcm[i]; }
    public BigInteger cost(int s) {
    	int col = cols[s];
    	return A[0][col];
    }
    
    public BigInteger get(int r, int s)
    {
    	int row = rows[r];
    	int col = cols[s];
    	return A[row][col];
    }
    
    public BigInteger b(int r)
    {
    	int row = rows[r];
    	return A[row][0];
    }
    
    public boolean lexflag() { 
    	if (lexmindirty) {
    		_lexflag = lexmincol(0);
    		lexmindirty = false;
    	}
    	return _lexflag; 
    }
    
    public void copy(Dictionary src)
    {
    	this.d = src.d;
    	this.m = src.m;    	
    	this.nonnegative = src.nonnegative;
    	this._det = src._det;
        this._lexflag = src._lexflag;
        this.lexmindirty = src.lexmindirty;
        this.obj = src.obj;
        this.lastdv = src.lastdv;
        this._det = src._det;
    	
    	this.B = new int[src.B.length];
    	for (int i = 0; i < this.B.length; ++i) {
    		this.B[i] = src.B[i];
    	}    	
    	
    	this.C = new int[src.C.length];
    	for (int i = 0; i < this.C.length; ++i) {
    		this.C[i] = src.C[i];
    	}
    	
    	this.cols = new int[src.cols.length];
    	for (int i = 0; i < this.cols.length; ++i) {
    		this.cols[i] = src.cols[i];
    	}
    	
    	this.rows = new int[src.rows.length];
    	for (int i = 0; i < this.rows.length; ++i) {
    		this.rows[i] = src.rows[i];
    	}
    	
    	this._gcd = new BigInteger[src._gcd.length];
    	for (int i = 0; i < this._gcd.length; ++i) {
    		this._gcd[i] = src._gcd[i];
    	}
    	
    	this._lcm = new BigInteger[src._lcm.length];
    	for (int i = 0; i < this._lcm.length; ++i) {
    		this._lcm[i] = src._lcm[i];
    	}
    	
    	this.A = new BigInteger[src.A.length][];
    	for (int i = 0; i < this.A.length; ++i) {
    		this.A[i] = new BigInteger[src.A[i].length];
    		for (int j = 0; j < this.A[i].length; ++j) {
    			this.A[i][j] = src.A[i][j];
    		}
    	}
    }
    
    private void readDic(int hull, Rational[][] matrix, boolean verbose)
    {
    	//init matrix
    	A[0][0] = ONE;
    	_lcm[0] = ONE;
    	_gcd[0] = ONE;

    	//should this be m or m_A
    	for (int i = 1; i <= matrix.length; ++i)	/* read in input matrix row by row                 */
    	{
    		_lcm[i] = ONE;	/* Lcm of denominators */
    		_gcd[i] = ZERO;	/* Gcd of numerators */
    		for (int j = hull; j < matrix[i-1].length; ++j)	/* hull data copied to cols 1..d */
    		{
    			Rational rat = matrix[i-1][j];
    			A[i][j] = rat.num;
    			A[0][j] = rat.den;
    			if (!one(A[0][j])) {
    				_lcm[i] = BigIntegerUtils.lcm(_lcm[i], A[0][j]);	/* update lcm of denominators */
    			}
    			_gcd[i] = _gcd[i].gcd(A[i][j]);	/* update gcd of numerators   */
    		}

    	    if (hull != 0)
    	  	{
    	    	A[i][0] = ZERO;	/*for hull, we have to append an extra column of zeroes */
    	  	  	if (!one(A[i][1]) || !one(A[0][1]))	{/* all rows must have a one in column one */
    	  	  		// TODO: Q->polytope = false;
    	  	  	}
    	  	}
    	      
    		if (!zero(A[i][hull]))	/* for H-rep, are zero in column 0     */ {
    			homogeneous = false;	/* for V-rep, all zero in column 1     */
    		}

    		if (greater(_gcd[i], ONE) || greater(_lcm[i], ONE)) {
    			for (int j = 0; j <= d; j++)
    			{
    				BigInteger tmp = A[i][j].divide(_gcd[i]);	/*reduce numerators by Gcd  */
    				tmp = tmp.multiply(_lcm[i]);				/*remove denominators */
    				A[i][j] = tmp.divide(A[0][j]);				/*reduce by former denominator */
    			}
    		}
    	}

    	/* 2010.4.26 patch */
    	/* set up Gcd and Lcm for nonexistent nongative inequalities */
    	if(nonnegative) {
    		for (int i = matrix.length + 1; i < _lcm.length; ++i) { 
    			_lcm[i] = ONE;
    		//}
    		//for (int i = matrix.length + 1; i < Gcd.length; ++i) { 
    			_gcd[i] = ONE;
    		}    		
    	}
    	
    	if (homogeneous && verbose)
    	{
    		System.out.println();
    		System.out.print("*Input is homogeneous, column 1 not treated as redundant");
    	}
    }
    
    /*private void setRow(int hull, int row, Rational[] values, boolean isLinearity)
    {
    	  BigInteger[] oD = new BigInteger[d];
    	  oD[0] = ONE;

    	  int i = row;
    	  _lcm[i] = ONE;     // Lcm of denominators
    	  _gcd[i] = ZERO;     // Gcd of numerators
    	  for (int j = hull; j <= d; ++j)       // hull data copied to cols 1..d
    	  {
    		  A[i][j] = values[j-hull].num;
    	      oD[j] = values[j-hull].den;
	          if (!one(oD[j])) {
    	            _lcm[i] = BigIntegerUtils.lcm(_lcm[i], oD[j]);      // update lcm of denominators
	          }
	          _gcd[i] = _gcd[i].gcd(A[i][j]);   // update gcd of numerators
    	  }

    	  if (hull != 0)
    	  {
    		  A[i][0] = ZERO;        // for hull, we have to append an extra column of zeroes
	          if (!one(A[i][1]) || !one(oD[1])) {       // all rows must have a one in column one
    	            //Q->polytope = FALSE;
	          }
    	  }
    	  if (!zero(A[i][hull])) {  // for H-rep, are zero in column 0
    	       //homogeneous = false; // for V-rep, all zero in column 1
    	  }

    	  if (greater(_gcd[i], ONE) || greater(_lcm[i], ONE)) {
    	        for (int j = 0; j <= d; j++)
    	          {
    	        	A[i][j] = A[i][j].divide(_gcd[i]).multiply(_lcm[i]).divide(oD[j]);
    	            //exactdivint (A[i][j], Gcd[i], Temp);        //reduce numerators by Gcd
    	            //mulint (Lcm[i], Temp, Temp);        		//remove denominators
    	            //exactdivint (Temp, oD[j], A[i][j]);       	//reduce by former denominator
    	          }
    	  }
    	 if (isLinearity)        // input is linearity
	     {
    	      linearities.add(row);    	      
	     }

    	  // 2010.4.26   Set Gcd and Lcm for the non-existant rows when nonnegative set
    	  if (nonnegative && row == m) {
    		  for (int j = 1; j <= d; ++j) { 
    			  _lcm[m + j] = ONE;
    			  _gcd[m + j] = ONE;
    		  }
    	  }
    }*/
    
    /*private void setObj(int hull, Rational[] values, boolean max)
    {
	  if (max) {
	       //Q->maximize=TRUE;
	  } else {
	       //Q->minimize=TRUE;
	       for(int i=0; i<= d; ++i) {
	          values[i]= values[i].negate();
	       }
       }

	  setRow(hull, 0, values, false);
    }*/
    
    public int[] cobasis() {
    	int[] cobasis = new int[d];
    	for (int i = 0; i < cobasis.length; ++i) {
    		cobasis[cols[i] - 1] = i;
    	}
    	return cobasis;
    }
    
    public boolean isNonNegative() { return nonnegative; }
    
    
    /* Qpivot routine for array A              */
    /* indices bas, cob are for Basis B and CoBasis C    */
    /* corresponding to row Row[bas] and column       */
    /* Col[cob]   respectively                       */
    public void pivot(int r, int s, boolean debug)			     
	{
    	lexmindirty = true;
    	
    	int row = rows[r];
    	int col = cols[s];

    	/* Ars=A[r][s]    */
    	BigInteger Ars = A[row][col];
    	if ((positive(Ars) && negative(_det)) || (negative(Ars) && positive(_det))) {
    		_det = _det.negate();	/*adjust determinant to new sign */
    	}


    	for (int i = 0; i < A.length; i++) {
    		if (i != row) {
    			for (int j = 0; j <= d; j++) {
    				if (j != col) 
    				{
    					/* A[i][j]=(A[i][j]*Ars-A[i][s]*A[r][j])/P->det; */
    					BigInteger Nt = A[i][j].multiply(Ars);
    					BigInteger Ns = A[i][col].multiply(A[row][j]);
    					A[i][j] = (Nt.subtract(Ns)).divide(_det);
    				}
    			}
    		}
    	}
    	if (positive(Ars) || zero(Ars)) {
    		for (int j = 0; j <= d; j++)	/* no need to change sign if Ars neg */
    			/*   A[r][j]=-A[r][j];              */
    			if (!zero (A[row][j]))
    				A[row][j] = A[row][j].negate();
    	}				/* watch out for above "if" when removing this "}" ! */
    	else {
    		for (int i = 0; i < A.length; i++) {
    			if (!zero (A[i][col])) {
    				A[i][col] = A[i][col].negate();	
    			}
    		}
    	}

    	/*  A[r][s]=P->det;                  */
    	A[row][col] = _det;		/* restore old determinant */
    	_det = negative(Ars) ? Ars.negate() : Ars; /* always keep positive determinant */	

    	/* set the new rescaled objective function value */
    	obj = new Rational(
    			_gcd[0].multiply(A[0][0]).negate(), 	//num
    			_det.multiply(_lcm[0]));				//den
	}
    
    public boolean lexmin(int s)
    {
    	return lexmincol(cols[s]);
    }
    
    /*test if basis is lex-min for vertex or ray, if so true */
	/* false if a_r,g=0, a_rs !=0, r > s          */
	private boolean lexmincol(int compareCol)	
	{		
		/*do lexmin test for vertex if col=0, otherwise for ray */
		for (int i = lastdv + 1; i <= m; i++)
		{
			int row = rows[i];
			if (zero(A[row][compareCol])) {	/* necessary for lexmin to fail */
				for (int j = 0; j < d; j++)
				{
					int col = cols[j];
					if (B[i] > C[j])	/* possible pivot to reduce basis */
					{
						if (zero(A[row][0]))	/* no need for ratio test, any pivot feasible */
						{
							if (!zero(A[row][col])) {
								return false;
							}
						}
						else if (negative(A[row][col]) && ismin(row, col))
						{
							return false;
						}
					}
				}
			}
		}
		return true;
	}				/* end of lexmin */
	
	/*test if A[r][s] is a min ratio for col s */
	private boolean ismin (int row, int col)	
	{
		for (int i = 1; i < A.length; i++)
			if ((i != row) && negative (A[i][col]) && BigIntegerUtils.comprod(A[i][0], A[row][col], A[i][col], A[row][0]) != 0) {
				return false;
			}

		return true;
	}
	
	/* find min index ratio -aig/ais, ais<0 */
	/* if multiple, checks successive basis columns */
	/* recoded Dec 1997                     */
	public int ratio (int s, boolean debug)	/*find lex min. ratio */	
	{
		int col = cols[s];
		
		int[] minratio = new int[m + 1];
		int nstart = 0;
		int ndegencount = 0;
		int degencount = 0;
		
		/* search rows with negative coefficient in dictionary */
		/*  minratio contains indices of min ratio cols        */
		for (int j = lastdv + 1; j <= m; j++) {			
			if (negative (A[rows[j]][col])) {
				minratio[degencount++] = j;
			}
		}
		
		if (debug) {
			System.out.print("  Min ratios: ");
			for (int i = 0; i < degencount; i++)
				System.out.print(String.format(" %d ", B[minratio[i]]));
		}
		
		if (degencount == 0) {
			return degencount;	/* non-negative pivot column */
		}
		
		int ratiocol = 0;			/* column being checked, initially rhs */
		int start = 0;			/* starting location in minratio array */
		int bindex = d + 1;		/* index of next basic variable to consider */
		int cindex = 0;			/* index of next cobasic variable to consider */
		int basicindex = d;		/* index of basis inverse for current ratio test, except d=rhs test */
		
		while (degencount > 1)	/*keep going until unique min ratio found */
		{
			if (B[bindex] == basicindex)	/* identity col in basis inverse */
			{
				if (minratio[start] == bindex) {
					/* remove this index, all others stay */
					start++;
					degencount--;
				}
				bindex++;
			} else {
				/* perform ratio test on rhs or column of basis inverse */			
				boolean firstime = true; /*For ratio test, true on first pass,else false */
				/*get next ratio column and increment cindex */
				if (basicindex != d) {
					ratiocol = cols[cindex++];
				}
				
				BigInteger Nmin = null, Dmin = null; //they get initialized before they are used
				for (int j = start; j < start + degencount; j++)
				{
					int i = rows[minratio[j]];	/* i is the row location of the next basic variable */
					int comp = 1;		/* 1:  lhs>rhs;  0:lhs=rhs; -1: lhs<rhs */
					
					if (firstime) {
						firstime = false;	/*force new min ratio on first time */
					} else {
						if (positive (Nmin) || negative (A[i][ratiocol])) {
							if (negative (Nmin) || positive (A[i][ratiocol])) {
								comp = BigIntegerUtils.comprod(Nmin, A[i][col], A[i][ratiocol], Dmin);
							} else {
								comp = -1;
							}
						} else if (zero(Nmin) && zero(A[i][ratiocol])) {
							comp = 0;
						}

						if (ratiocol == 0) {
							comp = -comp;	/* all signs reversed for rhs */
						}
					}
					
					if (comp == 1) {
						/*new minimum ratio */
						nstart = j;
						Nmin = A[i][ratiocol];
						Dmin = A[i][col];
						ndegencount = 1;
					} else if (comp == 0) {
						/* repeated minimum */					
						minratio[nstart + ndegencount++] = minratio[j];
					}
				}
				degencount = ndegencount;
				start = nstart;
			}
			basicindex++;		/* increment column of basis inverse to check next */
			
			if (debug) {
				System.out.print(String.format(" ratiocol=%d degencount=%d ", ratiocol, degencount));
				System.out.print("  Min ratios: ");
				for (int i = start; i < start + degencount; i++)
					System.out.print(String.format(" %d ", B[minratio[i]]));
			}
		}

		return (minratio[start]);
	}
	
	
	/* print the integer m by n array A 
	   with B,C,Row,Col vectors         */	
	@Override
	public String toString()	
	{	  
		String newline = System.getProperty("line.separator");
		StringWriter output = new StringWriter();
		output.write(newline);
		
		output.write(" Basis    ");
		for (int i = 0; i <= m; i++) {
			output.write(String.format("%d ", B[i]));
		}
		output.write(newline);
		
		output.write(" Row ");
		for (int i = 0; i <= m; i++) {
			output.write(String.format("%d ", rows[i]));
		}		
		output.write(newline);
		
		output.write(" Co-Basis ");
		for (int i = 0; i <= d; i++) {
			output.write(String.format("%d ", C[i]));
		}
		output.write(newline);
		
		output.write(" Column ");
		for (int i = 0; i <= d; i++) {
			output.write(String.format("%d ", cols[i]));
		}
		output.write(newline);
		
		output.write(String.format(" det=%s", _det.toString()));
		output.write(newline);
		
		ColumnTextWriter colpp = new ColumnTextWriter();
		colpp.writeCol("A");
		for (int j = 0; j <= d; j++) {
			colpp.writeCol(C[j]);
		}
		colpp.endRow();
		for (int i = 0; i <= m; ++i) {
			colpp.writeCol(B[i]);
			for (int j = 0; j <= d; j++) {
				colpp.writeCol(A[rows[i]][cols[j]].toString());
			}			
			if (i==0 && nonnegative) { //skip basic rows - don't exist!
				i=d;
			}
			colpp.endRow();
		}
		output.write(colpp.toString());
		return output.toString();
	}
	
	/*print the long precision integer in row r col s of matrix A */
	/*private void pimat (int r, int s, BigInteger Nt, String name, StringWriter output)	 
	{
		if (s == 0) {
			output.write(String.format("%s[%d][%d]=", name, B[r], C[s]));
		} else {
			output.write(String.format("[%d]=", C[s]));
		}
		output.write(String.format("%s", Nt.toString()));
	}*/
}
