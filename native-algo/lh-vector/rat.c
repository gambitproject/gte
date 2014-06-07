/** \file rat.c 
 *
 * For the computation of rational numbers. The rat.c file
 * contains the implementation of the methods defined in rat.h
 * which use mp.
 *
 * 27 Apr 2000
 * Author: Bernhard von Stengel  stengel@maths.lse.ac.uk
 *
 * Edited: Tobenna Peter, Igwe   ptigwe@gmail.com August 2012.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
    /* sprintf	*/
#include "rat.h"

/* Creates a rational number from two integers */
Rat itorat(int num, int den)
{
    Rat r;
    itomp(num, r.num);
    itomp(den, r.den);
    ratreduce(r);
    return r;
}

/* converts integer i to rational */
/* GSoC12: Tobenna Peter, Igwe (Edited)*/
Rat ratfromi(int i)
{
    Rat tmp;
    /*tmp.num = i; */
    itomp(i, tmp.num);
    /*tmp.den = 1; */
    itomp(1, tmp.den);
    return tmp;
}

/* Create a rational number from two mp numbers */
/* GSoC12: Tobenna Peter, Igwe */
Rat mptorat(mp num, mp den)
{
    Rat rat;
    copy(rat.num, num);
    copy(rat.den, den);
    return rat;
}

/* Create a rational number from one mp number */
/* GSoC12: Tobenna Peter, Igwe */
Rat ratfrommp(mp num)
{
    mp den;
    itomp(1, den);
    return mptorat(num, den);
}

/* Parses a string that of the format "x" and "x/y"
* and returns the equivalent rational numbers */
/* GSoC12: Tobenna Peter, Igwe */
    Rat parseRat(char* srat, const char* info, int j)
{
    char snum[MAXSTR], sden[MAXSTR];
    mp num, den;

    atoaa(srat, snum, sden);
    atomp(snum, num);
    if (sden[0]=='\0') 
        itomp(1, den);
    else
    {
        atomp(sden, den);
        if (negative(den) || zero(den))
        {
            char str[MAXSTR];
            mptoa(den, str);
            fprintf(stderr, "Warning: Denominator "); 
            fprintf(stderr, "%s of %s[%d] set to 1 since not positive\n", 
                str, info, j+1);
            itomp(1, den);  
        }
    }
    Rat r = mptorat(num, den);
    return r;
}

/* Parses a string that of the format "x.y"
* and returns the equivalent rational numbers */
/* GSoC12: Tobenna Peter, Igwe */
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
    mp num;
    atomp(str, num);
    /*int den = pow(10, count);*/
    int i;
    strcpy(str, "10");
    for(i = 1; i < count; ++i)
    {
        strcat(str, "0");
    }
    mp den;
    atomp(str, den);

    Rat rat = mptorat(num, den);
    return rat;
}

/* Parses a string that of the format "x", "x/y" and "x.y"
* and returns the equivalent rational numbers */
/* GSoC12: Tobenna Peter, Igwe */
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

/* returns sum  a+b, normalized                         */
/* GSoC12: Tobenna Peter, Igwe (Edited) */
Rat ratadd (Rat a, Rat b)
{
    /*
    a.num = a.num * b.den + a.den * b.num;
    a.den *= b.den;
    return ratreduce(a);
    */

    mp num, den, x, y, t;

    /*itomp (a.num, num) ;*/
    copy(num, a.num);
    /*itomp (a.den, den) ;*/
    copy(den, a.den);
    /*itomp (b.num, x) ;*/
    copy(x, b.num);
    /*itomp (b.den, y) ;*/
    copy(y, b.den);
    mulint (y, num, t);
    copy(num, t);
    mulint (den, x, x);
    linint (num, 1, x, 1);
    mulint (y, den, den);
    reduce(num, den) ;
    /*mptoi( num, &a.num, 1 );
    mptoi( den, &a.den, 1 );*/
    copy(a.num, num);
    copy(a.den, den);
    return a ; 
}

/* returns quotient  a/b, normalized                    */
Rat ratdiv (Rat a, Rat b)
{
    return ratmult(a, ratinv(b) );
}

/* returns product  a*b, normalized                     */
/* GSoC12: Tobenna Peter, Igwe (Edited) */
Rat ratmult (Rat a, Rat b)
{
    mp x;

    /* avoid overflow in intermediate product by cross-cancelling first
    */
    /*x = a.num ; */
    copy(x, a.num);
    /*a.num = b.num ;*/
    copy(a.num, b.num);
    /*b.num = x ;*/
    copy(b.num, x);
    a = ratreduce(a);
    b = ratreduce(b);
    /*a.num *= b.num;*/
    mulint(a.num, b.num, x);
    copy(a.num, x);
    /*a.den *= b.den;*/
    mulint(a.den, b.den, x);
    copy(a.den, x);
    return ratreduce(a);        /* a  or  b  might be non-normalized    s*/
}

/* returns -a, normalized only if a normalized          */
/* GSoC12: Tobenna Peter, Igwe (Edited)*/
Rat ratneg (Rat a)
{
    /*a.num = - a.num;*/
    changesign(a.num);
    return  a;
}

/* normalizes (make den>0, =1 if num==0)
* and reduces by  gcd(num,den)
*/
/* GSoC12: Tobenna Peter, Igwe (Edited) */
Rat ratreduce (Rat a)
{
    if (zero(a.num))
    {
        /*a.den = 1;*/
        itomp(1, a.den);
    }
    else
    {
        mp div;
        mp c;
        if (negative(a.den))
        {
            /*a.den = -a.den;*/
            changesign(a.den);
            /*a.num = -a.num;*/
            changesign(a.num);
        }
        /*div = ratgcd(a.den, a.num);*/
        ratgcd(a.den, a.num, div);
        /*a.num = a.num/div;*/
        divint(a.num, div, c);
        copy(a.num, c);
        /*a.den = a.den/div;*/
        divint(a.den, div, c);
        copy(a.den, c);
    }
    return a;
}

/* computes gcd of integers  a  and  b,  0 if both 0 and stores the value in c*/
void ratgcd(mp a, mp b, mp c)
{
    mp d;
    copy(c, a);
    copy(d, b);
    gcd(c, d);
}

/* GSoC12: Tobenna Peter, Igwe (Edited)*/
Rat ratinv (Rat a)
{
    mp x;

    /*x = a.num ;*/
    copy(x, a.num);
    /*a.num = a.den ;*/
    copy(a.num, a.den);
    /*a.den = x ;*/
    copy(a.den, x);
    return a;
}

/* returns Boolean condition that a > b                 */
Bool ratgreat (Rat a, Rat b)
{
    Rat c = ratadd(a, ratneg(b));
    return (positive(c.num));
}

/* returns Boolean condition that a==b
* a, b are assumed to be normalized
*/
/* GSoC12: Tobenna Peter, Igwe (Edited) */
Bool ratiseq (Rat a, Rat b)
{
    /*return (a.num == b.num && a.den == b.den);*/
    mp c;
    itomp(1, c);
    int x = comprod(a.num, c, b.num, c);
    int y = comprod(a.den, c, b.den, c);
    return ((x == 0) && (y == 0));
}

/* Returns the maximum element in an array of n Rat elements */
/* GSoC12: Tobenna Peter, Igwe */
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
/* GSoC12: Tobenna Peter, Igwe */
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
    /* GSoC12: Tobenna Peter, Igwe */
    mptoa(r.num, str);
    l = sprintf(s, "%s", str);
    if(!one(r.den))
    {
        /*a = sprintf(s+l, "/%d", r.den);*/
        mptoa(r.den, str);
        a = sprintf(s+l, "/%s", str);
        l += a + 1;
    }
    return l;
}

/* converts rational  a  to  double                     */
/* GSoC12: Tobenna Peter, Igwe (Edited) */
double rattodouble(Rat a)
{    
    /*return (double)a.num/(double)a.den*/
    int num, den;
    mptoi(a.num, &num, 1);
    mptoi(a.den, &den, 1);
    return (double)num / (double)den;
}
