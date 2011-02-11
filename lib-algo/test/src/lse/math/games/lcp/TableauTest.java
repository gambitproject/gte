package lse.math.games.lcp;

import static org.junit.Assert.*;
import org.junit.Test;

public class TableauTest {
	
	@Test
     public void testPosPivot()
     {
         int sizeBasis = 2;
         Tableau M = new Tableau(sizeBasis);
         for (int i = 0; i < sizeBasis; ++i)
         {
             for (int j = 0; j <= M.RHS(); ++j)
             {
                 long value = (i + 1) + j * 10;
                 M.set(i, j, value);
                 assertEquals(value, M.get(i, j));
             }
         }

         assertEquals(1,  M.get(0, 0)); //pivot entry
         assertEquals(11, M.get(0, 1)); //same row, diff col
         assertEquals(2,  M.get(1, 0)); //same col, diff row
         assertEquals(12, M.get(1, 1)); //diff row, diff col            

         //M.pivotOnRowCol(0, 0);
         M.pivot(M.vars().w(1), M.vars().z(0));

         assertEquals(-1, M.get(0, 0)); //pivot entry:           A[row,col] = det = -1
         assertEquals(11, M.get(0, 1)); //same row, diff col:    unchanged
         assertEquals(-2, M.get(1, 0)); //same col, diff row:    negative
         assertEquals(10, M.get(1, 1)); //diff row, diff col:    A[i,j] = (A[i,j] A[row,col] - A[i,col] A[row,j]) / det = (12*1 - 2*11)/-1
     }

     @Test
     public void testNegCol()
     {
         int sizeBasis = 3;
         Tableau M = new Tableau(sizeBasis);
         for (int i = 0; i < sizeBasis; ++i)
         {
             for (int j = 0; j <= M.RHS(); ++j)
             {
            	 int value = i + j * 10;
                 M.set(i, j, value);
             }
         }

         M.negCol(1);

         assertEquals( 20, M.get(0, 2));
         assertEquals(-10, M.get(0, 1));
         assertEquals(-11, M.get(1, 1)); //not sure I understand this assignment?
         assertEquals(-12, M.get(2, 1)); //not sure why determinent starts as negative 1?
     }

     @Test
     public void testPositiveValuesRatioTest()
     {
         int sizeBasis = 2;
         Tableau M = new Tableau(sizeBasis);
         for (int i = 0; i < sizeBasis; ++i)
         {
             for (int j = 0; j <= M.RHS(); ++j)
             {
            	 int value = (i+1) + j * 10;
                 M.set(i, j, value); 
             }
         }

         int sgn = M.ratioTest(0, 1, 0, 1);      /* sign of  A[a,testcol] / A[a,col] - A[b,testcol] / A[b,col]   */
         // A[0,1] / A[0,0] - A[1,1] / A[1,0] = 5
         assertEquals(1, sgn);

         sgn = M.ratioTest(1, 0, 0, 1);
         // A[1,1] / A[1,0] - A[0,1] / A[0,0] = -5
         assertEquals(-1, sgn);
     }
}
