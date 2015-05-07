# the file "Depend" must exist for make to run
# for lemke code only

.SUFFIXES:
.SUFFIXES: .c .o .h

CC = gcc
# -lm  links the math library in
CFLAGS = -ansi -Wall -g

LDFLAGS = -lm

GMPLIB = -lgmp

# needed for gmp library
LIBDIR     = /usr/local/lib

%.o : %.c
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@

DEPFILE = Depend

COMOBJ  = alloc.o col.o mp.o

LEMKE   = rat.o equilibrium.o list.o lemke.o

GLEMKE  = gmpwrap.o grat.o glist.o gequilibrium.o glemke.o 

INLEMOBJ  = inlemke.o 

INLHOBJ = inlemkehowson.o

ALLOBJ = $(COMOBJ) $(INLEMOBJ) $(LEMKE) $(GLEMKE) $(INGLEMOBJ) $(INLHOBJ) $(INGLHOBJ)

# local variables for single substitutions

GMP = $(COMOBJ) $(TREEOBJ) $(METHOBJ) $(GMPOBJ) 

INLEMKE = $(COMOBJ) $(LEMKE) $(INLEMOBJ)

INGLEMKE = $(COMOBJ) $(GLEMKE) $(INLEMOBJ)

INLH = $(COMOBJ) $(LEMKE) $(INLHOBJ)

INGLH = $(COMOBJ) $(GLEMKE) $(INLHOBJ)

inlh: $(INLH)
	$(CC) -c $(CFLAGS) $(CPPFLAGS) inlemkehowson.c -o inlemkehowson.o;
	$(CC) $(CFLAGS) $(INLH) $(LDFLAGS) -o inlh

inglh: $(INGLH)
	$(CC) -c  -D GLEMKE $(CFLAGS) $(CPPFLAGS) inlemkehowson.c -o inlemkehowson.o;
	$(CC) $(CFLAGS) $(INGLH) $(LDFLAGS) $(GMPLIB) -o inlh
	
glist.o: list.c
	$(CC) -c -D GLEMKE $(CFLAGS) list.c -o glist.o

inlemke: $(INLEMKE)
	$(CC) $(CFLAGS) $(INLEMKE) -o inlemke
	
inglemke: $(INGLEMKE)
	$(CC) -D GLEMKE $(CFLAGS) $(INGLEMKE) $(GMP) -o inlemke 

doc: Doxyfile
	doxygen

subdir:
	cd path; $(MAKE)
	cd test/identity/; $(MAKE)
	cd test/dualcyclic/dxd/; $(MAKE)
	cd test/invAB; $(MAKE)

depend:: 
	gcc -MM $(ALLOBJ:.o=.c) > $(DEPFILE)

.PHONY : clean cleansubdir doc

cleansubdir:
	cd path; $(MAKE) clean
	cd test/identity/; $(MAKE) clean
	cd test/dualcyclic/dxd/; $(MAKE) clean
	cd test/invAB; $(MAKE) clean

clean:
	-rm -rf doc *.o core *.exe $(DEPFILE); touch $(DEPFILE); make depend

include $(DEPFILE)
