CC = gcc
CFLAGS = -Wall -O3 -g

lh-label: lh-label.o
	$(CC) lh-label.o $(LDFLAGS) -o lh-label
	
lh-label.o: lh-label.c
	$(CC) lh-label.c -c $(CFLAGS) -o lh-label.o 

clean:
	rm -rf *.o lh-label lh-label