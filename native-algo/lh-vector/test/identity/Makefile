CC = gcc
CFLAGS = -ansi -Wall -O3 -g

all: genidentity genidenpath

genidentity: genidentity.o
	$(CC) genidentity.o $(LDFLAGS) -o genidentity
	
genidentity.o: genidentity.c
	$(CC) genidentity.c -c $(CFLAGS) -o genidentity.o 

genidenpath: genidenpath.o
	$(CC) genidenpath.o $(LDFLAGS) -o genidenpath

genidenpath.o: genidenpath.c
	$(CC) genidenpath.c -c $(CFLAGS) -o genidenpath.o
	
clean:
	rm -rf *.o genidentity genidenpath