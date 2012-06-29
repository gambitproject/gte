
/* buffer.c     Reads standard input and builds a circular buffer of maxbuffer lines        */
/* input line should have max length maxline and is printed only if it is not in the buffer */
/* calling arguments:    maxline maxbuffer                                          */
/* defaults:                5000        50                                          */
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#define MAXBUFFER 5000 /*max number of lines in buffer */
char *line;

int maxline;
int Getline(void);
void notimpl(char s[]);

int
main(int argc, char *argv[])
{
        extern int maxline;
        extern char *line;
	int i;
        int bufsize;
        int next;
        int count, counton;
        char *c;
        char *buffer [MAXBUFFER];
        int maxbuffer=50;
        void *calloc();

        maxline=5000;
/* allocate space for buffer */
        if (argc >= 2 ) maxline=atoi(argv[1])+2;   /* allow for \n and \0 */
        if (maxline <= 2 ) notimpl("line length must be greater than zero");
        if (argc >= 3 ) maxbuffer=atoi(argv[2]);
        if (maxbuffer <= 0 ) notimpl("buffer length must be greater than zero");
        for(i=0;i<maxbuffer;i++) buffer[i]=calloc(maxline,sizeof(char));
	line=calloc(maxline,sizeof(char));

	next= -1;     /*next location to write in buffer*/
	bufsize= -1;  /*upper index of buffer size*/
        count=-1;     /* count lines output "begin" before "end" minus 1*/
        counton=0;
	while ( Getline() > 0 )
	{
		i=0;
                if(strncmp(line,"end",3)==0) counton=0;
                while ( i <= bufsize && (strcmp(line,buffer[i])) != 0 )
			i++;
		if ( i > bufsize )         /* write out line and put in buffer */
		{
			next++;
			if ( next > maxbuffer-1 ) next=0;
                        if ( bufsize < maxbuffer-1 ) bufsize++;
			c=strcpy(buffer[next],line);
			printf("%s",line);
                        if(counton)count++;
		}
                if(strncmp(line,"begin",5)==0) counton=1;
	}
        printf("\n*Number of output lines between begin/end = %d",count);
        if(count > maxbuffer ) 
             printf("\n*Buffer size of %d lines exceeded-some duplicates may remain",maxbuffer);
         else
             printf("\n*All duplicates removed");

        printf("\n");
	return 0;
}

/* getline from KR P.32 */
int Getline(void)
{
	int c,i;
	extern int maxline;
        extern char *line;

	for (i=0;i<maxline-1
              && (c=getchar()) != EOF && c != '\n'; ++i)
		line[i]=c;

        if (i == maxline-1 ) {
             fprintf(stderr,"\n%s ",line);
             fprintf(stderr,"\nmaximum line length = %d ",maxline-2);
             notimpl("maximum line length exceded");
        }
	if (c == '\n' )  {
		line[i]=c;
		++i;
	}
	line[i]= '\0';
	return i;
}	
void notimpl( char s[])
{fprintf(stderr,"\n%s\n",s);
 exit(1);
}
