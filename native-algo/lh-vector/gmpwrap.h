/* gmpwrap.h
 * 13 July 2000
 * wrapper for GMP functions similar to  mp.h
 * Author: Bernhard von Stengel  stengel@maths.lse.ac.uk
 */ 

/* include before:  "gmp.h"	*/

#ifndef GMPWRAP_H
#define GMPWRAP_H

typedef mpz_t  gmpt ;

#define MAXGMPCHARS 500

/* a = b + c 	*/
#define gadd(a, b, c)            mpz_add(a, b, c)
#define gchangesign(a)           mpz_neg((a),(a))
#define gclear(a)                mpz_clear (a) 
#define gexactdivint(a, b, c)    mpz_divexact((c),(a),(b))  
#define ginit(a)                 mpz_init(a) 
/* convert  int  n  to  mp  a 	*/
#define gitomp(n, a)		 mpz_set_si( a , n )
/* a = lcm(a,b)	*/
#define glcm(a, b)               mpz_lcm(a, a, b)
/* convert  mp  a  to decimal string s, must be allocated */
#define gmptoa(a, s)		 mpz_get_str(s, 10, a)
/* c = a * b 	*/
#define gmulint(a, b, c)         mpz_mul((c),(a),(b))
#define gset(a, b)               mpz_set(a, b)    
/* a = b - c 	*/
#define gsub(a, b, c)            mpz_sub(a, b, c)
/* +1 0 -1 depending on sign of  a	*/
#define gsgn(a)                  mpz_sgn(a) 

/* a == 1	*/
#define gone(a)                  (mpz_cmp_si((a), 1) == 0)
/* a == 0	*/
#define gzero(a)                 (mpz_sgn(a) == 0)
/* a > 0	*/
#define gpositive(a)             (mpz_sgn(a) > 0)
/* a < 0	*/
#define gnegative(a)             (mpz_sgn(a) < 0)

/* initialize the 1-dim  array  A  of dimension  n  of  mp's
 * previously allocated with  A = TALLOC(n, gmpt)
 */
#define GINIT(A, n) {int i; \
    for (i=0; i < (n); i++) ginit(A[i]);}
/* clear the 1-dim  array  A  of dimension  n  of  mp's
 * previously initialized with  GINIT(A, n)
 */
#define GCLEAR(A, n) {int i; \
    for (i=0; i < (n); i++) gclear(A[i]);}

/* initialize the 2-dim  nrows x ncols  array  A  of  mp's
 * previously allocated with  T2ALLOC(A, nrows, ncols, gmpt)
 */
#define G2INIT(A, nrows, ncols) {int i, j; \
    for (i=0; i < (nrows); i++) for (j=0; j < (ncols); j++) \
	    ginit(A[i][j]);}
/* clear the 2-dim  nrows x ncols  array  A  of  mp's
 * previously initialized with  G2INIT(A, nrows, ncols)
 */
#define G2CLEAR(A, nrows, ncols) {int i, j; \
    for (i=0; i < (nrows); i++) for (j=0; j < (ncols); j++) \
	    gclear(A[i][j]);}
/* convert  mp a  back to integer in *result,
 * bcomplain:     give warning to stdout if overflow in conversion.
 * return value:  set to 1 if overflow, o/w 0
 */
int gmptoi(gmpt a, int *result, int bcomplain) ; 

/* divide  a  and  b  both by  gcd(a,b)	*/
void greduce(gmpt a, gmpt b);

#endif
