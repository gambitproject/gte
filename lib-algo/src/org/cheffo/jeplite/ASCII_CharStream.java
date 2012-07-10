package org.cheffo.jeplite;
/**
 * An implementation of interface CharStream, where the stream is assumed to
 * contain only ASCII characters (without unicode processing).
 */
public final class ASCII_CharStream
{
  public static final boolean staticFlag = false;
  int bufsize;
  int available;
  int tokenBegin;
  public int bufpos = -1;
  private boolean prevCharIsCR = false;
  private boolean prevCharIsLF = false;
  private java.io.Reader inputStream;
  private char[] buffer;
  private int maxNextCharInd = 0;
  private int inBuf = 0;

  private final void ExpandBuff(boolean wrapAround)
  {
     char[] newbuffer = new char[bufsize + 2048];
     try
     {
        if (wrapAround)
        {
           System.arraycopy(buffer, tokenBegin, newbuffer, 0, bufsize - tokenBegin);
           System.arraycopy(buffer, 0, newbuffer,
                                             bufsize - tokenBegin, bufpos);
           buffer = newbuffer;
           maxNextCharInd = (bufpos += (bufsize - tokenBegin));
        }
        else
        {
           System.arraycopy(buffer, tokenBegin, newbuffer, 0, bufsize - tokenBegin);
           buffer = newbuffer;
           maxNextCharInd = (bufpos -= tokenBegin);
        }
     }
     catch (Throwable t)
     {
        throw new Error(t.getMessage());
     }
     bufsize += 2048;
     available = bufsize;
     tokenBegin = 0;
  }

  private final void FillBuff() throws java.io.IOException
  {
     if (maxNextCharInd == available)
     {
        if (available == bufsize)
        {
           if (tokenBegin > 2048)
           {
              bufpos = maxNextCharInd = 0;
              available = tokenBegin;
           }
           else if (tokenBegin < 0)
              bufpos = maxNextCharInd = 0;
           else
              ExpandBuff(false);
        }
        else if (available > tokenBegin)
           available = bufsize;
        else if ((tokenBegin - available) < 2048)
           ExpandBuff(true);
        else
           available = tokenBegin;
     }
     int i;
     try {
        if ((i = inputStream.read(buffer, maxNextCharInd,
                                    available - maxNextCharInd)) == -1)
        {
           inputStream.close();
           throw new java.io.IOException();
        }
        else
           maxNextCharInd += i;
        return;
     }
     catch(java.io.IOException e) {
        --bufpos;
        backup(0);
        if (tokenBegin == -1)
           tokenBegin = bufpos;
        throw e;
     }
  }

  public final char BeginToken() throws java.io.IOException
  {
     tokenBegin = -1;
     char c = readChar();
     tokenBegin = bufpos;
     return c;
  }

  public final char readChar() throws java.io.IOException
  {
     if (inBuf > 0)
     {
        --inBuf;
        return (char)((char)0xff & buffer[(bufpos == bufsize - 1) ? (bufpos = 0) : ++bufpos]);
     }
     if (++bufpos >= maxNextCharInd)
        FillBuff();
     char c = (char)((char)0xff & buffer[bufpos]);
     return (c);
  }

  public final void backup(int amount) {
    inBuf += amount;
    if ((bufpos -= amount) < 0)
       bufpos += bufsize;
  }

  public ASCII_CharStream(java.io.Reader dstream, int startline,
  int startcolumn, int buffersize)
  {
    inputStream = dstream;
    available = bufsize = buffersize;
    buffer = new char[buffersize];
  }

  public ASCII_CharStream(java.io.Reader dstream, int startline,
                                                           int startcolumn)
  {
     this(dstream, startline, startcolumn, 4096);
  }

  public void ReInit(java.io.Reader dstream, int startline,
  int startcolumn, int buffersize)
  {
    inputStream = dstream;
    if (buffer == null || buffersize != buffer.length)
    {
      available = bufsize = buffersize;
      buffer = new char[buffersize];
    }
    prevCharIsLF = prevCharIsCR = false;
    tokenBegin = inBuf = maxNextCharInd = 0;
    bufpos = -1;
  }

  public void ReInit(java.io.Reader dstream, int startline,
                                                           int startcolumn)
  {
     ReInit(dstream, startline, startcolumn, 4096);
  }

  public ASCII_CharStream(java.io.InputStream dstream, int startline,
  int startcolumn, int buffersize)
  {
     this(new java.io.InputStreamReader(dstream), startline, startcolumn, 4096);
  }

  public ASCII_CharStream(java.io.InputStream dstream, int startline,
                                                           int startcolumn)
  {
     this(dstream, startline, startcolumn, 4096);
  }

  public void ReInit(java.io.InputStream dstream, int startline,
  int startcolumn, int buffersize)
  {
     ReInit(new java.io.InputStreamReader(dstream), startline, startcolumn, 4096);
  }

  public void ReInit(java.io.InputStream dstream, int startline,
                                                           int startcolumn)
  {
     ReInit(dstream, startline, startcolumn, 4096);
  }

  public final String GetImage()
  {
     if (bufpos >= tokenBegin)
        return new String(buffer, tokenBegin, bufpos - tokenBegin + 1);
     else
        return new String(buffer, tokenBegin, bufsize - tokenBegin) +
                              new String(buffer, 0, bufpos + 1);
  }

  public void Done()
  {
     buffer = null;
  }
}

