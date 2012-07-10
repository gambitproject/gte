package org.cheffo.jeplite.optimizer;

/**
 * Title:
 * Description:
 * Copyright:    Copyright (c) 2002
 * Company:
 * @author
 * @version 1.0
 */
import org.cheffo.jeplite.*;
import org.cheffo.jeplite.util.*;
import org.cheffo.jeplite.function.*;

import java.util.*;
public class ExpressionOptimizer implements ParserVisitor {

  SimpleNode node;
  final HashMap constTab = new HashMap();
  public ExpressionOptimizer(SimpleNode node) {
    this.node = node;
  }

  /**
   * Marks a variable name to be a constant name.
   */
  public void addConst(String constName) {
    constTab.put(constName, constName);
  }

  /**
   * Unmarks a variable name to be a constant name.
   */
  public void removeConst(String constName) {
    constTab.remove(constName);
  }

  public void clearConstants() {
    constTab.clear();
  }

  public SimpleNode optimize() {
    return (SimpleNode)node.jjtAccept(this, null);
  }

  public Object visit(ASTFunNode node, Object data) {
    SimpleNode res = node;
    try{
      boolean allConstNode = true;
      int numChildren = node.jjtGetNumChildren();
      SimpleNode[] nodes = new SimpleNode[numChildren];
      for(int i=0; i<numChildren; i++) {
        nodes[i] = (SimpleNode)node.jjtGetChild(i).jjtAccept(this, data);
        allConstNode &= (nodes[i] instanceof ASTConstant);
        // well, let wind the whole loop
      }

      if(res.getName().equals("+")||res.getName().equals("*"))
	      res = (ASTFunNode)visitAdditive(node, data);

      if(allConstNode) {
        ASTConstant constRes = new ASTConstant(-1);
        constRes.jjtSetParent(node.jjtGetParent());
        constRes.setValue(node.getValue());
        res = constRes;
      }

    } catch(Exception ex) {ex.printStackTrace();}
    return res;
  }

  /**
   * Now we are sure that we had visited/preevaluated all possible children.
   */
  private Object visitAdditive(ASTFunNode node, Object data) {
    ArrayList nodes = new ArrayList();
    int numChildren = node.jjtGetNumChildren();
    String nodeName = node.getName();
    boolean toOptimize = false;
    for(int i=0; i<numChildren; i++) {
      SimpleNode curChild = node.jjtGetChild(i);
      String curChildName = curChild.getName();
      if(curChildName!=null&&curChildName.equals(nodeName)) {
	toOptimize = true;
	int grandChildrenNum = curChild.jjtGetNumChildren();
	for(int j=0; j<grandChildrenNum; j++)
	  nodes.add(curChild.jjtGetChild(j));
      } else {
	nodes.add(curChild);
      }
    }
    ASTFunNode res = node;
    if(toOptimize) {
      res = new ASTFunNode(ParserTreeConstants.JJTFUNNODE);
      res.setName(node.getName());
      res.jjtSetParent(node.jjtGetParent());
      int pos = nodes.size()-1;
      for(Iterator i=nodes.iterator(); i.hasNext();)
	node.jjtAddChild((SimpleNode)i.next(), pos--);
      if(nodeName.equals("+"))
        res.setFunction("+", new Madd(nodes.size()));
      else
        res.setFunction("*", new Mmul(nodes.size()));
    }
    return res;
  }

  /**
   * If a var node is defined in the const table, make it to be a real constant.
   */
  public Object visit(ASTVarNode node, Object data) {
    boolean isConst = (constTab.get(node.getName())!=null);
    SimpleNode res = node;
    if(isConst) {
      try {
	ASTConstant res1 = new ASTConstant(ParserTreeConstants.JJTCONSTANT);
	res1.setValue(res.getValue());
	res1.jjtSetParent(res.jjtGetParent());
	res = res1;
      } catch(ParseException ex) {ex.printStackTrace();}
    }
    return res;
  }

  public Object visit(ASTConstant node, Object data) {
    return node;
  }

  public Object visit(SimpleNode node, Object data) {
    return node;
  }

  static class Madd extends PostfixMathCommand {
    Madd(int numberOfParameters) {
      this.numberOfParameters = numberOfParameters;
    }

    public double operation(double[] params) {return 0;};

    public void run(DoubleStack stack) {
      double res = 0;
      for(int i=0; i<numberOfParameters; i++)
	res += stack.pop();
      stack.push(res);
    }
  }

  static class Mmul extends PostfixMathCommand {
    Mmul(int numberOfParameters) {
      this.numberOfParameters = numberOfParameters;
    }

    public double operation(double[] params) {return 0;};

    public void run(DoubleStack stack) {
      double res = 1;
      for(int i=0; i<numberOfParameters; i++)
	res *= stack.pop();
      stack.push(res);
    }
  }
}