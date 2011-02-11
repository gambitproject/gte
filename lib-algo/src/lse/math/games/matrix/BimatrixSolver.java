package lse.math.games.matrix;

import java.io.PrintWriter;
import java.util.List;
import java.util.Random;
import java.util.logging.Logger;

import lse.math.games.Rational;

import lse.math.games.lrs.Lrs;
import lse.math.games.lrs.HPolygon;
import lse.math.games.lrs.VPolygon;
import lse.math.games.lcp.LCP;
import lse.math.games.lcp.LemkeAlgorithm;
import lse.math.games.lcp.LemkeAlgorithm.LemkeException;

public class BimatrixSolver 
{	
	private static final Logger log = Logger.getLogger(BimatrixSolver.class.getName());
	
	public Rational[] computePriorBeliefs(int size, Random prng)
	{
		Rational[] priors = null;
		if (prng != null)  {					
			priors = Rational.probVector(size, prng);
		} else {
			priors = new Rational[size];
			Rational prob = Rational.ONE.divide(Rational.valueOf(size));
			for (int i = 0; i < size; ++i) {
				priors[i] = prob;
			}
		}
		return priors;
	}
	
	public Equilibrium findOneEquilibrium(LemkeAlgorithm lemke, Rational[][] a, Rational[][] b, Rational[] xPriors, Rational[] yPriors, PrintWriter out)
		throws LemkeException
	{	
		// 1. Adjust the payoffs to be strictly negative (max = -1)
		Rational payCorrectA = BimatrixSolver.correctPaymentsNeg(a);
		Rational payCorrectB = BimatrixSolver.correctPaymentsNeg(b);
		
		// 2. Generate the LCP from the two payoff matrices and the priors
		LCP lcp = BimatrixSolver.generateLCP(a, b, xPriors, yPriors);
		//out.println("#Lemke LCP " + lcp.size());
		//out.println(lcp.toString());
		log.info(lcp.toString());
		
		// 3. Pass the combination of the two to the Lemke algorithm		
		Rational[] z = lemke.run(lcp);		
		
		// 4. Convert solution into a mixed strategy equilibrium
		Equilibrium eq = BimatrixSolver.extractLCPSolution(z, a.length);		
		Equilibria eqs = new Equilibria();
		eqs.add(eq);
				
		
		// 5. Get original payoffs back and compute expected payoffs
		if (payCorrectA.compareTo(0) < 0) {
			BimatrixSolver.applyPayCorrect(a, payCorrectA.negate());
	    }
		
		if (payCorrectB.compareTo(0) < 0) {
			BimatrixSolver.applyPayCorrect(b, payCorrectB.negate());
	    }
		eq.payoff1 = BimatrixSolver.computeExpectedPayoff(a, eq.probVec1, eq.probVec2);
		eq.payoff2 = BimatrixSolver.computeExpectedPayoff(b, eq.probVec1, eq.probVec2);
		
		return eq;
	}	
	
	public Equilibria findAllEq(Lrs lrs, Rational[][] a, Rational[][] b)
	{
		int rows = a.length;
		int columns = (rows > 0) ? a[0].length : 0;
		
		if (b.length != rows || (rows > 0 && b[0].length != columns)) {
			throw new RuntimeException("Matrix b does not match matrix a"); //TODO
		}

		// create LRS inputs matrices
		// First we adjust payoffs to make sure payoff matrices are positive
		Rational payCorrectB = getPayCorrectPos(b);
		Rational[][] lrs1 = new Rational[columns][rows + 1];
		for (int j = 0; j < lrs1.length; j++) {
			lrs1[j][0] = Rational.ONE;
			for (int i = 1; i < lrs1[j].length; i++) {
				lrs1[j][i] = b[i-1][j].add(payCorrectB).negate();
			}
		}
	
		Rational payCorrectA = getPayCorrectPos(a);
		Rational[][] lrs2 = new Rational[rows][columns + 1];
		for (int i = 0; i < lrs2.length; i++) {
			lrs2[i][0] = Rational.ONE;		
	        for (int j = 1; j < lrs2[i].length; j++) {
	            lrs2[i][j] = a[i][j-1].add(payCorrectA).negate();
	        }
	    }
	
		// run lrs on each input			
		VPolygon lrsout1 = lrs.run(new HPolygon(lrs1, true));
		VPolygon lrsout2 = lrs.run(new HPolygon(lrs2, true));	
	
		// create probability vectors by rescaling vertex coordinates		
		// a vertex is a strategy, the strategy is defined by an array of probabilities
		Rational[][] p1_vertex_array = convertToProbs(lrsout1.vertices);
		Rational[][] p2_vertex_array = convertToProbs(lrsout2.vertices);
		
		List<Integer[]> p1_vertex_labels = lrsout1.cobasis;
		List<Integer[]> p2_vertex_labels = lrsout2.cobasis;

		// rearrange labels for P1
		// for i in 1...M+N  if i>N i=i-N if i<=N i=i+M
		// This is needed to coordinate the labels between p1 and p2.
		for (Integer[] labels : p1_vertex_labels) {
			for (int i = 0; i < labels.length; ++i) {
	        	if (labels[i] > columns) { 
	        		labels[i] -= columns;
	    		} else { 
	    			labels[i] += rows;
				}
			}
	    }
		
		//create array of integers representing binding inequalities
		//represents bit string with 1s in all positions except 0
		int[] p1_lab_int_array = createLabelBitmapArr(p1_vertex_labels, rows, columns);
		int[] p2_lab_int_array = createLabelBitmapArr(p2_vertex_labels, rows, columns);
	
		// calculate p2_artificial integer so that we can ignore artificial equilibrium
		int p2_art_int = (1<<(rows + columns + 1)) - 2;
		for (int i = (rows + 1); i < (rows + columns + 1); i++) {
			p2_art_int -= (1<<i);
		}
		
		// setup array (one for each player) @p1_eq_strategy initially with -1s for each index
		// it is set to the next free integer when a new  number for each equilibrium vertex
		int[] p1_eq_strategy = new int[p1_vertex_array.length];
		for (int i = 0; i < p1_eq_strategy.length; ++i) {
			p1_eq_strategy[i] = -1; 		
		}
		
		int[] p2_eq_strategy = new int[p2_vertex_array.length];
		for (int i = 0; i < p2_eq_strategy.length; ++i) {
	        p2_eq_strategy[i] = -1;
	    }
		
		// find and record equilibria by testing for complementarity
		// test for 0 as result of bit wise and on label_integers for vertices

		int p1_index = 0; // 
		int p2_index = 0;
		// index of vertices - used to go through p1/2_lab_int_array
		int eq_index = 1;
		// indexes number of extreme equilibria
		int s1 = 1;
		int s2 = 1;
		Equilibria equilibria = new Equilibria();
		
		// i, j index equilibrium strategy profiles of p1,p2 respectively
		for (int p1_int : p1_lab_int_array)
        {
	        for (int p2_int : p2_lab_int_array)
			{
				if ((p1_int & p2_int) == 0 && p2_int != p2_art_int)
				{
					// print eq vertex indices to IN
					if (p1_eq_strategy[p1_index] == -1) {
						p1_eq_strategy[p1_index] = s1;
						s1++;
					}
					if (p2_eq_strategy[p2_index] == -1) {
                        p2_eq_strategy[p2_index] = s2;
                        s2++;
                    }
			
					Equilibrium eq = new Equilibrium(p1_eq_strategy[p1_index], p2_eq_strategy[p2_index]);					
					
					eq.probVec1 = p1_vertex_array[p1_index];
					eq.payoff1 = computeExpectedPayoff(a, p1_vertex_array[p1_index], p2_vertex_array[p2_index]);
										
					eq.probVec2 = p2_vertex_array[p2_index];
					eq.payoff2 = computeExpectedPayoff(b, p1_vertex_array[p1_index], p2_vertex_array[p2_index]);
					
					equilibria.add(eq);
	
					eq_index++;
				}
				p2_index++;
	 		}
			p1_index++;
			p2_index = 0; 
        }
		
		return equilibria;
	}

	public static Rational computeExpectedPayoff(Rational[][] payMatrix, Rational[] probsA, Rational[] probsB)
	{
		Rational eq_payoff = Rational.ZERO;
		for (int i = 0; i < payMatrix.length; i++)
        {
            for (int j = 0; j < payMatrix[i].length; j++)
			{
				eq_payoff = eq_payoff.add(payMatrix[i][j].multiply(probsA[i].multiply(probsB[j])));
			}
		}
		return eq_payoff;
	}
	
	public static Rational correctPaymentsNeg(Rational[][] matrix)
	{
		Rational max = matrix[0][0];
		for (int i = 0; i < matrix.length; ++i) {
	        for (int j = 0; j < matrix[i].length; ++j) {
				if (matrix[i][j].compareTo(max) > 0) {
					max = matrix[i][j];
				}
            }
        }
		
		Rational correct = Rational.ZERO;
		if (max.compareTo(0) >= 0) {
			correct = max.negate().subtract(1);
			applyPayCorrect(matrix, correct);
		}
		return correct;
	}
	
	public static void applyPayCorrect(Rational[][] matrix, Rational correct)
	{
        for (int i = 0; i < matrix.length; ++i) {
            for (int j = 0; j < matrix[i].length; ++j) {	                
            	matrix[i][j] = matrix[i][j].add(correct); // -=
            }
        }
	}
	
	public static Rational getPayCorrectPos(Rational[][] matrix)
	{
		Rational min = matrix[0][0];
		for (int i = 0; i < matrix.length; ++i) {
	        for (int j = 0; j < matrix[i].length; ++j) {
				if (matrix[i][j].compareTo(min) < 0) {
					min = matrix[i][j];
				}
            }
        }
		
		Rational correct = Rational.ZERO;
		if (min.compareTo(0) <= 0) {
			correct = min.negate().add(1);
		}
		return correct;
	}
	
	// this assumes pays have been normalized to -1 as the max value
	public static LCP generateLCP(Rational[][] a, Rational[][] b, Rational[] xPriors, Rational[] yPriors)
	{
		int nStratsA = a.length;
		int nStratsB = a.length > 0 ? a[0].length : 0;
		int size = nStratsA + 1 + nStratsB + 1;
		LCP lcp = new LCP(size);

        /* fill  M  */
        /* -A       */        
        for (int i = 0; i < nStratsA; i++) {
            for (int j = 0; j < nStratsB; j++) {
                lcp.setM(i, j + nStratsA + 1, a[i][j].negate());
            }
        }        

        /* -E\T     */
        for (int i = 0; i < nStratsA; i++) {
            lcp.setM(i, nStratsA + 1 + nStratsB, Rational.NEGONE);
        }
        /* F        */
        for (int i = 0; i < nStratsB; i++) {
            lcp.setM(nStratsA, nStratsA + 1 + i, Rational.ONE);
        }
        /* -B\T     */
        lcp.payratmatcpy(b, true, true, nStratsA, nStratsB, nStratsA + 1, 0);
        for (int i = 0; i < nStratsA; i++) {
            for (int j = 0; j < nStratsB; j++) {                
                lcp.setM(j + nStratsA + 1, i, b[i][j].negate());
            }
        } 

        /* -F\T     */
        for (int i = 0; i < nStratsB; i++) {
            lcp.setM(nStratsA + 1 + i, nStratsA, Rational.NEGONE);
        }
        /* E        */
        for (int i = 0; i < nStratsA; i++) {
            lcp.setM(nStratsA + 1 + nStratsB, i, Rational.ONE);
        }

        /* define RHS q     */
        lcp.setq(nStratsA, Rational.NEGONE);
        lcp.setq(nStratsA + 1 + nStratsB, Rational.NEGONE);
        
        generateCovVector(lcp, xPriors, yPriors);
        return lcp;
	}
	
	private static void generateCovVector(LCP lcp, Rational[] xPriors, Rational[] yPriors)
	{
        /* covering vector  = -rhsq */
        for (int i = 0; i < lcp.size(); i++) {// i < lcpdim
            lcp.setd(i, lcp.q(i).negate());
        }

        /* first blockrow += -Aq    */
        int offset = xPriors.length + 1;
        for (int i = 0; i < xPriors.length; i++) {
            for (int j = 0; j < yPriors.length; ++j) {                    
            	lcp.setd(i, lcp.d(i).add(lcp.M(i, offset + j).multiply(yPriors[j])));
            }
        }

        /* third blockrow += -B\T p */
        for (int i = offset; i < offset + yPriors.length; i++) {
            for (int j = 0; j < xPriors.length; ++j) {                    
            	lcp.setd(i, lcp.d(i).add(lcp.M(i, j).multiply(xPriors[j])));
            }
        }        
	}	
	
	public static Equilibrium extractLCPSolution(Rational[] z, int nrows)
	{
		Equilibrium eq = new Equilibrium();
		int offset = nrows + 1;
        
        Rational[] pl1 = new Rational[offset - 1];
        System.arraycopy(z, 0, pl1, 0, pl1.length);

    	Rational[] pl2 = new Rational[z.length - offset - 1];
        System.arraycopy(z, offset, pl2, 0, pl2.length);

        eq.probVec1 = pl1;
        eq.probVec2 = pl2;        
        
        return eq;
	}
	
	private Rational[] getVertexSums(List<Rational[]> vertices)
	{
		Rational[] vertexSums = new Rational[vertices.size()];
		int i = 0;
		for (Rational[] vertex : vertices)
	    {
			Rational sum = Rational.ZERO;
	        for (int j = 1; j < vertex.length; ++j) // skip the first (0|1)
	        {
	            sum = sum.add(vertex[j]);
	        }
	        vertexSums[i] = sum;
			++i;
	    }
		return vertexSums;
	}
	
	private Rational[][] convertToProbs(List<Rational[]> lrs_vertex_array)
	{
		//calculate sums for each vertex in order to normalize
		Rational[] lrs_vertex_sum = getVertexSums(lrs_vertex_array);
		Rational[][] prob_vertex_array = new Rational[lrs_vertex_array.size()][];
		for (int i = 0; i < prob_vertex_array.length; ++i)
	    {
			Rational div = lrs_vertex_sum[i];
			prob_vertex_array[i] = new Rational[lrs_vertex_array.get(i).length - 1];
	        if (div.compareTo(0) == 0) // this means the sum was zero, so every element is zero, why are we setting to -1?
			{
	        	for (int j = 0; j < prob_vertex_array[i].length; ++j) {
	        		prob_vertex_array[i][j] = Rational.ONE.negate();
	        	}
			} 
			else	
			{
				for (int j = 0; j < prob_vertex_array[i].length; ++j)
				{
					prob_vertex_array[i][j] = lrs_vertex_array.get(i)[j + 1].divide(div); // skip the first (0|1)
				}
			}
	    }
		return prob_vertex_array;
	}
	
	private int[] createLabelBitmapArr(List<Integer[]> pl_label_array, int rows, int columns)
	{
		int i = 0;
		int[] pl_lab_int_array = new int[pl_label_array.size()];
		for (Integer[] aref : pl_label_array)
	    {
			int sum = (1 << (rows + columns + 1)) - 2;
	        for (int label : aref)
	        {
	            sum -= (1 << label);
	        }
	        pl_lab_int_array[i] = sum;
			i++; 
	    }
		return pl_lab_int_array;
	}
}
