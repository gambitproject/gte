CC = gcc
CFLAGS = -ansi -Wall -O3 -g

path: path.o
	$(CC) path.o $(LDFLAGS) -o path
	
path.o: path.c
	$(CC) path.c -c $(CFLAGS) -o path.o 
	
clean:
	rm -rf path.o path lh-*