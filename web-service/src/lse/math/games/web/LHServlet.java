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
* adapted by Tobenna Peter, Igwe
*/
@SuppressWarnings("serial")
public class LHServlet extends AbstractRESTServlet 
{    
    private static final Logger log = Logger.getLogger(LHServlet.class.getName());
    final static String lineSeparator = System.getProperty("line.separator");
	
    private String os;
    //program1=Create H-representation
    private String program="inlh";


    public void init(ServletConfig config) 
        throws ServletException
    {
        super.init(config);           
        os=System.getProperty("os.name");
        if (os.startsWith("Windows")){
            program += ".exe";
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
        File f; 
        String consoleOutput="";

        int estimate=Integer.parseInt(request.getParameter("es"));
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
		
        if (!this.hasErrors(request)) 
        {
            game = new Bimatrix(new String[]{"A" , "B"}, a, b, rowNames, colNames);
			
            try {
                f = new File(pathToAlgo+program);
                Runtime rt=Runtime.getRuntime();
                Process p=null;
                String[] cmdArray = null;

                //Call external program and create H-Representation
                if(estimate == 0)
                    cmdArray = new String[]{f.getCanonicalPath(), "-e"};
                else if(estimate == 1)
                    cmdArray = new String[]{f.getCanonicalPath(), "-p"};
                p = rt.exec(cmdArray);
                
                BufferedWriter out = new BufferedWriter(new OutputStreamWriter(p.getOutputStream()));
                BufferedReader bri = new BufferedReader(new InputStreamReader(p.getInputStream()));
                out.write("m= " + nrows + " n= " + ncols);
                out.write("A= " + processMatrix(a));
                out.write("B= " + processMatrix(b));
                out.flush();
                out.close();
                
                p.waitFor();
				
                //Read consoleOutput
                String line;
                String lineSeparator = System.getProperty("line.separator");
                while ((line = bri.readLine()) != null) {
                    consoleOutput+=line+lineSeparator;
                }
                bri.close();
                log.info(consoleOutput);
                p.waitFor();
            } catch (IOException e1){
                addError(request, e1.getMessage());
                log.log(Level.SEVERE,e1.toString());
            } catch(Throwable e2)	{
                addError(request, e2.getMessage());
                log.log(Level.SEVERE,e2.toString());
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
                    outStrBuilder.append(formatOutput(processOutput(consoleOutput, true, rowNames, colNames), estimate));
                    outStrBuilder.append(lineSeparator);
                    outStrBuilder.append("Decimal:");
                    outStrBuilder.append(lineSeparator);
                    outStrBuilder.append(formatOutput(processOutput(consoleOutput, false, rowNames, colNames), estimate));

                    response.getWriter().println(outStrBuilder.toString());
                }
            } catch (Exception ex) {
                ex.printStackTrace();
                response.getWriter().println(ex.getStackTrace());
            }
			
        }
    }
    
    private String processMatrix(Rational[][] A)
    {
        String s = "";
        String lineSeparator = System.getProperty("line.separator");
        
        for (int i=0; i < A.length; i++)
        {
            for (int j=0; j < A[i].length; j++)
            {
                s += " " + A[i][j];
            }
            s += lineSeparator;
        }
        return s;
    }
		
    private <T> boolean checkDimensions(T[][] mat, int row, int col)
    {
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
    
    private String processOutput(String s, Boolean rational, String[] rowNames, String[] colNames)
    {
        StringBuilder output = new StringBuilder();
        String lines[] = s.split("\\r?\\n");
        String lineSeparator = System.getProperty("line.separator");
        
        for (int i = 0; i < lines.length; ++i)
        {
            output.append(processLine(lines[i], rational, rowNames, colNames));
            output.append(lineSeparator);
        }
        
        return output.toString();
    }
    
    private String processLine(String l, Boolean rational, String[] rowNames, String[] colNames)
    {
        StringBuilder output = new StringBuilder();
        String entries[] = l.split("\\s+");
        
        if (entries[0].contains("P") || entries[0].contains("E"))
        {
            output.append(entries[0] + " ");
            for (int i = 1; i < entries.length; ++i)
            {
                if (entries[i].contains("P") || entries[i].contains("E") || entries[i].contains("d"))
                {
                    output.append(entries[i] + " ");
                    continue;
                }
                if (rational)
                {
                    output.append(entries[i] + " ");
                }
                else
                {
                    String ts = Double.toString((Math.round(Rational.valueOf(entries[i]).doubleValue() *100000.)/100000.));
                    if (ts.equals("0.0")) {
                        ts="0";
                    }
                    output.append(ts + " ");
                }
            }
        }
        else if (entries[0].contains("L"))
        {
            output.append(entries[0] + " ");
            output.append(entries[1] + " ");
            
            for (int i = 2; i < entries.length; ++i)
            {
                if (i >= rowNames.length + colNames.length + 2)
                    break;
                
                if (i == rowNames.length + 2)
                    output.append(" - ");
                
                String label = (i - 2 < rowNames.length) ? rowNames[i - 2] : colNames[i - rowNames.length - 2];
                output.append(entries[i].replace((i - 1) + "->", label + "->") + " ");
            }
        }
        
        return output.toString();
    }
    
    private String formatOutput(String s, int estimate)
    {
        String lines[] = s.split("\\r?\\n");
        Vector<Integer> l=new Vector<Integer>();
        if (estimate == 1)
        {
            String p1[] = lines[4].split("\\s+");
            for (int j = 0; j < p1.length; j++)
            {
                l.add(p1[j].length());
            }
        }
        for (int i=0;i<lines.length;i++){
            String p1[] = lines[i].split("\\s+");
            if (i==0) {
                if (estimate == 0)
                {
                    for (int j=0;j<p1.length;j++) {
                        l.add(p1[j].length());	
                    }
                }
                else
                    i = 3;
            
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
