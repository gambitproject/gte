/* gmp-wrap.c
 * 13 July 2000
 * wrapper for GMP functions similar to  mp.h
 * Author: Bernhard von Stengel  stengel@maths.lse.ac.uk
 */ 

#include <stdio.h>
#include <stdlib.h>
        /* atoi()       */
#include <limits.h>
        /* INT_MAX, INT_MIN     */

#include "gmp.h"
#include "gmpwrap.h"

void greduce(mpz_t a, mpz_t b)
{
    mpz_t tmp;
    mpz_init(tmp);
    mpz_gcd(tmp, a, b);
    mpz_divexact(a, a, tmp);
    mpz_divexact(b, b, tmp);
    mpz_clear(tmp);
}

int gmptoi(mpz_t a, int *result, int bcomplain) 
{
    char smp [MAXGMPCHARS];       /* string to print  mp  into */
    
    gmptoa(a, smp);
    *result = atoi(smp);
    if (*result == INT_MAX || *result == INT_MIN)
    {
        if (bcomplain)
        {
            printf("Warning: Long integer %s ", smp);
            printf("overflown, replaced by %d\n", *result);
        }
        return 1;
    }
    else
        return 0;
}


