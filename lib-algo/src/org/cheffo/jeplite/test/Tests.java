package org.cheffo.jeplite.test;

import java.util.*;
import java.io.*;

import org.cheffo.jeplite.*;
import org.cheffo.jeplite.util.*;
import org.cheffo.jeplite.optimizer.*;

/**
 * Title:
 * Description:
 * Copyright:    Copyright (c) 2002
 * Company:
 * @author
 * @version 1.0
 */

/**
 * Provided to check for backward compability and performance.
 */
public class Tests {

  public Tests() {
  }

  static void parseParams(String[] args) {
    for(int i=0; i<args.length; i+=2) {
      params.put(args[i].toLowerCase().trim(), args[i+1]);
    }
  }

  static JEP jep = new JEP();
  static HashMap params = new HashMap();

  static void doIt(String toParse, BufferedWriter fw, SimpleNode optNode) throws Exception {
    long[] testArray = new long[10];
    double d = 0;
    DoubleStack stack = new DoubleStack();
    for(int j=0; j<10; j++) {
      Thread.yield();
      long start = System.currentTimeMillis();
      for(int i=0; i<100000; i++){
	d = optNode.getValue();
      }
      testArray[j] = System.currentTimeMillis()-start;
    }
    fw.write("100000 evaluations: ");
    for(int j=0; j<10; j++) {
      fw.write(testArray[j]+", ");
    }
    fw.write("\n");
  }

  public static void main(String[] args) throws Exception {
    Date startTime = new Date();
    parseParams(args);
    File inFile = new File((String)params.get("-file"));
    File logFile = new File((String)params.get("-logfile"));

    BufferedReader fr = new BufferedReader(new FileReader(inFile));
    BufferedWriter fw = new BufferedWriter(new FileWriter(logFile));


    jep.addStandardConstants();
    jep.addStandardFunctions();

    String curLine = null;
    int lines = 0;
    while(null!=(curLine=fr.readLine())) {
      if(curLine.startsWith("#"))
	continue;
      String description = curLine;
      String toParse = fr.readLine();
      double result = Double.parseDouble(fr.readLine().trim());

      fw.write("Processing:"+toParse+",\n");
      fw.write("Expected: "+result+"\n");
      fw.flush();

      // Give enought time to the jit compiler.
      double d = 0;
      DoubleStack stack = new DoubleStack();
      for(int i=0; i<1000; i++) {
	jep.parseExpression(toParse);
	d = jep.getValue(stack);
      }
      SimpleNode optNode = jep.getTopNode();
      //if(Boolean.getBoolean("noopt")) {
	fw.write("Not Optimized: ");
	doIt(toParse, fw, optNode);
      //}

      //if(Boolean.getBoolean("opt")) {
	ExpressionOptimizer optimizer = new ExpressionOptimizer(jep.getTopNode());
	//optimizer.addConst("pi");
	//optimizer.addConst("e");
	optNode = optimizer.optimize();

	fw.write("Optimized    : ");

	doIt(toParse, fw, optNode);

	long[] testArray = new long[10];
	for(int j=0; j<10; j++) {
	  Thread.yield();
	  long start = System.currentTimeMillis();
	  for(int i=0; i<1000; i++){
	    jep.parseExpression(toParse);
	  }
	  testArray[j] = System.currentTimeMillis()-start;
	}
	fw.write("1000 parses: ");
	for(int j=0; j<10; j++) {
	  fw.write(testArray[j]+", ");
	}
	fw.write("\n");
	fw.write(d+"\n_____________________________________________________\n");
	fw.flush();
      //}
    }
    Date endTime = new Date();
    fw.write("Start time: "+startTime+"\n");
    fw.write("End time: "+endTime+"\n");
    fw.write("Total time: "+(endTime.getTime()-startTime.getTime())+ " ms");
    fw.close();
  }
}