package org.cheffo.jeplite;
import org.cheffo.jeplite.util.*;
public class SimpleNode {
  protected SimpleNode parent;
  protected SimpleNode[] children;
  protected int id;
  protected Parser parser;
  protected String name;

  public SimpleNode(int i) {
    id = i;
  }

  public SimpleNode(Parser p, int i) {
    this(i);
    parser = p;
  }

  public void setName(String name) {
    this.name = name;
  }

  public String getName() {
    return name;
  }

  public void jjtOpen() {
  }

  public void jjtClose() {
  }

  public final void jjtSetParent(SimpleNode n) { parent = n; }
  public final SimpleNode jjtGetParent() { return parent; }

  public void jjtAddChild(SimpleNode n, int i) {
    if (children == null) {
      children = new SimpleNode[i + 1];
    } else if (i >= children.length) {
      SimpleNode c[] = new SimpleNode[i + 1];
      System.arraycopy(children, 0, c, 0, children.length);
      children = c;
    }
    children[i] = n;
  }

  public final SimpleNode jjtGetChild(int i) {
    return children[i];
  }

  public final int jjtGetNumChildren() {
    return (children == null) ? 0 : children.length;
  }

  public Object jjtAccept(ParserVisitor visitor, Object data) {
    return visitor.visit(this, data);
  }

  public Object childrenAccept(ParserVisitor visitor, Object data) {
    if (children != null) {
      for (int i = 0; i < children.length; ++i) {
        children[i].jjtAccept(visitor, data);
      }
    }
    return data;
  }

  public String toString() { return ParserTreeConstants.jjtNodeName[id]; }

  public double getValue() throws ParseException
  {
    return 0;
  }

  public void getValue(DoubleStack stack) throws ParseException {
    stack.push(getValue());
  }
}