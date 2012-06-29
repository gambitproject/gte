/*************************************************************************/
/* Author:: Tallman Zacharia Nkgau                                       */
/* Name:: fourier.c v.1.0. (Revision 1)                                  */
/* Requires:: lrslib.h, lrslib.c lrsmp.c lrsmp.h from lrslib v.4.1.      */
/* Purpose:: To compute a projection from a higher dimension to a lower  */
/*           dimension using Fourier Elimination.                        */
/* Input Requirements:: Uses lrslib/cddlib input file format. Only input */
/*                      type "integer" or "rational" is accepted. Options*/
/*                      are restricted to "project" only.                */
/* Option:                                                               */
/* project t d_1 d_2 ... d_t                                             */
/* which projects onto the t dimensions specified                        */
/*                                                                       */
/* Output:: Output is written to standard output if no output file is    */
/*          given. It may optionally include statistics. It is in        */
/*          lrslib/cddlib format.                                        */
/*************************************************************************/
#define USAGE "fourier infile [outfile]"

/*************************************************************************/

#include <stdio.h>
#include <string.h>
#include "lrslib.h"

#define MAXCOL 1000  /* maximum number of variables. */


/**************************************************************************/

void fel_abort(char str[])
{
  printf("%s\n", str );
  exit(1);
}
/*************************************************************************/
 
									  
									  
/*******************************************************************/
/* Function to read all lines above the "matrix" in the input file.*/
/* Adapted from Prof. Avis' function in lrslib.c.                  */
/*******************************************************************/
 long readHfile(lrs_dat *Q)
{
  char line[100];
    char ch;
    long firstline = TRUE;
    
    if(fscanf(lrs_ifp, "%s", line)==EOF)
       exit(1);
    while (strcmp(line, "begin") != 0)
      {
	
	if (strncmp(line, "*", 1) == 0)
	  {
	    ch = line[0];
	    while ((ch != EOF) && (ch != '\n'))
	      ch = fgetc(lrs_ifp);
	  }
	else if (strcmp(line, "H-representation") == 0)
	  {
	    Q->hull = FALSE;
	  }
	else if (strcmp(line, "linearity")==0)
	  {
          /* disabled 2009.2.5 due to bug in linearity handling */
	 /*   if (!readlinearity(Q)) */
              fprintf(lrs_ofp, "\nfourier does not handle linearity option:\n replace each linearity by two inequalities\n");
	      return (FALSE);
	  }
	else if (firstline)
	  {
	    stringcpy(Q->fname, line);
	    fprintf(lrs_ofp, "%s\n", Q->fname);
	    firstline = FALSE;
	  }
	if (fscanf(lrs_ifp, "%s", line) == EOF)
	  {
	    fprintf(lrs_ofp, "No begin line\n");
	    return (FALSE); 
	  }
	
      } /* end of while */
    if (fscanf(lrs_ifp, "%ld %ld %s", &Q->m, &Q->n, line) == EOF)
      {
	fprintf(lrs_ofp, "No data in file\n");
	return (FALSE);
      }
    
    if (!((strcmp(line, "rational") == 0) || (strcmp(line, "integer") == 0)))
      {
	fprintf(lrs_ofp, "Data type must be rational\n");
	return (FALSE);
      }
    if (Q->m == 0)
      {
	fprintf(lrs_ofp, "No input given\n");
	return (FALSE);
      }
    return (TRUE);
    
}
/***************************************************************/
/* Function to read in the dictionary from input file.         */
/***************************************************************/
long readHmat(lrs_dic *P, lrs_dat *Q, long *project)
{
  char line[100];
  char ch;
  long p, i;

  if (!lrs_read_dic(P, Q))
    {
      fprintf(lrs_ofp, "Data matrix not properly formatted\n");
      return (FALSE);
    }
  /* "lrs_read_dic" doesn't handle option "project", so improvise */
  if (fseek(lrs_ifp, 0L, 0) <= 0) /* rewind file. */
    {
      while (fscanf(lrs_ifp, "%s", line) != EOF)
	{
	  if (strncmp(line, "*", 1) == 0)
	    {
	      ch = line[0];
	      while ((ch != EOF) && (ch != '\n'))
		ch = fgetc(lrs_ifp);
	    }
	  if (strcmp(line, "project") == 0)
	    {
	      if(fscanf(lrs_ifp, "%ld", &p)==EOF)
                {
                  fprintf(lrs_ofp, "No variables to project.\n");
                  return (FALSE);
                }

	      project[0] = p;
	      if (p <= 0)
		{
		  fprintf(lrs_ofp, "No variables to project.\n");
		  return (FALSE);
		}
	      for(i=1; i<=project[0]; i++)
		{
		  if (fscanf(lrs_ifp, "%ld", &p) == EOF)
		    {
		      fprintf(lrs_ofp, "Missing variables in 'project' line.\n");
		      return (FALSE);
		    }
		  project[i] = p;
		}
	    }
	}
    }
  else
    {
      fprintf(lrs_ofp, "Can't process input file\n");
      return (FALSE);
    }
  return (TRUE);
}
/*******************************************************************************/
void linear_dep(lrs_dic *P, lrs_dat *Q, long *Dep)
{
  long d;
  long nlinearity;
  lrs_mp_matrix A;
  long i, j, k, row, col,m;

  d = P->d;
  nlinearity = Q->nlinearity;
  
  A = lrs_alloc_mp_matrix(nlinearity+1, d+2);
  for(i=0;i<nlinearity+1;i++)
    Dep[i] = 0;              /* assume lin. dep. */
  for(i=1;i<=nlinearity;i++)
    {
      for(j=0;j<=d;j++)
	copy(A[i][j], P->A[i][j]);
      itomp(ZERO, A[i][d+1]);
    }
  for(col=1;col<=d;col++)
    {
      row = -1;
      for(i=1;i<=nlinearity;i++)
	if ((zero(A[i][d+1]))&& !zero(A[i][col]))
	  {
	    row = i;
	    break;
	  }

      if (row > 0)
	for(k=1;k<=nlinearity;k++)
	  {
	    if ((zero(A[k][d+1]))&&(!zero(A[k][col])) && (k!=row))
	      {
		printf("row=%ld k = %ld\n", row, k);
		if (sign(A[k][col])*sign(A[row][col]) < 0)
		  {
		    copy(A[0][0], A[k][col]);
		    copy(A[0][1], A[row][col]);
		    
		    storesign(A[0][0], POS);
		    storesign(A[0][1], POS);
		    
		    for(i=0;i<=d;i++)
		      {
			mulint(A[0][0], A[row][i], A[0][2]);
			mulint(A[0][1], A[k][i], A[0][3]);
			addint(A[0][2], A[0][3], A[k][i]);
		      }
		  }
		else
		  {
		    copy(A[0][0], A[k][col]);
		    copy(A[0][1], A[row][col]);
		    
		    storesign(A[0][0], NEG);
		    storesign(A[0][1], POS);
		    
		    for(i=0;i<=d;i++)
		      {
			mulint(A[0][0], A[row][i], A[0][2]);
			mulint(A[0][1], A[k][i], A[0][3]);
			addint(A[0][2], A[0][3], A[k][i]);
		      }
		  }
		itomp(ONE, A[row][d+1]);
		for(i=1;i<=nlinearity; i++)
		  {
		    for(m=0;m<=d;m++)
		      pmp("", A[i][m]);
		    fprintf(lrs_ofp, "\n");
		  }
		fprintf(lrs_ofp, "\n");
	      }
	  }
    }
  for(row=1,i=0;row<=nlinearity;row++)
    {
      for(k=0,i=0;k<=d;k++)
	if(zero(A[row][k]))
	  i++;
      if (i==d+1)
	Dep[row] =1;
    }  
  
}
/********************************************************************************/
/* groups[i] = +1 if A[i][col] > 0, groups[i] = -1 if A[i][col] < 0,            */
/* groups[i] = 0 if A[i][col] = 0, groups[m+1] = # of rows with <0 entry        */
/* in column 'col', and groups[m+2] = # of rows with > 0 entry in column 'col'  */
/********************************************************************************/
void lrs_compute_groups(lrs_dat *Q, lrs_dic *P, long col, long *groups)
{
  long i, row;
  long m;

  m = Q->m;
  for(i=0;i<= m+2; i++)
    {
      groups[i] = 0;
    }
   for(row = 1; row <= Q->m; row++)
    {
      if (sign(P->A[row][col]) < 0)
	{
	  groups[row] = -1;
	  groups[m+1]++;
	}
      else if (zero(P->A[row][col]))
	{
	  groups[0]++;
	}
      else
	{
	  groups[row] = 1;
	  groups[m+2]++;
	}
    }
   
}
/*******************************************************************/
/* Function to copy matrix A  from dictionary P to dictionary P1.  */
/* The column (variable) with index 'skip' is left out.            */
/* Set skip to '-1' if no column is to be left out.                */
/* Adapted from Prof. Avis' function in lrslib.c.                  */
/*******************************************************************/
void copydicA(lrs_dic *P1, lrs_dic *P, long skip_row, long skip_col)
{
  long i, j;
  long d, m_A;

  d = P->d; /* dimension of space of variables */
  m_A = P->m_A;

  if (skip_col > 0)
    {
      if (skip_row > 0)
	{
	  for (i = 1; i < skip_row; i++)
	    {
	      for(j = 0; j < skip_col; j++)
		copy (P1->A[i][j], P->A[i][j]);
	      for(j = skip_col+1; j <= d; j++)
		copy (P1->A[i][j-1], P->A[i][j]);
	      
	    }
	  for (i = skip_row+1; i <= m_A; i++)
	    {
	      for(j = 0; j < skip_col; j++)
		copy (P1->A[i-1][j], P->A[i][j]);
	      for(j = skip_col+1; j <= d; j++)
		copy (P1->A[i-1][j-1], P->A[i][j]);
	      
	    }
	}
      else
	{
	  for (i = 1; i <= m_A; i++)
	    {
	      for(j = 0; j < skip_col; j++)
		copy (P1->A[i-1][j], P->A[i][j]);
	      for(j = skip_col+1; j <= d; j++)
		copy (P1->A[i-1][j-1], P->A[i][j]);
	      
	    }
	}

    }
  else
    {
      if (skip_row > 0)
	{
	  for (i = 1; i < skip_row; i++)
	    for(j = 0; j <= d; j++)
	      copy (P1->A[i][j], P->A[i][j]);
	  for (i = skip_row+1; i <= m_A; i++)
	    for(j = 0; j <= d; j++)
	      copy (P1->A[i-1][j], P->A[i][j]);
	}
      else
	{
	  for (i = 1; i <= m_A; i++)
	    for(j = 0; j <= d; j++)
	      copy (P1->A[i][j], P->A[i][j]);
	 
	}
    }
}
/***************************************************************/
/* copy linearity from iQ to Q                                 */ 
/***************************************************************/
void copy_linearity(lrs_dat *Q, lrs_dat *iQ)
{
  long nlinearity;
  long i;

  nlinearity = iQ->nlinearity;
  if (nlinearity > 0)
    {
      Q->linearity = CALLOC ((nlinearity +1), sizeof (long));
      for(i=0; i < nlinearity; i++)
	Q->linearity[i] = iQ->linearity[i];
      Q->nlinearity = nlinearity;
      Q->polytope = FALSE;
    }
}
/***************************************************************/
void put_linearities_first(lrs_dat *Q, lrs_dic *P)
{
  long nlinearity;
  long i, row;
  lrs_mp Temp;

  lrs_alloc_mp(Temp);

  nlinearity = Q->nlinearity;
  for(row=1; row <= nlinearity; row++)
    {
      if (Q->linearity[row-1] != row)
	{
	  for(i=0;i<=P->d; i++)
	    {
	      copy(Temp, P->A[row][i]);
	      copy(P->A[row][i], P->A[Q->linearity[row-1]][i]);
	      copy(P->A[Q->linearity[row-1]][i], Temp);
	    }
	  copy(Temp, Q->Gcd[row]);
	  copy(Q->Gcd[row], Q->Gcd[Q->linearity[row-1]]);
	  copy(Q->Gcd[Q->linearity[row-1]], Temp);
	  copy(Temp, Q->Lcm[row]);
	  copy(Q->Lcm[row], Q->Lcm[Q->linearity[row-1]]);
	  copy(Q->Lcm[Q->linearity[row-1]], Temp);
	  Q->linearity[row-1] = row;
	}
      
    }
  
  lrs_clear_mp(Temp);

}
/***************************************************************/
/* Function to compute redundancies. redineq[i] = 1 if row i   */
/* is redundant. Adapted from Prof. Avis' function in lrslib.c.*/
/***************************************************************/ 
long compute_redundancy(long *redineq, lrs_dic *P, lrs_dat *Q)
{
  long ineq;
  long d, m;
  long nlinearity;
  long lastdv, index;
  lrs_mp_matrix Lin;
  
  m = P->m_A;
  d = P->d;
  
  if (!lrs_getfirstbasis(&P, Q, &Lin, TRUE))
    {
      return (FALSE);
    }
  m = P->m_A;
  d = P->d;
  nlinearity = Q->nlinearity;
  lastdv = Q->lastdv;
  for(index = lastdv +1;index <= m+d; index++)
    {
      ineq = Q->inequality[index-lastdv];
      redineq[ineq] = checkindex(P, Q, index);
    }
  return (TRUE);
}
/******************************************************************/
/* Function to project original space to space of variables       */
/* contained in the array 'variables'.                            */
/******************************************************************/
void lrs_project_var(lrs_dic **iP, lrs_dat **iQ, long *variables, long stat)
{
  lrs_dic *P1, *P2, *tP2, *P;
  lrs_dat *Q1, *Q2, *tQ2, *Q;
  
  long *redineq, *tgroups;
  long i, j, k, l, m, n, red, col, row;
  long empty_set;
  long *var_remove; /* variables to be removed */
  long count;
  /* could do with less of these  monsters */ 
  lrs_mp Temp, Temp1, Lcm, div1, div2, Temp2, Temp3, Temp4, Temp5;

  lrs_alloc_mp(Temp); lrs_alloc_mp(Temp1);lrs_alloc_mp(Temp2);
  lrs_alloc_mp(Temp3); lrs_alloc_mp(Temp4);lrs_alloc_mp(Temp5);
  lrs_alloc_mp(Lcm); lrs_alloc_mp(div1);lrs_alloc_mp(div2);

 

  if (stat)
    {
      fprintf(lrs_ofp, "*Number of\t Number after\t Number of\n");
      fprintf(lrs_ofp, "*Inequalties\t Removing Var.\t Redundancies\n");
      fprintf(lrs_ofp,  "*============================================\n");
      
    }
  /* create a copy of iP, iQ */
  if( (Q = lrs_alloc_dat("LRS GLOBALS")) == NULL)
    fel_abort("ERROR>Can't allocate memory for structures");
  
  Q->m = (*iQ)->m;
  Q->n = (*iQ)->n;
  n = (*iQ)->n;
  if (( P = lrs_alloc_dic(Q)) == NULL)
    fel_abort("ERROR>Can't allocate dictionary space");
  copydicA(P, (*iP),-1, -1);
   
  var_remove = CALLOC ((n + 2), sizeof (long));
  if (var_remove == NULL)
    fel_abort("ERROR>Can't allocate memory.");
  var_remove[0]=0;
  for(l=1; l<=n-1; l++)
    {
      var_remove[0]++;
      var_remove[l] = l;
    }
  for(l=1;l<=variables[0];l++)
    {
      var_remove[variables[l]] = 0;
      var_remove[0]--;
    }

  for (i = 1; i <= n-1; i++) /* main loop */
    {
      count = 0;
      if (var_remove[i])
	{
	  if (stat)
	    fprintf(lrs_ofp, "*%11ld     ", Q->m);
	  
	  /* create a copy of P, Q */
	  if( (Q1 = lrs_alloc_dat("LRS GLOBALS")) == NULL)
	    fel_abort("ERROR>Can't allocate memory for structures");
	  
	  Q1->m = Q->m;
	  Q1->n = Q->n;
	  
	  if (( P1 = lrs_alloc_dic(Q1)) == NULL)
	    fel_abort("ERROR>Can't allocate dictionary space");
	  copydicA(P1, P, -1, -1);
	  col = var_remove[i]; /* column to be removed */
	  for(l=i+1;l<=n-1;l++) /* fix variables for second round */
	    {
	      if ((var_remove[l]) && (var_remove[l] > col))
		  var_remove[l]--;
	    }
	  tgroups = CALLOC ((Q1->m+4), sizeof (long));
	  if (tgroups == NULL)
	    fel_abort("ERROR>Can't allocate memory.");
	  /* compute groupings tgroups[0] =  # of rows with '0' in column 'col'           */
	  lrs_compute_groups(Q1, P1, col, tgroups);
	  /* check for overflow */
	  if (tgroups[Q1->m +1] > 0)
	    if (tgroups[Q1->m + 2] > (MAXD/tgroups[Q1->m +1]))
	      {
		fel_abort("ERROR>Overflow...too many rows produced.");
	      }
	  
	  /* create P2, Q2 */
	  if( (Q2 = lrs_alloc_dat("LRS GLOBALS")) == NULL)
	    fel_abort("ERROR>Can't allocate memory for structures");
	  empty_set = (!tgroups[Q1->m +1] && tgroups[Q1->m +2]) ||
	              (tgroups[Q1->m +1] && !tgroups[Q1->m +2]) ||
	              (!(tgroups[Q1->m +1] + tgroups[Q1->m +2]));
	  
	  if (empty_set) /* one of the sets is empty, just remove the variable */
	    {
	      
	      Q2->m = Q1->m;
	      Q2->n = (Q1->n) - 1;
	      
	      if (( P2 = lrs_alloc_dic(Q2)) == NULL)
		fel_abort("ERROR>Can't allocate dictionary space");
	      
	      copydicA(P2, P1,-1, col);
	      
	      if (stat)
		fprintf(lrs_ofp, "%13ld", Q2->m);
	      
	    }
	  else
	    {
	      
	      Q2->m = (tgroups[Q1->m + 1]*tgroups[Q1->m +2]) + tgroups[0];
	      Q2->n = (Q1->n)-1;
	      if (stat)
		fprintf(lrs_ofp, "%13ld   ", Q2->m);
	      if (( P2 = lrs_alloc_dic(Q2)) == NULL)
		fel_abort("ERROR>Can't allocate dictionary space");
	      row = 1;
	      
	      for(j = 1; j <= Q1->m; j++)
		{
		  if (tgroups[j] < 0) 
		    for(k=1; k <= Q1->m; k++)
		      {
			
			if (tgroups[k] > 0)
			  {
			    copy(div1, P1->A[j][col]);
			    copy(div2, P1->A[k][col]);
			    storesign(div1, POS);
			    copy(Lcm, div1);
			    lcm(Lcm, div2);
			    
			    copy(Temp, Lcm);
			    copy(Temp1, div1);
			    divint(Temp, Temp1, Temp2);
			    
			    copy(Temp, Lcm);
			    copy(Temp1, div2);
			    divint(Temp, Temp1, Temp3);
			    
			    
			    for(l=0;l< col; l++)  
			      {
				
				copy(Temp, P1->A[j][l]);
				copy(Temp1, P1->A[k][l]); 
				mulint(Temp,Temp2 ,Temp4);
				mulint(Temp1,Temp3,Temp5);
				addint(Temp4, Temp5, P2->A[row][l]);
				
			      }
			    for(l=col+1;l<Q1->n; l++)  
			      {
				
				copy(Temp, P1->A[j][l]);
				copy(Temp1, P1->A[k][l]); 
				mulint(Temp,Temp2 ,Temp4);
				mulint(Temp1,Temp3,Temp5);
				addint(Temp4, Temp5, P2->A[row][l-1]);
				
			      }
			    reducearray(P2->A[row], Q2->n);
			    
			    row++;
			  } /* end if (tgroups[k]) */
		      } /* end for k */
		} /* end for j*/
	      for(j=1;j<=Q1->m;j++)
		{
		  if (tgroups[j]==0)  /* just copy row, coefficient was '0' */
		    {
		      for(l=0;l<col;l++)
			copy(P2->A[row][l], P1->A[j][l]);
		      for(l=col+1;l<Q1->n;l++)
			copy(P2->A[row][l-1], P1->A[j][l]);
		      reducearray(P2->A[row], Q2->n);
		      row++;
		    }
		}
	    } /* end else  */
	      
	  /* create temp P2, Q2 */
	  lrs_free_dic(P1, Q1);
	  lrs_free_dat(Q1);
	  for(row=1;row<=Q2->m;row++)
	    {
	      l = 0;
	      for(j=1;j<Q2->n; j++)
		if (zero(P2->A[row][j]))
		  l++;
	      if (l==Q2->n -1 ) {
		count++;
	     }
	    }
	  if( (tQ2 = lrs_alloc_dat("LRS GLOBALS")) == NULL)
	    fel_abort("ERROR>Can't allocate memory for structures");
	      
	  tQ2->m = Q2->m;
	  tQ2->n = Q2->n;
	      
	  if (( tP2 = lrs_alloc_dic(tQ2)) == NULL)
	    fel_abort("ERROR>Can't allocate dictionary space");
	  
	  copydicA(tP2, P2, -1, -1);
	  
	  /* find redundacies */
	  m = tQ2->m;
	  redineq = CALLOC ((m+1), sizeof (long));
	  if (redineq == NULL)
	    fel_abort("ERROR>Can't allocate memory.");
	  
	  if (!compute_redundancy(redineq, tP2, tQ2))
	    fel_abort("ERROR>Can't pivot in redundancy LP");
	  red = 0;
	    
	  for(row=1;row<=Q2->m; row++)
	    if (redineq[row] == 1L)
	      {
		red++;
	      }
	  if (stat)
	    fprintf(lrs_ofp, "%12ld%8ld\n", red, count);
	  
	  /* make new P, Q */
	  
	  lrs_free_dic(P , Q );
	  lrs_free_dat(Q );
	  
	  if( (Q = lrs_alloc_dat("LRS GLOBALS")) == NULL)
	    fel_abort("ERROR>Can't allocate memory for structures");
	  
	  Q->m = Q2->m - red;
	  Q->n = Q2->n;
	  
	  if (( P = lrs_alloc_dic(Q)) == NULL)
	    fel_abort("ERROR>Can't allocate dictionary space");  
	  
	  /* copy to P (from P2) nonredundant rows */  
	  k = 0;
	  for(row=1;row<=Q2->m; row++)
	    if (redineq[row] != 1L)
	      {
		k++;
		for(l=0;l<=(Q2->n)-1;l++)
		  copy(P->A[k][l], P2->A[row][l]);
	      }
	  free(redineq);
	  free(tgroups);
	  lrs_free_dic(tP2, tQ2);
	  lrs_free_dat(tQ2);
	  lrs_free_dic(P2, Q2);
	  lrs_free_dat(Q2);  
	} /* end if (var_remove[i]) */
    }/* end "for i " */
  *iP = P;
  *iQ = Q;
    lrs_clear_mp(Temp); lrs_clear_mp(Temp1);lrs_clear_mp(Temp2);
    lrs_clear_mp(Temp3); lrs_clear_mp(Temp4);lrs_clear_mp(Temp5);
    lrs_clear_mp(Lcm); lrs_clear_mp(div1);lrs_clear_mp(div2);

}
/*********************************************************************/
void full_fel(lrs_dic *iP, lrs_dat *iQ, long *variables)
{
  lrs_dic *P1, *P2,  *P;
  lrs_dat *Q1, *Q2,  *Q;
  
  long *proj, *redineq;                    /* for variables to project to */ 
  long i, j, k, l, m, n, lindep, col, row, red;
  long *var_remove; /* variables to be removed */
  long *Dep;        /*Dep[0] not used, Dep[i] = 1 if eqn lin. dep., else 0 */
  long nlinearity;
  long eqn;
  long last=0;       /* =1 if equation used to remove var. =2 if FME used */
  /* could do with less of these  monsters */ 
  lrs_mp Temp, Temp1, div1;
 
  /* create a copy of iP, iQ */
  if( (Q = lrs_alloc_dat("LRS GLOBALS")) == NULL)
    fel_abort("ERROR>Can't allocate memory for structures");
  
  Q->m = iQ->m;
  Q->n = iQ->n;
  copy_linearity(Q, iQ);
  n = iQ->n;
  if (( P = lrs_alloc_dic(Q)) == NULL)
    fel_abort("ERROR>Can't allocate dictionary space");
  copydicA(P, iP,-1, -1);
   
  var_remove = CALLOC ((n + 2), sizeof (long));
  if (var_remove == NULL)
    fel_abort("ERROR>Can't allocate memory.");
  var_remove[0]=0;
  for(l=1; l<=n-1; l++)
    {
      var_remove[0]++;
      var_remove[l] = l;
    }
  for(l=1;l<=variables[0];l++)
    {
      var_remove[variables[l]] = 0;
      var_remove[0]--;
    }
  nlinearity = iQ->nlinearity;
  for (i = 1; i <= n-1; i++) /* main loop */
    {
      if (var_remove[i])
	{
	  
	  /* create a copy of P, Q */
	  if( (Q1 = lrs_alloc_dat("LRS GLOBALS")) == NULL)
	    fel_abort("ERROR>Can't allocate memory for structures");
	  
	  Q1->m = Q->m;
	  Q1->n = Q->n;
	  copy_linearity(Q1, Q);
	  if (( P1 = lrs_alloc_dic(Q1)) == NULL)
	    fel_abort("ERROR>Can't allocate dictionary space");
	  copydicA(P1, P,-1, -1);
	  col = var_remove[i]; /* column to be removed */
	  for(l=i+1;l<=n-1;l++) /* fix variables for second round */
	    {
	      if ((var_remove[l]) && (var_remove[l] > col))
		  var_remove[l]--;
	    }
	  for(l=1, eqn=-1; l <= nlinearity; l++)
	    if (!zero(P1->A[l][col])) 
	      {
		eqn = l; /* use this linearity row to eliminate col */
		break;
	      } 
	  if (eqn > 0)
	    {
	      last = 1;
	      for(l=eqn-1;l<nlinearity-1;l++) /* reduce linearities */
		{
		  Q1->linearity[l] = Q1->linearity[l+1] -1;
		}
	      nlinearity--;
	      Q1->nlinearity = nlinearity;
	      
	      for(j=0;j<=P1->d;j++)
		{
		  if ((j!=col) && !zero(P1->A[eqn][j]))
		    changesign(P1->A[eqn][j]);
		}
	      
	      copy(div1, P1->A[eqn][col]);
	      for(k=1;k<=P1->m;k++)
		{
		  if (k!=eqn)
		    {
		      for(j=0;j<=P1->d;j++)
			{
			  if (j!=col)
			    {
			      if (zero(P1->A[k][col]))
				break;
			      mulint(P1->A[k][col], P1->A[eqn][j], Temp);
			      mulint(P1->A[k][j], div1, Temp1);
			      addint(Temp, Temp1, P1->A[k][j]);
			      if (negative(div1))
				{
				  if (!zero(P1->A[k][j]))
				    {
				      changesign(P1->A[k][j]);
				    }
				}
			      
			      
			    }
			}
		      itomp(0L, P1->A[k][col]);
		      reducearray(P1->A[k], Q1->n);
		    }
		}
	      /* make new P, Q */
	      lrs_free_dic(P , Q );
	      lrs_free_dat(Q );
	      
	      if( (Q = lrs_alloc_dat("LRS GLOBALS")) == NULL)
		fel_abort("ERROR>Can't allocate memory for structures");
	      
	      Q->m = Q1->m -1;
	      Q->n = Q1->n -1;
	      copy_linearity(Q, Q1);
	      if (( P = lrs_alloc_dic(Q)) == NULL)
		fel_abort("ERROR>Can't allocate dictionary space");  
	      copydicA(P, P1, eqn, col);
	      lrs_free_dic(P1 , Q1 );
	      lrs_free_dat(Q1 );
     
	    }
	  else
	    {
	      last = 2;
	      if( (Q2 = lrs_alloc_dat("LRS GLOBALS")) == NULL)
		fel_abort("ERROR>Can't allocate memory for structures");
	      
	      Q2->m = Q1->m - Q1->nlinearity;
	      Q2->n = Q1->n;
	      if (( P2 = lrs_alloc_dic(Q2)) == NULL)
		fel_abort("ERROR>Can't allocate dictionary space");  
	      /* copy inequalities */
	      for(row=Q1->nlinearity+1;row<=Q1->m; row++)
		{
		  for(l=0;l<=(Q1->n)-1;l++)
		    copy(P2->A[row-Q1->nlinearity][l], P1->A[row][l]);
		}
	      proj = CALLOC ((Q1->n +2), sizeof (long));
	      for(l=1;l<col;l++)
		proj[l] = l;
	      
	      for(l=col+1;l<Q1->n;l++)
		proj[l-1] = l;
	      proj[0] = Q1->n-2;
	      lrs_project_var(&P2, &Q2, proj, FALSE);
	      /* make new P, Q */
	      lrs_free_dic(P , Q );
	      lrs_free_dat(Q );
	      
	      if( (Q = lrs_alloc_dat("LRS GLOBALS")) == NULL)
		fel_abort("ERROR>Can't allocate memory for structures");
	      
	      Q->m = Q1->nlinearity + P2->m_A;;
	      Q->n = Q1->n - 1;
	      copy_linearity(Q, Q1);
	      if (( P = lrs_alloc_dic(Q)) == NULL)
		fel_abort("ERROR>Can't allocate dictionary space");
	      for(row=1;row<=Q1->nlinearity; row++)
		{
		  for(l=0;l<col;l++)    /* skip column 'col' */
		    copy(P->A[row][l], P1->A[row][l]);
		  for(l=col+1;l<=(Q->n)-1;l++)
		    copy(P->A[row][l-1], P1->A[row][l]);
		}
	      for(row=1;row<=P2->m_A; row++)
		{
		  for(l=0;l<=(Q->n)-1;l++)
		    copy(P->A[row][l], P2->A[row][l]);
		}
	      lrs_free_dic(P1 , Q1 );
	      lrs_free_dat(Q1 );
	      lrs_free_dic(P2 , Q2 );
	      lrs_free_dat(Q2 );
	    }
	   
	}
      
    }
  /* remove linearly dependent linearities */
  Dep = CALLOC ((Q->nlinearity+2), sizeof (long));
  linear_dep(P, Q, Dep);
  for(l=1, lindep=0; l <= Q->nlinearity; l++)
      if (Dep[l])
	lindep++;
  
  /*if (last==1)  perform one last redundancy checking */
    
      if( (Q1 = lrs_alloc_dat("LRS GLOBALS")) == NULL)
	fel_abort("ERROR>Can't allocate memory for structures");
      Q1->m = Q->m - Q->nlinearity;
      Q1->n = Q->n;
      if (( P1 = lrs_alloc_dic(Q1)) == NULL)
	fel_abort("ERROR>Can't allocate dictionary space");
      for(row=Q->nlinearity+1;row<=Q->m; row++)
	{
	  for(l=0;l<=(Q->n)-1;l++)
	    copy(P1->A[row-Q->nlinearity][l], P->A[row][l]);
	}
      m = Q1->m;
      redineq = CALLOC ((m+1), sizeof (long));
      if (redineq == NULL)
	fel_abort("ERROR>Can't allocate memory.");
      
      if (!compute_redundancy(redineq, P1, Q1))
	fel_abort("ERROR>Can't pivot in redundancy LP");
      for(row=1,red=0;row<=m; row++)
	if (redineq[row] == 1L)
	  {
	    red++;
	  }
      lrs_free_dic(P1 , Q1 );
      lrs_free_dat(Q1 );
      
    

  /* assemble final result */
  if( (Q2 = lrs_alloc_dat("LRS GLOBALS")) == NULL)
    fel_abort("ERROR>Can't allocate memory for structures");
  
  Q2->m = (m-red) + (Q->nlinearity - lindep);
  Q2->n = Q->n;
  Q2->nlinearity = 0L;

  if (( P2 = lrs_alloc_dic(Q2)) == NULL)
    fel_abort("ERROR>Can't allocate dictionary space");
  for(l=1, row=1;l<=Q->nlinearity;l++)
    if (!Dep[l])
      {
	for(i=0;i<=Q->n-1;i++)
	  copy(P2->A[row][i], P->A[l][i]);
	row++;
      }

  for(l=Q->nlinearity+1;l<=Q->m;l++)
    if (redineq[l-Q->nlinearity]!=1L)
      {
	for(i=0;i<=Q->n-1;i++)
	  copy(P2->A[row][i], P->A[l][i]);
	row++;
      }
  Q2->nlinearity = Q->nlinearity - lindep;
  for(l=1;l<=Q2->nlinearity;l++)
    Q2->linearity[l-1] = l;
  lrs_free_dic(P , Q );
  lrs_free_dat(Q );
  fprintf(lrs_ofp, "H-representation\n");
  if (Q2->nlinearity > 0)
    {
      fprintf(lrs_ofp, "linearity %ld", Q2->nlinearity);
	 for(row=0; row<Q2->nlinearity;row++)
	   fprintf(lrs_ofp, " %ld", Q2->linearity[row]);
	 fprintf(lrs_ofp, "\n");
    }
  fprintf(lrs_ofp, "begin\n");
  fprintf(lrs_ofp, "%ld %ld %s", Q2->m, Q2->n, "rational");
  for(row=1;row<=Q2->m; row++)
    lrs_printrow("", Q2, P2->A[row], Q2->inputd);
  fprintf(lrs_ofp, "\nend\n");
  
}

/***************************************************************/
 int main(int argc, char *argv[])
   {
	 
     lrs_dic *P;                  /* holds dictionary */
     lrs_dat *Q;                  /* holds information about dictionary */
 
     FILE  *infile, *outfile;
     
     long *proj;                  
     
     /* try opening files */
     if (argc < 2)
       fel_abort(USAGE);
       
     if ((infile = fopen(argv[1], "r")) == NULL)
        fel_abort("ERROR>Can't open input file");
     
     if (argc == 2)
        outfile =  stdout;
     else if ((outfile = fopen(argv[2], "a")) == NULL)
    	    fel_abort("ERROR>Can't open output file");

     /* initialize lrs */

     if (!lrs_init("Fourier Elimination\n")) 
        fel_abort("ERROR>Can't initialize lrs");
     /* set lrs global file pointers */
     lrs_ifp = infile;
     lrs_ofp = outfile;

     
     /* allocate space for problem */
     if( (Q = lrs_alloc_dat("LRS GLOBALS")) == NULL)
       fel_abort("ERROR>Can't allocate memory for structures");
    
     if (!readHfile(Q))    /* get info about data from input file */
       {
	 fprintf(stderr, "Can't read input file\n");
	 exit(1);
       }
      
     
     if (( P = lrs_alloc_dic(Q)) == NULL) 
       fel_abort("ERROR>Can't allocate dictionary space");
     
     proj = CALLOC ((MAXCOL), sizeof (long)); /* variables to project to are stored here */
     if (!readHmat(P, Q, proj))     /* read in the matrix/dictionary */
       {
	 fprintf(stderr, "Can't read input file\n");
	 exit(1);
       }
    
     /*  lrs_project_var(P, Q, proj, TRUE);  compute projection, TRUE means print statistics */
     /* clean up */
     put_linearities_first(Q, P);
     full_fel(P, Q, proj); 
/*
     fprintf(lrs_ofp, "H-representation\n");
     if (Q->nlinearity > 0)
       {
	 fprintf(lrs_ofp, "linearity %ld", Q->nlinearity);
	 for(row=0; row<Q->nlinearity;row++)
	   fprintf(lrs_ofp, " %ld", Q->linearity[row]);
	 fprintf(lrs_ofp, "\n");
       }
     fprintf(lrs_ofp, "begin\n");
     fprintf(lrs_ofp, "%ld %ld %s", Q->m, Q->n, "rational");
     for(row=1;row<=Q->m; row++)
       lrs_printrow("", Q, P->A[row], Q->inputd);
     fprintf(lrs_ofp, "\nend\n");
*/
     lrs_free_dic(P, Q);
     lrs_free_dat(Q);
     lrs_close("Fourier Elimination\n"); 
     printf("\n");
     return(0);
}





