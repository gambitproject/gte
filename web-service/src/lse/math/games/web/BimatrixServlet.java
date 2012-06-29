package lse.math.games.web;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.DataInputStream;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;

import java.util.Arrays;
import java.util.Random;
import java.util.logging.Logger;

import javax.servlet.ServletConfig;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import lse.math.games.Rational;
import lse.math.games.lrs.LrsAlgorithm;
import lse.math.games.lrs.Lrs;
import lse.math.games.matrix.Bimatrix;
import lse.math.games.matrix.BimatrixSolver;
import lse.math.games.matrix.BipartiteClique;
import lse.math.games.matrix.Equilibria;
import lse.math.games.matrix.Equilibrium;
import lse.math.games.io.ColumnTextWriter;
import lse.math.games.lcp.LemkeAlgorithm;
import lse.math.games.lcp.LemkeAlgorithm.LemkeException;

/**
 * @author Mark Egesdal
 */
@SuppressWarnings("serial")
public class BimatrixServlet extends AbstractRESTServlet 
{    
	private static final Logger log = Logger.getLogger(BimatrixServlet.class.getName());

	private Lrs lrs;
	private BimatrixSolver solver = new BimatrixSolver();	

	public void init(ServletConfig config) 
	throws ServletException
	{
		super.init(config);           
		lrs = new LrsAlgorithm();           
	}

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) 
	throws ServletException, IOException 
	{		
		doPost(request, response);
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) 
	throws ServletException, IOException 
	{			
		response.setContentType("text/plain");
		log.info("Processing new request");
	
		
		Bimatrix game = null;
		Rational[] xPriors = null;
		Rational[] yPriors = null;
		Long seed = null;
		Equilibria eqs = null;
		
	
		
		try {
			Rational[][] a = parseMultiRowRatParam(request, "a");
			Rational[][] b = parseMultiRowRatParam(request, "b");
			String[] rowNames = request.getParameter("r") != null ? request.getParameter("r").split(" ") : null;
			String[] colNames = request.getParameter("c") != null ? request.getParameter("c").split(" ") : null;
			String algo =  request.getParameter("algo");
			xPriors = parseSingleRowRatParam(request, "x");
			yPriors = parseSingleRowRatParam(request, "y");
			seed = this.parseRandomSeed(request.getParameter("s"));

			int nrows = 0;
			int ncols = 0;

			if (a != null) {
				nrows = a.length;
				ncols = a.length > 0 ? a[0].length : 0;

				log.info("Processing bimatrix with nrows " + nrows + " and ncols " + ncols);

				if(!checkDimensions(a, nrows, ncols)) {
					addError(request, "A (" + nrows + "x" + ncols + ") is incomplete: " + request.getParameter("a"));
				}
			} else {
				addError(request, "Unable to parse A: " + request.getParameter("a"));
			}		

			if (b != null && a != null) {
				if(!checkDimensions(b, nrows, ncols)) {
					int nrowsb = a.length;
					int ncolsb = a.length > 0 ? a[0].length : 0;
					addError(request, "Dimensions of B (" + nrowsb + "x" + ncolsb + ") do not match A");
				}
			} else {
				addError(request, "Unable to parse B: " + request.getParameter("b"));
			}

			if (rowNames != null && rowNames.length != nrows) {
				//if (rowNames.length != 0 || nrows != 1) {
					addError(request, "Row names length does not match pay matrix " + Arrays.toString(rowNames));
				//}
			}
			if (colNames != null && colNames.length != ncols) {
				//if (colNames.length != 0 || ncols != 1) {
					addError(request, "Col names length does not match pay matrix " + Arrays.toString(colNames));
				//}
			}

			if (!this.hasErrors(request)) 
			{
				game = new Bimatrix(new String[]{"A" , "B"}, a, b, rowNames, colNames);
				log.info(game.toString());
			

				if (algo != null && algo.equals("menum")) {				
					log.info("lrs enumerate");
					if (nrows + ncols > 30) {
						// TODO: add this logic to solver and throw an exception
						addError(request, "Dimensions are too large (we restrict rows + cols < 31)");					
					} else {
						eqs = solver.findAllEq(lrs, a, b);				
						log.info("equilibria found");						
					}
				} else {
					log.info("lemke");				

					Equilibrium eq = null;
					LemkeAlgorithm lemke = new LemkeAlgorithm();
					try {			

						// 0. Compute and print prior beliefs
						Random prng = seed != null ? new Random(seed) : null;
						if (xPriors == null)  {					
							xPriors = solver.computePriorBeliefs(nrows, prng);
						} else if (prng != null) {
							this.addWarning(request, "Manual priors for rows override randomization");
						}

						if (yPriors == null) {
							yPriors = solver.computePriorBeliefs(ncols, prng);
						} else if (prng != null) {
							this.addWarning(request, "Manual priors for columns override randomization");
						}

						eq = solver.findOneEquilibrium(lemke, a, b, xPriors, yPriors, response.getWriter());								
					} catch (LemkeException ex) {
						//TODO: write better error output for ray termination, etc.
						addError(request, ex.getMessage());
					}
					if (eq != null) {
						log.info("equilibrium found");
						eqs = new Equilibria();
						eqs.add(eq);						
					}
				}
			}
		} catch (Exception ex) {
			addError(request, ex.getMessage());
		}
		try {
		this.writeResponseHeader(request, response);
		if (game != null) {
			response.getWriter().println("NormalForm " + game.nrows() + " " + game.ncols());
			response.getWriter().println(game.toString());

		}
		if (xPriors != null && yPriors != null) {
			printPriors(xPriors, yPriors, seed, game, response.getWriter());
		}
		if (eqs != null) {
			if (eqs.count() > 1) {
				printResultCompact(eqs, game, response.getWriter());
			} else {
				printResultOld(eqs, game, response.getWriter());
			}
		}
		} catch (Exception ex) {
			response.getWriter().println(ex.getMessage());
		}
	}

	private void printPriors(Rational[] xPriors, Rational[] yPriors, Long seed, Bimatrix game, PrintWriter output) 
	{
		ColumnTextWriter colpp = new ColumnTextWriter();
		colpp.writeCol("Priors");
		colpp.endRow();
		if (seed != null) {
			colpp.writeCol("seed");
			colpp.writeCol(seed.toString());
			colpp.endRow();
			colpp.endRow();
		}		

		for (int i = 0; i < game.nrows(); ++i) {
			printRow(game.row(i), xPriors[i], colpp, false);
		}
		colpp.endRow();
		for (int j = 0; j < game.ncols(); ++j) {
			printRow(game.col(j), yPriors[j], colpp, false);
		}

		colpp.alignLeft(0);
		output.println(colpp.toString());
	}

	private <T> boolean checkDimensions(T[][] mat, int row, int col) {
		if (mat.length != row) return false;
		for (int i = 0; i < row; ++i)
		{
			if (mat[i].length != col) return false;
		}
		return true;
	}

	private Rational[][] parseMultiRowRatParam(HttpServletRequest request, String name)
	{
		String matStr = request.getParameter(name);		
		if (matStr != null) {		
			try { 			
				return parseRatMatrix(matStr);
			} catch (NumberFormatException ex) {			
				addError(request, name + " matrix has invalid entries: " + ex.getMessage() + "\r\n" + matStr);
			}
		}
		return null;
	}

	private Rational[] parseSingleRowRatParam(HttpServletRequest request, String name)
	{
		String vecStr = request.getParameter(name);		
		if (vecStr != null) {
			try { 				
				return parseRatVector(vecStr);				
			} catch (NumberFormatException ex) {
				addError(request, name + " vector has invalid entries: " + vecStr);
			}
		}
		return null;
	}


	private Rational[][] parseRatMatrix(String matStr)
	{		
		String[] vecStrArr = matStr.trim().split("\\r\\n");
		Rational[][] mat = new Rational[vecStrArr.length][];
		for (int i = 0; i < mat.length; ++i)
		{
			mat[i] = parseRatVector(vecStrArr[i].trim());
		}
		return mat;
	}

	private Rational[] parseRatVector(String vecStr)
	{
		String[] strArr = vecStr.split(",?\\s+");
		Rational[] vec = new Rational[strArr.length];
		for (int i = 0; i < vec.length; ++i)
		{
			vec[i] = Rational.valueOf(strArr[i]);
		}
		return vec;
	}

	/*private void printHeader(Bimatrix game, ColumnTextWriter colpp, Equilibria eqs)
	{
		if (eqs.count() > 1) {
			colpp.writeCol("");
		}
		colpp.alignLeft();
		for(int i = 0; i < game.nrows(); ++i) {
			boolean hasNonZeroEntry = false;
			for (Equilibrium eq : eqs) {
				if (!eq.probVec1[i].isZero()) {
					hasNonZeroEntry = true;
					break;
				}
			}
			if (hasNonZeroEntry) {
				colpp.writeCol(game.row(i));
			} else {
				colpp.writeCol("");
			}
		}
		colpp.writeCol("\u00A3" + game.firstPlayer());
		colpp.writeCol("  ");

		if (eqs.count() > 1) {
			colpp.writeCol("");
		}
		colpp.alignLeft();
		for(int j = 0; j < game.ncols(); ++j) {			
			boolean hasNonZeroEntry = false;
			for (Equilibrium eq : eqs) {
				if (!eq.probVec2[j].isZero()) {
					hasNonZeroEntry = true;
					break;
				}
			}
			if (hasNonZeroEntry) {
				colpp.writeCol(game.col(j));
			} else {
				colpp.writeCol("");
			}
		}
		colpp.writeCol("\u00A3" + game.secondPlayer());		
		colpp.endRow();
	}*/

	private void printResultCompact(Equilibria eqs, Bimatrix game, PrintWriter out) throws IOException
	{
		ColumnTextWriter colpp = new ColumnTextWriter();
		if (eqs.count() > 1) {
			out.println("Equilibria " + eqs.count());			
		}
		
		for (Equilibrium eq : eqs) {
			colpp.writeCol("x" + eq.getVertex1());
			for (int i = 0; i < eq.probVec1.length; ++i) {
				Rational prob = eq.probVec1[i];
				if (!prob.isZero()) {
					colpp.writeCol(game.row(i) + ":");
					colpp.alignLeft();
					colpp.writeCol(String.format("%.3f", prob.doubleValue()));
				} else {
					colpp.writeCol("");
					colpp.writeCol("");
				}
			}
			colpp.writeCol("  \u00A3" + String.format("%.2f", eq.payoff1.doubleValue()));
			colpp.writeCol("  y" + eq.getVertex2());
			for (int j = 0; j < eq.probVec2.length; ++j) {
				Rational prob = eq.probVec2[j];
				if (!prob.isZero()) {
					colpp.writeCol(game.col(j) + ":");
					colpp.alignLeft();
					colpp.writeCol(String.format("%.3f", prob.doubleValue()));
				} else {
					colpp.writeCol("");
					colpp.writeCol("");
				}
			}
			colpp.writeCol("  \u00A3" + String.format("%.2f", eq.payoff2.doubleValue()));
			colpp.endRow();
			
			colpp.writeCol("");
			for (int i = 0; i < eq.probVec1.length; ++i) {
				Rational prob = eq.probVec1[i];
				colpp.writeCol("");
				if (!prob.isZero()) {
					colpp.writeCol(prob.toString());
				} else {
					colpp.writeCol("");
				}
			}
			colpp.writeCol(eq.payoff1.toString());
			colpp.writeCol("");
			for (int j = 0; j < eq.probVec2.length; ++j) {
				Rational prob = eq.probVec2[j];
				colpp.writeCol("");
				if (!prob.isZero()) {
					colpp.writeCol(prob.toString());
				} else {
					colpp.writeCol("");
				}
			}
			colpp.writeCol(eq.payoff2.toString());
			colpp.endRow();
			colpp.endRow();
		}
		out.print(colpp.toString());
		
		if (eqs.count() > 1) {
			out.println("Cliques");
			for (BipartiteClique clique : eqs.cliques()) 
			{						
				StringBuilder sb = new StringBuilder();

				if (eqs.count() > 1) {
					sb.append(" {");
					for (int i = 0; i < clique.left.length; ++i) {
						if (i > 0) {
							sb.append(", ");
						}
						sb.append("x" + clique.left[i]);
					}
					sb.append("} x {");
					for (int i = 0; i < clique.right.length; ++i) {
						if (i > 0) {
							sb.append(", ");
						}
						sb.append("y" + clique.right[i]);
					}
					sb.append("}");
				}
				out.println(sb.toString());
			}
		}
	}
	
	// This is a first attempt to display cliques and equilibria together... it has a bug with only
	// displaying one payoff per player instead of one per strategy of the other player
	// (i.e. if pl 1 has 2 eq and pl 2 has 3, pl 1 should have 3 pays and pl 2 should have 2)
	// It is a good format for displaying a single result, which is how it is currently used.
	private void printResultOld(Equilibria eqs, Bimatrix game, PrintWriter out) throws IOException
	{
		ColumnTextWriter colpp = new ColumnTextWriter();
		if (eqs.count() > 1) {
			colpp.writeCol("Equilibria " + eqs.count());
			colpp.endRow();
		}
		
		for (BipartiteClique clique : eqs.cliques()) 
		{						
			StringBuilder sb = new StringBuilder();

			if (eqs.count() > 1) {
				sb.append(" {");
				for (int i = 0; i < clique.left.length; ++i) {
					if (i > 0) {
						sb.append(", ");
					}
					sb.append(clique.left[i]);
				}
				sb.append("} x {");
				for (int i = 0; i < clique.right.length; ++i) {
					if (i > 0) {
						sb.append(", ");
					}
					sb.append(clique.right[i]);
				}
				sb.append("}");
			}
			
			colpp.writeCol("Equilibrium" + sb.toString());
			colpp.endRow();
			
			Rational payX = null;
			Rational payY = null;
			for (int i = 0; i < clique.left.length; ++i) 
			{
				Equilibrium x = eqs.getByVertex1(clique.left[i]);
				if (payX == null) {
					payX = x.payoff1;
				}
				for (int j = 0; j < x.probVec1.length; ++j) {
					printRow(game.row(j), x.probVec1[j], colpp, true);
				}
				colpp.endRow();
			}
			
			for (int i = 0; i < clique.right.length; ++i) 
			{
				Equilibrium y = eqs.getByVertex2(clique.right[i]);
				if (payY == null) {
					payY = y.payoff2;
				}
				for (int j = 0; j < y.probVec2.length; ++j) {					
					printRow(game.col(j), y.probVec2[j], colpp, true);
				}
				colpp.endRow();
			}
			
			printRow("\u00A3" + game.firstPlayer(), payX, colpp, false);
			printRow("\u00A3" + game.secondPlayer(), payY, colpp, false);
			colpp.endRow();
		}
		colpp.alignLeft(0);
		out.print(colpp.toString());		
	}
	
	public static void printRow(String name, Rational value, ColumnTextWriter colpp, boolean excludeZero)
	{					
		Rational.printRow(name, value, colpp, excludeZero);	
	}

	/*private void printResult(Equilibrium eq, ColumnTextWriter colpp, boolean printVertex)
	{
		if (printVertex) {
			colpp.writeCol("x" + (eq.getVertex1() > 0 ? eq.getVertex1() : ""));
		}
		for (Rational coord : eq.probVec1) {
			if (!coord.isZero()) {
				colpp.writeCol(coord.toString());
			} else {
				colpp.writeCol("");
			}
		}
		colpp.writeCol(eq.payoff1.toString());

		colpp.writeCol("");

		if (printVertex) {
			colpp.writeCol("y" + (eq.getVertex1() > 0 ? eq.getVertex2() : ""));
		}
		for (Rational coord : eq.probVec2) {
			if (!coord.isZero()) {
				colpp.writeCol(coord.toString());
			} else {
				colpp.writeCol("");
			}
		}
		colpp.writeCol(eq.payoff2.toString());

		colpp.endRow();		
	}*/

	/*private void printMatrix(String name, Rational[][] matrix, String[] rowNames, String[] colNames, PrintWriter out)
	{
		ColumnTextWriter colpp = new ColumnTextWriter();		

		colpp.writeCol(name);
		colpp.alignLeft();
		for (String colName : colNames) {
			colpp.writeCol(colName);
		}
		colpp.endRow();

		//out.println(name + " " + rows + " " + cols);

		for(int i = 0; i < matrix.length; ++i) {
			colpp.writeCol(rowNames[i]);
			Rational[] row = matrix[i];
			for (Rational entry : row) {
				colpp.writeCol(entry.toString());		
			}
			colpp.endRow();	
		}		

		log.info(colpp.toString());
		out.println(colpp.toString());	
	}*/	
}
