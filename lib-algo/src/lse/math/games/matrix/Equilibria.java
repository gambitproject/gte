package lse.math.games.matrix;

import java.io.IOException;
import java.io.Writer;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import lse.math.games.Rational;
import lse.math.games.io.ColumnTextWriter;

public class Equilibria implements Iterable<Equilibrium> {
	private List<Equilibrium> extremeEquilibria = new ArrayList<Equilibrium>();
	private List<BipartiteClique> cliques = null;
	
	private Map<Integer,Equilibrium> vertexMap1 = new HashMap<Integer,Equilibrium>();
	private Map<Integer,Equilibrium> vertexMap2 = new HashMap<Integer,Equilibrium>();
	
	private CliqueAlgorithm coclique = new CliqueAlgorithm();
	
	private boolean dirty = true;
	
	public void add(Equilibrium eq) 
	{
		extremeEquilibria.add(eq);
		
		// TODO: how can I turn these into indices
		vertexMap1.put(eq.getVertex1(), eq);
		vertexMap2.put(eq.getVertex2(), eq);
		dirty = true;
	}
	
	public Equilibrium getByVertex1(int vertexId)
	{
		return vertexMap1.get(vertexId);
	}
	
	public Equilibrium getByVertex2(int vertexId)
	{
		return vertexMap2.get(vertexId);
	}
	
	public Equilibrium get(int idx) {
		return extremeEquilibria.get(idx);
	}
	
	public int ncliques() {
		return cliques.size();
	}
	
	public BipartiteClique getClique(int idx) {
		return cliques.get(idx);
	}
	
	public void setCliques(List<BipartiteClique> cliques) {
		this.cliques = cliques;
		dirty = true;
	}
	
	public int count() {
		return extremeEquilibria.size();
	}
	
	public void print(Writer output, boolean decimal) throws IOException
	{
		ColumnTextWriter colpp = new ColumnTextWriter();
		int idx = 1;
		for(Equilibrium ee : extremeEquilibria)
		{
			colpp.writeCol("EE");
			
			colpp.writeCol(String.format("%s", idx++));			
			colpp.alignLeft();
			
			colpp.writeCol("P1:");
			colpp.writeCol(String.format("(%1s)", ee.getVertex1()));
			for (Rational coord : ee.probVec1)
			{
				colpp.writeCol(String.format(
						decimal ? "%.4f" : "%s", 
						decimal ? coord.doubleValue() : coord.toString()));
			}
			colpp.writeCol("EP=");
			colpp.writeCol(String.format(
					decimal ? "%.3f" : "%s", 
					decimal ? ee.payoff1.doubleValue() : ee.payoff1.toString()));
			
			colpp.writeCol("P2:");
			colpp.writeCol(String.format("(%1s)", ee.getVertex2()));
			for (Rational coord : ee.probVec2)
			{
				colpp.writeCol(String.format(
						decimal ? "%.4f" : "%s", 
						decimal ? coord.doubleValue() : coord.toString()));
			}
			colpp.writeCol("EP=");
			colpp.writeCol(String.format(
					decimal ? "%.3f" : "%s", 
					decimal ? ee.payoff2.doubleValue() : ee.payoff2.toString()));
			colpp.endRow();
		}
		output.write(colpp.toString());
	}
	
	public Iterator<Equilibrium> iterator() { 
		return extremeEquilibria.iterator();
	}
	
	public Iterable<BipartiteClique> cliques() {
		return new CliqueIterator();
	}
	
	public class CliqueIterator implements Iterable<BipartiteClique>
	{
		public Iterator<BipartiteClique> iterator() {
			if (dirty) {
				coclique.run(Equilibria.this);
				dirty = false;
			}
			return cliques.iterator();
		}
	}
}
