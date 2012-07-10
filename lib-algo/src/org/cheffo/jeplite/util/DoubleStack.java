package org.cheffo.jeplite.util;

public class DoubleStack {
  private static final int DEFAULT_STACK_DEPTH = 10;
  private static final int DEFAULT_STACK_INCREMENT = DEFAULT_STACK_DEPTH;
  private double[] theStack;
  private int stackPtr;
  private int stackDepth;
  private int stackIncrement;
  public static int instances;

  public DoubleStack() {
    this(DEFAULT_STACK_DEPTH);
  }

  public DoubleStack(int stackDepth) {
    theStack = new double[this.stackDepth=stackDepth];
    instances++;
  }

  public final double peek() {
    return theStack[stackPtr-1];
  }

  public final double pop() {
    return theStack[--stackPtr];
  }

  public final void push(double what) {
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
    double[] newStack = new double[stackDepth];
    System.arraycopy(theStack, 0, newStack, 0, stackDepth);
    theStack = newStack;
  }

  public final double elementAt(int index) {
    return theStack[0];
  }

  public final void removeAllElements() {
    stackPtr = 0;
  }
}