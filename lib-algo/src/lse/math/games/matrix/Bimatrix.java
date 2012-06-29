package lse.math.games.matrix;

import lse.math.games.Rational;
import lse.math.games.io.ColumnTextWriter;

public class Bimatrix {
	private String[] names;
	private Rational[][] a;
	private Rational[][] b;
	private String[] rowNames;
	private String[] colNames;
	
	final static String lineSeparator = System.getProperty("line.separator");
	
	public Bimatrix(String[] names, Rational[][] a, Rational[][] b, String[] rowStrats, String[] colStrats)
	{
		this.names = names;
		this.a = a;
		this.b = b;
		this.rowNames = rowStrats;
		this.colNames = colStrats;
	}
	
	public int nrows() {
		return a != null ? a.length : 0;
	}
	public int ncols() {
		return nrows() > 0 ? a[0].length : 0;
	}
	
	public String row(int idx) {
		return strat(rowNames, idx);
	}
	
	public String col(int idx) {
		return strat(colNames, idx);
	}
	
	public String firstPlayer() { return name(0); }
	public String secondPlayer() { return name(1); }
	private String name(int idx) {
		return names != null && names.length > 0 && names[idx] != null ? names[idx] : String.valueOf(idx + 1);
	}
	
	
	private String strat(String[] arr, int idx) {
		return (arr != null && (idx < arr.length) && arr[idx] != null? arr[idx] : String.valueOf(idx + 1));
	}
	@Override
	public String toString()
	{
		ColumnTextWriter colpp = new ColumnTextWriter();		
		addMatrix(0, colpp);
		colpp.endRow();
		addMatrix(1, colpp);		
		return colpp.toString();
	}
	
	
	
	private void addMatrix(int idx, ColumnTextWriter colpp) {	
		colpp.writeCol(name(idx));
		colpp.alignLeft();
		for (String colName : colNames) {
			colpp.writeCol(colName);
		}
		colpp.endRow();
		
		Rational[][] mat = idx == 0 ? a : b;
		for(int i = 0; i < mat.length; ++i) {
			colpp.writeCol(rowNames[i]);
			Rational[] row = mat[i];
			for (Rational entry : row) {
				colpp.writeCol(entry.toString());		
			}
			colpp.endRow();	
		}
	}
	
	
	public String printFormat()
	{
		String s="";
		s+=a.length + " "+a[0].length+lineSeparator;
		s+=lineSeparator;
		for (int i=0;i<a.length;i++){
			for (int j=0;j<a[i].length;j++){
				s+=" "+a[i][j];
			}
			s+=lineSeparator;
		}
		
		s+=lineSeparator;
		s+=lineSeparator;
		for (int i=0;i<b.length;i++){
			for (int j=0;j<b[i].length;j++){
				s+=" "+b[i][j];
			}
			s+=lineSeparator;
		}
		
		return s;
	}
	
}
