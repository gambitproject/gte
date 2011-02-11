package lse.math.games.matrix;

import static org.junit.Assert.*;
import lse.math.games.Rational;
import lse.math.games.lrs.Lrs;
import lse.math.games.lrs.LrsAlgorithm;

import org.junit.Test;

public class BimatrixSolverTest 
{
	@Test
	public void testFindAllEqWithDegeneracy() {
		BimatrixSolver program = new BimatrixSolver();
		Rational[][] payoff1 = new Rational[][] { 
				{ Rational.valueOf("3"), Rational.valueOf("3")}, 
				{ Rational.valueOf("2"), Rational.valueOf("5")}, 
				{ Rational.valueOf("0"), Rational.valueOf("6")}
		};
		
		Rational[][] payoff2 = new Rational[][] { 
				{ Rational.valueOf("3"), Rational.valueOf("3")}, 
				{ Rational.valueOf("2"), Rational.valueOf("6")}, 
				{ Rational.valueOf("3"), Rational.valueOf("1")}
		};
		
		Rational[][] probs1 = new Rational[][] { 
				{ Rational.valueOf("1"), Rational.valueOf("0"), Rational.valueOf("0")}, 
				{ Rational.valueOf("1"), Rational.valueOf("0"), Rational.valueOf("0")}, 
				{ Rational.valueOf("0"), Rational.valueOf("1/3"), Rational.valueOf("2/3")}
		};
		Rational[][] probs2 = new Rational[][] { 
				{ Rational.valueOf("1"), Rational.valueOf("0")}, 
				{ Rational.valueOf("2/3"), Rational.valueOf("1/3")}, 
				{ Rational.valueOf("1/3"), Rational.valueOf("2/3")}
		};
		Rational[] epayoffs1 = new Rational[] {
				Rational.valueOf("3"), Rational.valueOf("3"), Rational.valueOf("4")	
		};
		Rational[] epayoffs2 = new Rational[] {
				Rational.valueOf("3"), Rational.valueOf("3"), Rational.valueOf("8/3")	
		};
				
		Lrs lrs = new LrsAlgorithm();		
		Equilibria eqs = program.findAllEq(lrs, payoff1, payoff2);
		checkResults(eqs, probs1, probs2, epayoffs1, epayoffs2);
	}
	
	@Test
	public void testFindAllEqNoDegeneracy() {
		BimatrixSolver program = new BimatrixSolver();
		Rational[][] payoff1 = new Rational[][] { 
				{ Rational.valueOf("3"), Rational.valueOf("3")}, 
				{ Rational.valueOf("2"), Rational.valueOf("5")}, 
				{ Rational.valueOf("0"), Rational.valueOf("6")}
		};
		
		Rational[][] payoff2 = new Rational[][] { 
				{ Rational.valueOf("3"), Rational.valueOf("2")}, 
				{ Rational.valueOf("2"), Rational.valueOf("6")}, 
				{ Rational.valueOf("3"), Rational.valueOf("1")}
		};
		
		Rational[][] probs1 = new Rational[][] { 
				{ Rational.valueOf("1"), Rational.valueOf("0"), Rational.valueOf("0")}, 
				{ Rational.valueOf("4/5"), Rational.valueOf("1/5"), Rational.valueOf("0")}, 
				{ Rational.valueOf("0"), Rational.valueOf("1/3"), Rational.valueOf("2/3")}
		};
		Rational[][] probs2 = new Rational[][] { 
				{ Rational.valueOf("1"), Rational.valueOf("0")}, 
				{ Rational.valueOf("2/3"), Rational.valueOf("1/3")}, 
				{ Rational.valueOf("1/3"), Rational.valueOf("2/3")}
		};
		Rational[] epayoffs1 = new Rational[] {
				Rational.valueOf("3"), Rational.valueOf("9/3"), Rational.valueOf("4")	
		};
		Rational[] epayoffs2 = new Rational[] {
				Rational.valueOf("3"), Rational.valueOf("14/5"), Rational.valueOf("8/3")	
		};
				
		Lrs lrs = new LrsAlgorithm();		
		Equilibria eqs = program.findAllEq(lrs, payoff1, payoff2);
		checkResults(eqs, probs1, probs2, epayoffs1, epayoffs2);
	}
	
	private void checkResults(Equilibria eqs, Rational[][] probs1, Rational[][] probs2, Rational[] epayoffs1, Rational[] epayoffs2) 
	{
		assertEquals(3, eqs.count());
		for (int i = 0; i < 3; ++i) {
			Equilibrium eq = eqs.get(i);
			assertEquals(epayoffs1[i], eq.payoff1);
			assertEquals(epayoffs2[i], eq.payoff2);
			assertEquals(3, eq.probVec1.length);
			for (int j = 0; j < 3; ++j) {
				assertEquals(probs1[i][j], eq.probVec1[j]);
			}
			assertEquals(2, eq.probVec2.length);
			for (int j = 0; j < 2; ++j) {
				assertEquals(probs2[i][j], eq.probVec2[j]);
			}			
		}
	}
}
