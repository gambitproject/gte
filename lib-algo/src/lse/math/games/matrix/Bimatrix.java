package lse.math.games.matrix;

import java.util.LinkedList;

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
	
	
	public String printFormatHTML()
	{
		String s="";
		s+=this.nrows() + " x " + this.ncols() +" Payoff player 1"+lineSeparator; 
		
		s+=lineSeparator;
		s+=buildMatrixString(buildString(a));
		
		/*
		for (int i=0;i<a.length;i++){
			for (int j=0;j<a[i].length;j++){
				s+=" "+a[i][j];
			}
			s+=lineSeparator;
		}*/
		
		s+=lineSeparator;
		s+=lineSeparator;
		s+=this.nrows() + " x " + this.ncols() +" Payoff player 2"+lineSeparator;
		s+=lineSeparator;
		s+=buildMatrixString(buildString(b));
		/*
		for (int i=0;i<b.length;i++){
			for (int j=0;j<b[i].length;j++){
				s+=" "+b[i][j];
			}
			s+=lineSeparator;
		}*/
		s+=lineSeparator;
		return s;
	}
	
	
	/**
	 * Create a String from the array of payoffs
	 *@param pm:Array - 2-dim Array of payoffs
	 *@return String - an return seperated string with all payoffs.
	 *@author Martin  
	 */	
	private String[][] buildString(Rational[][] pm) 
	{
		
		if (pm==null) 
			return null;
		if (pm[0]==null) 
			return null;
		
		String[][] pm_out=new String[pm.length+1][pm[0].length+1];
		
		for (int i=0;i<pm_out[0].length;i++) {
			if (i==0) {
				pm_out[0][0]=new String("");
			} else {
				pm_out[0][i]=new String(this.colNames[i-1]);	
			}
		}
		
		for (int i=0;i<pm_out.length;i++) {
			if (i==0) {
				pm_out[0][0]=new String("");
			} else {
				pm_out[i][0]=new String(this.rowNames[i-1]);	
			}
		}
		
		for (int i=1;i<pm_out.length;i++) {
			for (int j=1;j<pm_out[i].length;j++) {
				pm_out[i][j]=pm[i-1][j-1].toString();
			}
		}
		
		return pm_out;
	}	
	
	
	/**
	 * Create a String from the array of payoffs
	 *@param pm:Array - 2-dim Array of payoffs
	 *@return String - an return seperated string with all payoffs.
	 *@author Martin  
	 */	
	private String buildMatrixString(String[][] pm) 
	{
		
		
		String delimeter=" ";
		LinkedList<Integer>  maxLength = new LinkedList<Integer>(); 
		int i=0;
		int j=0;
		
		if (pm==null) 
			return "";
		if (pm[0]==null) 
			return "";
		
		for (j=0;j<pm[0].length;j++){
			int maxLen = 0;
			for (i=0;i<pm.length;i++){
				if (pm[i][j]!=null) {
					if (pm[i][j].length()>maxLen) {
						maxLen=pm[i][j].length();
					}
					
				}
			}
			
			maxLength.add(Integer.valueOf(maxLen));
		}
		
		String matrixString= "";
		for (i=0;i<pm.length;i++){
			for (j=0;j<pm[i].length;j++){
				
				for (int w=0;w<maxLength.get(j) - pm[i][j].length();w++) {
					matrixString += " ";
				}
				matrixString += pm[i][j];
				if (j<pm[i].length-1){
					matrixString +=delimeter;
				}
				
			}
			if (i<pm.length - 1) {
				matrixString += lineSeparator;
			}
		}
		return matrixString;
	
	}
	

}
