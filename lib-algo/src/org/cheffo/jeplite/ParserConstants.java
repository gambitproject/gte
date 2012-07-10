package org.cheffo.jeplite;
public interface ParserConstants {
  int EOF = 0;
  int INTEGER_LITERAL = 2;
  int DECIMAL_LITERAL = 3;
  int FLOATING_POINT_LITERAL = 4;
  int EXPONENT = 5;
  int STRING_LITERAL = 6;
  int IDENTIFIER = 7;
  int LETTER = 8;
  int DIGIT = 9;
  int DEFAULT = 0;
  String[] tokenImage = {
    "<EOF>",
    "\" \"",
    "<INTEGER_LITERAL>",
    "<DECIMAL_LITERAL>",
    "<FLOATING_POINT_LITERAL>",
    "<EXPONENT>",
    "<STRING_LITERAL>",
    "<IDENTIFIER>",
    "<LETTER>",
    "<DIGIT>",
    "\"&&\"",
    "\"||\"",
    "\"!\"",
    "\"<\"",
    "\">\"",
    "\"<=\"",
    "\">=\"",
    "\"!=\"",
    "\"==\"",
    "\"+\"",
    "\"-\"",
    "\"*\"",
    "\"/\"",
    "\"%\"",
    "\"^\"",
    "\"(\"",
    "\")\"",
    "\",\"",
    "\"[\"",
    "\"]\"",
  };
}