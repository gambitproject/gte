/** \file col.h
 * Automatic pretty printing in columns.
 * 
 * Author: Bernhard von Stengel  stengel@maths.lse.ac.uk   17 Apr 2000
 */

/** 
 * Number of bytes of buffer to print into.  Buffer will be 
 * printed and flushed if full (not assumed to happen),
 * suffices for one page of text  
 */
#define COLBUFSIZE 30000  
#define ISTR 20 	/**< Number of bytes to print an integer      */

/** 
 * Resetting buffer with c columns.
 * This method is assumed to be called before all other routines.
 *
 * \param c The number of columns to be printed out
 */
void colset(int c);

/** 
 * Print integer into the current column
 *
 * \param i The integer to be printed out
 */
void colipr(int i);

/** 
 * Making column c left-adjusted
 *
 * \param c  index of column in range 0..ncols-1  
 */
void colleft(int c);

/** Terminate current line early, prints blank line if in col  0 */
void colnl(void);

/** Print out the current buffer, without flushing               */
void colout(void);

/** 
 * Store string into the current column.
 * The column width is updated after printing the string.
 *
 * \param s The string to be printed out.
 */
void colpr(const char *s);
