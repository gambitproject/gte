package lse.math.games.web;

import java.io.BufferedReader;
import java.io.BufferedWriter;

import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.File;

import java.util.Arrays;

import java.util.logging.Level;
import java.util.logging.Logger;

import javax.servlet.ServletConfig;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import lse.math.games.Rational;
import lse.math.games.matrix.Bimatrix;
import lse.math.games.io.ColumnTextWriter;
import lse.math.games.io.SettingLoader;


/**
 * @author Martin Prause
 */
@SuppressWarnings("serial")
public class LrsCServlet extends AbstractRESTServlet 
{    
	private static final Logger log = Logger.getLogger(LrsCServlet.class.getName());
	private SettingLoader settings;
	private String os;
	private String program1="";
	private String program2="";
	
	public void init(ServletConfig config) 
	throws ServletException
	{
		super.init(config);           
		settings=SettingLoader.getInstance();
		os=System.getProperty("os.name");
		
		if (os.startsWith("Windows")){
			program1="prepare_nash.exe";
			program2="nash.exe";
		} else {
			program1="prepare_nash";
			program2="nash";
		}
		
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
		File[] f= new File[3]; //Later we need different temp files; 
		String consoleOutput="";
		
		try {
			Rational[][] a = parseMultiRowRatParam(request, "a");
			Rational[][] b = parseMultiRowRatParam(request, "b");
			String[] rowNames = request.getParameter("r") != null ? request.getParameter("r").split(" ") : null;
			String[] colNames = request.getParameter("c") != null ? request.getParameter("c").split(" ") : null;
			String algo =  request.getParameter("algo");

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
					addError(request, "Row names length does not match pay matrix " + Arrays.toString(rowNames));
			}
			if (colNames != null && colNames.length != ncols) {
					addError(request, "Col names length does not match pay matrix " + Arrays.toString(colNames));
			}

			if (!this.hasErrors(request)) 
			{
				game = new Bimatrix(new String[]{"A" , "B"}, a, b, rowNames, colNames);
				
				log.info(game.toString());
				log.info(settings.getProperty("path.algo.lrs"));
				
				try {
					
					//Create the tempfiles
					for (int i=0;i<3;i++){
						f[i]=File.createTempFile("game","lrs");
						log.info(f[i].getCanonicalPath());
					}
					
					
					
					//Write the game to a file
					FileWriter fstream= new FileWriter(f[0]);
					BufferedWriter out = new BufferedWriter(fstream);
					out.write(game.printFormat());
					out.close();
					
					Runtime rt=Runtime.getRuntime();
					Process p=null;

					//Call external program
					String[] cmdArray1 = new String[]{settings.getProperty("path.algo.lrs")+program1, 
							f[0].getCanonicalPath(),
							f[1].getCanonicalPath(),
							f[2].getCanonicalPath()};
					p = rt.exec(cmdArray1);
					p.waitFor();
					
					
					//Call external program
					String[] cmdArray2 = new String[]{settings.getProperty("path.algo.lrs")+program2, 
							f[1].getCanonicalPath(),
							f[2].getCanonicalPath()};
					p = rt.exec(cmdArray2);
					
					//Read consoleOutput
					String line;
					String lineSeparator = System.getProperty("line.separator");
					BufferedReader bri = new BufferedReader(new InputStreamReader(p.getInputStream()));
						while ((line = bri.readLine()) != null) {
							consoleOutput+=line+lineSeparator;
					      }
					bri.close();
					p.waitFor();
				} catch (IOException e1){
					log.log(Level.SEVERE,e1.toString());
				} catch(Throwable e2)	{
					log.log(Level.SEVERE,e2.toString());
				} finally {
					//Delete files
					for (int i=0;i<3;i++){
						if (f[i]!=null) {
							f[i].delete();
						}
					}
					
				}
			} //has !errors
			
		} catch (Exception ex) {
			addError(request, ex.getMessage());
		}
		try {
		this.writeResponseHeader(request, response);
		if (game != null) {
			response.getWriter().println("NormalForm " + game.nrows() + " " + game.ncols());
			response.getWriter().println(game.printFormat());
			response.getWriter().println("From C Algo:");
			response.getWriter().println(consoleOutput);
		}
		} catch (Exception ex) {
			response.getWriter().println(ex.getMessage());
		}
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

	
	
	public static void printRow(String name, Rational value, ColumnTextWriter colpp, boolean excludeZero)
	{					
		Rational.printRow(name, value, colpp, excludeZero);	
	}

	
}
