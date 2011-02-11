package lse.math.games;

import org.junit.Test;
import static org.junit.Assert.*;

public class RationalTest {
	@Test
     public void testLargeCrossProductAdd()
     {
         //NOTE: longMax is odd since it is 0111...111 in bits
         Rational a = new Rational(Long.MAX_VALUE, (Long.MAX_VALUE - 1) / 2);
         Rational b = new Rational(-3, 2);

         a = a.add(b);

         Rational result = new Rational((Long.MAX_VALUE - 1) / 2 + 2, Long.MAX_VALUE - 1);
         assertEquals(result, a);
     }

     @Test
     public void testPositiveNumAddEq()
     {
         Rational a = Rational.valueOf(1127L);
         Rational b = Rational.valueOf(1011L);

         a = a.add(b);

         assertTrue(a.compareTo(2138L) == 0);            
         assertEquals(a.doubleValue(), 2138D, 0.000000001);
     }

     @Test
     public void testPositiveNumMulEq()
     {
         Rational a = Rational.valueOf(27L);
         Rational b = Rational.valueOf(11L);

         a = a.multiply(b);

         assertTrue(a.compareTo(297L) == 0);            
         assertEquals(a.doubleValue(), 297D, 0.000000001);
     }

     @Test
     public void testPositiveReciprocal()
     {
         Rational a = Rational.valueOf(4L);
         a = a.reciprocate();

         assertEquals(new Rational(1, 4), a);            
         assertEquals(a.doubleValue(), 0.25D, 0.000000001);
     }

     @Test
     public void testNegativeNumMulEq()
     {
         Rational a = Rational.valueOf(27L);
         Rational b = Rational.valueOf(-11L);

         a = a.multiply(b);

         assertTrue(a.compareTo(-297L) == 0);            
         assertEquals(a.doubleValue(), -297D, 0.000000001);
     }

     @Test
     public void testDoubleNegativeNumMulEq()
     {
         Rational a = Rational.valueOf(-27L);
         Rational b = Rational.valueOf(-11L);

         a = a.multiply(b);
         
         assertTrue(a.compareTo(297L) == 0);
         assertEquals(297D, a.doubleValue(), 0.000000001);
     }

     @Test
     public void testFractionReduction()
     {
         Rational a = new Rational(3,5);
         Rational b = new Rational(10,7);

         a = a.multiply(b);

         assertEquals(new Rational(6, 7), a);            
     }

     @Test
     public void testPositiveNumbertoString()
     {
         Rational a = new Rational(3, 4);
         assertEquals("3/4", a.toString());
     }

     @Test
     public void testNegativeNumeratortoString()
     {
         Rational a = new Rational(-3, 4);
         assertEquals("-3/4", a.toString());
     }

     @Test
     public void testNegativeDenominatortoString()
     {
         Rational a = new Rational(3, -4);
         assertEquals("-3/4", a.toString());
     }

     @Test
     public void testFractionReductionIntoString()
     {
         Rational a = new Rational(-6, -8);
         assertEquals("3/4", a.toString());
     }

     @Test
     public void testLargeNumAndDen()
     {
         Rational r = new Rational(Long.MAX_VALUE, Long.MAX_VALUE);
         assertEquals(1.0, r.doubleValue(), 0.000000001);
         assertEquals("1", r.toString());
     }

     @Test
     public void testLargeNegNumAndDen()
     {
         Rational r = new Rational(Long.MIN_VALUE + 1, Long.MIN_VALUE + 1);
         assertEquals(1.0, r.doubleValue(), 0.000000001);
         assertEquals("1", r.toString());
     }

     @Test
     public void testLargeNumLargeNegDen() {
         Rational r = new Rational(Long.MAX_VALUE, Long.MIN_VALUE + 1);
         assertEquals(-1.0, r.doubleValue(), 0.000000001);
         assertEquals("-1", r.toString());
     }

     @Test
     public void testLargeNegNumLargeDen() {
         Rational r = new Rational(Long.MIN_VALUE + 1, Long.MAX_VALUE);
         assertEquals(-1.0, r.doubleValue(), 0.000000001);
         assertEquals("-1", r.toString());
     }

     @Test
     public void testLargeDen() {
         Rational r = new Rational(1L, Long.MAX_VALUE);
         assertEquals(String.format("1/%s", Long.MAX_VALUE), r.toString());
     }

     @Test
     public void testLargeNum() {
         Rational r = new Rational(Long.MAX_VALUE, 1L);
         assertEquals((double) Long.MAX_VALUE, r.doubleValue(), 0.000000001);
         assertEquals(String.format("%s", Long.MAX_VALUE), r.toString());
     }

     @Test
     public void testDoubleConversion()
     {
         double dv = (double)(Long.MAX_VALUE - 1024L);
         assertEquals(Long.MAX_VALUE - 1023L, (long) dv); //expected consistent? small rounding error

         double value = 0.00000000000000001;
         Rational r = Rational.valueOf(value);
         assertEquals(value, r.doubleValue(), 0.00000000000000001);
         assertEquals("1/100000000000000000", r.toString());
         assertEquals(new Rational(1, 100000000000000000L), r);            
     }

     @Test
     public void testDoubleConversionMinuteFloorDiff()
     {
         {
             double value = 0.5D / Long.MAX_VALUE;
             Rational r = Rational.valueOf(value);
             assertEquals(value, r.doubleValue(), 0.000000001);
         }
     }

     @Test
     public void testFlipWithLargeNum()
     {
         Rational r = Rational.valueOf(Long.MAX_VALUE);
         assertTrue(r.compareTo(Long.MAX_VALUE) == 0);            
         r = r.reciprocate();
         assertEquals(new Rational(1, Long.MAX_VALUE), r);            
     }



     @Test
     public void testGCD()
     {
         long gcd = Rational.gcd(Long.MIN_VALUE + 1, Long.MAX_VALUE);
         assertEquals(Long.MAX_VALUE, gcd);
     }

     @Test
     public void testReduceLargeNegNum()
     {
         Rational r = new Rational(Long.MIN_VALUE + 1, Long.MAX_VALUE); //reduce done in constructor
         assertTrue(r.compareTo(-1L) == 0);            
     }
}
