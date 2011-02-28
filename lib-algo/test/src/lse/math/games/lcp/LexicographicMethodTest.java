package lse.math.games.lcp;

import lse.math.games.lcp.LemkeAlgorithm.RayTerminationException;

import org.junit.Test;
import static org.junit.Assert.*;

public class LexicographicMethodTest {
	@Test
     public void testLexMinVar()
     {
         Tableau A = new Tableau(2);
         A.set(0, 0, 2);
         A.set(0, 1, 2);
         A.set(0, 2, 1);
         A.set(0, 3, -1);
         A.set(1, 0, 1);
         A.set(1, 1, 1);
         A.set(1, 2, 3);
         A.set(1, 3, -1);

         LexicographicMethod lex = new LexicographicMethod(A.vars().size(), null);
         
         try
         {
        	 int leave = lex.lexminratio(A, 0);
        	 assertFalse(lex.z0leave());
        	 assertEquals(4, leave);
         }
         catch (RayTerminationException ex)
         {
             assertTrue(ex.getMessage(), false);
         }

         try
         {
        	 int leave = lex.lexminratio(A, 1);
        	 assertFalse(lex.z0leave());
        	 assertEquals(4, leave);
         }
         catch (RayTerminationException ex)
         {
             assertTrue(ex.getMessage(), false);
         }

         try
         {
        	 int leave = lex.lexminratio(A, 2);
        	 assertFalse(lex.z0leave());
        	 assertEquals(3, leave); 
         }
         catch (RayTerminationException ex)
         {
             assertTrue(ex.getMessage(), false);
         }

         try
         {
        	 lex.lexminratio(A, 3);
             assertFalse("Should have thrown exception", true);
         }
         catch (RuntimeException ex) {
             assertEquals("Basic variable w1 should be cobasic.", ex.getMessage());
         }
         catch (RayTerminationException ex)
         {
             assertTrue(ex.getMessage(), false);
         }

         try
         {
        	 lex.lexminratio(A, 4);
             assertFalse("Should have thrown exception", true);
         }
         catch (RuntimeException ex) {
             assertEquals("Basic variable w2 should be cobasic.", ex.getMessage());
         }
         catch (RayTerminationException ex)
         {
             assertTrue(ex.getMessage(), false);
         }
     }

     @Test
     public void test1000LexMinVarOnLargeTableu()
     {
         Tableau A = new Tableau(1000);
         for (int i = 0; i < 1000; ++i)
             for (int j = 0; j < 1002; ++j)
             {
                 if (j == 0) A.set(i, j, 1);
                 else A.set(i, j, (i - (j-1)) * ((j * 17) - (i * 63)));
             }

         LexicographicMethod lex = new LexicographicMethod(A.vars().size(), null);

         long before = System.currentTimeMillis();
         for (int i = 0; i < 1000; ++i)
         {
             try
             {
                 int leave = lex.lexminratio(A, 0);
                 assertFalse(lex.z0leave());
                 assertEquals(1001, leave);
             }
             catch (RayTerminationException ex)
             {
                 assertTrue(ex.getMessage() + " " + i, false);
             }
         }
         long duration = System.currentTimeMillis() - before;
         assertTrue(String.valueOf(duration), duration < 10000000); // less than 10 seconds
     }

     @Test
     public void testMinRatioTest()
     {
         Tableau A = new Tableau(2);
         A.set(0, 0, 2);
         A.set(0, 1, 2);
         A.set(0, 2, 1);
         A.set(0, 3, -1);
         A.set(1, 0, 1);
         A.set(1, 1, 1);
         A.set(1, 2, 3);
         A.set(1, 3, -1);

         LexicographicMethod lex = new LexicographicMethod(A.vars().size(), null);
         int[] candidates = new int[] { 0, 1 };
         int numcand = candidates.length;

         assertEquals(2, numcand);
         assertEquals(0, candidates[0]);

         int col = 1;
         int testcol = 2;

         /* sign of  A[l_0,t] / A[l_0,col] - A[l_i,t] / A[l_i,col]   */
         /* should be 1/2 - 3/1 = -5/2 */
         int sgn = A.ratioTest(candidates[0], candidates[1], col, testcol);
         assertEquals(-1, sgn);

         numcand = lex.minRatioTest(A, col, testcol, candidates, numcand);

         assertEquals(1, numcand);
         assertEquals(0, candidates[0]);

         col = 2;
         testcol = 1;
         
         /* sign of  A[l_0,t] / A[l_0,col] - A[l_i,t] / A[l_i,col]   */
         /* should be 2/1 - 1/3 = 5/3 */
         sgn = A.ratioTest(candidates[0], candidates[1], col, testcol);
         assertEquals(1, sgn);

         numcand = 2;
         numcand = lex.minRatioTest(A, col, testcol, candidates, numcand);

         assertEquals(1, numcand);
         assertEquals(1, candidates[0]);
     }
}
