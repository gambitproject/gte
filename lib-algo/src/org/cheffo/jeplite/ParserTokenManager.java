package org.cheffo.jeplite;
import java.util.Vector;
import org.cheffo.jeplite.function.*;
import java.io.*;

public class ParserTokenManager implements ParserConstants
{
private final int jjStopStringLiteralDfa_0(int pos, long active0)
{
   switch (pos)
   {
      default :
         return -1;
   }
}
private final int jjStartNfa_0(int pos, long active0)
{
   return jjMoveNfa_0(jjStopStringLiteralDfa_0(pos, active0), pos + 1);
}
private final int jjStopAtPos(int pos, int kind)
{
   jjmatchedKind = kind;
   jjmatchedPos = pos;
   return pos + 1;
}
private final int jjStartNfaWithStates_0(int pos, int kind, int state)
{
   jjmatchedKind = kind;
   jjmatchedPos = pos;
   try { curChar = input_stream.readChar(); }
   catch(IOException e) { return pos + 1; }
   return jjMoveNfa_0(state, pos + 1);
}
private final int jjMoveStringLiteralDfa0_0()
{
   switch(curChar)
   {
      case 33:
         jjmatchedKind = 12;
         return jjMoveStringLiteralDfa1_0(0x20000L);
      case 37:
         return jjStopAtPos(0, 23);
      case 38:
         return jjMoveStringLiteralDfa1_0(0x400L);
      case 40:
         return jjStopAtPos(0, 25);
      case 41:
        return jjStopAtPos(0, 26);
      case 42:
         return jjStopAtPos(0, 21);
      case 43:
         return jjStopAtPos(0, 19);
      case 44:
         return jjStopAtPos(0, 27);
      case 45:
         return jjStopAtPos(0, 20);
      case 47:
         return jjStopAtPos(0, 22);
      case 60:
         jjmatchedKind = 13;
         return jjMoveStringLiteralDfa1_0(0x8000L);
      case 61:
         return jjMoveStringLiteralDfa1_0(0x40000L);
      case 62:
         jjmatchedKind = 14;
         return jjMoveStringLiteralDfa1_0(0x10000L);
      case 91:
         return jjStopAtPos(0, 28);
      case 93:
         return jjStopAtPos(0, 29);
      case 94:
         return jjStopAtPos(0, 24);
      case 124:
         return jjMoveStringLiteralDfa1_0(0x800L);
      default :
         return jjMoveNfa_0(0, 0);
   }
}

private final int jjMoveStringLiteralDfa1_0(long active0)
{
   try {curChar = input_stream.readChar();}
   catch(IOException e) {
      jjStopStringLiteralDfa_0(0, active0);
      return 1;
   }
   switch(curChar)
   {
      case 38:
         if ((active0 & 0x400L) != 0L)
            return jjStopAtPos(1, 10);
         break;
      case 61:
         if ((active0 & 0x8000L) != 0L)
            return jjStopAtPos(1, 15);
         else if ((active0 & 0x10000L) != 0L)
            return jjStopAtPos(1, 16);
         else if ((active0 & 0x20000L) != 0L)
            return jjStopAtPos(1, 17);
         else if ((active0 & 0x40000L) != 0L)
            return jjStopAtPos(1, 18);
         break;
      case 124:
         if ((active0 & 0x800L) != 0L)
            return jjStopAtPos(1, 11);
         break;
     default :
         break;
   }
   return jjStartNfa_0(0, active0);
}

private final void jjCheckNAdd(int state)
{
   if (jjrounds[state] != jjround)
   {
      jjstateSet[jjnewStateCnt++] = state;
      jjrounds[state] = jjround;
   }
}
private final void jjAddStates(int start, int end)
{
   do {
      jjstateSet[jjnewStateCnt++] = jjnextStates[start];
   } while (start++ != end);
}
private final void jjCheckNAddTwoStates(int state1, int state2)
{
   jjCheckNAdd(state1);
   jjCheckNAdd(state2);
}
private final void jjCheckNAddStates(int start, int end)
{
   do {
      jjCheckNAdd(jjnextStates[start]);
   } while (start++ != end);
}
private final void jjCheckNAddStates(int start)
{
   jjCheckNAdd(jjnextStates[start]);
   jjCheckNAdd(jjnextStates[start + 1]);
}
static final long[] jjbitVec0 = {
   0x0L, 0x0L, 0xffffffffffffffffL, 0xffffffffffffffffL
};

private final int jjMoveNfa_0(int startState, int curPos)
{
   int[] nextStates;
   int startsAt = 0;
   jjnewStateCnt = 28;
   int i = 1;
   jjstateSet[0] = startState;
   int j, kind = 0x7fffffff;
   for (;;)
   {
      if (++jjround == 0x7fffffff)
         ReInitRounds();
      if (curChar < 64)
      {
         long l = 1L << curChar;
         MatchLoop: do
         {
            switch(jjstateSet[--i])
            {
               case 0:
                  if ((0x3ff000000000000L & l) != 0L)
                  {
                     if (kind > 2)
                       kind = 2;
                     jjCheckNAddStates(0, 4);
                  }
                 else if (curChar == 34)
                     jjCheckNAddStates(5, 7);
                  else if (curChar == 46)
                     jjCheckNAdd(1);
                  break;
               case 1:
                if ((0x3ff000000000000L & l) == 0L)
                     break;
                  if (kind > 4)
                     kind = 4;
                  jjCheckNAddTwoStates(1, 2);
                break;
               case 3:
                  if ((0x280000000000L & l) != 0L)
                    jjCheckNAdd(4);
                  break;
               case 4:
                if ((0x3ff000000000000L & l) == 0L)
                     break;
                  if (kind > 4)
                     kind = 4;
                  jjCheckNAdd(4);
                  break;
               case 5:
                  if (curChar == 34)
                     jjCheckNAddStates(5, 7);
                  break;
               case 6:
                  if ((0xfffffffbffffdbffL & l) != 0L)
                   jjCheckNAddStates(5, 7);
                  break;
               case 8:
                  if ((0x8400000000L & l) != 0L)
                     jjCheckNAddStates(5, 7);
                  break;
               case 9:
                  if (curChar == 34 && kind > 6)
                     kind = 6;
                  break;
               case 10:
                  if ((0xff000000000000L & l) != 0L)
                     jjCheckNAddStates(8, 11);
                  break;
               case 11:
                  if ((0xff000000000000L & l) != 0L)
                     jjCheckNAddStates(5, 7);
                  break;
               case 12:
                  if ((0xf000000000000L & l) != 0L)
                     jjstateSet[jjnewStateCnt++] = 13;
                  break;
               case 13:
                  if ((0xff000000000000L & l) != 0L)
                     jjCheckNAdd(11);
                  break;
               case 15:
                  if ((0x3ff000000000000L & l) == 0L)
                     break;
                  if (kind > 7)
                     kind = 7;
                  jjstateSet[jjnewStateCnt++] = 15;
                  break;
               case 16:
                  if ((0x3ff000000000000L & l) == 0L)
                     break;
                  if (kind > 2)
                     kind = 2;
                  jjCheckNAddStates(0, 4);
                  break;
               case 17:
                  if ((0x3ff000000000000L & l) == 0L)
                     break;
                  if (kind > 2)
                     kind = 2;
                  jjCheckNAdd(17);
                  break;
               case 18:
                  if ((0x3ff000000000000L & l) != 0L)
                     jjCheckNAddTwoStates(18, 19);
                  break;
               case 19:
                  if (curChar != 46)
                     break;
                  if (kind > 4)
                     kind = 4;
                  jjCheckNAddTwoStates(20, 21);
                  break;
               case 20:
                  if ((0x3ff000000000000L & l) == 0L)
                     break;
                  if (kind > 4)
                     kind = 4;
                  jjCheckNAddTwoStates(20, 21);
                 break;
             case 22:
                  if ((0x280000000000L & l) != 0L)
                     jjCheckNAdd(23);
                  break;
               case 23:
                  if ((0x3ff000000000000L & l) == 0L)
                     break;
                  if (kind > 4)
                     kind = 4;
                  jjCheckNAdd(23);
                  break;
               case 24:
                if ((0x3ff000000000000L & l) != 0L)
                     jjCheckNAddTwoStates(24, 25);
                  break;
               case 26:
                  if ((0x280000000000L & l) != 0L)
                     jjCheckNAdd(27);
                  break;
               case 27:
                  if ((0x3ff000000000000L & l) == 0L)
                     break;
                  if (kind > 4)
                     kind = 4;
                  jjCheckNAdd(27);
                  break;
               default : break;
            }
         } while(i != startsAt);
      }
      else if (curChar < 128)
      {
         long l = 1L << (curChar & 077);
         MatchLoop: do
         {
            switch(jjstateSet[--i])
            {
               case 0:
               case 15:
                  if ((0x7fffffe87fffffeL & l) == 0L)
                     break;
                  if (kind > 7)
                     kind = 7;
                  jjCheckNAdd(15);
                  break;
               case 2:
                  if ((0x2000000020L & l) != 0L)
                     jjAddStates(12, 13);
                  break;
               case 6:
                  if ((0xffffffffefffffffL & l) != 0L)
                     jjCheckNAddStates(5, 7);
                  break;
               case 7:
                  if (curChar == 92)
                     jjAddStates(14, 16);
                  break;
               case 8:
                  if ((0x14404410000000L & l) != 0L)
                     jjCheckNAddStates(5, 7);
                  break;
               case 21:
                  if ((0x2000000020L & l) != 0L)
                     jjAddStates(17, 18);
                  break;
               case 25:
                  if ((0x2000000020L & l) != 0L)
                     jjAddStates(19, 20);
                  break;
               default : break;
            }
         } while(i != startsAt);
      }
      else
      {
         int i2 = (curChar & 0xff) >> 6;
         long l2 = 1L << (curChar & 077);
         MatchLoop: do
         {
            switch(jjstateSet[--i])
            {
               case 6:
                  if ((jjbitVec0[i2] & l2) != 0L)
                     jjAddStates(5, 7);
                  break;
               default : break;
            }
         } while(i != startsAt);
      }
      if (kind != 0x7fffffff)
      {
         jjmatchedKind = kind;
         jjmatchedPos = curPos;
         kind = 0x7fffffff;
      }
      ++curPos;
      if ((i = jjnewStateCnt) == (startsAt = 28 - (jjnewStateCnt = startsAt)))
         return curPos;
      try { curChar = input_stream.readChar(); }
      catch(IOException e) { return curPos; }
   }
}

static final int[] jjnextStates = {
   17, 18, 19, 24, 25, 6, 7, 9, 6, 7, 11, 9, 3, 4, 8, 10,
   12, 22, 23, 26, 27,
};
public static final String[] jjstrLiteralImages = {
"", null, null, null, null, null, null, null, null, null, "\46\46",
"\174\174", "\41", "\74", "\76", "\74\75", "\76\75", "\41\75", "\75\75", "\53", "\55",
"\52", "\57", "\45", "\136", "\50", "\51", "\54", "\133", "\135", };
public static final String[] lexStateNames = {
   "DEFAULT",
};
static final long[] jjtoToken = {
   0x3ffffcd5L,
};
static final long[] jjtoSkip = {
   0x2L,
};
private ASCII_CharStream input_stream;
private final int[] jjrounds = new int[28];
private final int[] jjstateSet = new int[56];
protected char curChar;
public ParserTokenManager(ASCII_CharStream stream)
{
   if (ASCII_CharStream.staticFlag)
      throw new Error("ERROR: Cannot use a static CharStream class with a non-static lexical analyzer.");
   input_stream = stream;
}
public ParserTokenManager(ASCII_CharStream stream, int lexState)
{
  this(stream);
   SwitchTo(lexState);
}
public void ReInit(ASCII_CharStream stream)
{
   jjmatchedPos = jjnewStateCnt = 0;
   curLexState = defaultLexState;
   input_stream = stream;
   ReInitRounds();
}

private final void ReInitRounds()
{
   int i;
   jjround = 0x80000001;
   for (i = 28; i-- > 0;)
      jjrounds[i] = 0x80000000;
}
public void ReInit(ASCII_CharStream stream, int lexState)
{
   ReInit(stream);
   SwitchTo(lexState);
}
public void SwitchTo(int lexState)
{
   if (lexState >= 1 || lexState < 0)
      throw new TokenMgrError("Error: Ignoring invalid lexical state : " + lexState + ". State unchanged.", TokenMgrError.INVALID_LEXICAL_STATE);
   else
      curLexState = lexState;
}

private final Token jjFillToken()
{
   Token t = Token.newToken(jjmatchedKind);
   t.kind = jjmatchedKind;
   String im = jjstrLiteralImages[jjmatchedKind];
   t.image = (im == null) ? input_stream.GetImage() : im;
   return t;
}

int curLexState = 0;
int defaultLexState = 0;
int jjnewStateCnt;
int jjround;
int jjmatchedPos;
int jjmatchedKind;

public final Token getNextToken()
{
  int kind;
  Token specialToken = null;
  Token matchedToken;
  int curPos = 0;
  EOFLoop :
  for (;;)
  {
   try
   {
      curChar = input_stream.BeginToken();
   }
   catch(IOException e)
   {
      jjmatchedKind = 0;
      matchedToken = jjFillToken();
      return matchedToken;
   }

   try { input_stream.backup(0);
      while (curChar <= 32 && (0x100000000L & (1L << curChar)) != 0L)
         curChar = input_stream.BeginToken();
   }
   catch (IOException e1) { continue EOFLoop; }
   jjmatchedKind = 0x7fffffff;
   jjmatchedPos = 0;
   curPos = jjMoveStringLiteralDfa0_0();
   if (jjmatchedKind != 0x7fffffff)
   {
      if (jjmatchedPos + 1 < curPos)
         input_stream.backup(curPos - jjmatchedPos - 1);
      if ((jjtoToken[jjmatchedKind >> 6] & (1L << (jjmatchedKind & 077))) != 0L)
      {
         matchedToken = jjFillToken();
         return matchedToken;
      }
      else
      {
         continue EOFLoop;
      }
   }
   String error_after = null;
   boolean EOFSeen = false;
   try { input_stream.readChar(); input_stream.backup(1); }
  catch (IOException e1) {
      EOFSeen = true;
      error_after = curPos <= 1 ? "" : input_stream.GetImage();
   }
   if (!EOFSeen) {
      input_stream.backup(1);
      error_after = curPos <= 1 ? "" : input_stream.GetImage();
   }
   throw new TokenMgrError(EOFSeen, curLexState, error_after, curChar, TokenMgrError.LEXICAL_ERROR);
  }
}
}