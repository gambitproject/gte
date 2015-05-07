/** \file rat.h
 * For the computation of rational numbers. The .h file 
 * includes definitions for use with both mp and gmp. These
 * definitions are seperated with the #ifdef GLEMKE directive
 * to avoid a clash in names.
 *
 * 22 Apr 2000
 * Author: Bernhard von Stengel  stengel@maths.lse.ac.uk
 *
 * Edited: Tobenna Peter, Igwe   ptigwe@gmail.com August 2012.
 */
#ifndef RAT_H
#define RAT_H

#ifdef GLEMKE

#include "gmp.h"
#include "gmpwrap.h"

#endif
#include "mp.h"


#define MAXSTR 100

#ifndef TRUE
#define TRUE 1L
#endif
#ifndef FALSE
#define FALSE 0L
#endif

typedef int Bool;        /* Boolean value 0/1                   */

/**
 * \brief A representation of rational numbers.
 * 
 * A structure which is used to represent rational
 * numbers. The numerator and denominator are
 * stored as a multiple point precision integer
 * using either mp (from mp.h) or gmpt (from gmp.h)
 *
 */
typedef struct /* GSoC12: Tobenna Peter, Igwe (Edited) */
{
	#ifdef GLEMKE
    gmpt        num;    /*!< \brief Numerator. Used if GLEMKE is defined.    */
    gmpt        den;    /*!< \brief Denominator. Used if GLEMKE is defined.  */
	#else
    mp        num;    /*!< \brief Numerator. Used if GLEMKE is not defined.    */
    mp        den;    /*!< \brief Denominator. Used if GLEMKE is not defined.  */
	#endif
}
Rat;

#ifdef GLEMKE

/**
 * \brief Initialise a rational number and returns it.
 * 
 * Creates a Rat and initialises the numerator
 * and denominator. To be used when creating a rational
 * number with gmp.
 * This function is only available if GLEMKE is defined.
 * 
 * \return The initialised Rat structure.
 * \sa grat.c
 */
/* GSoC12: Tobenna Peter, Igwe */
Rat ratinit();

/**
 * \brief Clears the rational number.
 *
 * Clears the contents of the rational number which
 * has gmp type numerator and denominator.
 * 
 * \param rat The rational number to be cleared.
 * \sa grat.c
 */
/* GSoC12: Tobenna Peter, Igwe */
void ratclear(Rat rat);

#endif

/**
 * Creates a rational number from two integers.
 *
 * \param num The numerator.
 * \param den The denominator.
 * \return The rational representation of the two integers
 */
Rat itorat(int num, int den);

/** 
 * Converts integer to a rational number.
 * This is equivalent to calling itorat(i, 1)
 *
 * \param i Integer to be converted
 * \return The equivalent rational number
 * \sa itorat()
 */
Rat ratfromi(int i);

#ifdef GLEMKE

/**
 * Create a rational number from two gmp numbers.
 * The values of numerator and denominator are copied
 * over to a rational structure.
 *
 * \param num The numerator
 * \param den The denominator
 * \return The equivalent rational number
 */
/* GSoC12: Tobenna Peter, Igwe */
Rat gmptorat(gmpt num, gmpt den);

/**
 * Create a rational number from one gmp number.
 *
 * \param a the gmp number to be converted.
 * \return The equivalent rational number.
 */
/* GSoC12: Tobenna Peter, Igwe */
Rat ratfromgmp(gmpt a);

#else

/**
 * Create a rational number from two mp numbers.
 * The values of numerator and denominator are copied
 * over to a rational structure.
 *
 * \param num The numerator
 * \param den The denominator
 * \return The equivalent rational number
 */
/* GSoC12: Tobenna Peter, Igwe */
Rat mptorat(mp num, mp den);

/**
 * Create a rational number from one mp number.
 *
 * \param a the gmp number to be converted.
 * \return The equivalent rational number.
 */
/* GSoC12: Tobenna Peter, Igwe */
Rat ratfrommp(mp a);
#endif

/**
 * Converts an array of characters to a Rat.
 * Parses a string that of the format "x", "x/y" and "x.y"
 * and returns the equivalent rational numbers.
 *
 * \param str The array of charcters.
 * \param info Some information about str, to allow the
 * function print out some information if there was an error.
 * \param j The index of the array it is being read into
 * so the correct information can be displayed if an error occurs.
 */
/* GSoC12: Tobenna Peter, Igwe */
Rat ratfroma(char* str, const char* info, int j);

/** 
 * Returns the normalised sum of a and b.
 *
 * \returns The normalised sum of a and b.
 */
Rat ratadd (Rat a, Rat b);

/**
 * Returns the normalised value of a/b.
 * 
 * \returns The normalise value of a/b
 */
Rat ratdiv (Rat a, Rat b);

/**
 * Returns the normalised value of a*b.
 *
 * \returns The normalised value of a*b
 */
Rat ratmult (Rat a, Rat b);

/**
 * Returns -a. If a is normalised, then -a is normalised otherwise
 * the returned value is not normalised.
 *
 * \returns The value of -a
 */
Rat ratneg (Rat a);

/**
 * Returns the normalised rational number.
 * Normalizes (make den>0, =1 if num==0)
 * and reduces by  gcd(num,den).
 *
 * \param a Rational number to be normalised.
 * \returns The normalised rational number.
 */
Rat ratreduce (Rat a);

/* GSoC12: Tobenna Peter, Igwe */
#ifdef GLEMKE
/** 
 * \brief Computes gcd of two integers.
 * Computes the gcd of a and b, 0 if both 0 and stores the value in c.
 *
 * Note: Used if GLEMKE is defined.
 *
 * \param a First integer.
 * \param b Second integer.
 * \param c Destination to store the value of gcd(a,b)
 */
void ratgcd(gmpt a, gmpt b, gmpt c);
#else
/** 
 * \brief Computes gcd of two integers.
 * Computes the gcd of a and b, 0 if both 0 and stores the value in c.
 *
 * Note: Used if GLEMKE is defined.
 *
 * \param a First integer.
 * \param b Second integer.
 * \param c Destination to store the value of gcd(a,b)
 */
void ratgcd(mp a, mp b, mp c);
#endif

/**
 * Returns the value of 1/a. This is normalised if a is normalised.
 *
 * \param a The rational number
 * \returns The inverse of a
 */
Rat ratinv (Rat a);

/** 
 * Returns Boolean condition that a > b.
 *
 * \returns TRUE if a > b otherwise FALSE
 */
Bool ratgreat (Rat a, Rat b);

/**
 * Returns Boolean condition that a==b. 
 * The values a and b are assumed to be normalized.
 *
 * \returns TRUE if a > b otherwise FALSE
 */
Bool ratiseq (Rat a, Rat b);

/**
 * Returns the maximum element in an array of n rational elements
 *
 * \param rat The array of rational numbers
 * \param n The length of the array rat.
 * \returns The maximum value in rat
 */
/* GSoC12: Tobenna Peter, Igwe */
Rat maxrow(Rat* rat, int n);

/**
 * Returns the maximum element in an mxn matrix of Rat elements.
 *
 * \param rat The matrix of rational numbers
 * \param m   The number of rows
 * \param n   The number of columns
 * \returns   The maximum value in rat
 */
/* GSoC12: Tobenna Peter, Igwe */
Rat maxMatrix(Rat** rat, int m, int n);

/**
 * Converts a rational to a string. 
 * Omit den == 1, s  must be sufficiently long to contain result.
 *
 * \param r The rational number to be converted
 * \param s The array of characters to store the result
 * \returns  The length of the string
 */
int rattoa (Rat r, char *s);

/**
 * Converts a rational to a double. If an overflow occurs, it is
 * reported to the standard output.
 *
 * \param a The rational number to be converted
 * \returns The double value of a
 */
double rattodouble (Rat a);

#endif