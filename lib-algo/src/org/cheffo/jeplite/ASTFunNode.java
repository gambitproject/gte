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

import org.cheffo.jeplite.function.*;
import org.cheffo.jeplite.util.*;
import java.util.*;

public class ASTFunNode extends SimpleNode {
  private PostfixMathCommand pfmc;

  public ASTFunNode(int id) {
    super(id);
  }

  public ASTFunNode(Parser p, int id) {
    super(p, id);
  }

  public Object jjtAccept(ParserVisitor visitor, Object data) {
    return visitor.visit(this, data);
  }

  public void setFunction(String name_in, PostfixMathCommand pfmc_in)
  {
  	name = name_in;
    pfmc = pfmc_in;
  }

  public String toString()
  {
    if (name!=null)
    {
    	try {
      		return "Function \"" + name + "\" = " + getValue();
      	} catch (Exception e) {
      		return "Function \"" + name + "\"";
      	}
    }
    else
    {
      return "Function: no function class set";
    }
  }

	public double getValue() throws ParseException
	{
		double value = 0;
		DoubleStack tempStack = new DoubleStack();
    getValue(tempStack);
		return tempStack.pop();
	}

	public final void getValue(DoubleStack tempStack) throws ParseException {
	  double value = 0;
	  for (int i=0; i < jjtGetNumChildren(); i++)
	  {
		  children[i].getValue(tempStack);
	  }
	  if (pfmc!=null)
	  {
		  try {
			  pfmc.run(tempStack);
		  } catch (ParseException e)
		  {
			  String errorStr = "Error in \"" + name + "\" function: ";
			  errorStr += e.getErrorInfo();
			  throw new ParseException(errorStr);
		  }
	  }
	}
}