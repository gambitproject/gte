package lse.math.games.lrs;

import java.math.BigInteger;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

import lse.math.games.Rational;
import static lse.math.games.BigIntegerUtils.*;

public class LrsAlgorithm implements Lrs 
{	
	private static final Logger log = Logger.getLogger(LrsAlgorithm.class.getName());
	private static final int MAXD = 27; //TODO
	
	Dictionary P;
	                         
	Rational volume;
	Rational bound;
    //long unbounded;		/* lp unbounded */    
    
    /* initially holds order used to find starting  */
    /* basis, default: m,m-1,...,2,1                */
    //long[] facet;		/* cobasic indices for restart in needed        */           
    //long[] temparray;		/* for sorting indices, dimensioned to d        */
    //long[] isave, jsave;	/* arrays for estimator, malloc'ed at start     */
    
    
    BigInteger sumdet;		/* sum of determinants */
    long[] count;			/* count[0]=rays [1]=verts. [2]=base [3]=pivots [4]=integer vertices*/
    long totalnodes;		/* count total number of tree nodes evaluated   */    

    /* given by inputd-nredundcol                   */
    
    //long runs;			/* probes for estimate function                 */
    //long seed = 1234L;			/* seed for random number generator             */
    //double[] cest = new double[10];		/* ests: 0=rays,1=vert,2=bases,3=vol,4=int vert */
    
/**** flags  **********                         */
    //boolean allbases;		/* true if all bases should be printed          */
    //boolean bound;                 /* true if upper/lower bound on objective given */    
    //boolean dualdeg;		/* true if start dictionary is dual degenerate  */
    //long etrace;		/* turn off debug at basis # strace             */    
    //boolean geometric;		/* true if incident vertex prints after each ray */
    boolean getvolume = false;		/* do volume calculation                        */
    boolean givenstart = false;		/* true if a starting cobasis is given          */
        
    //boolean lponly;		/* true if only lp solution wanted              */    
    //boolean maximize;		/* flag for LP maximization                     */
    //boolean minimize;		/* flag for LP minimization                     */
    
    long maxdepth = MAXD;		/* max depth to search to in tree              */
    long mindepth = -MAXD;		/* do not backtrack above mindepth              */
    long depth = 0L;
    long deepest = 0L;		/* max depth ever reached in search             */
    
    //boolean nash;                  /* true for computing nash equilibria           */    
    
    boolean printcobasis = false;		/* true if all cobasis should be printed        */
    int frequency = 0;		/* frequency to print cobasis indices           */
    
    boolean incidence = true;             /* print all tight inequalities (vertices/rays) */
    boolean printslack = false;		/* true if indices of slack inequal. printed    */
    
    //boolean truncate;              /* true: truncate tree when moving from opt vert*/
    
    //boolean restart;		/* true if restarting from some cobasis         */
    //long strace;		/* turn on  debug at basis # strace             */
    
    // TODO: change to log levels
    boolean debug = false;
    boolean verbose = false;
        
    int[] inequality = null;		// indices of inequalities corr. to cobasic ind

    private List<Integer> redundancies = null;
    
    /* Variables for saving/restoring cobasis,  db */
    long[] saved_count = new long[3];	/* How often to print out current cobasis */
    long[] saved_C;
    BigInteger saved_det;
    long saved_depth;
    long saved_d;

    long saved_flag;		/* There is something in the saved cobasis */

    /* Variables for cacheing dictionaries, db */
    private CacheEntry cacheTail;
    private int cacheTries = 0;
    private int cacheMisses = 0;    
	

	//TODO: fix defaults
	public LrsAlgorithm()
	{
		  //for (i = 0; i < 10; i++)
		  //  {
		  //    Q.count[i] = 0L;
		  //    Q.cest[i] = 0.0;
		  //  }
		/* initialize flags */
		  //Q.allbases = false;
		  //Q.bound = false;            /* upper/lower bound on objective function given */
		  //Q.debug = false;
		  
		  printcobasis = true;

		  // TODO: set up log levels...
		  debug = false;
		  verbose = true;
		  if (debug == true) {
			  verbose = true;
		  }		  
	}
	
	public HPolygon run(VPolygon in) {
		// hull == true
		throw new RuntimeException("Not Impl");		
	}
	
	public VPolygon run(HPolygon in)
	{
		// TODO: put all this reset member vars in an initRun() method
		sumdet = BigInteger.ZERO;
		totalnodes = 0;
		count = new long[10];
		count[2] = 1L;
		
		P = new Dictionary(in, this);
    	inequality = new int[P.B.length];
    	inequality[0] = 2;
    	redundancies = new ArrayList<Integer>();
    	
        cacheTail = null;
        cacheTries = 0;
        cacheMisses = 0; 
    	
        if (debug) {
        	log.fine(P.toString());
			log.fine("exiting lrs_read_dic");    	
        }
		
		/*********************************************************************************/
		/* Step 2: Find a starting cobasis from default of specified order               */
		/*         P is created to hold  active dictionary data and may be cached        */
		/*         Lin is created if necessary to hold linearity space                   */
		/*         Print linearity space if any, and retrieve output from first dict.    */
		/*********************************************************************************/
		if (!getfirstbasis(P, in.linearities, 0)) {
			return null;
		}
		
		/* Pivot to a starting dictionary                      */
		/* There may have been column redundancy               */
		/* If so the linearity space is obtained and redundant */
		/* columns are removed. User can access linearity space */
		/* from lrs_mp_matrix Lin dimensions nredundcol x d+1  */
	  
		//int startcol = 0;
		//if (Q->homogeneous && Q->hull)
		 //   startcol++;			/* col zero not treated as redundant   */

		  //for (int col = startcol; col < Q->nredundcol; col++) {	/* print linearity space               */
		 //   lrs_printoutput (Q, Lin[col]);	/* Array Lin[][] holds the coeffs.     */
		  //}
		
		/*********************************************************************************/
		/* Step 3: Terminate if lponly option set, otherwise initiate a reverse          */
		/*         search from the starting dictionary. Get output for each new dict.    */
		/*********************************************************************************/

		/* We initiate reverse search from this dictionary       */
		/* getting new dictionaries until the search is complete */
		/* User can access each output line from output which is */
		/* vertex/ray/facet from the lrs_mp_vector output         */
		/* prune is TRUE if tree should be pruned at current node */
		
		BigInteger[] output = new BigInteger[in.getNumCols()];	/* output holds one line of output from dictionary     */
		VPolygon solution = new VPolygon();
		do
		{			
			//if (!lrs.checkbound(P)) {
			if (getvertex(P, output, solution)) { // check for lexmin vertex
				printoutput(output, solution);
			}
			// since I am not iterating by column, I think it messes up the order
			// get cobasis from Dictionary sorted by lowest col for parity
			int[] cobasis = P.cobasis();
			for (int i = 0; i < cobasis.length; ++i) {				
				if (getsolution (P, output, solution, cobasis[i])) {
					printoutput(output, solution);
				}
			}
			//}
		}
		while (getnextbasis (P/*, prune*/));		
		
		printsummary(in);
		
		return solution;
	}
	
	private void printsummary(HPolygon in)
	{		
		log.info("end");
		/*if (dualdeg)
		{
			System.out.println("*Warning: Starting dictionary is dual degenerate");
			System.out.println("*Complete enumeration may not have been produced");
			if (maximize) {
				System.out.println("*Recommendation: Add dualperturb option before maximize in input file");
			} else {
				System.out.println("*Recommendation: Add dualperturb option before minimize in input file");
			}
		}*/

		/*if (unbounded)
		{
			System.out.println("*Warning: Starting dictionary contains rays");
			System.out.println("*Complete enumeration may not have been produced");
			if (maximize) {
				System.out.println("*Recommendation: Change or remove maximize option or add bounds");
			} else {
				System.out.println("*Recommendation: Change or remove minimize option or add bounds");
			}
		}*/
		
		/*if (truncate) {
			System.out.println("*Tree truncated at each new vertex");
		}*/
		if (maxdepth < MAXD) {
			log.info(String.format("*Tree truncated at depth %d", maxdepth));
		}
		/*if (maxoutput > 0) {
			System.out.println(String.format("*Maximum number of output lines = %ld", maxoutput));
		}*/


		log.info("*Sum of det(B)=" + sumdet.toString());		

		/* next block with volume rescaling must come before estimates are printed */

		/*if (getvolume)
		{
			volume = rescalevolume (P, Q);

			if (polytope) {
				System.out.println("*Volume=" + volume.toString());
			} else {
				System.out.println("*Pseudovolume=" + volume.toString());
			}
		}*/

		/*if (hull)
		{
			fprintf (lrs_ofp, "\n*Totals: facets=%ld bases=%ld", count[0], count[2]);

			if (nredundcol > homogeneous)	// don't count column 1 as redundant if homogeneous
			{
				fprintf (lrs_ofp, " linearities=%ld", nredundcol - homogeneous);
				fprintf (lrs_ofp, " facets+linearities=%ld",nredundcol-homogeneous+count[0]);
			}


			if ((cest[2] > 0) || (cest[0] > 0))
			{
				fprintf (lrs_ofp, "\n*Estimates: facets=%.0f bases=%.0f", count[0] + cest[0], count[2] + cest[2]);
				if (getvolume)
				{
					rattodouble (Q->Nvolume, Q->Dvolume, &x);
					for (i = 2; i < d; i++)
						cest[3] = cest[3] / i;	//adjust for dimension
					fprintf (lrs_ofp, " volume=%g", cest[3] + x);
				}

				fprintf (lrs_ofp, "\n*Total number of tree nodes evaluated: %ld", Q->totalnodes);
				fprintf (lrs_ofp, "\n*Estimated total running time=%.1f secs ",(count[2]+cest[2])/Q->totalnodes*get_time () );

			}

		} else */        /* output things specific to vertex/ray computation */
		{
			StringBuilder sb = new StringBuilder();			
			sb.append(String.format("*Totals: vertices=%d rays=%d bases=%d integer_vertices=%d ", count[1], count[0], count[2], count[4]));

			if (redundancies.size() > 0) {
				sb.append(String.format(" linearities=%d", redundancies.size()));
			}
			if (count[0] + redundancies.size() > 0 )
			{
				sb.append(" vertices+rays");
				if (redundancies.size() > 0) {
					sb.append("+linearities");
				}
				sb.append(String.format("=%d",redundancies.size() + count[0] + count[1]));
			}
			log.info(sb.toString());
			
			/*if ((cest[2] > 0) || (cest[0] > 0))
			{
				fprintf (lrs_ofp, "\n*Estimates: vertices=%.0f rays=%.0f", count[1]+cest[1], count[0]+cest[0]);
				fprintf (lrs_ofp, " bases=%.0f integer_vertices=%.0f ",count[2]+cest[2], count[4]+cest[4]);

				if (getvolume)
				{
					rattodouble (Nvolume, Dvolume, &x);
					for (i = 2; i <= d - homogeneous; i++) {
						cest[3] = cest[3] / i;	// adjust for dimension
					}
					fprintf (lrs_ofp, " pseudovolume=%g", cest[3] + x);
				}
				System.out.println();
				System.out.println(String.format("*Total number of tree nodes evaluated: %d", totalnodes));		
				System.out.print(String.format("*Estimated total running time=%.1f secs ",(count[2]+cest[2])/totalnodes*get_time()));
			}*/

			/*if (restart || allbases) {       // print warning
				System.out.println("*Note! Duplicate vertices/rays may be present");
			} else if ((count[0] > 1 && !homogeneous)) {
				System.out.println("*Note! Duplicate rays may be present");
			}*/
		}


		  if(!verbose) {
		     return;
		  }

		  
		  log.info(String.format("*Input size m=%d rows n=%d columns working dimension=%d", P.m, in.getNumCols(), P.d));
		  /*if (hull) {
			  System.out.println(String.format(" working dimension=%d", d - 1 + homogeneous));
		  } else {
			  System.out.println(String.format(" working dimension=%d", P.d));
		  }		*/  
		  
		  StringBuilder scob = new StringBuilder();
		  scob.append("*Starting cobasis defined by input rows");
		  Integer[] temparray = new Integer[P.lastdv];
		  for (int i = 0; i < in.linearities.length; i++) {
		    temparray[i] = in.linearities[i];
		  }
		  for (int i = in.linearities.length; i < P.lastdv; i++) {
		    temparray[i] = inequality[P.C[i - in.linearities.length] - P.lastdv];
		  }
		  for (int i = 0; i < P.lastdv; i++) {
			  reorder(temparray);
		  }
		  for (int i = 0; i < P.lastdv; i++) {
			  scob.append(String.format(" %d", temparray[i]));
		  }
		  log.info(scob.toString());
		  log.info(String.format("*Dictionary Cache: max size= %d misses= %d/%d   Tree Depth= %d", 0/*dict_count*/, cacheMisses, cacheTries, deepest));
	}
	
	private void printoutput (BigInteger[] output, VPolygon solution)
	{
		StringBuilder sb = new StringBuilder();
		Rational[] vertex = new Rational[output.length];
		if (zero(output[0]))	/*non vertex */
		{
			for (int i = 0; i < output.length; i++) {
				String ratStr = output[i].toString();
				vertex[i] = Rational.valueOf(ratStr);
				sb.append(" " + ratStr + " ");
			}
		}
		else
		{				/* vertex   */
			sb.append(" 1 ");
			vertex[0] = Rational.ONE;
			for (int i = 1; i < output.length; i++) {
				vertex[i] = new Rational(output[i], output[0]);
				sb.append(" " + vertex[i].toString() + " ");
			}		
		}
		log.info(sb.toString());
		solution.vertices.add(vertex);
	}
	
	/*
	public void lrs(Tableau first)
	{
		List<Object> vertices = new ArrayList<Object>();
		Tableau A = first; 
		int d = A.vars().
		
		int j = 1;
		while (true)
		{
			while (j <= d)
			{ 
				int v = N(j); // jth index of the cobasic variables?
				int u = reverse(B, v); //
				if (u >= 0)
				{ 
					pivot(B, u, v); // new basis found //
					if (lexmin(B, 0)) {
						output current vertex;
					}
					j = 1;
				}
				else j = j + 1;
			}
			selectpivot(B, r, j); //backtrack //
			pivot(B, r, N(j));
			j = j + 1;
			if (j > d && B == Bstar) break;
		}
	}
	*/
	
	//rv[0] = r (leaving row)
	//rv[1] = s (entering column)
	/* select pivot indices using lexicographic rule   */
	/* returns TRUE if pivot found else FALSE          */
	/* pivot variables are B[*r] C[*s] in locations Row[*r] Col[*s] */	
	public int[] selectpivot (Dictionary P)	
	{
		int[] out = new int[2];
		int r = out[0] = 0;
		int s = out[1] = P.d;

		/*find positive cost coef */
		int j = 0;
		while ((j < P.d) && (!positive (P.cost(j)))) {
			++j;
		}
		
		if (j < P.d) {
			
			/* pivot column found! */
			s = j;

			/*find min index ratio */
			r = P.ratio(s, debug);
			if (r != 0) {
				out[0] = r;
				out[1] = s;
				//return true;		/* unbounded */
			}
		}
		return out;
		//return false;
	}
	
	/**
	 * find reverse indices 
	 * true if B[r] C[s] is a reverse lexicographic pivot 
	 * is true and returns u = B(i) if and only if 
	 * (i) w(0)v < 0, 
	 * (ii) u = B(i) = lexminratio(B, v) != 0, and
	 * (iii) setting w = w(0) - a(0)w(i) /a(i), we have w(j) >= 0, for all j in N, j < u
	 * Returns false (-1) otherwise... TODO: can I return 0?
	 */
	public int reverse (Dictionary P, int s)
	{
		int r = -1; // return value (-1 if false)

		int enter = P.C[s];
		int col = P.cols[s];

		log.fine(String.format("+reverse: col index %d C %d Col %d ", s, enter, col));
		
		if (!negative (P.cost(s)))
		{
			log.fine(" Pos/Zero Cost Coeff");
			return -1;
		}

		r = P.ratio(s, debug);
		if (r == 0)			/* we have a ray */
		{
			log.fine(" Pivot col non-negative:  ray found");
			return -1;
		}

		//int row = P.rows[r];

		/* check cost row after "pivot" for smaller leaving index    */
		/* ie. j s.t.  A[0][j]*A[row][col] < A[0][col]*A[row][j]     */
		/* note both A[row][col] and A[0][col] are negative          */

		for (int i = 0; i < P.d && P.C[i] < P.B[r]; i++) {
			if (i != s)
			{
				int j = P.cols[i];
				if (positive(P.cost(i)) || negative(P.get(r, i)))		/*or else sign test fails trivially */
				{
					if ((!negative(P.cost(i)) && !positive(P.get(r, i))) ||				
							comprod(P.cost(i), P.get(r, s), P.cost(s), P.get(r, i)) == -1)
					{			/*+ve cost found */
						log.fine(String.format("Positive cost found: index %d C %d Col %d", i, P.C[i], j));
						return -1;
					}
				}
			}
		}
		log.fine(String.format("+end of reverse : indices r %d s %d ", r, s));
		return r;
	}
	
	/* gets first basis, false if none              */
	/* P may get changed if lin. space Lin found    */
	/* no_output is true supresses output headers   */
	private boolean getfirstbasis (Dictionary D, int[] linearity, int hull)	
	{
		if (linearity.length > 0 && D.isNonNegative()) {
			log.warning("*linearity and nonnegative options incompatible - all linearities are skipped");
			log.warning("*add nonnegative constraints explicitly and remove nonnegative option");			
		}
		
		
		/* default is to look for starting cobasis using linearies first, then     */
		/* filling in from last rows of input as necessary                         */
		/* linearity array is assumed sorted here                                  */
		/* note if restart/given start inequality indices already in place         */
		/* from nlinearity..d-1   													*/
		for (int i = 0; i < linearity.length; ++i) {	/* put linearities first in the order */
			inequality[i] = linearity[i];
		}

		int k = givenstart ? P.d : linearity.length;			/* index for linearity array   */

		for (int i = D.m; i >= 1; i--)
		{
			int j = 0;
			while (j < k && inequality[j] != i) {
				++j;			/* see if i is in inequality  */
			}
			if (j == k) {
				inequality[k++] = i;
			}
		}
		
		if (log.isLoggable(Level.FINE)) {
			StringBuilder sb = new StringBuilder();
			sb.append("*Starting cobasis uses input row order");
			for (int i = 0; i < D.m; i++) {
				sb.append(String.format(" %d", inequality[i]));
			}
			log.fine(sb.toString());
		}

		/* for voronoi convert to h-description using the transform                  */
		/* a_0 .. a_d-1 . (a_0^2 + ... a_d-1 ^2)-2a_0x_0-...-2a_d-1x_d-1 + x_d >= 0 */
		/* note constant term is stored in column d, and column d-1 is all ones      */
		/* the other coefficients are multiplied by -2 and shifted one to the right  */
		if (log.isLoggable(Level.FINE)) {
			log.fine(D.toString());		
		}

		for (int j = 0; j <= D.d; j++) {
			D.A[0][j] = BigInteger.ZERO; // TODO: why is this being assigned here?
		}

		/* Now we pivot to standard form, and then find a primal feasible basis       */
		/* Note these steps MUST be done, even if restarting, in order to get         */
		/* the same index/inequality correspondance we had for the original prob.     */
		/* The inequality array is used to give the insertion order                   */
		/* and is defaulted to the last d rows when givenstart=false                  */

		if(P.isNonNegative()) {
			/* no need for initial pivots here, labelling already done */
			P.lastdv = D.d;
		} else if (!getabasis(D, inequality, linearity, hull)) {
			return false;		     
		}

		/********************************************************************/
		/* now we start printing the output file  unless no output requested */
		/********************************************************************/		
		log.info("V-representation");		
		log.info("begin");		
		log.info(String.format("***** %d rational", D.d + 1));


		/* Reset up the inequality array to remember which index is which input inequality */
		/* inequality[B[i]-lastdv] is row number of the inequality with index B[i]              */
		/* inequality[C[i]-lastdv] is row number of the inequality with index C[i]              */

		for (int i = 1; i <= D.m; i++) {
			inequality[i] = i;
		}
		
		if (linearity.length > 0) {								/* some cobasic indices will be removed */	    
			for (int i = 0; i < linearity.length; ++i) {		/* remove input linearity indices */
				inequality[linearity[i]] = 0;
			}
			k = 1;												/* counter for linearities         */
			for (int i = 1; i <= P.m - linearity.length; ++i) {
				while (k <= P.m && inequality[k] == 0) {
					k++;										/* skip zeroes in corr. to linearity */
				}
				inequality[i] = inequality[k++];
			}
	    }

		if (log.isLoggable(Level.FINE)) {
			StringBuilder sb = new StringBuilder();
			sb.append("inequality array initialization:");
			for (int i = 1; i <= D.m - linearity.length; i++) {
				sb.append(String.format(" %d", inequality[i]));
			}
			log.fine(sb.toString());
		}


		/* Do dual pivots to get primal feasibility */
		if (!primalfeasible(D)) {			
			log.warning("No feasible solution");
			return false;
		}


		/* re-initialize cost row to -det */
		for (int j = 1; j <= D.d; j++) {
			D.A[0][j] = D.det().negate();
		}
		D.A[0][0] = BigInteger.ZERO;	/* zero optimum objective value */


		/* reindex basis to 0..m if necessary */
		/* we use the fact that cobases are sorted by index value */
		if (debug) {
			log.fine(D.toString());
		}

		while (D.C[0] <= D.m)
		{
			int i = D.C[0];
			int j = inequality[D.B[i] - D.lastdv];
			inequality[D.B[i] - D.lastdv] = inequality[D.C[0] - D.lastdv];
			inequality[D.C[0] - D.lastdv] = j;
			D.C[0] = D.B[i];
			D.B[i] = i;
			reorder(D.C, D.cols, 0, D.d);
		}

		if (log.isLoggable(Level.FINE)) {
			StringBuilder sb = new StringBuilder();
			sb.append(String.format("*Inequality numbers for indices %d .. %d : ", D.lastdv + 1, D.m + D.d));
			for (int i = 1; i <= D.m; i++) {
				sb.append(String.format(" %d ", inequality[i]));
			}
			log.fine(sb.toString());
		}
		
		if (debug) {
			log.fine(D.toString());
		}

		return true;
	}

	/*****************************************/
	/* getnextbasis in reverse search order  */
	/*****************************************/

	/* gets next reverse search tree basis, FALSE if none  */
	/* switches to estimator if maxdepth set               */
	/* backtrack TRUE means backtrack from here            */
	private boolean getnextbasis (Dictionary D/*, boolean backtrack*/)
	{
		int i = 0, j = 0;

		boolean backtrack = false; //TODO
		if (backtrack && depth == 0) {
			return false;                       /* cannot backtrack from root      */
		}

		//if (maxoutput > 0 && count[0]+Qcount[1] >= maxoutput)
		//   return FALSE;                      /* output limit reached            */

		while ((j < D.d) || (D.B[D.m] != D.m))	/*main while loop for getnextbasis */
		{
			if (depth >= maxdepth)
			{
				backtrack = true;
				if (maxdepth == 0)	/* estimate only */
					return false;	/* no nextbasis  */
			}

			//if ( Q->truncate && negative(D->A[0][0]))   /* truncate when moving from opt. vertex */
			//     backtrack = TRUE;

			if (backtrack)		/* go back to prev. dictionary, restore i,j */
			{
				backtrack = false;
				
				if (cacheTail != null)
				{
					CacheEntry entry = popCache();
					D.copy(entry.getDict());
					i = entry.getBas();
					j = entry.getCob();
					depth = entry.getDepth();
					log.fine(String.format(" Cached Dict. restored to depth %d", depth));					
				} else {
					--depth;
					int[] vars = selectpivot(D);
					vars = doPivot(D, vars[0], vars[1]);					
					i = vars[0];
					j = vars[1];
				}

				if (debug)
				{					
					log.fine(String.format(" Backtrack Pivot: indices i=%d j=%d depth=%d", i, j, depth));
					log.fine(D.toString());
				};

				j++;			/* go to next column */
			}			/* end of if backtrack  */

			if (depth < mindepth) {
				break;
			}

			/* try to go down tree */
			while (j < D.d) {
				i = reverse(D, j);
				if (i >= 0) {
					break;
				}
				j++;
			}
			
			if (j == D.d) {
				backtrack = true;
			} else { /*reverse pivot found */
				
				pushCache(D, i, j, depth);

				++depth;
				if (depth > deepest) {
					deepest = depth;
				}

				doPivot(D, i, j);
				
				count[2]++;
				totalnodes++;

				//save_basis (D); TODO
				//if (strace == count[2])
				//	debug = true;
				//if (etrace == count[2])
				//	debug = false;
				return true;		/*return new dictionary */
			}
		}
		return false;			/* done, no more bases */
	}
	
	
	private int[] doPivot(Dictionary D, int r, int s)
	{
    	if (log.isLoggable(Level.FINE)) {    		
    		log.fine(String.format(" pivot  B[%d]=%d  C[%d]=%d ", r, D.B[r], s, D.C[s]));
    		log.fine(D.toString());
    	}
    	
    	count[3]++;    /* count the pivot */
		D.pivot(r, s, debug);
		
    	if (log.isLoggable(Level.FINE)) {
    		log.fine(String.format(" depth=%d det=%s", depth, D.det().toString()));		  
    	}		
		
		int[] vars = new int[] { r, s };
		update(D, vars);	/*Update B,C,i,j */
		return vars;
	}
	
	
	/*reorder array a in increasing order with one misplaced element at index newone */
	/*elements of array b are updated to stay aligned with a */	
	private static void reorder (int a[], int b[], int newone, int range)
	{
		while (newone > 0 && a[newone] < a[newone - 1]) {
			int temp = a[newone];
			a[newone] = a[newone - 1];
			a[newone - 1] = temp;
			temp = b[newone];
			b[newone] = b[newone - 1];
			b[--newone] = temp;
		}
		
		while (newone < range - 1 && a[newone] > a[newone + 1]) {
			int temp = a[newone];
			a[newone] = a[newone + 1];
			a[newone + 1] = temp;
			temp = b[newone];
			b[newone] = b[newone + 1];
			b[++newone] = temp;
		}
	}
	
	
	/* Do dual pivots to get primal feasibility */
	/* Note that cost row is all zero, so no ratio test needed for Dual Bland's rule */	
	private boolean primalfeasible (Dictionary P)
	{
		boolean primalinfeasible = true;
		int m = P.m;
		int d = P.d;

		/*temporary: try to get new start after linearity */

		while (primalinfeasible)
		{
			int i = P.lastdv+1;
			while (i <= m && !negative(P.b(i))) {
				++i;
			}
			if (i <= m)
			{
				int j = 0;		/*find a positive entry for in row */
				while (j < d && !positive(P.get(i, j))) {
					++j;
				}
				if (j >= d) {
					return false;	/* no positive entry */
				}
				int[] vars = doPivot(P, i, j);
				i = vars[0];
				j = vars[1];				         
			} else {
				primalinfeasible = false;
			}
		}
		return true;
	}
		
   /* check if column indexed by col in this dictionary */
   /* contains output                                   */
   /* col=0 for vertex 1....d for ray/facet             */
	private boolean getsolution (Dictionary P, BigInteger[] output, VPolygon solution, int s)
	{
		int col = P.cols[s];
		// we know col != 0 from here down...
		if (!negative(P.cost(s))) {  		// check for rays: negative in row 0 , positive if lponly		 
			return false;
		}
		
		/*  and non-negative for all basic non decision variables */
		int j = P.lastdv + 1; /* cobasic index     */
		while (j <= P.m && !negative(P.get(j, s))) {
			++j;
		}

		if (j <= P.m) {
			return false;
		}

		if (P.lexmin(s)) {
			if (debug) {				
				log.fine(String.format(" lexmin ray in col=%d ", col));
				log.fine(P.toString());
			}
			return getray(P, col, output, solution);
		}

		return false;			/* no more output in this dictionary */
	}
	
	/*Print out solution in col and return it in output   */
	/*redcol =n for ray/facet 0..n-1 for linearity column */
	/*hull=1 implies facets will be recovered             */
	/* return FALSE if no output generated in column col  */
	private boolean getray (Dictionary P, int col, BigInteger[] output, VPolygon solution)
	{
		if (debug) {
			log.fine(P.toString());
		}

		++count[0];
		if (printcobasis) {
			printcobasis(P, solution, col);
		}

		int i = 1;
		for (int j = 0; j < output.length; ++j)	/* print solution */
		{
			if (j == 0) {	/* must have a ray, set first column to zero */
				output[0] = BigInteger.ZERO;
			} else {
				output[j] = getnextoutput (P, i, col);
				i++;
			}
		}
		reducearray (output);
		/* printslack for rays: 2006.10.10 */
		/* printslack inequality indices  */
		/*
	   if (printslack)
	    {
	       fprintf(lrs_ofp,"\nslack ineq:");
	       for(int i = lastdv + 1; i <= P.m; i++)
	         {
	           if (!zero(P.A[P.Row[i]][col]))
	                 fprintf(lrs_ofp," %d ", inequality[P.B[i] - lastdv]);
	         }
	    }
		 */
		return true;
	}

	/* get A[B[i]][col] and return to out */
	private BigInteger getnextoutput(Dictionary P, int i, int col)	
	{
		if (P.isNonNegative()) 	/* if m+i basic get correct value from dictionary          */
			/* the slack for the inequality m-d+i contains decision    */
			/* variable x_i. We first see if this is in the basis      */
			/* otherwise the value of x_i is zero, except for a ray    */
			/* when it is one (det/det) for the actual column it is in */
		{
			for (int j = P.lastdv + 1; j <= P.m; j++) {
				if (inequality[P.B[j] - P.lastdv] == P.m - P.d + i) {
					return P.A[P.rows[j]][col];
				}
			}
			/* did not find inequality m-d+i in basis */
			if (i == col) {
				return P.det();
			} else {
				return BigInteger.ZERO;
			}
		}
		else {			
			return P.A[P.rows[i]][col];
		}
	}
	
	/*Print out current vertex if it is lexmin and return it in output */
	/* return FALSE if no output generated  */	
	private boolean getvertex (Dictionary P, BigInteger[] output, VPolygon solution)
	{
		if (P.lexflag()) {
			++count[1];
		}

		if (debug) {
			log.fine(P.toString());
		}

		sumdet = sumdet.add(P.det());

		/*print cobasis if printcobasis=TRUE and count[2] a multiple of frequency */
		/* or for lexmin basis, except origin for hull computation - ugly!        */
		if (printcobasis) {
			if (P.lexflag() || (frequency > 0 && count[2] == (count[2] / frequency) * frequency)) {
				printcobasis(P, solution, 0);
			}
		}

		if (!P.lexflag()) {	/* not lexmin, and not printing forced */
			return false;
		}

		/* copy column 0 to output */
		output[0] = P.det();

		/* extract solution */
		for (int j = 1, i = 1; j < output.length; ++j, ++i) {
			output[j] = getnextoutput(P, i, 0);
		}

		reducearray(output);
		if (one(output[0])) {
			++count[4];               /* integer vertex */
		}

		/* uncomment to print nonzero basic variables 

	 printf("\n nonzero basis: vars");
	  for(i=1;i<=lastdv; i++)
	   {
	    if ( !zero(A[Row[i]][0]) )
	         printf(" %d ",B[i]);
	   }
		 */

		/* printslack inequality indices  */

		/*if (Q->printslack)
	    {
	       fprintf(lrs_ofp,"\nslack ineq:");
	       for(i=lastdv+1;i<=P->m; i++)
	         {
	           if (!zero(A[Row[i]][0]))
	                 fprintf(lrs_ofp," %d ", Q->inequality[B[i]-lastdv]);
	         }
	    }*/

		return true;
	}

	/* col is output column being printed */
	private void printcobasis (Dictionary P, VPolygon solution, int col)	
	{
		StringBuilder sb = new StringBuilder();
		sb.append(String.format("V#%d R#%d B#%d h=%d facets ", count[1], count[0], count[2], depth));

		int rflag = (-1);				/* used to find inequality number for ray column */
		Integer[] cobasis = new Integer[P.d]; //TODO: should I make this a list? perf?
		for (int i = 0; i < cobasis.length; i++)
		{
			cobasis[i] = inequality[P.C[i] - P.lastdv];
			if (P.cols[i] == col) { //can make if (i == s)
				rflag = cobasis[i];	/* look for ray index */
			}
		}
		for (int i = 0; i < cobasis.length; ++i) {
			reorder(cobasis);
		}
		for (int i = 0; i < cobasis.length; ++i)
		{
			sb.append(String.format(" %d", cobasis[i]));

			// perhaps I need to have a special name for the result column
			if (!(col == 0) && (rflag == cobasis[i])) {
				sb.append("*"); // missing cobasis element for ray
			}
		}		
		
		/* get and print incidence information */
		long nincidence;       /* count number of tight inequalities */
		if (col == 0) {
			nincidence = P.d;
		} else {
			nincidence = P.d - 1;
		}
		
		boolean firstime = true;
		List<Integer> incidenceList = new ArrayList<Integer>();
		Collections.addAll(incidenceList, cobasis);
		for (int i = P.lastdv + 1; i <= P.m; i++) {
			if (zero(P.b(i))) {
				if ((col == 0) || zero(P.A[P.rows[i]][col])) { 
					++nincidence;
					if (incidence) {
						if (firstime) {
							sb.append(" :");
							firstime = false;
						}
						sb.append(String.format(" %d", inequality[P.B[i] - P.lastdv]));
						incidenceList.add(inequality[P.B[i] - P.lastdv]);
					}
				}
			}
		}
		sb.append(String.format(" I#%d", nincidence));

		sb.append(String.format(" det=%s", P.det()));
		Rational vol = rescaledet(P); 	/* scales determinant in case input rational */
		sb.append(String.format(" in_det=%s", vol.toString()));
			
		log.info(sb.toString());
		if (P.lexflag()) {
			solution.cobasis.add(incidenceList.toArray(new Integer[0]));
		}
	}
	
	/* rescale determinant to get its volume */
	/* Vnum/Vden is volume of current basis  */
	private Rational rescaledet(Dictionary P)	
	{
		BigInteger gcdprod = BigInteger.ONE;
		BigInteger vden = BigInteger.ONE;		
		for (int i = 0; i < P.d; i++) {
			if (P.B[i] <= P.m) {
				gcdprod = gcdprod.multiply(P.gcd(inequality[P.C[i] - P.lastdv]));
				vden = vden.multiply(P.lcm(inequality[P.C[i] - P.lastdv]));
			}
		}
		BigInteger vnum = P.det().multiply(gcdprod);
		Rational rv = new Rational(vnum, vden);
		return rv;			
	}
	
	private CacheEntry popCache()
	{
		++cacheTries;

		CacheEntry rv = null;
		if (cacheTail == null) {
			++cacheMisses;
		} else {
			rv = cacheTail;
			cacheTail = cacheTail.prev;		
		}
		return rv;
	}
	
	private void pushCache(Dictionary d, int i, int j, long depth)
	{
		Dictionary copy = new Dictionary(d);	  
		log.fine(String.format("Saving dict at depth %d", depth));
		
		CacheEntry entry = new CacheEntry(copy, i ,j, depth);		
		entry.prev = cacheTail;
		cacheTail = entry;
	}
	
	
	/*update the B,C arrays after a pivot */
	/*   involving B[bas] and C[cob]           */
	private static void update (Dictionary dict, int[] vars)	
	{
		int i = vars[0];
		int j = vars[1];

		int leave = dict.B[i];
		int enter = dict.C[j];
		dict.B[i] = enter;
		reorder(dict.B, dict.rows, i, dict.m + 1);
		dict.C[j] = leave;
		reorder(dict.C, dict.cols, j, dict.d);
		
		/* restore i and j to new positions in basis */
		for (i = 1; dict.B[i] != enter; i++);		/*Find basis index */
		vars[0] = i;
		
		for (j = 0; dict.C[j] != leave; j++);		/*Find co-basis index */
		vars[1] = j;
	}
	
	/* Pivot Ax<=b to standard form */
	/*Try to find a starting basis by pivoting in the variables x[1]..x[d]        */
	/*If there are any input linearities, these appear first in order[]           */
	/* Steps: (a) Try to pivot out basic variables using order                    */
	/*            Stop if some linearity cannot be made to leave basis            */
	/*        (b) Permanently remove the cobasic indices of linearities           */
	/*        (c) If some decision variable cobasic, it is a linearity,           */
	/*            and will be removed.                                            */
	boolean getabasis(Dictionary P, int order[], int[] linearitiesIn, int hull)
	{		
		long nredundcol = 0L;		/* will be calculated here */

		List<Integer> linearities = new ArrayList<Integer>();
		for (int i = 0; i < linearitiesIn.length; ++i) {
			linearities.add(linearitiesIn[i]);
		}
		
		if (log.isLoggable(Level.FINE)) 
		{
			StringBuilder sb = new StringBuilder();
			sb.append("getabasis from inequalities given in order");
			for (int i = 0; i < P.m; i++) {
				sb.append(String.format(" %d", order[i]));
			}
			log.fine(sb.toString());
		}

		for (int j = 0; j < P.m; j++)
		{
			int i = 0;
			while (i <= P.m && P.B[i] != P.d + order[j]) {
				i++;			/* find leaving basis index i */
			}
			
			if (j < linearities.size() && i > P.m)	/* cannot pivot linearity to cobasis */
			{
				if (debug) {
					log.fine(P.toString());
				}				
				log.warning("Cannot find linearity in the basis");
				return false;
			}
			
			if (i <= P.m)
			{			/* try to do a pivot */
				int k = 0;
				while (P.C[k] <= P.d && zero (P.get(i, k))) {
					++k;
				}

				if (P.C[k] <= P.d)
				{
					int[] rs = doPivot(P, i, k);
					i = rs[0];
					k = rs[1];					
				} else if (j < linearities.size()) {			/* cannot pivot linearity to cobasis */
					if (zero(P.b(i))) {						
						log.warning(String.format("*Input linearity in row %d is redundant--converted to inequality", order[j]));
						linearities.set(j, 0);					
					} else {
						if (debug) {
							log.fine(P.toString());
						}						
						log.warning(String.format("*Input linearity in row %d is inconsistent with earlier linearities", order[j]));
						log.warning("*No feasible solution");
						return false;
					}
				}
			}
		}

		/* update linearity array to get rid of redundancies */		
		int k = 0;			/* counters for linearities         */
		while (k < linearities.size()) {
			if (linearities.get(k) == 0) {
				linearities.remove(k);
			} else {
				++k;				
			}
		}

		/* column dependencies now can be recorded  */
		/* redundcol contains input column number 0..n-1 where redundancy is */
		k = 0;
		while (k < P.d && P.C[k] <= P.d) {
			if (P.C[k] <= P.d) {		/* decision variable still in cobasis */
				redundancies.add(P.C[k] - hull);	/* adjust for hull indices */
				++k;
			}
		}

		/* now we know how many decision variables remain in problem */
		P.lastdv = P.d - redundancies.size();

		
		
		if (log.isLoggable(Level.FINE)) {
			log.fine(String.format("end of first phase of getabasis: lastdv=%d nredundcol=%d", P.lastdv, redundancies.size()));
			
			StringBuilder sb = new StringBuilder();
			sb.append("redundant cobases:");
			for (int i = 0; i < nredundcol; ++i) {
				sb.append(redundancies.get(i));
			}
			log.fine(sb.toString());
			
			log.fine(P.toString()); // TODO: finer?
		}

		/* Remove linearities from cobasis for rest of computation */
		/* This is done in order so indexing is not screwed up */

		for (int i = 0; i < linearities.size(); ++i)
		{				/* find cobasic index */
			k = 0;
			while (k < P.d && P.C[k] != linearities.get(i) + P.d) {
				++k;
			}
			if (k >= P.d) {
				log.warning("Error removing linearity");
				return false;
			}
			if (!removecobasicindex(P, k)) {
				return false;
			}
			// TODO: no need if we use P.d all the time to reset d = P.d;
		}
		if (debug && linearities.size() > 0) {
			log.fine(P.toString());
		}
		/* set index value for first slack variable */

		/* Check feasability */
		if (givenstart)
		{
			int i = P.lastdv + 1;
			while (i <= P.m && !negative (P.A[P.rows[i]][0])) {
				++i;
			}
			if (i <= P.m) {				
				log.warning("*Infeasible startingcobasis - will be modified");
			}
		}
		return true;
	}
	
	/* remove the variable C[k] from the problem */
	/* used after detecting column dependency    */
	private boolean removecobasicindex(Dictionary P, int k)	
	{			
		log.fine(String.format("removing cobasic index k=%d C[k]=%d", k, P.C[k]));					
		int cindex = P.C[k];		/* cobasic index to remove              */
		int deloc = P.cols[k];		/* matrix column location to remove     */

		for (int i = 1; i <= P.m; ++i)	{/* reduce basic indices by 1 after index */
			if (P.B[i] > cindex) {
				P.B[i]--;
			}
		}

		for (int j = k; j < P.d; j++)	/* move down other cobasic variables    */
		{
			P.C[j] = P.C[j + 1] - 1;	/* cobasic index reduced by 1           */
			P.cols[j] = P.cols[j + 1];
		}

		if (deloc != P.d) {
			/* copy col d to deloc */
			for (int i = 0; i <= P.m; ++i) {
				P.A[i][deloc] = P.A[i][P.d];
			}
			
			/* reassign location for moved column */
			int j = 0;
			while (P.cols[j] != P.d) {
				j++;
			}

			P.cols[j] = deloc;
		}

		P.d--;
		if (debug) {
			log.fine(P.toString());
		}
		return true;
	}
	
	/*reorder array in increasing order with one misplaced element */
	public static void reorder (Integer[] a)	
	{
		for (int i = 0; i < a.length - 1; i++) {
			if (a[i] > a[i + 1])
			{
				int temp = a[i];
				a[i] = a[i + 1];
				a[i + 1] = temp;
			}
		}
		for (int i = a.length - 2; i >= 0; i--) {
			if (a[i] > a[i + 1])
			{
				int temp = a[i];
				a[i] = a[i + 1];
				a[i + 1] = temp;
			}
		}
	}
	
	private static class CacheEntry
	{
		private Dictionary dict;
		private int bas;
		private int cob;
		private long depth;
		
		public CacheEntry(Dictionary dict, int bas, int cob, long depth) {
			this.dict = dict;
			this.bas = bas;
			this.cob = cob;
			this.depth = depth;
		}
		
		public Dictionary getDict() { return dict; }
		public int getBas() { return bas; }
		public int getCob() { return cob; }
		public long getDepth() { return depth; }
			
		public CacheEntry prev;
	}
}
