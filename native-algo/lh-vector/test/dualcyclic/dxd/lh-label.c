/*  LH-paths on cyclic polytopes 
 *  Bellairs 15 March 2003
 *  LSE 18 March 2003
 *  
 *  options:
 *      -d  #   dimension, must be even
 *      -l  #   only dropping this label (default: all)
 *      -o      output bitstrings (default not)
 */

#include <stdio.h>
#include <ctype.h>	/* isprint()            */
#include <stdlib.h>	/* atoi()       */
#include <getopt.h>
    /* getopt(), optarg, optopt, optind             */

#define MAXD    100   /* max dimension       */
#define MAXN  2*MAXD

/*-------- global variables --------*/
int perm[MAXN];    // permutation of second polytope
int invperm[MAXN]; // inverse permutation
int vertex1[MAXN]; // gale evenness representation of first vertex
int vertex2[MAXN]; // gale evenness representation of second vertex
int parity1[MAXN]; // parity of 1's in first vertex
int parity2[MAXN]; // parity of 2's in first vertex
int d=6;	   // dimension
int n;		   // 2 times dimension, = number of facets
int bout=0;	   // output vertices

void genarteq(void) // generate artificial equilibrium 
{
    int i;
    for (i=0; i<d; i++)
    {
        vertex1[i] = vertex2[d+i] = 1;
        vertex2[i] = vertex1[d+i] = 0;
        parity1[i] = parity2[d+i] = i % 2;
        parity2[i] = parity1[d+i] = 0;  // just for better readability
    }
}

void genperm(void)	// generate relevant permutation
    // example d=6:  0 2 1 4 3 5 | 7 6 9 8 11 10
{
    int i;
    perm[0]=0;
    perm[d-1]=d-1;
    for (i=2; i<d; i+=2)  // first half
    {
        perm[i-1] = i;
        perm[i] = i-1;
    }
    for (i=d; i<n-1; i+=2)  // second half
    {
        perm[i] = i+1;
        perm[i+1] = i;
    }
    for (i=0; i<n; i++)  // inverse permutation
        invperm[perm[i]]=i;
}
void outperm(void) // output permutation
{
    int i;
    for (i=0; i<n; i++)
        printf("%d ", perm[i]+1);
    printf("\n");
    for (i=0; i<n; i++)
        printf("%d ", invperm[i]+1);
    printf("\n");
}

void outbits(int vertex[]) // output vertex, no line feed
{
    int i;
    for (i=0; i<n; i++)
        printf("%1c", vertex[i] ? '@' : '.');
}

int adjvertex(int vertex[], int parity[], int whichbit)
    // generates the next gale evenness vertex
    // when facet with index  whichbit  is left
    // return position of new bit which is  one
{
    int direc, prevparity;
    if (vertex[whichbit]==0)
        printf("not a one in position %d\n", whichbit);
    direc = parity[whichbit]==0 ? 1 : -1;
    vertex[whichbit] = 0; // set current bit to zero
    parity[whichbit] = 0; // clean up
    // gale evenness is repaired by going in correct direction
    // parity must be updated
    while(1)
    {
        whichbit += direc;
        if (whichbit >=n ) whichbit -= n;
        if (whichbit < 0 ) whichbit += n;
    // printf("whichbit %d\n",whichbit);
        if (vertex[whichbit] == 0) break;
        prevparity = parity[whichbit] = 1 - parity[whichbit];
    }
    parity[whichbit] = 1 - prevparity;
    vertex[whichbit] = 1; // set new bit to one 
    return whichbit;
}

void testparity(void)
    // outputs both vertices and their parity:
{
    printf("Vertex 1:\n");
    outbits(vertex1);
    printf("\n");
    outbits(parity1);
    printf("\n");
    /*
    printf("Vertex 2:\n");
    outbits(vertex2);
    printf("\n");
    outbits(parity2);
    printf("\n");
    */
    printf("\n");
}

double lhpath(int droplabel)
    // compute lemke-howson path when dropping label  droplabel
    // return length of path
{
    double length=0.0;  // length of path
    int newlabel;
    if (droplabel < d) // start in vertex 1
    {
        newlabel = invperm[adjvertex(vertex1, parity1, droplabel)];
        if (bout) { outbits(vertex1) ; printf("  "); outbits(vertex2); printf("\n");}
        //	if (bout) { outbits(vertex1); printf("  ");}
        printf("newlabel %d\n", invperm[newlabel]+1);
        length += 1.0;
    }
    else {
        newlabel = invperm[droplabel];  // start in vertex 2 // EDIT BY RAHUL 1 July 2012
        //newlabel = droplabel;  // start in vertex 2
    }
    while(1)
    {
        // vertex 2 to move
        newlabel = perm[adjvertex(vertex2, parity2, newlabel)];
        if (bout) { outbits(vertex1) ; printf("  "); outbits(vertex2); printf("\n");}
        /*if (bout) { outbits(vertex2); printf("\n");}*/
        printf("newlabel %d\n", newlabel+1);
        length += 1.0;
        if (newlabel==droplabel) break;
        // vertex 1 to move
        newlabel = invperm[adjvertex(vertex1, parity1, newlabel)];
        if (bout) { outbits(vertex1) ; printf("  "); outbits(vertex2); printf("\n");}
        //if (bout) { outbits(vertex1); printf("  ");}
        printf("newlabel %d\n", invperm[newlabel]+1);
        length += 1.0;
        //if (newlabel==droplabel) break;
        if (newlabel==invperm[droplabel]) break; // EDIT BY RAHUL 1 July 2012
    }
    if (bout) printf("\n");
    return(length);
}

/*================ main ==============*/
int main(int argc, char *argv[])
{
    int c;
    int dl = -1 ; // droplabel
    /* parse options    */
    while ( (c = getopt (argc, argv, "d:l:o")) != -1)
        switch (c)
    {
        int x; 
        case 'd':
        x = atoi(optarg);
        x = 2*(x/2);
        if (x <= MAXD &&  x > 0 )
            d = x ;
        else
        {
            fprintf(stderr, "Entered dimension %d ", x);
            fprintf(stderr, "not OK.\n");
            return 1;
        }	
        break;
        case 'l':
        dl = atoi(optarg)-1 ;
        if (dl >= 0 && dl < 2*d)
            break;
        fprintf(stderr, "Dropped label %d ", dl);
        fprintf(stderr, "not in range 1 .. %d, not OK.\n", 
            d+1);
        return 1;
        case 'o':
        bout = 1;
        break;
        case '?':
        if (isprint (optopt))
            fprintf (stderr, "Unknown option `-%c'.\n", optopt);
        else
            fprintf (stderr,
            "Unknown option character `\\x%x'.\n",
            optopt);
        return 1;
        default:
        abort ();
    }
    /* options have been input */
    {
        int i , fromlabel, tolabel;
        double l,old =1.0;
        n = 2*d;
        if (dl<0)
            {  fromlabel = 0; tolabel =n;}
        else
            {  fromlabel = dl; tolabel = dl+1;}
        genperm();
        outperm();
        printf("Dimension %2d: \n", d);

        for (i=fromlabel; i<tolabel; i++)
        {
            genarteq();
            l = lhpath(i);
            printf("label %2d: ", i+1);
            printf("iterations %12.0f\n", l);
        }
    }
    return 0;
}
