package lse.math.games.builder.model 
{		
	import org.flexunit.Assert;
	
	/**
	 * @author Mark
	 */
	public class RationalTest
	{
		[Test]
		public function testSubtraction():void
		{
			var a:Rational = new Rational(1, 2);
			var b:Rational = new Rational(2, 3);
			
			var result:Rational = a.subtract(b);
			
			var num:int = -1;
			var den:int = 6;
			Assert.assertEquals(num, result.num);
			Assert.assertEquals(den, result.den);
			Assert.assertTrue(result.equals(new Rational(num, den)));
		}
		
		[Test]
		public function testMultiplication():void
		{
			var a:Rational = new Rational(1, 2);
			var b:Rational = new Rational(2, 3);			
			
			var result:Rational = a.multiply(b);
			
			var num:int = 1;
			var den:int = 3;			
			Assert.assertEquals(num, result.num);
			Assert.assertEquals(den, result.den);
			Assert.assertTrue(result.equals(new Rational(num, den)));
		}
		
		[Test]
		public function testComparison():void
		{
			var a:Rational = new Rational(6, 7);
			var b:Rational = new Rational(7, 8);			
					
			Assert.assertTrue(a.isLessThan(b));
			Assert.assertTrue(b.isGreaterThan(a));
			Assert.assertTrue(!a.equals(b));
		}
		
		[Test]
		public function testFractionStringParse():void
		{
			var a:Rational = Rational.parse("2/6");			
					
			Assert.assertEquals(1, a.num);
			Assert.assertEquals(3, a.den);
		}
		
		[Test]
		public function testDecimalStringParse():void
		{
			var a:Rational = Rational.parse("0.125");			
					
			Assert.assertEquals(1, a.num);
			Assert.assertEquals(8, a.den);
		}
		
		[Test]
		public function testIntegerStringParse():void
		{
			var a:Rational = Rational.parse("-5");			
					
			Assert.assertEquals(-5, a.num);
			Assert.assertEquals(1, a.den);
		}
	}	
}