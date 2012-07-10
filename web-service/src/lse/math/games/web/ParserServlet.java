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

import org.cheffo.jeplite.*;

/**
 * @author Martin Prause
 */
@SuppressWarnings("serial")
public class ParserServlet extends AbstractRESTServlet 
{    
	private static final Logger log = Logger.getLogger(ParserServlet.class.getName());
	
	
	public void init(ServletConfig config) 
	throws ServletException
	{
		super.init(config);           
	
	
		
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
		
	
		try {
		this.writeResponseHeader(request, response);
		
			response.getWriter().println("Answer: " + request.getParameter("d"));
			
			JEP jep = new JEP();
			jep.addVariable("x", 10);
			jep.parseExpression("x+1");
			
			Object result = jep.getValue();
			
			response.getWriter().println("Answer: " + result);
			
		
		} catch (Exception ex) {
			response.getWriter().println(ex.getMessage());
		}
	}



	
}
