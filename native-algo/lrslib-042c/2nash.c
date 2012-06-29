// 2nash.c     v1.0  Jan 15, 2009

// Hack of nlrs.c by Conor Meagher to run lrs simultaneously on n processors for n input files
// runs nash on input files A B in both orders simultaneously, terminating when first proc finishes
// output goes in third argument if any, else in file: out

#include <sys/wait.h>
       #include <stdlib.h>
       #include <unistd.h>
       #include <stdio.h>

       int main(int argc, char *argv[])
	       {
                  pid_t cpid[argc - 1], w;
		  char buffer [250];	
                  int status,l,j;
                  if (argc < 3 || argc > 4) {
                      printf("Usage: 2nash A B [outfile]\n");
                      return(0);
                      }
		  for(l = 1; l < 3; l++) {  
	              cpid[l -1] = fork();
	              if (cpid[l -1] == -1) {
		          perror("fork");
		          exit(EXIT_FAILURE);
		      }
		      if(cpid[l-1] == 0) {
			 //forked threads
			// n= sprintf(buffer, "lrs %s > out%i", argv[l], l);
                         if(l==1) {
                              int n= sprintf(buffer, "nash %s %s > out%i", argv[1], argv[2], l);
                         }
                         else     {
                              int n= sprintf(buffer, "nash %s %s > out%i", argv[2], argv[1], l);
                         }

			 int i=system(buffer);
                          _exit(0);
		      }
		  }
		  // main thread
		  w = wait(&status);
		  for(j = 1; j < 3; j++) {
		      if(w == cpid[j-1]) {
			  // this child finished first
                          if(j==1)
			      printf("nash %s %s   finished first\n", argv[1], argv[2]);
                          else {
			      printf("nash %s %s   finished first\n", argv[2], argv[1]);
			      printf("player numbers will be reversed in output\n");
                               }
                           if(argc == 4) {
			       printf("output file: %s\n", argv[3]);
			       int n = sprintf(buffer, "/bin/mv -f out%i %s", j, argv[3]);
                           }
                           else  {
			        printf("output file: out\n", argv[2], argv[1]);
			        int n = sprintf(buffer, "/bin/mv -f out%i out", j);
                           }
			  int i = system(buffer);
		      } else {
			  int n = sprintf(buffer, "/bin/rm -f out%i", j);
			  int i = system(buffer);
		      }
		  }
		  printf("the other process will be ");   /*...will be killed */
                  fflush(stdout);
		  kill(0,9);

exit(EXIT_SUCCESS);
}
