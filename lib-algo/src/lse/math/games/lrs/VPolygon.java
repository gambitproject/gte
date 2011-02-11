package lse.math.games.lrs;

import java.util.ArrayList;
import java.util.List;

import lse.math.games.Rational;

public class VPolygon {
	public List<Rational[]> vertices = new ArrayList<Rational[]>(); // may also contain rays
	public List<Integer[]> cobasis = new ArrayList<Integer[]>();
	//boolean hull = true; //when is this false?  I should try to set this as an output param as well
	//boolean voronoi = false; //(if true, then poly is false)
	
	/* all rows must have a one in column one */
	public boolean polytope() {
		boolean ispoly = true;
		for (Rational[] row : vertices) {
			if (row.length < 1 || !row[0].isOne()) {
				ispoly = false;
			}
		}
		return ispoly;
	}
	
	/* for V-rep, all zero in column 1     */
	public boolean homogeneous() {
		boolean ishomo = true;
		for (Rational[] row : vertices) {
			if (row.length < 2 || !row[1].isZero()) {
				ishomo = false;
			}
		}
		return ishomo;		
	}
}
