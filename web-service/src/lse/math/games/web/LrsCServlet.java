package lse.math.games.web;

import java.io.BufferedReader;
import java.io.BufferedWriter;

import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.File;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.io.OutputStream;
import java.io.OutputStreamWriter;

import java.util.Arrays;
import java.util.LinkedList;
import java.util.Vector;

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



/**
 * @author Martin Prause
 * adapted by Rahul Savani
 */
@SuppressWarnings("serial")
public class LrsCServlet extends AbstractRESTServlet 
{    
	private static final Logger log = Logger.getLogger(LrsCServlet.class.getName());
	
	private String os;
	//program1=Create H-representation
	private String program1="";
	//program2=Solve equation system
	private String program2="";
	//program3=Estimate process time
	private String program3="";
	//program4=Clique process
	private String program4="";


	public void init(ServletConfig config) 
	throws ServletException
	{
		super.init(config);           
		os=System.getProperty("os.name");
		if (os.startsWith("Windows")){
			program1="prepare_nash.exe";
			program2="nash.exe";
			program3="lrs.exe";
			program4="coclique3.exe"; 
		} else {
			program1="prepare_nash";
			program2="nash";
			program3="lrs";
			program4="coclique3";
		}
		outputPath = Paths.get(System.getProperty("user.dir")).resolve("game-output");
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

		String estimate=request.getParameter("es");
		Rational[][] a = parseMultiRowRatParam(request, "a");
		Rational[][] b = parseMultiRowRatParam(request, "b");
		String[] rowNames = request.getParameter("r") != null ? request.getParameter("r").split(" ") : null;
		String[] colNames = request.getParameter("c") != null ? request.getParameter("c").split(" ") : null;
		String algo =  request.getParameter("algo");
		String pathToAlgo=request.getParameter("d");
		String maxSeconds=request.getParameter("ms");
		int nrows = 0;
		int ncols = 0;

		//Check payoff matrix
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
		
			if (estimate.equals("0")) {	
						try {
							//Create the tempfiles
							for (int i=0;i<3;i++){
								f[i]=File.createTempFile("game","lrs",outputPath.toFile());
								log.info(f[i].getCanonicalPath());
							}
							//Write the game to a file
							FileWriter fstream= new FileWriter(f[0]);
							BufferedWriter out = new BufferedWriter(fstream);
							out.write(game.printFormat());
							out.close();
							
							Runtime rt=Runtime.getRuntime();
							Process p=null;
		
							//Call external program and create H-Representation
							String[] cmdArray1 = new String[]{pathToAlgo+program1, 
									f[0].getCanonicalPath(),
									f[1].getCanonicalPath(),
									f[2].getCanonicalPath()};
							p = rt.exec(cmdArray1);
							p.waitFor();
							
							//Call external program and calculate equilibria
							String[] cmdArray2 = new String[]{pathToAlgo+program2, 
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
							addError(request, e1.getMessage());
							log.log(Level.SEVERE,e1.toString());
						} catch(Throwable e2)	{
							addError(request, e2.getMessage());
							log.log(Level.SEVERE,e2.toString());
						} finally {
							//Delete files
							for (int i=0;i<3;i++){
								if (f[i]!=null) {
									f[i].delete();
								}
							}
							
						}
					try {
						this.writeResponseHeader(request, response);
						if (game != null) {
							StringBuilder outStrBuilder=new StringBuilder();
							outStrBuilder.append("Strategic form: ");
							outStrBuilder.append(lineSeparator);
							outStrBuilder.append(lineSeparator);
							outStrBuilder.append(game.printFormatHTML());
							outStrBuilder.append(lineSeparator);
							outStrBuilder.append(lineSeparator);
							outStrBuilder.append("EE = Extreme Equilibrium, EP = Expected Payoffs");
							outStrBuilder.append(lineSeparator);
							outStrBuilder.append(lineSeparator);
							outStrBuilder.append("Rational:");
							outStrBuilder.append(lineSeparator);
							outStrBuilder.append(lineSeparator);
							StringBuilder clique=new StringBuilder();
							outStrBuilder.append(formatOutput(processOutput(consoleOutput,true,clique)));
							outStrBuilder.append(lineSeparator);
							outStrBuilder.append("Decimal:");
							outStrBuilder.append(lineSeparator);
							outStrBuilder.append(lineSeparator);
							outStrBuilder.append(formatOutput(processOutput(consoleOutput,false,clique)));
							outStrBuilder.append(processClique(pathToAlgo,clique));

							File outFile=File.createTempFile("stratform-lrs-all-",".txt",outputPath.toFile());
							//Write the game to a file
							FileWriter fstream= new FileWriter(outFile);
							BufferedWriter out = new BufferedWriter(fstream);
							out.write(outStrBuilder.toString());
							out.close();

							response.getWriter().println(outStrBuilder.toString());
						}
					} catch (Exception ex) {
						response.getWriter().println(ex.getMessage());
					}
				
				} else if (estimate.equals("1")) {
					try {
						//Create the tempfiles
						for (int i=0;i<3;i++){
							f[i]=File.createTempFile("game","lrs",outputPath.toFile());
							log.info(f[i].getCanonicalPath());
						}
						//Write the game to a file
						FileWriter fstream= new FileWriter(f[0]);
						BufferedWriter out = new BufferedWriter(fstream);
						out.write(game.printFormat());
						out.close();
						
						Runtime rt=Runtime.getRuntime();
						Process p=null;
	
						//Call external program and create H-Representation
						String[] cmdArray1 = new String[]{pathToAlgo+program1, 
								f[0].getCanonicalPath(),
								f[1].getCanonicalPath(),
								f[2].getCanonicalPath()};
						p = rt.exec(cmdArray1);
						p.waitFor();
						
						//Add parameters to the outputfile of the H-representation
						String lineSeparator = System.getProperty("line.separator");
						fstream= new FileWriter(f[1],true);
						out = new BufferedWriter(fstream);
						out.write(lineSeparator+"maxdepth 5");
						out.write(lineSeparator+"estimates 1");
						out.close();
						
						//Call external program and estimate the process time
						String[] cmdArray2 = new String[]{pathToAlgo+program3,f[1].getCanonicalPath()};
						p = rt.exec(cmdArray2);
						
						//Read consoleOutput
						String line;

						String bases="0";
						String nodes="0";
						String time="0";

						int startIndex=-1;
						int endIndex=-1;
						
						
						BufferedReader bri = new BufferedReader(new InputStreamReader(p.getInputStream()));
							while ((line = bri.readLine()) != null) {
								if (line.startsWith("*Estimates")){
									log.info(line);
									startIndex=line.indexOf("bases=");
									endIndex=line.indexOf(" ",startIndex);
									bases=line.substring(startIndex+6,endIndex).trim();
									consoleOutput+=lineSeparator+"Bases:"+bases;
									log.info(bases);
								} else if (line.startsWith("*Total number")){
									log.info(line);
									startIndex=line.indexOf("evaluated:");
									endIndex=line.indexOf(" ",startIndex);
									nodes=line.substring(startIndex+10,line.length()).trim();
									consoleOutput+=lineSeparator+"Nodes:"+nodes;
									log.info(nodes);
								} else if (line.startsWith("*Estimated total")){
									log.info(line);
									startIndex=line.indexOf("time=");
									endIndex=line.indexOf(" ",startIndex);
									time=line.substring(startIndex+5,endIndex).trim();
									consoleOutput+=lineSeparator+"Time(sec):"+time;
									log.info(time);
								}
						      }
						bri.close();
						p.waitFor();
						
						int _bases=0;
						int _nodes=0;
						double _time=0;
						double esTime=0;
						String esTimeText="Estimation:";
						try {
							_bases=Integer.parseInt(bases);
							_nodes=Integer.parseInt(nodes);
							_time=Double.parseDouble(time);
							if ((_nodes>0) && (_time>0)) {
								esTime=(_bases/_nodes)*_time;
								esTimeText+=Math.round(esTime);
							} else {
								esTimeText+="0";
							}
						} catch (Exception e) {
							addError(request, e.getMessage());
							log.log(Level.SEVERE,e.toString());
						}
						
						consoleOutput+=lineSeparator+esTimeText;
						consoleOutput+=lineSeparator+"MaxSeconds:"+maxSeconds;
						log.log(Level.SEVERE,consoleOutput);
					
					} catch (IOException e1){
						addError(request, e1.getMessage());
						log.log(Level.SEVERE,e1.toString());
					} catch(Throwable e2)	{
						addError(request, e2.getMessage());
						log.log(Level.SEVERE,e2.toString());
					} finally {
						//Delete files
						for (int i=0;i<3;i++){
							if (f[i]!=null) {
								f[i].delete();
							}
						}
						
					}
					try {
						this.writeResponseHeader(request, response);
						
						if (game != null) {
							response.getWriter().println("STEP");
							response.getWriter().println(consoleOutput);
						
						}
						
					} catch (Exception ex) {
						response.getWriter().println(ex.getMessage());
					}
				}
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
	
	private String processClique(String pathToAlgo,StringBuilder cliqueInput){
		String ret=new String("");
		File[] f= new File[2]; 
		
		//Not working on windows
		if (program4.equals(""))
			return ret;
		
		try {
			//Create the tempfiles
			for (int i=0;i<2;i++){
				f[i]=File.createTempFile("clique","lrs",outputPath.toFile());
				log.info(f[i].getCanonicalPath());
			}
			//Write cliqueInput to File
			FileWriter fstream= new FileWriter(f[0]);
			BufferedWriter out = new BufferedWriter(fstream);
			out.write(cliqueInput.toString());
			out.close();
			
			Runtime rt=Runtime.getRuntime();
			Process p=null;

			//Call external program 
			String[] cmdArray1 = new String[]{pathToAlgo+program4, 
					"<"+f[0].getCanonicalPath()};
			p = rt.exec(pathToAlgo+program4);
			
			OutputStream os = p.getOutputStream();
		    OutputStreamWriter osr = new OutputStreamWriter(os);
		    BufferedWriter bw=new BufferedWriter(osr);
		    bw.write(cliqueInput.toString());
		    bw.flush();
		    bw.close();
		
					
			String line;
			String lineSeparator = System.getProperty("line.separator");
			BufferedReader bri = new BufferedReader(new InputStreamReader(p.getInputStream()));
				while ((line = bri.readLine()) != null) {
					ret+=line+lineSeparator;
			      }
			bri.close();
			p.waitFor();
			
			
		} catch (IOException e1){
			log.log(Level.SEVERE,e1.toString());
		} catch(Throwable e2)	{
		log.log(Level.SEVERE,e2.toString());
		} finally {
			//Delete files
			for (int i=0;i<2;i++){
				if (f[i]!=null) {
					f[i].delete();
		    		}
			}
			
		}
		
		return ret;
	}
	
	private String processOutput(String s,Boolean rational,StringBuilder clique_string){
		
		String lines[] = s.split("\\r?\\n");
		String ts="";
		Boolean start=false;
		int eq=0;
		String ret="";
		if (clique_string==null){
			clique_string=new StringBuilder();
		} else {
			clique_string.setLength(0);
		}
		LinkedList<String> indexP1=new LinkedList<String>();
		LinkedList<String> indexP2=new LinkedList<String>();
		
		for (int i=0;i<lines.length;i++){
			if ((lines[i]!=null) && (lines[i].length()>=5) && (lines[i].substring(0,4).equals("*Num"))) {
				start=false;
			}	
			
			if (start) {
				if ((lines[i]!=null) && (lines[i].length()>=1)) {
					eq++;
					LinkedList<String> lp1=new LinkedList<String>();
					LinkedList<String> lp2=new LinkedList<String>();
					while ((lines[i]!=null) && (lines[i].length()>=1)) {
						String d1[] = lines[i].split("\\s+");
						if (d1[0].trim().equals("1")) {
							lp1.add(lines[i]);
							
						}
						if (d1[0].trim().equals("2")) {
							lp2.add(lines[i]);
							
						}
						i++;
					}

					if (lp1.size()>lp2.size()){
						while (lp2.size()<lp1.size()) {
							if (lp2.size()>0) {
								String d1=lp2.get(lp2.size()-1);
								
								lp2.add(new String(d1));
							} else {
								lp2.add(new String(""));
							}
						}
					}
					if (lp1.size()<lp2.size()){
						while (lp1.size()<lp2.size()) {
							if (lp1.size()>0) {
								String d1=lp1.get(lp1.size()-1);
								
								lp1.add(new String(d1));
							} else {
								lp1.add(new String(""));
							}
						}
					}	
					
										
					for (int k1=0;k1<lp1.size();k1++) {
						
						String iP1=lp1.get(k1);
						String iP2=lp2.get(k1);
						int indexEqP1=0;
						int indexEqP2=0;
						
						for (int n=0;n<indexP1.size();n++){
							if (indexP1.get(n).equals(iP1))
								indexEqP1=n+1;
						}
						if (indexEqP1==0){
							indexP1.add(iP1);
							indexEqP1=indexP1.size();
						}
						
						for (int n=0;n<indexP2.size();n++){
							if (indexP2.get(n).equals(iP2))
								indexEqP2=n+1;
						}
						if (indexEqP2==0){
							indexP2.add(iP2);
							indexEqP2=indexP2.size();
						}
						
						String p2[] = lp1.get(k1).split("\\s+");
						String p1[] = lp2.get(k1).split("\\s+");
						
						if (k1>0) {
							eq++;
						}
						
						ret+="EE "+eq+" P1: ("+indexEqP1+") ";
						clique_string.append(indexEqP1+" ");
						
						for (int j=1;j<p2.length-1;j++){
							if (rational) {
								ret+=p2[j]+" ";
							}else {
								ts=Double.toString((Math.round(Rational.valueOf(p2[j]).doubleValue() *100000.)/100000.));
								if (ts.equals("0.0")) {
									ts="0";
								}
								ret+=ts+" ";
							}
						}
						
						if (rational) {
							ret+="EP= "+p1[p1.length-1]+" ";
						} else {
							ts=Double.toString((Math.round(Rational.valueOf(p1[p1.length-1]).doubleValue() *100000.)/100000.));
							if (ts.equals("0.0")) {
								ts="0";
							}
							ret+="EP= "+ts+" ";
						}
						
						ret+="P2: ("+indexEqP2+") ";
						clique_string.append(indexEqP2);
						clique_string.append(System.getProperty("line.separator"));

						for (int j=1;j<p1.length-1;j++){
							if (rational) {
								ret+=p1[j]+" ";
							} else {
								ts=Double.toString((Math.round(Rational.valueOf(p1[j]).doubleValue() *100000.)/100000.));
								if (ts.equals("0.0")) {
									ts="0";
								}
								ret+=ts+" ";
							}
						}
						
						if (rational) {
							ret+="EP= "+p2[p2.length-1]+System.getProperty("line.separator") ;
						} else {
							ts=Double.toString((Math.round(Rational.valueOf(p2[p2.length-1]).doubleValue() *100000.)/100000.));
							if (ts.equals("0.0")) {
								ts="0";
							}
							ret+="EP= "+ts +System.getProperty("line.separator") ;
						}

					}
					
				}
				
				/*
				if ((lines[i]!=null) && (lines[i].length()>=1)) {
					eq++;
					String p1[] = lines[i].split("\\s+");
					i++;
					String p2[] = lines[i].split("\\s+");
					
					ret+="EE "+eq+" P1: ("+eq+") ";
					
					for (int j=1;j<p2.length-1;j++){
						if (rational) {
							ret+=p2[j]+" ";
						}else {
							ts=Double.toString((Math.round(Rational.valueOf(p2[j]).doubleValue() *100000.)/100000.));
									
							ret+=ts+" ";
						}
					}
					
					if (rational) {
						ret+="EP= "+p1[p1.length-1]+" ";
					} else {
						ts=Double.toString((Math.round(Rational.valueOf(p1[p1.length-1]).doubleValue() *100000.)/100000.));
						ret+="EP= "+ts+" ";
					}
					
					ret+="P2: ("+eq+") ";

					for (int j=1;j<p1.length-1;j++){
						if (rational) {
							ret+=p1[j]+" ";
						} else {
							ts=Double.toString((Math.round(Rational.valueOf(p1[j]).doubleValue() *100000.)/100000.));
							ret+=ts+" ";
						}
					}
					
					if (rational) {
						ret+="EP= "+p2[p2.length-1]+System.getProperty("line.separator") ;
					} else {
						ts=Double.toString((Math.round(Rational.valueOf(p2[p2.length-1]).doubleValue() *100000.)/100000.));
						ret+="EP= "+ts +System.getProperty("line.separator") ;
					}
				} */
				
			}
			
				
			if ((lines[i]!=null) && (lines[i].length()>=5) && (lines[i].substring(0,4).equals("****"))) {
				start=true;
			}
			
			
		}
		
		return ret;
	}
	
	private String formatOutput(String s){
		String lines[] = s.split("\\r?\\n");
		Vector<Integer> l=new Vector<Integer>();
		for (int i=0;i<lines.length;i++){
			String p1[] = lines[i].split("\\s+");
			if (i==0) {
				for (int j=0;j<p1.length;j++) {
					l.add(p1[j].length());	
				}
			} else {
				for (int j=0;j<p1.length;j++) {
					if (((int)l.get(j)) < p1[j].length()) {
						l.setElementAt(p1[j].length(), j);
					}
				}
			}
			
		}
		String ret="";
		for (int i=0;i<lines.length;i++){
			String p1[] = lines[i].split("\\s+");
			for (int j=0;j<p1.length;j++) {
				int k=(int)l.get(j)-p1[j].length();
				for (int n=0;n<k;n++){
					ret+=" ";
				}
				ret+=p1[j]+" ";
			}
			ret+=System.getProperty("line.separator") ;
		}
		
		return ret;
	}

	
}
