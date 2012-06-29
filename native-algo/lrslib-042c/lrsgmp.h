/* lrsgmp.h       (lrs long integer arithmetic library based on gmp */
/* Copyright: David Avis 2000, avis@cs.mcgill.ca                    */
/* Version 4.0, April 13, 2000                                      */

/* This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */
/******************************************************************************/
/*  See http://cgm.cs.mcgill.ca/~avis/C/lrs.html for lrs usage instructions   */
/******************************************************************************/
/* This package contains the extended precision routines used by lrs
   and some other miscellaneous routines. It is based on gmp
   and this file is derived from lrsmp.h and lrslong.h
*/

#include "gmp.h"

/***********/
/* defines */
/***********/
/*
   this is number of longwords. Increasing this won't cost you that much
   since only variables other than the A matrix are allocated this size.
   Changing affects running time in small but not very predictable ways.
 */

#define MAX_DIGITS 255L

/*
   this is in decimal digits, you pay in memory if you increase this,
   unless you override by a line with
   digits n
   before the begin line of your file.
 */
#define DEFAULT_DIGITS 100L

#ifndef B64
/*32 bit machines */
#define FORMAT "%4.4u"
#define MAXD 2147483647L
#define BASE 10000L
#define BASE_DIG 4
#define INTSIZE 8L
#define BIT "32bit"
#else
/* 64 bit machines */
#define MAXD 9223372036854775807L
#define BASE 1000000000L
#define FORMAT "%9.9u"
#define BASE_DIG 9
#define INTSIZE 16L
#define BIT "64bit"
#endif

#define MAXINPUT 1000           /*max length of any input rational */

#define POS 1L
#define NEG -1L
#ifndef TRUE
#define TRUE 1L
#endif
#ifndef FALSE
#define FALSE 0L
#endif
#define ONE 1L
#define TWO 2L
#define ZERO 0L


/**********************************/
/*         MACROS                 */
/* dependent on mp implementation */
/**********************************/

#define addint(a, b, c)         mpz_add((c),(a),(b))
#define changesign(a)           mpz_neg((a),(a))
#define copy(a, b)              mpz_set(a,b)         
#define decint(a, b)            mpz_sub((a),(a),(b))
#define divint(a, b, c)         mpz_tdiv_qr((c),(a),(a),(b))
#define exactdivint(a, b, c)    mpz_divexact((c),(a),(b))    /*known there is no remainder */          
#define getfactorial(a, b)      mpz_fac_ui( (a), (b))
#define greater(a, b)           (mpz_cmp((a),(b))>0 ? ONE : ZERO)
#define gcd(a,b)                mpz_gcd((a),(a),(b))
#define itomp(in, a)            mpz_set_si( (a) , (in) )
#define mptoi(a)                mpz_get_si( (a) )
#define mptodouble(a)           mpz_get_d ( (a) )
#define mulint(a, b, c)         mpz_mul((c),(a),(b))
#define one(a)                  (mpz_cmp_si((a),ONE) == 0 ? ONE : ZERO)
#define negative(a)             (mpz_sgn(a) < 0 ? ONE : ZERO)
#define normalize(a)            (void) 0
#define positive(a)             (mpz_sgn(a) > 0 ? ONE : ZERO)
#define sign(a)                 (mpz_sgn(a) < 0 ? NEG : POS)
#define subint(a, b, c)         mpz_sub((c),(a),(b))
#define zero(a)                 (mpz_sgn(a) == 0 ? ONE : ZERO)


/*
 *  convert between decimal and machine (longword digits). Notice lovely
 *  implementation of ceiling function :-)
 */
#define DEC2DIG(d) ( (d) % BASE_DIG ? (d)/BASE_DIG+1 : (d)/BASE_DIG)
#define DIG2DEC(d) ((d)*BASE_DIG)

#ifndef OMIT_SIGNALS
#include <signal.h>
#include <stdlib.h>		/* labs */
#include <unistd.h>

#define errcheck(s,e) if ((long)(e)==-1L){  perror(s);exit(1);}
#endif

#ifndef OMIT_TIMES
void ptimes ();
#endif


#define CALLOC(n,s) xcalloc(n,s,__LINE__,__FILE__)

/*************/
/* typedefs  */
/*************/

typedef mpz_t lrs_mp;		/* type lrs_mp holds one long integer    */
typedef mpz_t lrs_mp_t;         /* for GMP same as lrs_mp for MP *lrs_mp */
typedef mpz_t *lrs_mp_vector;
typedef mpz_t **lrs_mp_matrix;

/*********************/
/*global variables   */
/*********************/

extern long lrs_digits;		/* max permitted no. of digits   */
extern long lrs_record_digits;		/* this is the biggest acheived so far.     */

#include <stdio.h>
extern FILE *lrs_ifp;			/* input file pointer       */
extern FILE *lrs_ofp;			/* output file pointer      */

/*********************************************************/
/* Initialization and allocation procedures - must use!  */
/******************************************************* */

long lrs_mp_init (long dec_digits, FILE * lrs_ifp, FILE * lrs_ofp);	/* max number of decimal digits, fps   */
void lrs_mp_close ();

#define lrs_alloc_mp(a)		(mpz_init (a) )
#define lrs_clear_mp(a)		(mpz_clear (a) )
lrs_mp_vector lrs_alloc_mp_vector (long n);	/* allocate lrs_mp_vector for n+1 lrs_mp numbers         */
lrs_mp_matrix lrs_alloc_mp_matrix (long m, long n);	/* allocate lrs_mp_matrix for m+1 x n+1 lrs_mp   */
void lrs_clear_mp_vector (lrs_mp_vector p, long n);	/* clear lrs_mp_vector for n+1 lrs_mp numbers    */
void lrs_clear_mp_matrix (lrs_mp_matrix p, long m, long n); /* clear m by n lrs_mp_matrix                */

/*********************************************************/
/* Core library functions - depend on mp implementation  */
/******************************************************* */
void atomp (const char s[], lrs_mp a);	/* convert string to lrs_mp integer               */
long compare (lrs_mp a, lrs_mp b);	/* a ? b and returns -1,0,1 for <,=,>             */
void linint (lrs_mp a, long ka, lrs_mp b, long kb);     /* compute a*ka+b*kb --> a        */
void pmp (char name[], lrs_mp a);       /* print the long precision integer a             */
void prat (char name[], lrs_mp Nt, lrs_mp Dt);	/* reduce and print  Nt/Dt                */
void readmp (lrs_mp a);		/* read an integer and convert to lrs_mp          */
long readrat (lrs_mp Na, lrs_mp Da);	/* read a rational or int and convert to lrs_mp   */
void reduce (lrs_mp Na, lrs_mp Da);	/* reduces Na Da by gcd(Na,Da)                    */
void storesign(lrs_mp Na, long sa);     /* change sign of Na to sa=POS/NEG                */
/*********************************************************/
/* Standard arithmetic & misc. functions                 */
/* should be independent of mp implementation            */
/******************************************************* */

void atoaa (const char in[], char num[], char den[]);	/* convert rational string in to num/den strings  */
long atos (char s[]);		/* convert s to integer                           */
long comprod (lrs_mp Na, lrs_mp Nb, lrs_mp Nc, lrs_mp Nd);	/* +1 if Na*Nb > Nc*Nd,-1 if Na*Nb > Nc*Nd else 0 */
void divrat (lrs_mp Na, lrs_mp Da, lrs_mp Nb, lrs_mp Db, lrs_mp Nc, lrs_mp Dc);
						       /* computes Nc/Dc = (Na/Da) /( Nb/Db ) and reduce */
void linrat (lrs_mp Na, lrs_mp Da, long ka, lrs_mp Nb, lrs_mp Db, long kb, lrs_mp Nc, lrs_mp Dc);
void lcm (lrs_mp a, lrs_mp b);	/* a = least common multiple of a, b; b is saved  */
void mulrat (lrs_mp Na, lrs_mp Da, lrs_mp Nb, lrs_mp Db, lrs_mp Nc, lrs_mp Dc);
						       /* computes Nc/Dc=(Na/Da)*(Nb/Db) and reduce      */
long myrandom (long num, long nrange);	/* return a random number in range 0..nrange-1    */
void notimpl (char s[]);	/* bail out - help!                               */
void rattodouble (lrs_mp a, lrs_mp b, double *x);	/* convert lrs_mp rational to double              */
void reduceint (lrs_mp Na, lrs_mp Da);	/* divide Na by Da and return it                  */
void reducearray (lrs_mp_vector p, long n);	/* find gcd of p[0]..p[n-1] and divide through by */
void scalerat (lrs_mp Na, lrs_mp Da, long ka);	/* scales rational by ka                          */

/**********************************/
/* Miscellaneous functions        */
/******************************** */

void lrs_getdigits (long *a, long *b);	/* send digit information to user                         */

void stringcpy (char *s, char *t);	/* copy t to s pointer version                            */

#ifndef __STDC__
void *calloc ();
void *malloc ();
#endif

void *xcalloc (long n, long s, long l, char *f);

void lrs_default_digits_overflow ();

/* end of  lrs_mp.h (vertex enumeration using lexicographic reverse search) */
