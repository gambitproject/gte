/** 
 * \file alloc.c
 * Memory allocation with error output if fails.
 *
 * Author: Bernhard von Stengel  stengel@maths.lse.ac.uk 17 Apr 2000
 */

#include <stdio.h>
        /* fprintf, stderr      */
#include <stdlib.h>
        /* calloc, free          */
#include "alloc.h"

void * xcalloc(size_t n, size_t s, int l, char* f)
{
    void *tmp;
    tmp = calloc(n, s);
    if (tmp==NULL)
    {
        fprintf(stderr, "Failure to allocate %d objects of %d bytes ", n, s); 
        fprintf(stderr, "on line %d of %s\n", l, f);
        fprintf(stderr, "Emergency stop.\n");
        exit(1);
    }
    return tmp;
}

