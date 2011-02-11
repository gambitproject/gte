package lse.math.games.lrs;
//
//import lse.math.games.Rational;
//
public class RedundAlgorithm {

//	public void run()
//	{
//		/*******************************************************/
//		/* redund_main is driver for redund.c, removes all     */
//		/* redundant rows from an H or V-representation        */
//		/* showing function calls intended for public use      */
//		/*******************************************************/
//		  Rational[][] Ain;		/* holds a copy of the input matrix to output at the end */
//
//		  long[] redineq;		/* redineq[i]=0 if ineq i non-red,1 if red,2 linearity  */
//		  long ineq;			/* input inequality number of current index             */
//
//		  Dictionary P;			/* structure for holding current dictionary and indices */
//		  Dictionary Q;			/* structure for holding static problem data            */
//
//		  Rational[][] Lin;		/* holds input linearities if any are found             */
//
//		  long i, j, d, m;
//		  long nlinearity;		/* number of linearities in input file                  */
//		  long nredund;			/* number of redundant rows in input file               */
//		  long lastdv;
//		  long debug;
//		  long index;			/* basic index for redundancy test */
//
//		/* global variables lrs_ifp and lrs_ofp are file pointers for input and output   */
//		/* they default to stdin and stdout, but may be overidden by command line parms. */
//		/* Lin is global 2-d array for linearity space if it is found (redund columns)   */
//
//		 // lrs_ifp = stdin;
//		 // lrs_ofp = stdout;
//		/***************************************************
//		 Step 0: 
//		  Do some global initialization that should only be done once,
//		  no matter how many lrs_dat records are allocated. db
//
//		***************************************************/
//
//		  //if ( !lrs_init ("\n*redund:"))
//		  //  return 1;
//
//		  //printf (AUTHOR);
//
//		/*********************************************************************************/
//		/* Step 1: Allocate lrs_dat, lrs_dic and set up the problem                      */
//		/*********************************************************************************/
//
//		  //Q = lrs_alloc_dat ("LRS globals");	/* allocate and init structure for static problem data */
//
//		  //if (Q == NULL)
//		  //  return 1;
//
//		 // if (!lrs_read_dat (Q, argc, argv))	/* read first part of problem data to get dimensions   */
//		 //   return 1;                         	/* and problem type: H- or V- input representation     */
//
//		  P = lrs_alloc_dic (Q);	/* allocate and initialize lrs_dic                     */
//		  if (P == NULL)
//		    return 1;
//
//		  if (!lrs_read_dic (P, Q))	/* read remainder of input to setup P and Q            */
//		    return 1;
//
//		/* if non-negative flag is set, non-negative constraints are not input */
//		/* explicitly, and are not checked for redundancy                      */
//
//		  m = P->m_A;              /* number of rows of A matrix */   
//		  d = P->d;
//		  debug = Q->debug;
//
//		  redineq = calloc ((m + 1), sizeof (long));
//		  Ain = lrs_alloc_mp_matrix (m, d);	/* make a copy of A matrix for output later            */
//
//		  for (i = 1; i <= m; i++)
//		    {
//		      for (j = 0; j <= d; j++)
//			copy (Ain[i][j], P->A[i][j]);
//
//		      if (debug)
//			lrs_printrow ("*", Q, Ain[i], d);
//		    }
//
//		/*********************************************************************************/
//		/* Step 2: Find a starting cobasis from default of specified order               */
//		/*         Lin is created if necessary to hold linearity space                   */
//		/*********************************************************************************/
//
//		  if (!lrs_getfirstbasis (&P, Q, &Lin, TRUE))
//		    return 1;
//
//		  /* Pivot to a starting dictionary                      */
//		  /* There may have been column redundancy               */
//		  /* If so the linearity space is obtained and redundant */
//		  /* columns are removed. User can access linearity space */
//		  /* from lrs_mp_matrix Lin dimensions nredundcol x d+1  */
//
//
//		/*********************************************************************************/
//		/* Step 3: Test each row of the dictionary to see if it is redundant             */
//		/*********************************************************************************/
//
//		/* note some of these may have been changed in getting initial dictionary        */
//		  m = P->m_A;
//		  d = P->d;
//		  nlinearity = Q->nlinearity;
//		  lastdv = Q->lastdv;
//		      if (debug)
//			fprintf (lrs_ofp, "\ncheckindex m=%ld, n=%ld, nlinearity=%ld lastdv=%ld", m,d,nlinearity,lastdv);
//
//		/* linearities are not considered for redundancy */
//
//		  for (i = 0; i < nlinearity; i++)
//		    redineq[Q->linearity[i]] = 2L;
//
//		/* rows 0..lastdv are cost, decision variables, or linearities  */
//		/* other rows need to be tested                                */
//
//		  for (index = lastdv + 1; index <= m + d; index++)
//		    {
//		      ineq = Q->inequality[index - lastdv];	/* the input inequality number corr. to this index */
//
//		      redineq[ineq] = checkindex (P, Q, index);
//		      if (debug)
//			fprintf (lrs_ofp, "\ncheck index=%ld, inequality=%ld, redineq=%ld", index, ineq, redineq[ineq]);
//		      if (redineq[ineq] == ONE)
//		        {
//			fprintf (lrs_ofp, "\n*row %ld was redundant and removed", ineq);
//		        fflush  (lrs_ofp);
//		        }
//
//		    }				/* end for index ..... */
//
//		  if (debug)
//		    {
//		      fprintf (lrs_ofp, "\n*redineq:");
//		      for (i = 1; i <= m; i++)
//			fprintf (lrs_ofp, " %ld", redineq[i]);
//		    }
//
//		  if (!Q->hull)
//		    fprintf (lrs_ofp, "\nH-representation");
//		  else
//		    fprintf (lrs_ofp, "\nV-representation");
//
//		/* linearities will be printed first in output */
//
//		  if (nlinearity > 0)
//		    {
//		      fprintf (lrs_ofp, "\nlinearity %ld", nlinearity);
//		      for (i = 1; i <= nlinearity; i++)
//			fprintf (lrs_ofp, " %ld", i);
//
//		    }
//		  nredund = nlinearity;		/* count number of non-redundant inequalities */
//		  for (i = 1; i <= m; i++)
//		    if (redineq[i] == 0)
//		      nredund++;
//		  fprintf (lrs_ofp, "\nbegin");
//		  fprintf (lrs_ofp, "\n%ld %ld rational", nredund, Q->n);
//
//		/* print the linearities first */
//
//		  for (i = 0; i < nlinearity; i++)
//		    lrs_printrow ("", Q, Ain[Q->linearity[i]], Q->inputd);
//
//		  for (i = 1; i <= m; i++)
//		    if (redineq[i] == 0)
//		      lrs_printrow ("", Q, Ain[i], Q->inputd);
//		  fprintf (lrs_ofp, "\nend");
//		  fprintf (lrs_ofp, "\n*Input had %ld rows and %ld columns", m, Q->n);
//		  fprintf (lrs_ofp, ": %ld row(s) redundant", m - nredund);
//
//		  lrs_free_dic (P,Q);           /* deallocate lrs_dic */
//		  lrs_free_dat (Q);             /* deallocate lrs_dat */
//
//		  lrs_close ("redund:");
//		}
//		/*********************************************/
//		/* end of redund.c                           */
//		/*********************************************/
}
