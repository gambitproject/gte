/** 
 * \file alloc.h
 * Memory allocation with error output if fails.
 *
 * Author: Bernhard von Stengel  stengel@maths.lse.ac.uk 17 Apr 2000
 */

/**
 * Allocates n elements of size s
 * @hideinitializer
 */
#define CALLOC(n,s) xcalloc((size_t) n, (size_t) s,__LINE__,__FILE__)

/**
 * Allocates an array of the specified type.
 * @hideinitializer
 */
#define TALLOC(n,type) (type *) xcalloc((size_t) (n), sizeof(type),__LINE__,__FILE__)

/**
 * Allocate a 2-dim (nrows,ncols) array of  type  to ptr
 * Example:  T2ALLOC (sfpay, nseqs[1], nseqs[2], Payvec);
 * necessary type:    Payvec **sfpay;
 * @hideinitializer
 */

#define T2ALLOC(ptr,nrows,ncols,type) {int i; \
    ptr = TALLOC ((nrows), type *);             \
    for (i=0; i < (nrows); i++) ptr[i] = TALLOC ((ncols), type);}

/**
 * Free a 2-dim (nrows) array, usually allocated with T2ALLOC
 * @hideinitializer
 */

#define FREE2(ptr,nrows) {int i; \
    for (i=0; i < nrows; i++) free(ptr[i]); free(ptr);}

/**
 * Allocate  n  objects of size  s,
 * if fails: error noting line  l  and filename  f
 */
void * xcalloc(size_t n, size_t s, int l, char* f);

