package lse.math.games;

import static lse.math.games.BigIntegerUtils.*;

import java.math.BigDecimal;
import java.math.BigInteger;
import java.util.Random;

import lse.math.games.io.ColumnTextWriter;

public class Rational 
{
	public static final Rational ZERO = new Rational(BigInteger.ZERO, BigInteger.ONE);
	public static final Rational ONE = new Rational(BigInteger.ONE, BigInteger.ONE);
	public static final Rational NEGONE = new Rational(BigInteger.ONE.negate(), BigInteger.ONE);
	public BigInteger num;
	public BigInteger den;
	
	public Rational(BigInteger num, BigInteger den)
	{
		this.num = num;
		this.den = den;
        if (zero(den)) {
            throw new ArithmeticException("Divide by zero");
        } else if (!one(den)) {
    		reduce();
        }
	}
	
	public Rational(Rational toCopy)
	{
		this.num = toCopy.num;
		this.den = toCopy.den;
	}
	
    /* reduces Na Da by gcd(Na,Da) */
    private void reduce()
    {
    	if (!zero(num)) {
            if (negative(den))
            {
                den = den.negate();
                num = num.negate();
            }
	        BigInteger gcd = num.gcd(den);
	        if (!one(gcd)) {
		        num = num.divide(gcd);
		        den = den.divide(gcd);
	        }
    	} else {
    		den = BigInteger.ONE;
    	}
    }
    
    public Rational(long numerator, long denominator)
	{
	    this(BigInteger.valueOf(numerator), BigInteger.valueOf(denominator));
	}

	public void addEq(Rational toAdd)
    {
    	if (den.equals(toAdd.den)) {
    		num = num.add(toAdd.num);
    	} else {
	        num = num.multiply(toAdd.den);
	        num = num.add(toAdd.num.multiply(den));
	        den = den.multiply(toAdd.den);	        
    	}
    	reduce();
    }
    
    public static Rational valueOf(String s)
    throws NumberFormatException
    {
    	String[] fraction = s.split("/");
    	if (fraction.length < 1 || fraction.length > 2) 
    		throw new NumberFormatException("BigIntegerRational not formatted correctly");

    	if (fraction.length == 2) {
	    	BigInteger num = new BigInteger(fraction[0]);
	    	BigInteger den = new BigInteger(fraction[1]);
	    	return new Rational(num, den);
    	} else {
    		BigDecimal dec = new BigDecimal(s);
    		return valueOf(dec);
    	}
    }
    
    public static Rational valueOf(double dx)
    {
        BigDecimal x = BigDecimal.valueOf(dx);
        return valueOf(x);
    }
    
    public static Rational valueOf(BigDecimal x)
    {
        BigInteger num = x.unscaledValue();
        BigInteger den = BigInteger.ONE;
        
        int scale = x.scale();
        while (scale > 0) 
        {
        	den = den.multiply(BigInteger.TEN);
        	--scale;
        } 
        while (scale < 0)
        {
        	num = num.multiply(BigInteger.TEN);
        	++scale;
        }
        
        Rational rv = new Rational(num, den);
        rv.reduce();
        return rv;
    } 
    
    public static Rational valueOf(long value)
    {
    	if (value == 0) return ZERO;
    	else if (value == 1) return ONE;
    	else return new Rational(value);
    }
       
    private Rational(long value)
    {
        this(value, 1);
    }

    private void mulEq(Rational other)
    {
        num = num.multiply(other.num);
        den = den.multiply(other.den);
        reduce();
    }

    //Helper Methods
    private void flip() /* aka. Reciprocate */
    {
        BigInteger x = num;
        num = den;
        den = x;
    }   

    public Rational add(Rational b)
	{
		if (zero(num)) return b;
		else if (zero(b.num))return this; 
		Rational rv = new Rational(this);
	    rv.addEq(b);
	    return rv;
	}

	public Rational add(long b)
    {
        if (b == 0) return this;
        Rational rv = new Rational(b);
        rv.addEq(this);
        return rv;
    }

    public Rational subtract(Rational b)
	{
		if (zero(b.num))return this; 
		Rational c = b.negate();
	    if (!zero(num))
	    	c.addEq(this);
	    return c;
	}

	public Rational subtract(long b)
	{
	    if (b == 0) return this;
	    Rational c = new Rational(-b);
	    c.addEq(this);
	    return c;
	}

	public Rational multiply(Rational b)
    {
        if (zero(num) || zero(b.num)) return ZERO;
        Rational rv = new Rational(this);
        rv.mulEq(b);
        return rv;
    }

    public Rational divide(Rational b)
	{
		Rational rv = new Rational(b);
		rv.flip();
		rv.mulEq(this);
		return rv;
	}

	public Rational negate()
	{
	    if (zero(num)) return this;
	    return new Rational(num.negate(), den); 
	}

	public Rational reciprocate()
	{
		if (zero(num)) throw new ArithmeticException("Divide by zero");
		Rational rv = new Rational(this);
		rv.flip();
		if (negative(den)) {
			rv.num = rv.num.negate();
			rv.den = rv.den.negate();
		}
		return rv;
	}

	public int compareTo(Rational other)
    {
        if (num.equals(other.num) && den.equals(other.den))
        	return 0;
        
        //see if it is a num only compare...
        if (den.equals(other.den))
            return (greater(other.num, this.num)) ? -1 : 1;

        //check signs...
        if ((zero(num) || negative(num)) && positive(other.num)) 
        	return -1;
        else if (positive(num) && (zero(other.num) || negative(other.num))) 
        	return 1;

        Rational c = other.negate();            
        c.addEq(this);
        return (c.isZero() ? 0 : (negative(c.num) ? -1 : 1));
    }

    public int compareTo(long other)
    {
    	BigInteger othernum = BigInteger.valueOf(other);
        if (num.equals(othernum) && one(den)) return 0;
        else return compareTo(new Rational(othernum, BigInteger.ONE));
    }


    public double doubleValue()
	{    	
    	try {
    		return (new BigDecimal(num)).divide(new BigDecimal(den)).doubleValue();
    	} catch (ArithmeticException e) {
			return (new BigDecimal(num)).divide(new BigDecimal(den), 32, BigDecimal.ROUND_HALF_UP).doubleValue();
		}
	}

	//Num and Den are only used by Tableau... I'd like to get rid of them, but can't see how
	public boolean isZero() { return zero(num); }

	public boolean isOne() { return one(num) && one(den); } // should be reduced at all times

	//Basic Overrides
    @Override
    public boolean equals(Object obj)
    {
        if (obj == null || !(obj instanceof Rational))
            return false;

        Rational r = (Rational)obj;
        return (compareTo(r) == 0);
    }

    @Override
    public int hashCode()
    {
        return (num.multiply(BigInteger.valueOf(7)).intValue() ^ den.multiply(BigInteger.valueOf(17)).intValue());
    }

    @Override
    public String toString()
    {
    	StringBuilder sb = new StringBuilder();
    	sb.append(num.toString());
    	if (!one(den) && !zero(num))
    	{
    		sb.append("/");
    		sb.append(den);
    	}
    	return sb.toString();
    }

	public static Rational sum(Iterable<Rational> list)
	{
	    Rational sum = ZERO;
	    for (Rational rat : list) {
	        sum.addEq(rat);                
	    }
	    return sum;
	}

	// TODO: why is this here?
	public static long gcd(long a, long b)
	{
	    long c;
	    if (a < 0L) {
	    	a = -a;
	    }
	    if (b < 0L) {
	    	b = -b;
	    }
	    if (a < b) { 
	    	c = a; 
	    	a = b; 
	    	b = c; 
	    }
	    while (b != 0L) {
	        c = a % b;
	        a = b;
	        b = c;
	    }
	    return a;
	}
	
	public static Rational[] probVector(int length, Random prng)
	{
		if (length == 0) return new Rational[] {};
		else if (length == 1) return new Rational[] { Rational.ONE };
		
		double dProb = prng.nextDouble();
		Rational probA = Rational.valueOf(dProb);
		Rational probB = Rational.valueOf(1 - dProb);
		if (length == 2) {
			return new Rational[] { probA, probB };
		} else {
			Rational[] a = probVector(length / 2, prng);
			Rational[] b = probVector((length + 1) / 2, prng);
			Rational[] c = new Rational[a.length + b.length];
			for (int i = 0; i < a.length; ++i) {
				c[i] = a[i].multiply(probA);
			}
			for (int i = 0; i < b.length; ++i) {
				c[a.length + i] = b[i].multiply(probB);
			}
			return c;
		}		
	}
	
	// TODO: put this somewhere else...
	public static void printRow(String name, Rational value, ColumnTextWriter colpp, boolean excludeZero)
	{					
		if (!value.isZero() || !excludeZero) {
			colpp.writeCol(name);
			colpp.writeCol(value.toString());
					
			if (!BigIntegerUtils.one(value.den)) {
				colpp.writeCol(String.format("%.3f", value.doubleValue()));	
			}
			colpp.endRow();
		}		
	}
}
