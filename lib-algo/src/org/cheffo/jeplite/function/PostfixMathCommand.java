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
package org.cheffo.jeplite.function;
import org.cheffo.jeplite.util.*;
import org.cheffo.jeplite.*;
import java.util.HashMap;

public abstract class PostfixMathCommand
{
  public static final PostfixMathCommand ADD = new Add();
  public static final PostfixMathCommand DIVIDE = new Divide();
  public static final PostfixMathCommand MULTIPLY = new Multiply();
  public static final PostfixMathCommand UMINUS = new UMinus();
	public static final PostfixMathCommand AND = new Logical(0);
	public static final PostfixMathCommand OR = new Logical(1);

	protected int numberOfParameters;
	public final int getNumberOfParameters()
	{
		return numberOfParameters;
	}

  public double operation(double[] params) throws ParseException{throw new ParseException("Not implemented");}

	public void run(DoubleStack inStack)
		throws ParseException
	{
    double[] params = new double[numberOfParameters];
    for(int i=numberOfParameters-1; i>-1; i--)
      params[i] = inStack.pop();
		inStack.push(operation(params));
		return;
	}

  public static void fillFunctionTable(HashMap funTab) {
    funTab.put("sin", new Sine());
    funTab.put("cos", new Cosine());
    funTab.put("tan", new Tangent());
    funTab.put("asin", new ArcSine());
    funTab.put("acos", new ArcCosine());
    funTab.put("atan", new ArcTangent());
    funTab.put("sqrt", new Sqrt());

    funTab.put("log", new Logarithm());
    funTab.put("ln", new NaturalLogarithm());

    funTab.put("angle", new Angle());
    funTab.put("abs", new Abs());
    funTab.put("mod", new Modulus());
    funTab.put("sum", new Sum());

    funTab.put("rand", new Random());

    funTab.put("umin", new UMinus());
    funTab.put("add", new Add());
  }

  static class Abs extends PostfixMathCommand
  {
    public Abs() {
      numberOfParameters = 1;
    }

    public final void run(DoubleStack stack) {
      stack.push(Math.abs(stack.pop()));
    }
  }

  static class Add extends PostfixMathCommand
  {
    public Add()
    {
      numberOfParameters = 2;
    }

    public final void run(DoubleStack stack) {
      stack.push(stack.pop()+stack.pop());
    }
  }

  static class Angle extends PostfixMathCommand
  {
    public Angle()
    {
      numberOfParameters = 2;
    }

    public final void run(DoubleStack inStack)
      throws ParseException
    {
      double param2 = inStack.pop();
      double param1 = inStack.pop();
      inStack.push(Math.atan2(param1, param2));
    }
  }

  static class ArcCosine extends PostfixMathCommand {
    public ArcCosine()
    {
      numberOfParameters = 1;
    }

    public final void run(DoubleStack stack)
      throws ParseException
    {
      stack.push(Math.acos(stack.pop()));
    }
  }

  static class ArcSine extends PostfixMathCommand
  {
    public ArcSine()
    {
      numberOfParameters = 1;
    }

    public final double operation(double[] params)
      throws ParseException
    {
      return Math.asin(params[0]);
    }
  }

  static class ArcTangent extends PostfixMathCommand {
    public ArcTangent()
    {
      numberOfParameters = 1;
    }

    public final double operation(double[] params)
      throws ParseException
    {
      return Math.atan(params[0]);
    }
  }

  static class Cosine extends PostfixMathCommand
  {
    public Cosine()
    {
      numberOfParameters = 1;
    }

    public final double operation(double[] params)
      throws ParseException
    {
      return Math.cos(params[0]);
    }
  }

  static class Logarithm extends PostfixMathCommand
  {
    public Logarithm()
    {
      numberOfParameters = 1;
    }
    private static final double LOG_10 = Math.log(10);

    public final double operation(double[] params)
      throws ParseException
    {
      return Math.log(params[0])/LOG_10;
    }
  }

  static class NaturalLogarithm extends PostfixMathCommand
  {
    public NaturalLogarithm()
    {
      numberOfParameters = 1;
    }

    public final double operation(double[] params)
      throws ParseException
    {
      return Math.log(params[0]);
    }
  }

  static class Sine extends PostfixMathCommand
  {
    public Sine()
    {
      numberOfParameters = 1;
    }

    public final double operation(double[] params)
      throws ParseException
    {
        return Math.sin(params[0]);
    }
  }

  static class Tangent extends PostfixMathCommand
  {
    public Tangent()
    {
      numberOfParameters = 1;
    }

    public final double operation(double[] params)
      throws ParseException
    {
      return Math.tan(params[0]);
    }
  }

  static class UMinus extends PostfixMathCommand
  {
    public UMinus()
    {
      numberOfParameters = 1;
    }

    public final void run(DoubleStack stack)
      throws ParseException
    {
      stack.push(-stack.pop());
    }
  }

  static class Sqrt extends PostfixMathCommand
  {
    public Sqrt()
    {
      numberOfParameters = 1;
    }

    public final void run(DoubleStack stack)
      throws ParseException
    {
      stack.push(Math.sqrt(stack.pop()));
    }
  }

  public static class Divide extends PostfixMathCommand
  {
	  public Divide()
	  {
		  numberOfParameters = 2;
	  }

	  public final void run(DoubleStack stack) {
	    double p2 = stack.pop();
	    stack.push(stack.pop()/p2);
	  }

	  public final double operation(double[] params)
		  throws ParseException
	  {
	    return params[0]/params[1];
	  }
  }

  public static class Subtract extends PostfixMathCommand
  {
	  public Subtract()
	  {
		  numberOfParameters = 2;
	  }

    public final double operation(double[] params){return params[0]-params[1];}
  }

  public static class Comparative extends PostfixMathCommand
  {
	  int id;
	  double tolerance;

    public double operation(double[] params) {return 0;}
	  public Comparative(int id_in)
	  {
		  id = id_in;
		  numberOfParameters = 2;
		  tolerance = 1e-6;
	  }

	  public final void run(DoubleStack inStack)
		  throws ParseException
	  {
		  double y = inStack.pop();
		  double x = inStack.pop();
		  int r;
		  switch (id)
		  {
			  case 0:
				  r = (x<y) ? 1 : 0;
				  break;
			  case 1:
				  r = (x>y) ? 1 : 0;
				  break;
			  case 2:
				  r = (x<=y) ? 1 : 0;
				  break;
			  case 3:
				  r = (x>=y) ? 1 : 0;
				  break;
			  case 4:
				  r = (x!=y) ? 1 : 0;
				  break;
			  case 5:
				  r = (x==y) ? 1 : 0;
				  break;
			  default:
				  throw new ParseException("Unknown relational operator");
		  }
		  inStack.push(r);
	  }
  }

  public static class Power extends PostfixMathCommand
  {
	  public Power()
	  {
		  numberOfParameters = 2;
	  }

    public final double operation(double[] params) {return 0;}
	  public final void run(DoubleStack inStack)
		  throws ParseException
	  {
		  double param2 = inStack.pop();
		  double param1 = inStack.pop();

		  inStack.push(Math.pow(param1, param2));
	  }
  }

  static class Random extends PostfixMathCommand
  {
	  public Random()
	  {
		  numberOfParameters = 0;

	  }

    public double operation(double[] params){return 0;}

	  public final void run(DoubleStack inStack)
		  throws ParseException
	  {
		  inStack.push(Math.random());
	  }
  }

  public static class Logical extends PostfixMathCommand
  {
	  int id;

	  public Logical(int id_in)
	  {
		  id = id_in;
		  numberOfParameters = 2;
	  }

    public final double operation(double[] params) {return 0;}
	  public final void run(DoubleStack inStack)
		  throws ParseException
	  {
		  double y = inStack.pop();
		  double x = inStack.pop();
		  int r;

		  switch (id)
		  {
			  case 0:
				  // AND
				  r = ((x!=0d) && (y!=0d)) ? 1 : 0;
				  break;
			  case 1:
				  // OR
				  r = ((x!=0d) || (y!=0d)) ? 1 : 0;
				  break;
			  default:
				  r = 0;
		  }

		  inStack.push(r);
		  return;
	  }
  }

  public static class Multiply extends PostfixMathCommand
  {
	  public Multiply()
	  {
		  numberOfParameters = 2;
	  }

    public final double operation(double[] params) {return 0;}
	  public final void run(DoubleStack inStack)
		  throws ParseException
	  {
		  inStack.push(inStack.pop()*inStack.pop());
		  return;
	  }
  }

  public static class Not extends PostfixMathCommand
  {
	  public Not()
	  {
		  numberOfParameters = 1;

	  }

    public double operation(double[] params) {return 0;}
	  public void run(DoubleStack inStack)
		  throws ParseException
	  {
		  double param = inStack.pop();
		  int r = (param==0) ? 1 : 0;
		  inStack.push(r);
		  return;
	  }

  }

  public static class Modulus extends PostfixMathCommand
  {
	  public Modulus()
	  {
		  numberOfParameters = 2;
	  }

    public double operation(double[] params){return 0;}
	  public final void run(DoubleStack inStack)
		  throws ParseException
	  {
		  double param2 = inStack.pop();
		  double param1 = inStack.pop();
		  double result = param1 % param2;
		  inStack.push(result);
		  return;
	  }
  }

  static class Sum extends PostfixMathCommand
  {
	  public Sum()
	  {
		  numberOfParameters = -1;
	  }

    public final double operation(double[] params){return 0;}
	  public void run(DoubleStack inStack)
		  throws ParseException
	  {
		  if (null == inStack)
		  {
			  throw new ParseException("Stack argument null");
		  }
	  double r = 0;
	  while(!inStack.isEmpty())
	      r += inStack.pop();
	  inStack.push(r);
	  }
  }
}
