# Makefile for lrslib including lrs and redund 
# 2008.1.15
#
# choose one of the first 4 and gmp if applicable - see README
#
# make all      normal version for 32bit machines with timing/signals handling
# make all64    for machines with 64bit integers, eg. DEC Alpha
# make ansi     ansi standard version for 32bit machines without signals handling
# make nosigs   ansi standard version for 32bit machines without timing/signals handling

# make demo     compile the demo programs (vanilla machine)

# make gmp      uses gmp arithmetic, set paths for include files *first*

# make clean    to clean all executables


#Select one of the following INCLUDE,LIB paths only needed for gmp version

#linux at mcgill with gmp version 3
INCLUDEDIR = /usr/local/include
LIBDIR     = /usr/local/lib


#linux at mcgill with gmp version 2
#INCLUDEDIR = /labs/cgm/gmp2/include
#LIBDIR     = /labs/cgm/gmp2/lib


all:	lrs.c lrslib.c lrslib.h lrsmp.c lrsmp.h lrslong.c lrslong.h redund.c buffer.c nash.c 2nash.c 
	gcc-3 -O3 -DTIMES -DSIGNALS -o lrs  lrs.c lrslib.c lrsmp.c
	gcc-3 -O3 -DTIMES -DSIGNALS -o redund  redund.c lrslib.c lrsmp.c
	gcc-3 -O3 -DTIMES -DSIGNALS -DLONG -o lrs1  lrs.c lrslib.c lrslong.c
	gcc-3 -O3 -DTIMES -DSIGNALS -DLONG -o redund1  redund.c lrslib.c lrslong.c
	gcc-3 -O3 -DLRS_QUIET  -DTIMES -DSIGNALS -o nash nash.c lrslib.c lrsmp.c
	gcc-3 -O3 -DLRS_QUIET  -DTIMES -DSIGNALS -o prepare_nash prepare_nash.c lrslib.c lrsmp.c
	gcc-3 -O3 -o setupnash setupnash.c lrslib.c lrsmp.c
	gcc-3 -O3 -o setupnash2 setupnash2.c lrslib.c lrsmp.c
	gcc-3 -Wall -O3 -o fourier  fourier.c lrslib.c lrsmp.c
	gcc-3 -O3 -o buffer buffer.c
	gcc-3 -O3 -o 2nash 2nash.c

gmp:	fourier.c 2gnash.c lrs.c redund.c lrslib.h lrslib.c lrsgmp.h lrsgmp.c nash.c
	gcc-3 -O3 -static -DTIMES -DSIGNALS  -DGMP -I${INCLUDEDIR} lrs.c lrslib.c lrsgmp.c -L${LIBDIR}  -lgmp -o glrs
	gcc-3 -O3 -static -DTIMES -DSIGNALS -DGMP -I${INCLUDEDIR} redund.c lrslib.c lrsgmp.c -L${LIBDIR} -lgmp -o gredund
	gcc-3 -O3 -static -DLRS_QUIET -DTIMES -DSIGNALS -DGMP -I${INCLUDEDIR} nash.c lrslib.c lrsgmp.c -L${LIBDIR} -lgmp -o gnash
	gcc-3 -O3 -static -DTIMES -DSIGNALS  -DGMP -I${INCLUDEDIR} fourier.c lrslib.c lrsgmp.c -L${LIBDIR}  -lgmp -o gfourier
	gcc-3 -O3 -o buffer buffer.c
	gcc-3 -O3 -o 2gnash 2gnash.c
	gcc-3 -O3 -static -DTIMES -DSIGNALS  -DGMP -I${INCLUDEDIR} fourier.c lrslib.c lrsgmp.c -L${LIBDIR}  -lgmp -o gfourier
gnash:	lrslib.h lrslib.c lrsgmp.h lrsgmp.c nash.c 2gnash.c
	gcc-3 -O3 -static -DLRS_QUIET -DTIMES -DSIGNALS -DGMP -I${INCLUDEDIR} nash.c lrslib.c lrsgmp.c -L${LIBDIR} -lgmp -o gnash
	gcc-3 -O3 -o 2gnash 2gnash.c

all64:	lrs.c lrslib.c lrslib.h lrsmp.c lrsmp.h lrslong.c lrslong.h redund.c buffer.c
	gcc-3 -DTIMES -DSIGNALS -DB64 -O3 -o lrs  lrs.c lrslib.c lrsmp.c
	gcc-3 -DTIMES -DSIGNALS -DB64 -O3 -o redund  redund.c lrslib.c lrsmp.c
	gcc-3 -DTIMES -DSIGNALS -DLONG -DB64 -O3 -o lrs1  lrs.c lrslib.c lrslong.c
	gcc-3 -DTIMES -DSIGNALS -DLONG -DB64 -O3 -o redund1  redund.c lrslib.c lrslong.c
	gcc-3 -O3 -o buffer buffer.c

ansi:	lrs.c lrslib.c lrslib.h lrsmp.c lrsmp.h lrslong.c lrslong.h redund.c buffer.c nash.c
	gcc-3 -ansi -DTIMES   -O3 -o lrs  lrs.c lrslib.c lrsmp.c
	gcc-3 -ansi -DTIMES   -O3 -o redund redund.c lrslib.c lrsmp.c
	gcc-3 -ansi -DTIMES  -DLONG  -O3 -o lrs1  lrs.c lrslib.c lrslong.c
	gcc-3 -ansi -DTIMES  -DLONG  -O3 -o redund1 redund.c lrslib.c lrslong.c
	gcc-3 -O3 -o buffer buffer.c
	gcc-3 -Wall -ansi -O3 -o nash nash.c lrslib.c lrsmp.c

nosigs:	lrs.c lrslib.c lrslib.h lrsmp.c lrsmp.h lrslong.c lrslong.h redund.c buffer.c
	gcc-3 -ansi  -O3 -o lrs  lrs.c lrslib.c lrsmp.c
	gcc-3 -ansi  -O3 -o redund redund.c lrslib.c lrsmp.c
	gcc-3 -ansi  -O3 -DLONG -o lrs1  lrs.c lrslib.c lrslong.c
	gcc-3 -ansi  -O3 -DLONG -o redund1 redund.c lrslib.c lrslong.c
	gcc-3 -ansi -O3 -o buffer buffer.c

lrs:    lrs.c lrslib.c lrslong.c lrsmp.c
	gcc-3 -Wall -ansi -O3 -o lrs  lrs.c lrslib.c lrsmp.c

redund:    redund.c lrslib.c lrslong.c lrsmp.c
	gcc-3 -Wall -ansi -O3 -o redund redund.c lrslib.c lrsmp.c

nash:    setupnash2.c setupnash.c nash.c lrslib.c  lrsmp.c 2nash.c
	gcc-3 -Wall -DTIMES -ansi -O3 -o nash nash.c lrslib.c lrsmp.c
	gcc-3 -Wall -o setupnash setupnash.c lrslib.c lrsmp.c
	gcc-3 -Wall -o setupnash2 setupnash2.c lrslib.c lrsmp.c
	gcc-3 -O3 -o 2nash 2nash.c

fourier:    fourier.c lrslib.c lrslong.c lrsmp.c
	gcc-3 -Wall -O3 -o fourier  fourier.c lrslib.c lrsmp.c
	gcc-3 -O3 -static -DTIMES -DSIGNALS  -DGMP -I${INCLUDEDIR} fourier.c lrslib.c lrsgmp.c -L${LIBDIR}  -lgmp -o gfourier

demo:	lpdemo.c chdemo.c vedemo.c lrslib.c lrslong.c lrsmp.c
	gcc-3 -Wall -ansi -O3 -o lpdemo lpdemo.c lrslib.c lrsmp.c
	gcc-3 -Wall -ansi -O3 -o vedemo vedemo.c lrslib.c lrsmp.c
	gcc-3 -Wall -ansi -O3 -o chdemo chdemo.c lrslib.c lrsmp.c

float: float2rat.c rat2float.c lrsmp.c 
	gcc-3 -DLRSMP -Wall -ansi -o float2rat float2rat.c lrsmp.c
	gcc-3 -DLRSMP -Wall -ansi -o rat2float rat2float.c lrsmp.c

clean:
	rm -rf lrs lrs1 redund redund1 buffer glrs gredund
	rm -rf foo gfoo
	rm -rf lpdemo vedemo chdemo
	rm -rf fourier gfourier                   
	rm -rf nash gnash setupnash setupnash2

foo:	foo.c lrslib.h lrslib.c lrsmp.h lrsmp.c
	gcc-3 -O3 -static -DTIMES -DSIGNALS  foo.c lrslib.c lrsmp.c -L${LIBDIR} -o foo

gfoo:	foo.c lrslib.h lrslib.c lrsgmp.h lrsgmp.c
	gcc-3 -O3 -static -DTIMES -DSIGNALS  -DGMP -I${INCLUDEDIR} foo.c lrslib.c lrsgmp.c -L${LIBDIR}  -lgmp -o gfoo

