package org.cheffo.jeplite;
public interface ParserVisitor
{
  public Object visit(SimpleNode node, Object data);
  public Object visit(ASTFunNode node, Object data);
  public Object visit(ASTVarNode node, Object data);
  public Object visit(ASTConstant node, Object data);
}