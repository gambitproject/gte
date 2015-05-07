/* mp.c
 * 27 Apr 2000
 * Author: Bernhard von Stengel  stengel@maths.lse.ac.uk
 */

#include <stdio.h>
#include <stdlib.h>
        /* atoi()       */
#include <limits.h>
	/* INT_MAX, INT_MIN     */

#include "mp.h"

/*********************/
/*global variables   */
/*********************/
			  
long digits = MAX_DIGITS;          
long record_digits;

int mptoi(mp a, int *result, int bcomplain)
{
    char smp [DIG2DEC(MAX_DIGITS)+2];       /* string to print  mp  into */
    
    mptoa(a, smp);
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


long readrat(mp Na, mp Da) 
	/* read a rational or integer and convert to mp with base BASE */
	/* returns true if denominator is not one                      */
{
  char in[MAXINPUT],num[MAXINPUT],den[MAXINPUT];
  scanf("%s",in);
  atoaa(in,num,den);     /*convert rational to num/dem strings*/
  atomp(num,Na);
  if (den[0]=='\0') 
	{
	itomp(1L,Da);
	return(FALSE);
	}
   atomp(den,Da);
   return(TRUE);
}
void atomp(char s[], mp a)  /*convert string to mp integer*/
{
	mp mpone;
	long diff,ten,i,sig;
	itomp(1L,mpone);
	ten=10L;
	for (i=0; s[i]==' ' || s[i]=='\n' || s[i]=='\t'; i++);
	       /*skip white space*/
	sig=POS;
	if( s[i] == '+' || s[i]=='-' ) /* sign */
	   sig=(s[i++]=='+') ? POS : NEG;
	itomp(0L,a);
	while ( s[i] >= '0' && s[i] <= '9')
	{ diff=s[i] - '0';
	  linint(a,ten,mpone,diff);
	  i++;
	}
	storesign(a,sig);
}  /* end of atomp */

void readmp(mp a)      /* read an integer and convert to mp with base BASE */
{
  long in;
  scanf("%ld",&in);
  itomp(in,a);
}

void itomp(long in, mp a)     /* convert integer i to multiple precision with base BASE */
{
  long i;
  a[0]=2;          /* initialize to zero */
  for(i=1;i<digits;i++) a[i]=0;
  if (in < 0 ) {
		storesign(a,NEG);
		in=in*(-1);
		}
  i=0;
  while (in != 0) {
		   i++;
		   a[i]= in-BASE*(in/BASE);
		   in=in/BASE;
		   storelength(a,i+1);
		   }
}        /* end of itomp  */

void atoaa(char in[], char num[], char den[])  /* convert rational string in to num/den strings*/
{
 long i,j;
 for(i=0;in[i] != '\0' && in[i] != '/';i++) num[i]=in[i];
 num[i]='\0';
 den[0]='\0';
 if (in[i] == '/')
    {
     for(j=0;in[j+i+1] != '\0' ;j++) den[j]=in[i+j+1];
     den[j]='\0';
    }
}               /* end of atoaa */



void prat(char name[],mp Nt,mp Dt)  /*print the long precision rational Nt/Dt  */
{
	long i;
	printf("%s",name);
	if (sign(Nt)==NEG) printf("-");
	printf("%u",Nt[length(Nt)-1]);
	for (i=length(Nt)-2;i>=1;i--) printf(FORMAT,Nt[i]);
	if( !(Dt[0]==2 && Dt[1]==1))  /* rational */
	     { printf("/");
	       if (sign(Dt)==NEG) printf("-");
	       printf("%u",Dt[length(Dt)-1]);
	       for (i=length(Dt)-2;i>=1;i--) printf(FORMAT,Dt[i]);
	      }
	printf(" ");
}

/*  get rid void pimat(long r,long s,mp Nt,char name[])  */
	/* print the long precision integer in row r col s of matrix A */
/* of this {
 int i;
	if (s==0) printf("%s[%d][%d]=",name,B[r],C[s]);
	   else   printf("[%d]=",C[s]);
	if (sign(Nt)==NEG) printf("-");
	printf("%u",Nt[length(Nt)-1]);
		for (i=length(Nt)-2;i>=1;i--) printf(FORMAT,Nt[i]);

}*/

void pmp(char name[],mp a)  /*print the long precision integer a*/
{
	long i;
	printf("%s",name);
	if (sign(a)==NEG) printf("-");
	printf("%u",a[length(a)-1]);
	for (i=length(a)-2;i>=1;i--) printf(FORMAT,a[i]);
}

int mptoa(mp x, char s[])
	/* convert mp integer to string, returning length              */
	/* s  must be sufficiently long to contain result              */
{
int i, pos=0;
if (sign(x)==NEG) 
    pos = sprintf(s, "-");
pos += sprintf(&s[pos], "%u", x[length(x)-1] );
for (i=length(x)-2; i>=1; i--) 
    pos += sprintf(&s[pos], FORMAT, x[i]);
return pos;
}

/*
 *     Package of routines for multiple precision arithmetic
 */

/* returns u=gcd(u,v) destroying v
 * Euclid's algorithm.  Knuth, II, p.320
 * modified to avoid copies r=u,u=v,v=r
 * Switches to single precision when possible for greater speed
 */
void gcd(mp u, mp v)   
{
    mp r;
    unsigned long ul,vl;
    long i;
    static unsigned long maxspval=MAXD; 
	/* Max value for the last digit to guarantee    */
	/* fitting into a single long integer.          */

    static long maxsplen;               
	/* Maximum digits for a number that will fit    */
	/* into a single long integer.                  */

    static long firstime=TRUE;
    
    if(firstime)  /* initialize constants                 */
        {
	for (maxsplen = 2; maxspval >= BASE; maxsplen++)
             maxspval /= BASE;
	firstime=FALSE;
        }
    if(greater(v,u)) goto bigv;
  bigu:
    if(zero(v))
        return;
    if ((i=length(u))<maxsplen || i==maxsplen && u[maxsplen-1]<maxspval)
        goto quickfinish;
    divint(u,v,r);
    normalize(u);

  bigv:
    if (zero(u))
        {
        copy(u,v);
        return;
        }
    if ((i=length(v))<maxsplen || i==maxsplen && v[maxsplen-1]<maxspval)
        goto quickfinish;
    divint (v,u,r);
    normalize(v);
    goto bigu;

  /* Base 10000 only at the moment
   * when u and v are small enough, transfer to single precision integers 
   * and finish with Euclid's algorithm, then transfer back to mp
   */
  quickfinish:
    ul = vl = 0;
    for (i=length(u)-1; i>0; i--)
        ul = BASE*ul + u[i];
    for (i=length(v)-1; i>0; i--)
        vl = BASE*vl+v[i];
    if (ul>vl)
        goto qv;
  qu:
    if (vl==0)
        {
        for (i=1;ul;i++)
            {
            u[i] = ul % BASE ;
            ul = ul / BASE;
            }
        storelength(u,i);
        return;
        }
    ul %= vl;
  qv:
    if (ul==0) 
        {
        for (i=1;vl;i++)
            {
            u[i] = vl % BASE;
            vl = vl / BASE;
            }
        storelength(u,i);
        return;
        }
    vl %= ul;
    goto qu;
}


void reduce(mp Na,mp Da)    /* reduces Na Da by gcd(Na,Da) */
{
    mp Nb,Db,Nc,Dc;
    copy(Nb,Na);
    copy(Db,Da);
    storesign(Nb,POS);
    storesign(Db, POS);
    copy(Nc,Na);
    copy(Dc,Da);
    gcd(Nb,Db); /* Nb is the gcd(Na,Da) */
    divint(Nc,Nb,Na);
    divint(Dc,Nb,Da);
}

void lcm(mp a, mp b)      
	/* a = least common multiple of a, b; b is preserved */
{
    mp u,v;
    copy(u,a);
    copy(v,b);
    gcd(u,v);
    divint(a,u,v);   /* v=a/u   a contains remainder = 0 */
    mulint(v,b,a);
}             /* end of lcm */

long greater(mp a, mp b)  /* tests if a > b and returns (TRUE=POS) */
{
    long i;

    if(a[0] > b[0]) return(TRUE);
    if(a[0] < b[0]) return(FALSE);

    for (i=length(a)-1;i>=1;i--)
        {
        if (a[i] < b[i]) 
            {
            if(sign(a) == POS)
                return 0 ;
            else
                return 1 ;
            }
        if(a[i] > b[i]) 
            {
            if(sign(a) == NEG)
                return 0 ;
            else
                return 1 ;
            }
        }
    return 0 ;
}

void copy(mp a, mp b)   /* assigns a=b  */
{
    long i;
    for (i=0; i<=length(b); i++)
        a[i]=b[i];
}

/* compute a*ka+b*kb --> a
 * Handbook of Algorithms and Data Structures P.239
 */
void linint(mp a,long ka,mp b,long kb) 
{
    long i,la,lb;
    la = length(a);
    lb = length(b);
    for (i=1; i<la; i++)
        a[i] *= ka;
    if (sign(a) != sign(b))
        kb = -kb;
    if (lb>la)
        {
        storelength(a, lb);
	for (i=la; i<lb; i++)
            a[i]=0;
        }
    for (i=1; i<lb; i++)
        a[i] += kb * b[i];
    normalize(a);
}   /* end of linint */

void normalize(mp a)
{
    long cy,i,la;
    la=length(a);
  start:
    cy = 0;
    for (i=1; i<la; i++)
        {
        cy = (a[i] += cy)/BASE;
        a[i] -= cy*BASE;
	if(a[i]<0)
            {
            a[i]+=BASE;
            cy--;
            }
	}
    while(cy>0)
        {
        a[i++]=cy%BASE;
        cy/=BASE;
        }
    if(cy<0)
        {
        a[la-1]+=cy*BASE;
        for (i=1;i<la;i++)
            a[i]= -a[i] ;
        storesign(a, sign(a)==POS ? NEG : POS );
        goto start;
        }
    while (a[i-1]==0 && i>2)
        i--;
    if ( i > record_digits)
        {
        if ( ( record_digits= i  ) > digits)
            digits_overflow(la);
        };
    storelength(a,i);
    if (i==2 && a[1]==0)
        storesign(a,POS);
}  /* end of normalize */

void mulint(mp a,mp b,mp c) /* multiply two integers a*b --> c */
	/***Handbook of Algorithms and Data Structures, p239  ***/
{long nlength,i,j,la,lb;
 /*** b and c may coincide ***/
 la=length(a);
 lb=length(b);
 nlength=la+lb-2;
 if(nlength > digits ) 
  digits_overflow(nlength);

for (i=0;i<la-2;i++) c[lb+i]=0;
for (i=lb-1;i>0;i--) {
	for(j=2;j<la;j++)
		if((c[i+j-1]+=b[i]*a[j]) >
		      MAXD-(BASE-1)*(BASE-1)-MAXD/BASE){
		      c[i+j-1] -= (MAXD/BASE)*BASE;
		      c[i+j] += MAXD/BASE;
		      }
	c[i] = b[i]*a[1];
	}
storelength(c,nlength);
storesign(c,sign(a)==sign(b) ? POS : NEG );
normalize(c);
}  /***end of mulint ***/

long comprod(mp Na,mp Nb,mp Nc,mp Nd)      
	/* +1 if Na*Nb > Nc*Nd  */
	/* -1 if Na*Nb < Nc*Nd  */
	/*  0 if Na*Nb = Nc*Nd  */
{
 mp mc,md;
 mulint(Na,Nb,mc);
 mulint(Nc,Nd,md);
 linint(mc,ONE,md,-ONE);
 if(positive(mc)) return (1);
 if(negative(mc)) return (-1);
 return(0);
}

/********************************************************/
/* Divide two multiple precision integers (c=a/b).      */
/* a is destroyed and contains the remainder on return. */
/* From Knuth Vol.2 SemiNumerical Algorithms            */
/********************************************************/
void divint(mp a, mp b, mp c ) 
	/* c=a/b, a contains remainder on return */
{
  long cy, la, lb, lc, d1, s, t, sig;
  long i, j, qh;
  
/*  figure out and save sign, do everything with positive numbers*/
  sig=sign(a)*sign(b);

  la = length(a);
  lb = length(b);
  lc = la-lb+2;
  if ( la<lb )
  {
    storelength(c,TWO);
    storesign(c,POS);
    c[1] = 0;
    normalize(c);
    return;
  }
  for( i=1; i<lc; i++ ) c[i] = 0;
  storelength(c,lc);
  storesign(c, (sign(a)==sign(b)) ? POS : NEG );

  /******************************/
  /* division by a single word: */
  /*  do it directly            */
  /******************************/

  if( lb==2 ) {
    cy = 0;
    t = b[1];
    for (i=la-1; i>0; i--)  {
      cy = cy*BASE+a[i];
      a[i] = 0;
      cy -= (c[i] = cy/t) * t;
    }
    a[1] = cy;
    storesign(a,(cy==0) ? POS : sign(a));
    storelength(a,TWO);
    /*      set sign of c to sig  (**mod**)            */
    storesign(c,sig);
    normalize(c);
    return;
  }
  else
  {
    /* mp's are actually DIGITS+1 in length, so if length of a or b = */
    /* DIGITS, there will still be room after normalization. */
    /****************************************************/
    /* Step D1 - normalize numbers so b > floor(BASE/2) */
    d1 = BASE/(b[lb-1] + 1);
    if (d1 > 1)
    {
      cy = 0;
      for (i=1;i<la;i++)
      {
	cy = (a[i]=a[i]*d1+cy)/BASE;
	a[i] %= BASE;
      }
      a[i] = cy;
      cy = 0;
      for (i=1;i<lb;i++)
      {
	cy = (b[i]=b[i]*d1+cy)/BASE;
	b[i] %= BASE;
      }
      b[i] = cy;
    }
    else
    {
      a[la] = 0;                /* if la or lb = DIGITS this won't work */
      b[lb] = 0;
    }
    /*********************************************/
    /* Steps D2 & D7 - start and end of the loop */
    for (j = 0;j<=la-lb;j++)
    {
      /*************************************/
      /* Step D3 - determine trial divisor */
      if (a[la-j] == b[lb-1])
	qh = BASE - 1;
      else
      {
	s = (a[la-j]*BASE + a[la-j-1]);
	qh = s/b[lb-1];
	while (qh*b[lb-2] > (s - qh*b[lb-1])*BASE + a[la-j-2])
	  qh--;
      }
      /*******************************************************/
      /* Step D4 - divide through using qh as quotient digit */
      cy = 0;
      for (i=1;i<=lb;i++)
      {
	s = qh*b[i] + cy;
	a[la-j-lb+i] -= s%BASE;
	cy = s/BASE;
	if (a[la-j-lb+i] < 0)
	{
	  a[la-j-lb+i] += BASE;
	  cy++;
	}
      }
      /*****************************************************/
      /* Step D6 - adjust previous step if qh is 1 too big */
      if (cy)
      {
	qh--;
	cy = 0;
	for (i=1;i<=lb;i++)     /* add a back in */
	{
	  a[la-j-lb+i] += b[i] + cy;
	  cy = a[la-j-lb+i]/BASE;
	  a[la-j-lb+i] %= BASE;
	}
      }
      /***********************************************************************/
      /* Step D5 - write final value of qh.  Saves calculating array indices */
      /* to do it here instead of before D6 */
      
      c[la-lb-j+1] = qh;
      
    }
    /**********************************************************************/
    /* Step D8 - unnormalize a and b to get correct remainder and divisor */
    
    for (i=lc;c[i-1]==0 && i>2;i--); /* strip excess 0's from quotient */
    storelength(c,i);
    if(i==2 && c[1]==0) storesign(c,POS);
    cy = 0;
    for (i=lb-1;i>=1;i--)
    {
      cy = (a[i]+=cy*BASE)%d1;
      a[i] /= d1;
    }
    for (i=la;a[i-1]==0 && i>2;i--); /* strip excess 0's from quotient */
    storelength(a,i);
    if(i==2 && a[1]==0) storesign(a,POS);
    if (cy) printf("divide error");
    for (i=lb-1;i>=1;i--)
    {
      cy = (b[i]+=cy*BASE)%d1;
      b[i] /= d1;
    }
  }
}

/***************************************************************/
/*                                                             */
/*  End of package for multiple precision arithmetic           */
/*                                                             */
/***************************************************************/
 
void digits_overflow()
{
  printf("Overflow at digits=%d\n",DIG2DEC(digits));
  exit(1);
}

/***************************************************************/
/*                                                             */
/*     Package of routines for rational arithmetic             */
/*     (Built on top of package for multiprecision arithmetic  */
/*     Not currently used, but may be useful                   */
/***************************************************************/


linrat(Na,Da,ka,Nb,Db,kb,Nc,Dc) 
	/* computes Nc/Dc = ka*Na/Da  +kb* Nb/Db 
	   and reduces answer by gcd(Nc,Dc) */
mp Na,Da,Nb,Db,Nc,Dc;
long ka,kb;
{
mp c;
mulint(Na,Db,Nc);
mulint(Da,Nb,c);
linint(Nc,ka,c,kb);  /* Nc = (ka*Na*Db)+(kb*Da*Nb)  */
mulint(Da,Db,Dc);  /* Dc =  Da*Db           */
reduce(Nc,Dc);
}


divrat(Na,Da,Nb,Db,Nc,Dc) 
	/* computes Nc/Dc = (Na/Da)  / ( Nb/Db )
	   and reduces answer by gcd(Nc,Dc) */
mp Na,Da,Nb,Db,Nc,Dc;
{
mulint(Na,Db,Nc);
mulint(Da,Nb,Dc);
reduce(Nc,Dc);
}
 

mulrat(Na,Da,Nb,Db,Nc,Dc) 
	/* computes Nc/Dc = Na/Da  * Nb/Db
	   and reduces answer by gcd(Nc,Dc) */
mp Na,Da,Nb,Db,Nc,Dc;
{
mulint(Na,Nb,Nc);
mulint(Da,Db,Dc);
reduce(Nc,Dc);
}

/***************************************************************/
/*                                                             */
/*     End package of routines for rational arithmetic         */
/*                                                             */
/***************************************************************/

