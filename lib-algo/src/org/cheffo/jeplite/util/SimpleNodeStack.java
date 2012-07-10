package org.cheffo.jeplite.util;
import org.cheffo.jeplite.*;

public class SimpleNodeStack {
  private static final int DEFAULT_STACK_DEPTH = 10;
  private static final int DEFAULT_STACK_INCREMENT = DEFAULT_STACK_DEPTH;
  private SimpleNode[] theStack;
  private int stackPtr;
  private int stackDepth;
  private int stackIncrement;
  public static int instances;

  public SimpleNodeStack() {
    this(DEFAULT_STACK_DEPTH);
  }

  public SimpleNodeStack(int stackDepth) {
    theStack = new SimpleNode[this.stackDepth=stackDepth];
    instances++;
  }

  public final SimpleNode peek() {
    return theStack[stackPtr-1];
  }

  public final SimpleNode pop() {
    return theStack[--stackPtr];
  }

  public final void push(SimpleNode what) {
    if(stackPtr==stackDepth)
      enlarge();
    theStack[stackPtr++] = what;
  }

  public final boolean isEmpty() {
    return stackPtr==0;
  }

  public final int size() {
    return stackPtr;
  }

  private final void enlarge() {
    stackDepth += stackIncrement;
    SimpleNode[] newStack = new SimpleNode[stackDepth];
    System.arraycopy(theStack, 0, newStack, 0, stackDepth);
    theStack = newStack;
  }

  public final SimpleNode elementAt(int index) {
    return theStack[0];
  }

  public final void removeAllElements() {
    stackPtr = 0;
  }
}