CC = gcc
CFLAGS = -ansi -Wall -O3 -g

invABdtest: invABdtest.o ../../rat.o ../../alloc.o ../../mp.o
	$(CC) invABdtest.o $(LDFLAGS) -lm ../../rat.o ../../alloc.o ../../mp.o -o invABdtest
	
invABdtest.o: invABdtest.c
	$(CC) invABdtest.c -c $(CFLAGS) -o invABdtest.o 

clean:
	rm -rf *.o invABdtest
