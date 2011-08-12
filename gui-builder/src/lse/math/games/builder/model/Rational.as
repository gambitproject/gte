package lse.math.games.builder.model 
{		
	import util.Log;

	/**
	 * Class that represents numbers as fractions: with numerator and denominator. </p>
	 * It contains:
	 * <ul><li>Integers acting as numerator and denominator</li>
	 * <li>Functions for creating rationals from Strings and numbers</li>
	 * <li>Functions to operate with rationals</li>
	 * 
	 * @author Mark
	 */
	public class Rational
	{		
		public static const ONE:Rational = new Rational(1, 1);
		public static const ZERO:Rational = new Rational(0, 1);
		public static const POS_INFINITY:Rational = new Rational(1, 0);
		public static const NEG_INFINITY:Rational = new Rational( -1, 0);
		public static const NaN:Rational = new Rational(0, 0);
	
		private var _num:int;
		private var _den:int;
		
		private var log:Log = Log.instance;
				
		
		
		/** Creates a new rational, reduced, equivalent to 'num'/'den' */
		public function Rational(num:int, den:int)
		{
			_num = num;
			_den = den;
			if (den != 0 && den != 1) {
				reduce();
			}
		}
		
		/** Numerator */
		public function get num():int { return _num; }
		
		/** Denominator */
		public function get den():int { return _den; }
		
		/** If the fraction is 0/0 */
		public function get isNaN():Boolean { return _den == 0 && _num == 0; }
		
		/** If the number is finite (the denominator isn't 0) */
		public function get isFinite():Boolean { return _den != 0; }
		
		/** Float value of the rational */
		public function get floatValue():Number { return (Number(_num)/Number(_den)); }		
		
		
		
		/** Returns a new rational with the same value as this, with opposite sign */
		public function negate():Rational
		{
			if (_num == 0) return this;
			return new Rational(-_num, _den); 
		}
		
		/** Returns the product of this rational, times 'b*/
		public function multiply(b:Rational):Rational
		{
			if (_num == 0 || b.num == 0) return ZERO;
			var c:Rational = new Rational(_num, _den);
			c.mulEq(b);
			return c;
		}
		
		/** Returns the difference between this rational and 'b' (this - b) */
		public function subtract(b:Rational):Rational
		{
			if (b.num == 0) {
				return this;
			}
			var c:Rational = b.negate();
			if (_num != 0) {
				c.addEq(this);
			}
			return c;
		}
		
		/** Returns the sum of this rational and 'b' */
		public function add(b:Rational):Rational
		{
			if (_num == 0) return b;
			else if (b.num == 0)return this; 
			var c:Rational = new Rational(_num, _den);
			c.addEq(b);
			return c;
		}
		
		/** Returns true if this rational is less than 'other' */
		public function isLessThan(other:Rational):Boolean
		{			
			return (compareTo(other) < 0);
		}
		
		/** Returns true if this rational is greater than 'other' */
		public function isGreaterThan(other:Rational):Boolean
		{
			return (compareTo(other) > 0);
		}
		
		/** Returns true if this rational and 'other' are equivalent */
		public function equals(other:Rational):Boolean
		{
			return (compareTo(other) == 0);
		}
		
		/*
		 * Compares this rational against 'b'.
		 * @return 1: If this is greater than 'b'<br>
		 * -1: If this is lower than 'b'<br>
		 * 0: if both are equal
		 */
		private function compareTo(other:Rational):int
		{
			if (!isFinite && !other.isFinite) {
				if ((_num > 0 && other.num > 0) || (_num < 0 && other.num < 0)) {
					return 0;
				} else if (_num > 0) {
					return 1;
				} else {
					return -1;
				}
			} else if (!isFinite) {
				return _num > 0 ? 1 : -1;
			} else if (!other.isFinite) {
				return other.num > 0 ? -1 : 1;
			}
			
			if (_num == other.num && _den == other.den) {
				return 0;
			}
			
			//see if it is a num only compare...
			if (_den == other.den) {
				return (other.num > _num ? -1 : 1);
			}
			
			//check signs...
			if (_num <= 0 && other.num > 0) {
				return -1;
			} else if (_num > 0 && other.num <= 0) {
				return 1;
			}
			
			var diff:Rational = other.subtract(this);			
			return (diff.num == 0 ? 0 : (diff.num < 0 ? 1 : -1));
		}
		
		/** Returns a Rational parsed from a String input */
		public static function parse(s:String):Rational
		{
			var fraction:Array = s.split("/");
			if (fraction.length < 1 || fraction.length > 2) {
				return Rational.NaN; // "not a number"		
			}
			if (fraction.length == 2) {
				var num:int = parseInt(fraction[0]);
				var den:int = parseInt(fraction[1]);
				return new Rational(num, den);
			} else {
				var dec:Number = parseFloat(s);
				if (!isNaN(dec)) {
					return valueOf(dec);
				} else {
					return Rational.NaN;
				}
			}
		}
		
		/** Returns a Rational containing the value of a number */
		public static function valueOf(dec:Number):Rational
		{
			var nnext:Number, dnext:Number;
			var x:Number = dec;
            var xfl:Number = Math.floor(x);

            //if (accuracy > int.MAX_VALUE) accuracy = int.MAX_VALUE;

            if (xfl > Number(int.MAX_VALUE) ||
                xfl < Number(int.MIN_VALUE))
            {
				return dec > 0 ? POS_INFINITY : NEG_INFINITY;
                Log.instance.add(Log.ERROR_HIDDEN, x + " is too large");
            }

            var n0:int = 1;
            var d0:int = 0;
            var n1:int = int(xfl);
            var d1:int = 1;

            while (true)
            {
                x = 1 / (x - xfl);
                xfl = Math.floor(x);
                if (xfl > int.MAX_VALUE) {
                    break;
				}

                dnext = d1 * xfl + d0;
                nnext = n1 * xfl + n0;
                if (/*dnext > accuracy ||*/ nnext > int.MAX_VALUE || nnext < int.MIN_VALUE) {
                    break;
				}

                d0 = d1;
                d1 = int(dnext);
                n0 = n1;
                n1 = int(nnext);
            }
			
			return new Rational(n1, d1);            
		}
		
		/** Returns the Greatest Common Divisor of two ints */
		public static function gcd(a:int, b:int):int
		{
			var c:int;
			if (a < 0) {
				a = -a;
			}
			if (b < 0) {
				b = -b;
			}
			if (a < b) { 
				c = a; 
				a = b; 
				b = c; 
			}
			while (b != 0) {
				c = a % b;
				a = b;
				b = c;
			}
			return a;
		}
		
		// Sums 'b' to this rational, and reduces the result afterwards
		private function addEq(b:Rational):void
		{
			if (this == Rational.ONE || this == Rational.ZERO) {
				log.add(Log.ERROR_THROW, "altering state of const var...");
			}
			if (_den == b.den) {
				_num += b.num;
			} else {
				_num *= b.den;
				_num += b.num * _den;
				_den *= b.den;	        
			}
			reduce();
		}
		
		// Multiplies 'b' to this rational, and reduces the result afterwards
		private function mulEq(b:Rational):void
		{
			if (this == Rational.ONE || this == Rational.ZERO) {
				log.add(Log.ERROR_THROW, "altering state of const var...");
			}
			
			_num *= b.num;
			_den *= b.den;
			reduce();
		}
		
		// Reduces the fraction until numerator and denominator have no common multiples
		private function reduce():void
		{
			if (this == Rational.ONE || this == Rational.ZERO) {
				log.add(Log.ERROR_THROW, "altering state of const var...");
			}
			
			if (_num != 0) {
				if (_den < 0) {
					_den = -_den;
					_num = -_num;
				}
				var gcd:int = Rational.gcd(_num, _den);
				if (gcd != 1) {
					_num /= gcd;
					_den /= gcd;
				}
			} else {
				_den = 1;
			}
		}
		
		public function toString():String
		{
			if (this.isNaN) return "NaN";
			else if (!this.isFinite) {
				return ((_num < 0) ? "-" : "+") + "Infinity";
			}
			return _num + (_den != 1 ? "/" + _den : "");
		}
	}
}