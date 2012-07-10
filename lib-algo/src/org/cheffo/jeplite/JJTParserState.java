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
class JJTParserState {
  private SimpleNodeStack nodes;
  private IntegerStack marks;
  private int sp;		// number of nodes on stack
  private int mk;		// current mark
  private boolean node_created;
  JJTParserState() {
    nodes = new SimpleNodeStack(100);
    marks = new IntegerStack(100);
    sp = 0;
    mk = 0;
  }

  /* Determines whether the current node was actually closed and
     pushed.  This should only be called in the final user action of a
     node scope.  */
  final boolean nodeCreated() {
    return node_created;
  }

  /* Call this to reinitialize the node stack.  It is called
     automatically by the parser's ReInit() method. */
  void reset() {
    nodes.removeAllElements();
    marks.removeAllElements();
    sp = 0;
    mk = 0;
  }

  /* Returns the root node of the AST.  It only makes sense to call
     this after a successful parse. */
  final SimpleNode rootNode() {
    return nodes.elementAt(0);
  }

  final void pushNode(SimpleNode n) {
    nodes.push(n);
    ++sp;
  }

  /* Returns the node on the top of the stack, and remove it from the
     stack.  */
  final SimpleNode popNode() {
    if (--sp < mk) {
      mk = marks.pop();
    }
    return nodes.pop();
  }

  final SimpleNode peekNode() {
    return nodes.peek();
  }

  /* Returns the number of children on the stack in the current node
     scope. */
  final int nodeArity() {
    return sp - mk;
  }

  final void clearNodeScope(SimpleNode n) {
    while (sp > mk) {
      popNode();
    }
    mk = marks.pop();
  }

  final void openNodeScope(SimpleNode n) {
    marks.push(mk);
    mk = sp;
    n.jjtOpen();
  }

  final void closeNodeScope(SimpleNode n, int num) {
    mk = marks.pop();
    while (num-- > 0) {
      SimpleNode c = popNode();
      c.jjtSetParent(n);
      n.jjtAddChild(c, num);
    }
    n.jjtClose();
    pushNode(n);
    node_created = true;
  }

  /* A conditional node is constructed if its condition is true.  All
     the nodes that have been pushed since the node was opened are
     made children of the the conditional node, which is then pushed
     on to the stack.  If the condition is false the node is not
     constructed and they are left on the stack. */
  final void closeNodeScope(SimpleNode n, boolean condition) {
    if (condition) {
      int a = nodeArity();
      mk = marks.pop();
      while (a-- > 0) {
	      SimpleNode c = popNode();
  	    c.jjtSetParent(n);
	      n.jjtAddChild(c, a);
      }
      n.jjtClose();
      pushNode(n);
      node_created = true;
    } else {
      mk = marks.pop();
      node_created = false;
    }
  }
}