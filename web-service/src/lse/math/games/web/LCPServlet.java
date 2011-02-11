package lse.math.games.web;

import java.io.IOException;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletConfig;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import lse.math.games.Rational;
import lse.math.games.lcp.LemkeAlgorithm;
import lse.math.games.lcp.LemkeAlgorithm.LemkeException;
import lse.math.games.lcp.LemkeAlgorithm.RayTerminationException;
import lse.math.games.lcp.LemkeAlgorithm.TrivialSolutionException;
import lse.math.games.lcp.LCP;

/**
 * @author Mark Egesdal
 */
public class LCPServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
	
	private String jsppage;
	
	public void init(ServletConfig config) 
    throws ServletException
    {
           super.init(config);
           jsppage = config.getInitParameter("jsppage");
    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		RequestDispatcher dispatcher = getServletContext().getRequestDispatcher(jsppage);
		dispatcher.forward(request,response);
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException 
	{		
		boolean inputOk = true;
		LCP lcp = null;
		Rational[] d = parseSingleRowParam(request, "d");
		if (d == null) inputOk = false;
		else {
			lcp = new LCP(d.length);
			for (int i = 0; i < lcp.size(); ++i) {
				lcp.setd(i, d[i]);
			}			
		}
		
		Rational[] q = parseSingleRowParam(request, "q");
		if (q == null) inputOk = false;
		else if (lcp != null) {
			if (q.length != lcp.size()) {
				inputOk = false;
				request.setAttribute("qerror", "q vector does not match dimension of d vector");
			} else {
				for (int i = 0; i < lcp.size(); ++i) {
					lcp.setq(i, q[i]);
				}
			}
		}
		Rational[][] M = parseMultiRowParam(request, "M");
		if (M == null) inputOk = false;
		else if (lcp != null) {
			if (M.length != lcp.size()) {
				inputOk = false;
				request.setAttribute("Merror", "M matrix does not match dimension of d vector");
			} else {
				for (int i = 0; i < lcp.size(); ++i) {
					if (M[i].length == lcp.size()) {
						for (int j = 0; j < lcp.size(); ++j) {
							lcp.setM(i, j, M[i][j]);
						}
					} else {
						inputOk = false;
						request.setAttribute("Merror", "M matrix is not square");
					}
				}
			}
		}
		
		if (inputOk) {
			solve(request, lcp);
		} else {
			request.setAttribute("error", "Invalid inputs:");
		}
		doGet(request, response);
	}

	private void solve(HttpServletRequest request, LCP lcp) 
	{
		LemkeAlgorithm lemke = new LemkeAlgorithm();
		try {
			//lemke.init(lcp);
			Rational[] z = lemke.run(lcp);
			
			String[] zStr = new String[z.length];
			for (int i = 0; i < zStr.length; ++i)
			{
				zStr[i] = z[i].toString();			
			}
			request.setAttribute("z", zStr);				
		} 
		catch (TrivialSolutionException ex)
		{
			String[] zStr = new String[lcp.size()];
			for (int i = 0; i < zStr.length; ++i) {
				zStr[i] = "0";			
			}
			request.setAttribute("z", zStr);	
		}
		catch (RayTerminationException ex)
		{
			request.setAttribute("nosolz", ex.getMessage());
		}
		catch (LemkeException ex)
		{
			request.setAttribute("error", ex.getMessage());
		}
	}
	
	private Rational[] parseSingleRowParam(HttpServletRequest request, String name)
	{
		Rational[] vec = null;
		try { 
			String vecStr = request.getParameter(name);
			vec = parseVector(vecStr);
		} 
		catch (NumberFormatException ex)
		{
			request.setAttribute(name + "error", name + " vector has invalid entries");
		}
		return vec;
	}
	
	private Rational[][] parseMultiRowParam(HttpServletRequest request, String name)
	{
		Rational[][] mat = null;
		try { 
			String matStr = request.getParameter(name);
			mat = parseMatrix(matStr);
		} 
		catch (NumberFormatException ex)
		{
			mat = null;
			request.setAttribute(name + "error", name + " matrix has invalid entries");
		}
		return mat;
	}
	
	private Rational[][] parseMatrix(String matStr)
	{
		String[] vecStrArr = matStr.split("\\r\\n");
		Rational[][] mat = new Rational[vecStrArr.length][];
		for (int i = 0; i < mat.length; ++i)
		{
			mat[i] = parseVector(vecStrArr[i]);
		}
		return mat;
	}

	private Rational[] parseVector(String vecStr)
	{
		String[] strArr = vecStr.split(",?\\s+");
		Rational[] vec = new Rational[strArr.length];
		for (int i = 0; i < vec.length; ++i)
		{
			vec[i] = Rational.valueOf(strArr[i]);
		}
		return vec;
	}
}
