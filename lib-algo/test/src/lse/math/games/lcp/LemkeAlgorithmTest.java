package lse.math.games.lcp;

import lse.math.games.Rational;
import lse.math.games.lcp.LemkeAlgorithm.InvalidLCPException;
//import lse.math.games.lcp.LemkeAlgorithm.OnInitDelegate;
import lse.math.games.lcp.LemkeAlgorithm.RayTerminationException;
import lse.math.games.lcp.LemkeAlgorithm.TrivialSolutionException;

import org.junit.Test;
import static org.junit.Assert.*;

public class LemkeAlgorithmTest {
	
    LCP lcp;
    Rational[] cov;
	
	private void SetUp(int[][] M, int[] q, int[] d)
    {
        lcp = new LCP(q.length);

        if (M.length > 0) {
	        lcp.intratmatcpy(M, false, false, M.length, M[0].length, 0, 0);
	        for(int i = 0; i < M.length; ++i)
	            for (int j = 0; j < M[i].length; ++j)
	                assertTrue(lcp.M(i,j).compareTo(M[i][j]) == 0);
        }
        
        for (int i = 0; i < q.length; ++i) {
            lcp.setq(i, Rational.valueOf(q[i]));
        }            

        assertFalse("Trivial LCP", lcp.isTrivial());
        
        for (int i = 0; i < d.length; ++i) {
            lcp.setd(i, Rational.valueOf(d[i]));
        } 
    }

    /*@Test
    public void testLemkeInit()
    {
        int[][] M = new int[][] { { 2, 1 }, { 1, 3 } };
        int[] q = new int[] { -1, -1 };
        int[] d = new int[] { 2, 1 };

        SetUp(M, q, d);            

        LemkeAlgorithm algo = new LemkeAlgorithm();
        algo.onInit = new OnInitDelegate() {
        	public void onInit(String value, Tableau A) {
        		assertEquals("After filltableau", value);
        	}
    	}; //TODO: change back to addeq for chained delegates

        try {
        	algo.run(lcp);
        } catch (InvalidLCPException ex) {
        	assertTrue(ex.getMessage(), false);
        } catch (RayTerminationException ex) {
        	assertTrue(ex.getMessage(), false);
		} catch (TrivialSolutionException ex) {
			assertTrue(ex.getMessage(), false);
		}
        
		// TODO: I merged init and solve... this test is invalid... needs fixing
        assertEquals(2, algo.A.get(0, 0));           
    }*/

    @Test
    public void testLemkeRun()
    {
        int[][] M = new int[][] { { 0, -1, 2}, { 2, 0, -2 }, { -1, 1, 0} };
        int[] q = new int[] { -3, 6, -1 };
        int[] d = new int[] { 1, 1, 1 };

        SetUp(M, q, d);            

        LemkeAlgorithm algo = new LemkeAlgorithm();        
        
        //StringWriter output = new StringWriter();
        //LemkeWriter lemkeWriter = new LemkeWriter(output, output);
        //lemkeWriter.outtabl(algo.A);
        //Assert.True(false, output.ToString());

        Rational[] z = null;
        try {
        	z = algo.run(lcp);
        } catch (RayTerminationException ex) {
        	assertTrue(ex.getMessage(), false);
        } catch (InvalidLCPException ex) {
        	assertTrue(ex.getMessage(), false);
        } catch (TrivialSolutionException ex) {
        	assertTrue(ex.getMessage(), false);
		}
        
        assertEquals(3, z.length);
        assertEquals(0, z[0].doubleValue(), 0.000000001);
        assertEquals(1, z[1].doubleValue(), 0.000000001);
        assertEquals(3, z[2].doubleValue(), 0.000000001);
    }
}
