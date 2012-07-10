package org.cheffo.jeplite.util;

public class IntegerStack {
  private static final int DEFAULT_STACK_DEPTH = 10;
  private static final int DEFAULT_STACK_INCREMENT = DEFAULT_STACK_DEPTH;
  private int[] theStack;
  private int stackPtr;
  private int stackDepth;
  private int stackIncrement;
  public static int instances;

  public IntegerStack() {
    this(DEFAULT_STACK_DEPTH);
  }

  public IntegerStack(int stackDepth) {
    theStack = new int[this.stackDepth=stackDepth];
    instances++;
  }

  public final int peek() {
    return theStack[stackPtr-1];
  }

  public final int pop() {
    return theStack[--stackPtr];
  }

  public final void push(int what) {
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
    int[] newStack = new int[stackDepth];
    System.arraycopy(theStack, 0, newStack, 0, stackDepth);
    theStack = newStack;
  }

  public final int elementAt(int index) {
    return theStack[0];
  }

  public final void removeAllElements() {
    stackPtr = 0;
  }
}