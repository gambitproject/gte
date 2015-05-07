/**
 * \file mp.h
 * 13 July 2000
 * multiprecision routines taken from  lrs 
 * Author: Bernhard von Stengel  stengel@maths.lse.ac.uk
 */ 

/***********/
/* defines */
/***********/

/**********MACHINE DEPENDENT CONSTANTS***********/
/* MAXD is 2^(k-1)-1 where k=16,32,64 word size */
/* MAXD must be at least 2*BASE^2               */
/* If BASE is 10^k, use "%k.ku" for FORMAT      */
/* INTSIZE is number of bytes for integer       */
/* 32/64 bit machines                           */
/***********************************************/
#ifndef MP_H
#define MP_H
#ifndef B64
/*32 bit machines */
#define FORMAT "%4.4u"
#define MAXD 2147483647L
#define BASE 10000L
#define BASE_DIG 4
#define INTSIZE 8L
#define BIT "32"
#else
/* 64 bit machines */
#define MAXD 9223372036854775807L
#define BASE 1000000000L
#define FORMAT "%9.9u"
#define BASE_DIG 9
#define INTSIZE 16L
#define BIT "64"
#endif

#define MAXINPUT 1000  /*max length of any input rational*/

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

/********* MACROS ***********/
#define positive(a)     (((a)[0] < 2 || ((a)[0]==2 && (a)[1]==0))?FALSE:TRUE)
#define negative(a)     (((a)[0] > -2 || ((a)[0]==-2 && (a)[1]==0))?FALSE:TRUE)
#define zero(a)         ((((a)[0]==2 || (a)[0]==-2) && (a)[1]==0)?TRUE:FALSE)
#define one(a)          (((a)[0]==2 && (a)[1]==1)?TRUE:FALSE)
#define length(a)       (((a)[0] > 0) ? (a)[0] : -(a)[0])
#define sign(a)         (((a)[0] < 0) ? NEG : POS)
#define storesign(a,sa) a[0]=((a)[0] > 0) ? (sa)*((a)[0]) : -(sa)*((a)[0])
#define changesign(a)   a[0]= -(a)[0]
#define storelength(a,la) a[0]=((a)[0] > 0) ? (la) : -(la)

/*
   this is in decimal digits, you pay in memory if you increase this,
   unless you override by a line with
   digits n
   before the begin line of your file.
*/
#define DEFAULT_DIGITS 100L

/*
   this is number of longwords. Increasing this won't cost you that much
   since only variables other than the A matrix are allocated this size.
   Changing affects running time in small but not very predictable ways.
*/

/*
#define MAX_DIGITS 255L
#define MAX_DIGITS 50L
*/
#define MAX_DIGITS 40L

/*
 *  convert between decimal and machine (longword digits). Notice lovely
 *  implementation of ceiling function :-)
 */

#define DEC2DIG(d) ( (d) % BASE_DIG ? (d)/BASE_DIG+1 : (d)/BASE_DIG)
#define DIG2DEC(d) ((d)*BASE_DIG)

/*************/
/* typedefs  */
/*************/

typedef long mp[MAX_DIGITS+1]; 
	/* type mp holds one multi-precision integer*/

/* bvs: not yet used */

typedef long * mp_t;
typedef long **mp_array;
typedef long ***mp_matrix;

/*********************/
/*global variables   */
/*********************/
			  
/* max permitted, all checks in mp library assume that
 * A is alloc. to this size
 * - in fact an  mp,  even in  A,  is allocated size  MAX_DIGITS
 * - so set  digits = MAX_DIGITS
 */
extern  long digits;          
/* this is the biggest achieved so far.         */
extern  long record_digits;

/* convert  mp a  back to integer in *result,
 * bcomplain:     give warning to stdout if overflow in conversion.
 * return value:  set to 1 if overflow, o/w 0
 */
int mptoi(mp a, int *result, int bcomplain) ;

/*********************************************************/
/* Miscellaneous -arithmetic,etc should be hidden        */
/* taken from  lrs3.2a,  bvs beautified comments         */
/******************************************************* */

void atoaa(char in[], char num[], char den[]); 
	/**< convert rational string in to num/den strings               */
void atomp(char s[], mp a);         
	/**< convert string to mp integer                                */
long comprod(mp Na,mp Nb,mp Nc,mp Nd);         
	/**< +1 if Na*Nb > Nc*Nd, -1 if Na*Nb < Nc*Nd else 0             */
void copy(mp a, mp b);              
	/**< assigns a=b                                                 */
void divint(mp a, mp b, mp c );      
	/**< c=a/b, a contains remainder on return                       */
void gcd(mp u, mp v);               
	/**< returns u=gcd(u,v) destroying v                             */
long greater(mp a, mp b);           
	/**< tests if a > b and returns (TRUE=POS)                       */
void itomp(long in, mp a);                     
	/**< convert integer i to multiple precision with base BASE      */
void linint(mp a,long ka,mp b,long kb);        
	/**< compute a*ka+b*kb --> a                                     */
void lcm(mp a, mp b);                          
	/**< a = least common multiple of a, b; b is preserved           */
int mptoa(mp a, char s[]);         
	/**< convert mp integer to string, return length                 */
void mulint(mp a,mp b,mp c);                   
	/**< multiply two integers a*b --> c                             */
void normalize(mp a);              
	/**< normalize mp after computation                              */
void pmp(char name[],mp a);                    
	/**< print the long precision integer a                          */
void prat(char name[],mp Nt,mp Dt);            
	/**< print the long precision rational Nt/Dt                     */
void readmp(mp a) ;                            
	/**< read an integer and convert to mp with base BASE            */
long readrat(mp Na, mp Da);                    
	/**< read a rational or integer and convert to mp with base BASE */
void reduce(mp Na,mp Da);          
	/**< reduces Na Da by gcd(Na,Da)                                 */

void digits_overflow();

#endif
/* end of  mp.h  */
