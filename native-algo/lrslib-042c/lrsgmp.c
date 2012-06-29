/* lrsgmp.c      library code for lrs extended precision arithmetic  */
/* Version 4.1, April 3, 2001                                        */
/* Copyright: David Avis 2001, avis@cs.mcgill.ca                     */

/* For gmp package                                                   */
/* derived from lrslong.c and lrsmp.c                                */

#include <stdio.h>
#include <stdlib.h>
#include "lrsgmp.h"

long lrs_digits;		/* max permitted no. of digits   */
long lrs_record_digits;		/* this is the biggest acheived so far.     */

extern FILE *lrs_ifp;			/* input file pointer       */
extern FILE *lrs_ofp;			/* output file pointer      */

long digits;
long record_digits;

/* these are allocated once and used as temporary storage where needed */
lrs_mp temp1,temp2,temp3; 


#define MAXINPUT 1000		/*max length of any input rational */


void 
lcm (lrs_mp a, lrs_mp b)			/* a = least common multiple of a, b; b is preserved */
{
  copy (temp1, a);
  copy (temp2, b);
  gcd (temp1,temp2);
  exactdivint (a, temp1, temp2);		/* temp2=a/temp1   there is no remainder */
  mulint (temp2, b, a);
}				/* end of lcm */


/***************************************************************/
/*                                                             */
/*     Package of routines for rational arithmetic             */
/*     (Built on top of package for multiprecision arithmetic  */
/*                                                             */
/***************************************************************/

void 
reduce (lrs_mp Na, lrs_mp Da)	/* reduces Na/Da by gcd(Na,Da) */
{
  lrs_mp Nb, Db, Nc, Dc;
  lrs_alloc_mp(Nb); lrs_alloc_mp(Db);
  lrs_alloc_mp(Nc); lrs_alloc_mp(Dc);
  copy (Nb, Na);
  copy (Db, Da);
  storesign (Nb, POS);
  storesign (Db, POS);
  copy (Nc, Na);
  copy (Dc, Da);
  gcd (Nb, Db);			/* Nb is the gcd(Na,Da) */
  exactdivint (Nc, Nb, Na);
  exactdivint (Dc, Nb, Da);
  lrs_clear_mp(Nb); lrs_clear_mp(Db);
  lrs_clear_mp(Nc); lrs_clear_mp(Dc);
}

void 
reduceint (lrs_mp Na, lrs_mp Da)	/* divide Na by Da and return */
{
  copy (temp1, Na);
  exactdivint (temp1, Da, Na);
}


long 
comprod (lrs_mp Na, lrs_mp Nb, lrs_mp Nc, lrs_mp Nd)
					    /* +1 if Na*Nb > Nc*Nd  */
					    /* -1 if Na*Nb < Nc*Nd  */
					    /*  0 if Na*Nb = Nc*Nd  */
{
  long i;

  mulint (Na, Nb, temp1);
  mulint (Nc, Nd, temp2);
  i=mpz_cmp(temp1,temp2);
  if (i > 0)
    return (ONE);
  else if (i < 0)
    return (-ONE);
  else 
    return (ZERO);
}

void 
linrat (lrs_mp Na, lrs_mp Da, long ka, lrs_mp Nb, lrs_mp Db, long kb, lrs_mp Nc, lrs_mp Dc)

	/* computes Nc/Dc = ka*Na/Da  +kb* Nb/Db and reduces answer by gcd(Nc,Dc) */
{
  mulint (Na, Db, Nc);
  mulint (Da, Nb, temp1);
  linint (Nc, ka, temp1, kb);	/* Nc = (ka*Na*Db)+(kb*Da*Nb)  */
  mulint (Da, Db, Dc);		/* Dc =  Da*Db           */
  reduce (Nc, Dc);
}


void 
divrat (lrs_mp Na, lrs_mp Da, lrs_mp Nb, lrs_mp Db, lrs_mp Nc, lrs_mp Dc)
           /* computes Nc/Dc = (Na/Da) /( Nb/Db ) and reduce */
{
  mulint (Na, Db, Nc);
  mulint (Da, Nb, Dc);
  reduce (Nc, Dc);
}


void 
mulrat (lrs_mp Na, lrs_mp Da, lrs_mp Nb, lrs_mp Db, lrs_mp Nc, lrs_mp Dc)
              /* computes Nc/Dc=(Na/Da)*(Nb/Db) and reduce      */

{
  mulint (Na, Nb, Nc);
  mulint (Da, Db, Dc);
  reduce (Nc, Dc);
}

/***************************************************************/
/*                                                             */
/*     Conversion and I/O functions                            */
/*                                                             */
/***************************************************************/

void 
atomp (const char *s, lrs_mp a)	/*convert string to lrs_mp integer */
     /* based on  atoi KR p.58 */
{
  long diff, ten, i, sig;
  lrs_mp mpone;
  lrs_alloc_mp (mpone);
  itomp (ONE, mpone);
  ten = 10L;
  for (i = 0; s[i] == ' ' || s[i] == '\n' || s[i] == '\t'; i++);
  /*skip white space */
  sig = POS;
  if (s[i] == '+' || s[i] == '-')	/* sign */
    sig = (s[i++] == '+') ? POS : NEG;
  itomp (0L, a);
  while (s[i] >= '0' && s[i] <= '9')
    {
      diff = s[i] - '0';
      linint (a, ten, mpone, diff);
      i++;
    }
  storesign (a, sig);
  if (s[i])
    {
      fprintf (stderr, "\nIllegal character in number: '%s'\n", s + i);
      exit (1);
    }
  lrs_clear_mp (mpone);
}				/* end of atomp */

void 
atoaa (const char *in, char *num, char *den)
     /* convert rational string in to num/den strings */
{
  long i, j;
  for (i = 0; in[i] != '\0' && in[i] != '/'; i++)
    num[i] = in[i];
  num[i] = '\0';
  den[0] = '\0';
  if (in[i] == '/')
    {
      for (j = 0; in[j + i + 1] != '\0'; j++)
	den[j] = in[i + j + 1];
      den[j] = '\0';
    }
}				/* end of atoaa */


void 
rattodouble (lrs_mp a, lrs_mp b, double *x)	/* convert lrs_mp rati
						   onal to double */

{
  double y;
  y=mpz_get_d (a);
  (*x)=mpz_get_d (b);
  (*x) = y / (*x);
}

long 
readrat (lrs_mp Na, lrs_mp Da)	/* read a rational or integer and convert to lrs_mp */
	       /* returns true if denominator is not one       */
{
  char in[MAXINPUT], num[MAXINPUT], den[MAXINPUT];
  if(fscanf (lrs_ifp, "%s", in)==EOF)
                 {
                   fprintf (lrs_ofp, "\nInvalid rational input");
                   exit(1);
                 }

  if(!strcmp(in,"end"))          /*premature end of input file */
    {
     return (999L);
    }

  atoaa (in, num, den);		/*convert rational to num/dem strings */
  atomp (num, Na);
  if (den[0] == '\0')
    {
      itomp (1L, Da);
      return (FALSE);
    }
  atomp (den, Da);
  return (TRUE);
}

void
pmp (char *name, lrs_mp Nt)
{
  fprintf (lrs_ofp, "%s", name);
  if (sign (Nt) != NEG)
    fprintf (lrs_ofp, " ");
  mpz_out_str (lrs_ofp,10,Nt);
  fprintf (lrs_ofp, " ");
}


void 
prat (char *name, lrs_mp Nin, lrs_mp Din)
     /*print the long precision rational Nt/Dt  */
{
  copy (temp1, Nin);
  copy (temp2, Din);
  reduce (temp1, temp2);
  fprintf (lrs_ofp, "%s", name);
  if (sign (temp1) != NEG)
    fprintf (lrs_ofp, " ");
  mpz_out_str (lrs_ofp,10,temp1);
  if ( !one(temp2))
    {
    fprintf (lrs_ofp, "/");
    mpz_out_str (lrs_ofp,10,temp2);
    }
  fprintf (lrs_ofp, " ");
}				/* prat */


void
readmp (lrs_mp a)               /* read an integer and convert to lrs_mp */
{
  long in;
  if(fscanf (lrs_ifp, "%ld", &in)==EOF)
                 {
                   fprintf (lrs_ofp, "\nInvalid integer input");
                   exit(1);

                 }
  itomp (in, a);
}

/***************************************************************/
/*                                                             */
/*     Memory allocation functions                             */
/*                                                             */
/***************************************************************/

lrs_mp_vector 
lrs_alloc_mp_vector (long n)
 /* allocate lrs_mp_vector for n+1 lrs_mp numbers */
{
  lrs_mp_vector p;
  long i;

  p = CALLOC ((n + 1), sizeof (lrs_mp ));
  for (i = 0; i <= n; i++)
    lrs_alloc_mp(p[i]);

  return p;
}

void
lrs_clear_mp_vector (lrs_mp_vector p, long n)
/* free space allocated to p */
{
  long i;
  for (i=0; i<=n; i++)
     lrs_clear_mp (p[i] );
  free (p);
}

lrs_mp_matrix 
lrs_alloc_mp_matrix (long m, long n)
/* allocate lrs_mp_matrix for m+1 x n+1 lrs_mp numbers */
{
  lrs_mp_matrix a;
  int i, j;


  a = calloc ((m + 1), sizeof (lrs_mp_vector));

  for (i = 0; i < m + 1; i++)
    {
      a[i] = calloc ((n + 1), sizeof (lrs_mp ));

      for (j = 0; j < n + 1; j++)
	lrs_alloc_mp (a[i][j]);
    }
  return a;
}

void
lrs_clear_mp_matrix (lrs_mp_matrix p, long m, long n)
/* free space allocated to p */
{
  long i,j;
  for (i = 0; i < m + 1; i++)
    {
      for (j = 0; j < n + 1; j++)
        lrs_clear_mp (p[i][j]);

      free (p[i]);

    }

  free (p);
}

void 
lrs_getdigits (long *a, long *b)
{
/* send digit information to user */
  *a = ZERO;
  *b = ZERO;
  return;
}

void *
xcalloc (long n, long s, long l, char *f)
{
  void *tmp;

  tmp = calloc (n, s);
  if (tmp == 0)
    {
      char buf[200];

      sprintf (buf, "\n\nFatal error on line %ld of %s", l, f);
      perror (buf);
      exit (1);
    }
  return tmp;
}

long 
lrs_mp_init (long dec_digits, FILE * fpin, FILE * fpout)
/* max number of decimal digits for the computation */
/* long int version                                 */
{
  lrs_ifp = fpin;
  lrs_ofp = fpout;
  lrs_record_digits = 0;        /* not used for gmp arithmetic  */
  lrs_digits = 0;		/* not used for gmp arithmetic  */

  lrs_alloc_mp(temp1); lrs_alloc_mp(temp2); lrs_alloc_mp(temp3);
#ifndef LRS_QUIET
  printf(" gmp v.%d.%d",__GNU_MP_VERSION,__GNU_MP_VERSION_MINOR);
#endif
  return TRUE;
}

void lrs_mp_close()
{
   lrs_clear_mp(temp1); lrs_clear_mp(temp2); lrs_clear_mp(temp3);
}

void 
notimpl (char s[])
{
  fflush (stdout);
  fprintf (stderr, "\nAbnormal Termination  %s\n", s);
  exit (1);
}

/***************************************************************/
/*                                                             */
/*     Misc. functions                                         */
/*                                                             */
/***************************************************************/

/* find largest gcd of p[0]..p[n-1] and divide through */
void 
reducearray (lrs_mp_vector p, long n)
{
  lrs_mp divisor;
  long i = 0L;

  while ((i < n) && zero (p[i]))
    i++;
  if (i == n)
    return;

  lrs_alloc_mp (divisor);

  copy (divisor, p[i]);
  storesign (divisor, POS);
  i++;

  while (i < n)
    {
      if (!zero (p[i]))
	{
	  copy (temp1, p[i]);
	  storesign (temp1, POS);
	  gcd (divisor, temp1);
	}
      i++;
    }

  for (i = 0; i < n; i++)
    if (!zero (p[i]))
      reduceint (p[i], divisor);
  lrs_clear_mp (divisor);
}
				/* end of reducearray */


long 
myrandom (long num, long nrange)
/* return a random number in range 0..nrange-1 */

{
  long i;
  i = (num * 401 + 673) % nrange;
  return (i);
}

void 
stringcpy (char *s, char *t)	/*copy t to s pointer version */
{
  while (((*s++) = (*t++)) != '\0');
}

void
linint(lrs_mp a, long ka, lrs_mp b, long kb)
/* a=a*ka+b*kb,  b unchanged */
{

mpz_mul_ui (a,a,labs(ka));
if (ka < 0)
   mpz_neg(a,a);
mpz_mul_ui (temp1,b,labs(kb));
if (kb < 0)
   mpz_neg(temp1,temp1);
mpz_add(a,a,temp1);

}


void
storesign(lrs_mp a, long sa)
{
  if ( (sa)*sign(a) < 0 )
      mpz_neg(a,a);
}

