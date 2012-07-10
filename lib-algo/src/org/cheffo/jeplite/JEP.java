/*****************************************************************************
JEP - Java Expression Parser
    JEP is a Java package for parsing and evaluating mathematical
	expressions. It currently supports user defined variables,
	constant, and functions. A number of common mathematical
	functions and constants are included.
  JEPLite is a simplified version of JEP.
JEP Author: Nathan Funk
JEPLite Author: Stephen "Cheffo" Kolaroff
JEP Copyright (C) 2001 Nathan Funk
JEPLite Copyright (C) 2002 Stefan  Kolarov
    JEPLite is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    JEPLite is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with JEPLite; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*****************************************************************************/
package org.cheffo.jeplite;
import java.io.*;
import java.util.*;
import org.cheffo.jeplite.*;
import org.cheffo.jeplite.function.*;
import org.cheffo.jeplite.util.*;

public class JEP {
	private HashMap symTab;
	private HashMap funTab;
	private SimpleNode topNode;
	private boolean debug=false;
	private Parser parser;
	private boolean hasError;
	private ParseException parseException;
	public JEP()
	{
		topNode = null;
		hasError = true;
		parseException = null;
		initSymTab();
		initFunTab();
		parser = new Parser(new StringReader(""));
		parseExpression("");
	}

  	/**
	  * Initializes the symbol table
	  */
	public void initSymTab() {
		symTab = new HashMap();
	}

	/**
	  * Initializes the function table
	  */
	public void initFunTab() {
		funTab = new HashMap();
	}

	/**
	  * Adds the standard functions to the parser. If this function is not called
		* before parsing an expression, functions such as sin() or cos() would
		* produce an "Unrecognized function..." error.
		* In most cases, this method should be called immediately after the JEP
		* object is created.
	  */
	public void addStandardFunctions()
	{
    PostfixMathCommand.fillFunctionTable(funTab);
	}

	/**
	  * Adds the constants pi and e to the parser. As addStandardFunctions(), this
	  * method should be called immediatly after the JEP object is created.
	  */
	public void addStandardConstants(){
		addVariable("pi", Math.PI);
		addVariable("e", Math.E);
	}

	/**
	  * Adds a new function to the parser. This must be done before parsing
	  * an expression so the parser is aware that the new function may be
	  * contained in the expression.
	  */
	public void addFunction(String functionName, Object function)
	{
  	funTab.put(functionName, function);
	}

	/**
	  * Adds a new variable to the parser, or updates the value of an
	  * existing variable. This must be done before parsing
	  * an expression so the parser is aware that the new variable may be
	  * contained in the expression.
	  * @param name Name of the variable to be added
	  * @param value Initial value or new value for the variable
	  * @return Double object of the variable
	  */
	public Double addVariable(String name, double value)
	{
	  ASTVarNode toAdd = (ASTVarNode)symTab.get(name);
	  if(toAdd!=null)
	    toAdd.setValue(value);
	  else {
	    toAdd = new ASTVarNode(ParserTreeConstants.JJTVARNODE);
	    toAdd.setName(name);
	    toAdd.setValue(value);
	    symTab.put(name, toAdd);
	  }
    return new Double(value);
	}

	public ASTVarNode getVarNode(String var) {
	  return (ASTVarNode)symTab.get(var);
	}

  public void setVarNode(String var, ASTVarNode node) {
    symTab.put(var, node);
  }

	/**
	  * Parses the expression
	  * @param expression_in The input expression string
	  */
	public void parseExpression(String expression_in)
	{
		Reader reader = new StringReader(expression_in);
		hasError = false;
		parseException = null;
		try
		{
			topNode = parser.parseStream(reader, symTab, funTab);
		} catch (Throwable e)
		{
			if (debug && !(e instanceof ParseException))
			{
				System.out.println(e.getMessage());
				e.printStackTrace();
			}
			topNode = null;
			hasError = true;
			if (e instanceof ParseException)
				parseException = (ParseException)e;
			else
			    parseException = null;
		}
		Vector errorList = parser.getErrorList();
		if (!errorList.isEmpty()) hasError = true;
	}

	/**
	  * Evaluates and returns the value of the expression. If the value is
	  * complex, the real component of the complex number is returned. To
	  * get the complex value, use getComplexValue().
	  * @return The calculated value of the expression. If the value is
	  * complex, the real component is returned. If an error occurs during
	  * evaluation, 0 is returned.
	  */
	public double getValue() throws ParseException
	{
    return getValue(new DoubleStack());
	}

  public SimpleNode getTopNode() {
    return topNode;
  }

	public double getValue(DoubleStack evalStack) throws ParseException {
	  topNode.getValue(evalStack);
	  return(evalStack.pop());
	}

	/**
	  * Reports whether there is an error in the expression
	  * @return Returns true if the expression has an error
	  */
	public boolean hasError()
	{
		return hasError;
	}

	/**
	  * Reports information on the error in the expression
	  * @return Returns a string containing information on the error;
	  * null if no error has occured
	  */
	public String getErrorInfo()
	{
		if (hasError)
		{
			Vector el = parser.getErrorList();
			String str = "";
			if (parseException == null && el.size()==0) str = "Syntax error\n";
			if (parseException != null) str = parseException.getErrorInfo() + "\n";
			for (int i=0; i<el.size(); i++)
				str += el.elementAt(i) + "\n";
			return str;
		}
		else
			return null;
	}
}