package lse.math.games.lrs;

import lse.math.games.Rational;

public class LrsMain {

	/*******************************************************/
	/* lrs_main is driver for lrs.c does H/V enumeration   */
	/* showing function calls intended for public use      */
	/*******************************************************/
	public static void main(String[] args)
	{	
		/***************************************************
		 Step 0: 
		  Do some global initialization that should only be done once,
		  no matter how many lrs_dat records are allocated. db

		 ***************************************************/

		if (!lrs_init ("\n*lrs:")) {
			System.exit(1);
		}

		LrsMain program = new LrsMain();
		Rational[][] payoff1 = new Rational[][] { 
				{ Rational.valueOf("1"), Rational.valueOf("-3"), Rational.valueOf("-2"), Rational.valueOf("-3")}, 
				{ Rational.valueOf("1"), Rational.valueOf("-2"), Rational.valueOf("-6"), Rational.valueOf("-1")} 
		};
		
		Rational[][] payoff2 = new Rational[][] { 
				{ Rational.valueOf("1"), Rational.valueOf("-3"), Rational.valueOf("-3")}, 
				{ Rational.valueOf("1"), Rational.valueOf("-2"), Rational.valueOf("-5")}, 
				{ Rational.valueOf("1"), Rational.valueOf("0"), Rational.valueOf("-6")}
		};
				
		program.run(new HPolygon(payoff1, true), new HPolygon(payoff2, true));
		
		
		System.exit(0);
	}

	public void run(HPolygon one, HPolygon two)
	{
		//int startcol = 0;
		//boolean prune = false;		/* if TRUE, getnextbasis will prune tree and backtrack  */


		/*********************************************************************************/
		/* Step 1: Allocate lrs_dat, lrs_dic and set up the problem                      */
		/*********************************************************************************/

		//Q = lrs_alloc_dat ("LRS globals");	/* allocate and init structure for static problem data */
		//TODO: put in a factory that manages instances
		/*
		if (lrs_global_count >= MAX_LRS_GLOBALS)
	    {
		      fprintf (stderr,
			       "Fatal: Attempt to allocate more than %ld global data blocks\n", MAX_LRS_GLOBALS);
		      exit (1);

  	}

	  lrs_global_list[lrs_global_count] = Q;
	  Q->id = lrs_global_count;
	  lrs_global_count++;
		 */

		LrsAlgorithm lrs = new LrsAlgorithm(); /* structure for holding static problem data            */
		lrs.run(one);
		printtotals(lrs, one, lrs.P);	/* print final totals, including estimates       */

		lrs.run(two);
		printtotals(lrs, two, lrs.P);	/* print final totals, including estimates       */
		
		//lrs.close("lrs:");

		System.exit(0);
	}

	private static boolean lrs_init(String string) {

		/* TODO: put in a factory
		printf ("%s", name);
		  printf (TITLE);
		  printf (VERSION);
		  printf ("(");
		  printf (BIT);
		  printf (",");
		  printf (ARITH);
		  if (!lrs_mp_init (ZERO, stdin, stdout)) 
		    return FALSE;
		  printf (")");


		  lrs_global_count = 0;
		  lrs_checkpoint_seconds = 0;
		#ifdef SIGNALS
		  setup_signals ();
		#endif
		  return TRUE;
		 */

		return true;
	}
	/*********************************************/
	/* end of model test program for lrs library */
	/*********************************************/

	// These appear to be all comments... perhaps useful for logging?
	void printtotals (LrsAlgorithm Q, HPolygon input, Dictionary P)
	{
		System.out.println();
		System.out.print("end");

		if(Q.verbose)
		{
			System.out.println();
			System.out.print(String.format("*Sum of det(B)=%s", Q.sumdet.toString()));
		}

		/* output things specific to vertex/ray computation */

		System.out.println();
		System.out.print(String.format("*Totals: vertices=%d rays=%d bases=%d", Q.count[1], Q.count[0], Q.count[2]));
		System.out.print(String.format(" integer_vertices=%d ", Q.count[4]));

		if (Q.count[0] > 0)
		{
			System.out.print(String.format(" vertices+rays=%d", Q.count[0] + Q.count[1]));
		}

		/*
		if ((Q.cest[2] > 0) || (Q.cest[0] > 0))
		{
			System.out.println();
			System.out.print(String.format("*Estimates: vertices=%.0f rays=%.0f", Q.count[1] + Q.cest[1], Q.count[0] + Q.cest[0]));
			System.out.print(String.format(" bases=%.0f integer_vertices=%.0f ", Q.count[2] + Q.cest[2], Q.count[4] + Q.cest[4]));

			System.out.println();
			System.out.print(String.format("*Total number of tree nodes evaluated: %d", Q.totalnodes));
			//System.out.print("\n*Estimated total running time=%.1f secs ",(Q.count[2] + Q.cest[2])/Q.totalnodes * get_time());
		}
		*/
		/* end of output for vertices/rays */

		if(!Q.verbose)
			return;

		System.out.println();
		System.out.print(String.format("*Input size m=%d rows n=%d columns", input.getNumRows(), input.getNumCols()));
		System.out.print(String.format(" working dimension=%d", P.d));

		System.out.println();
		System.out.print("*Starting cobasis defined by input rows");
		Integer[] temparray = new Integer[P.lastdv];
		for (int i = 0; i < P.lastdv; i++)
			temparray[i] = Q.inequality[P.C[i] - P.lastdv];
		for (int i = 0; i < P.lastdv; i++)
			LrsAlgorithm.reorder(temparray);
		for (int i = 0; i < P.lastdv; i++)
			System.out.print(String.format(" %d", temparray[i]));

		System.out.println();
		//TODO: cache impl -> System.out.print(String.format("\n*Dictionary Cache: max size= %ld misses= %ld/%ld   Tree Depth= %ld", dict_count, cache_misses, cache_tries, Q.deepest));
	}				/* end of lrs_printtotals */
}
