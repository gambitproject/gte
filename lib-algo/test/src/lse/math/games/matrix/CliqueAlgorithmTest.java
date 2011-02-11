package lse.math.games.matrix;

import static org.junit.Assert.*;

import org.junit.Test;

public class CliqueAlgorithmTest {

	@Test
	public void testRunEquilibriaWithMultiA() {		
		Equilibria equilibria = new Equilibria();
		equilibria.add(new Equilibrium(7, 7));
		equilibria.add(new Equilibrium(7, 8));
		equilibria.add(new Equilibrium(8, 9));
		
		CliqueAlgorithm algo = new CliqueAlgorithm();
		algo.run(equilibria);
		
		assertEquals(2, equilibria.ncliques());
		assertEquals(1, equilibria.getClique(0).left.length);
		assertEquals(7, equilibria.getClique(0).left[0]);
		assertEquals(2, equilibria.getClique(0).right.length);
		assertEquals(7, equilibria.getClique(0).right[0]);
		assertEquals(8, equilibria.getClique(0).right[1]);
		assertEquals(1, equilibria.getClique(1).left.length);
		assertEquals(8, equilibria.getClique(1).left[0]);
		assertEquals(1, equilibria.getClique(1).right.length);
		assertEquals(9, equilibria.getClique(1).right[0]);
	}
	
	@Test
	public void testRunEquilibriaWithMultiB() {		
		Equilibria equilibria = new Equilibria();
		equilibria.add(new Equilibrium(7, 7));
		equilibria.add(new Equilibrium(8, 7));
		equilibria.add(new Equilibrium(9, 8));
		
		CliqueAlgorithm algo = new CliqueAlgorithm();
		algo.run(equilibria);
		
		assertEquals(2, equilibria.ncliques());
		assertEquals(2, equilibria.getClique(0).left.length);
		assertEquals(7, equilibria.getClique(0).left[0]);
		assertEquals(8, equilibria.getClique(0).left[1]);
		assertEquals(1, equilibria.getClique(0).right.length);
		assertEquals(7, equilibria.getClique(0).right[0]);		
		assertEquals(1, equilibria.getClique(1).left.length);
		assertEquals(9, equilibria.getClique(1).left[0]);
		assertEquals(1, equilibria.getClique(1).right.length);
		assertEquals(8, equilibria.getClique(1).right[0]);
	}
}
