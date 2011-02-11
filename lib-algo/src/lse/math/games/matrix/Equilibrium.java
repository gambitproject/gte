package lse.math.games.matrix;

import lse.math.games.Rational;

public class Equilibrium {
	
	private int vertex1;
	private int vertex2;
	
	public Equilibrium() {}
	
	public Equilibrium(int vertex1, int vertex2)
	{
		this.vertex1 = vertex1;
		this.vertex2 = vertex2;
	}
	
	public int getVertex1() { return vertex1; }
	public int getVertex2() { return vertex2; }
	
	public Rational[] probVec1; //length = #rows (1 per strategy)	
	public Rational payoff1;
		
	public Rational[] probVec2; //length = #cols (1 per strategy)
	public Rational payoff2;
}
