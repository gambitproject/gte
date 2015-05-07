/** \file grat.c 
 *
 * For the computation of rational numbers. The grat.c file
 * contains the implementation of the methods defined in rat.h
 * which use gmp.
 *
 * Author: Tobenna Peter, Igwe   ptigwe@gmail.com August 2012.
 */

#define GLEMKE

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
    /* sprintf	*/
#include "rat.h"

/* Initialise a rational number and returns it */
Rat ratinit()
{
    Rat rat;
    ginit(rat.num);
    ginit(rat.den);
    return rat;
}

/* Creates a clone of the given rational number */
Rat ratclone(Rat rat)
{
    Rat r = ratinit();
    gset(r.num, rat.num);
    gset(r.den, rat.den);
    return r;
}

/* Frees the memory occupied by a rational number */
void ratclear(Rat rat)
{
    gclear(rat.num);
    gclear(rat.den);
}

/* Creates a rational number from two integers */
Rat itorat(int num, int den)
{
    Rat r = ratinit();
    gitomp(num, r.num);
    gitomp(den, r.den);
    ratreduce(r);
    return r;
}

/* Returns the equivalent rational number of an integer */
Rat ratfromi(int i)
{
    Rat tmp = ratinit();
    /*tmp.num = i; */
    gitomp(i, tmp.num);
    /*tmp.den = 1; */
    gitomp(1, tmp.den);
    return tmp;
}

Rat gmptorat(gmpt num, gmpt den)
{
    Rat r = ratinit();
    gset(r.num, num);
    gset(r.den, den);
    return r;
}

Rat ratfromgmp(gmpt a)
{
    Rat rat = ratinit();
    gset(rat.num, a);
    gitomp(1, rat.den);
    return rat;
}

/* Parses a string of characters of the format "num" or "num/den" 
* and converts it to a rational number */
    Rat parseRat(char* srat, const char* info, int j)
{
    char snum[MAXSTR], sden[MAXSTR];
    gmpt num, den;
    ginit(num);
    ginit(den);

    atoaa(srat, snum, sden);
    mpz_set_str(num, snum, 10);
    if (sden[0]=='\0') 
        gitomp(1, den);
    else
    {
        mpz_set_str(den, sden, 10);
        if (gnegative(den) || gzero(num))
        {
            char str[MAXSTR];
            gmptoa(den, str);
            fprintf(stderr, "Warning: Denominator "); 
            fprintf(stderr, "%s of %s[%d] set to 1 since not positive\n", 
                str, info, j+1);
            gitomp(1, den);
        }
    }
    Rat r = gmptorat(num, den);
    return r;
}

/* Parses a string of characters of the format "i.d" to the a rational number */
Rat parseDecimal(char* srat, const char* info, int j)
{
    double x;
    int count;
    char* sub;

    sscanf(srat, "%lf", &x);

    sub = strchr(srat, '.');
    if(strchr(sub+1, '.') != NULL)
    {
        fprintf(stderr, "Error: Decimal ");
        fprintf(stderr, "%s of %s[%d] has more than one decimal point\n", srat, info, j);
        exit(1);
    }
    count = strlen(sub+1);

    char* str = strtok(srat, ".");
    strcat(str, strtok(NULL, "."));

    /*int num = floor(x * pow(10, count));*/
    gmpt num;
    mpz_set_str(num, str, 10);

    /*int den = pow(10, count);*/
    int i;
    strcpy(str, "10");
    for(i = 1; i < count; ++i)
    {
        strcat(str, "0");
    }
    gmpt den;
    mpz_set_str(den, str, 10);

    Rat rat = gmptorat(num, den);
    return rat;
}

/* Parses a string that of the format "x", "x/y" and "x.y"
* and returns the equivalent rational numbers */
    Rat ratfroma(char* srat, const char* info, int j)
{
    char* pos;
    Rat rat;

    if((pos = strchr(srat, '.')) != NULL)
    {
        rat = parseDecimal(srat, info, j);
    }
    else
    {
        rat = parseRat(srat, info, j);
    }
    return rat;
}
    /* for improved precision in  ratadd(a, b)	*/
Rat ratadd (Rat a, Rat b)
{
    /*
    a.num = a.num * b.den + a.den * b.num;
    a.den *= b.den;
    return ratreduce(a);
    */

    gmpt num, den, x, y, t;
    Rat c = ratinit();

    ginit(num);
    ginit(den);
    ginit(x);
    ginit(y);
    ginit(t);

    /*itomp (a.num, num) ;*/
    gset(num, a.num);
    /*itomp (a.den, den) ;*/
    gset(den, a.den);
    /*itomp (b.num, x) ;*/
    gset(x, b.num);
    /*itomp (b.den, y) ;*/
    gset(y, b.den);
    gmulint (y, num, t);
    gset(num, t);
    gmulint (den, x, x);

    /*linint (num, 1, x, 1);*/
    gadd(t, num, x);
    gset(num, t);

    gmulint (y, den, den);
    greduce(num, den) ;
    /*mptoi( num, &a.num, 1 );
    mptoi( den, &a.den, 1 );*/
        gset(c.num, num);
    gset(c.den, den);

    gclear(num);
    gclear(den);
    gclear(x);
    gclear(y);
    gclear(t);

    return c ; 
}

/* Returns the value of "a/b" */
Rat ratdiv (Rat a, Rat b)
{
    return ratmult(a, ratinv(b) );
}

/* returns product  a*b, normalized                     */
Rat ratmult (Rat a, Rat b)
{
    Rat a1 = ratclone(a);
    Rat b1 = ratclone(b);
    gmpt x;
    ginit(x);

    /* avoid overflow in intermediate product by cross-cancelling first
    */
    /*x = a.num ; */
    gset(x, a.num);
    /*a.num = b.num ;*/
    gset(a1.num, b.num);
    /*b.num = x ;*/
    gset(b1.num, x);
    a1 = ratreduce(a1);
    b1 = ratreduce(b1);
    /*a.num *= b.num;*/
    gmulint(a1.num, b1.num, x);
    gset(a1.num, x);
    /*a.den *= b.den;*/
    gmulint(a1.den, b1.den, x);
    gset(a1.den, x);

    gclear(x);
    ratclear(b1);
    return ratreduce(a1);        /* a  or  b  might be non-normalized    s*/
}

/* returns -a, normalized only if a normalized          */
Rat ratneg (Rat a)
        /* returns -a                                           */
{
    /*a.num = - a.num;*/
    gchangesign(a.num);
    return  a;
}

/* normalizes (make den>0, =1 if num==0)
* and reduces by  gcd(num,den)
*/
    Rat ratreduce (Rat a)
{
    if (gzero(a.num))
    {
        /*a.den = 1;*/
        gitomp(1, a.den);
    }
    else
    {
        gmpt div;
        gmpt c;
        ginit(div);
        ginit(c);
        if (gnegative(a.den))
        {
            /*a.den = -a.den;*/
            gchangesign(a.den);
            /*a.num = -a.num;*/
            gchangesign(a.num);
        }
        /*div = ratgcd(a.den, a.num);*/
        ratgcd(a.den, a.num, div);
        /*a.num = a.num/div;*/
        gexactdivint(a.num, div, c);
        gset(a.num, c);
        /*a.den = a.den/div;*/
        gexactdivint(a.den, div, c);
        gset(a.den, c);
        gclear(div);
        gclear(c);
    }
    return a;
}

/* Computes the gcd of a and b and stores it in c */
void ratgcd(gmpt a, gmpt b, gmpt c)
{
    gmpt d, e;
    ginit(d);
    ginit(e);

    gset(d, a);
    gset(e, b);
    mpz_gcd(c, d, e);

    gclear(d);
    gclear(e);
}

/* Inverts a rational number */
Rat ratinv (Rat a)
{
    Rat a1 = ratclone(a);

    /*a.num = a.den ;*/
    gset(a1.num, a.den);
    /*a.den = x ;*/
    gset(a1.den, a.num);

    return a1;
}

/* returns Boolean condition that a==b
* a, b are assumed to be normalized
*/
    Bool ratiseq (Rat a, Rat b)
{
    /*return (a.num == b.num && a.den == b.den);*/
    Rat a1 = ratclone(a);
    Rat b1 = ratclone(b);
    Rat c = ratadd(a1, ratneg(b1));

    int i = gzero(c.num);

    ratclear(a1);
    ratclear(b1);
    ratclear(c);
    return i;
}

/* returns Boolean condition that a > b                 */
Bool ratgreat (Rat a, Rat b)
{
    Rat a1 = ratclone(a);
    Rat b1 = ratclone(b);
    Rat c = ratadd(a1, ratneg(b1));

    int i = gpositive(c.num);

    ratclear(a1);
    ratclear(b1);
    ratclear(c);
    return i;
}

/* Returns the maximum element in an array of n Rat elements */
Rat maxrow(Rat* rat, int n)
{
    int i;
    Rat Mrow = ratfromi(0);
    for(i = 0; i < n; ++i)
    {
        Mrow = ratgreat(Mrow,rat[i]) ? Mrow : rat[i];
    }
    return Mrow;
}

/* Returns the maximum element in an mxn matrix of Rat elements */
Rat maxMatrix(Rat** rat, int m, int n)
{
    int i;
    int tmpm = m;
    int tmpn = n;
    Rat M = ratfromi(0);
    for(i = 0; i < tmpm; ++i)
    {
        Rat r = maxrow(rat[i], tmpn);
        M = ratgreat(M, r) ? M : r;
    }
    return M;
}

/* converts rational  r  to string  s, omit den 1
* s  must be sufficiently long to contain result
* returns length of string
*/
int rattoa (Rat r, char *s)
{
    char str[MAXSTR];
    int l, a;
    /*l = sprintf(s, "%d", r.num);*/
    gmptoa(r.num, str);
    l = sprintf(s, "%s", str);
    /*if (r.den != 1)*/
    if(!gone(r.den))
    {
        /*a = sprintf(s+l, "/%d", r.den);*/
        gmptoa(r.den, str);
        a = sprintf(s+l, "/%s", str);
        l += a + 1;
    }
    return l;
}

/* converts rational  a  to  double                     */
double rattodouble(Rat a)
{
    int num, den;
    gmptoi(a.num, &num, 1);
    gmptoi(a.den, &den, 1);
    /*return (double) a.num / (double) a.den ;*/
    return (double)num / (double)den;
}
