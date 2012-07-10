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
import org.cheffo.jeplite.util.*;
public final class ASTConstant extends SimpleNode {
  private double value;
  public ASTConstant(int id) {
    super(id);
  }

  public ASTConstant(Parser p, int id) {
    super(p, id);
  }

  public final void setValue(double val) {
    value = val;
  }

  public String toString() {
    return "Constant: " + value;
  }

  /*Return the Value of the node*/
  public final double getValue()
  {
    return value;
  }

  public final void getValue(DoubleStack stack) {
    stack.push(value);
  }
}