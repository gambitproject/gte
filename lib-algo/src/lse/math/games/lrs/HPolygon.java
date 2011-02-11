package lse.math.games.lrs;

import lse.math.games.Rational;

public class HPolygon {
	public boolean nonnegative = true;
	public boolean incidence = true; // for recording the full cobasis at lexmin points
	public boolean printcobasis = true; //incidence implies printcobasis
	//hull = false
	public int[] linearities = new int[0];
	
	private int n;
	private int m;
	private int d;
	
	public Rational[][] matrix;
		
	public HPolygon(Rational[][] matrix, boolean nonnegative)
	{
		this.matrix = matrix;
		m = matrix.length;
		n = m > 0 ? matrix[0].length : 0;
		d = n - 1;
		
		this.nonnegative = nonnegative;
	}
	
	
	public int getNumRows() { return m; }	
	public int getNumCols() { return n; }	
	public int getDimension() { return d; }
	
	
	public void setIncidence(boolean value)
	{
		incidence = value;
		if (value && !printcobasis)
			printcobasis = true;
	}
	
	/* for H-rep, are zero in column 0     */
	public boolean homogeneous() {
		boolean ishomo = true;
		for (Rational[] row : matrix) {
			if (row.length < 1 || !row[0].isZero()) {
				ishomo = false;
			}
		}
		return ishomo;		
	}
}
