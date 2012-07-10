package org.cheffo.jeplite;
public interface ParserTreeConstants
{
  public int JJTSTART = 0;
  public int JJTVOID = 1;
  public int JJTFUNNODE = 2;
  public int JJTVARNODE = 3;
  public int JJTCONSTANT = 4;

  public String[] jjtNodeName = {
    "Start",
    "void",
    "FunNode",
    "VarNode",
    "Constant",
  };
}