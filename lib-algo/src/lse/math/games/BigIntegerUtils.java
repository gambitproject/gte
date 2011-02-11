package lse.math.games;

import java.math.BigInteger;

public class BigIntegerUtils {
	
    public static BigInteger lcm(BigInteger a, BigInteger b)
    {
        BigInteger u = a.gcd(b);
        BigInteger v = a.divide(u);   /* v=a/u */
        return v.multiply(b).abs();
    } 
    
    /* find largest gcd of p[0]..p[n-1] and divide through */
    public static void reducearray (BigInteger[] p)
    {
      int i = 0;

      while ((i < p.length) && zero(p[i]))
        i++;
      if (i == p.length)
        return;

      BigInteger divisor = p[i].abs();
      i++;

      while (i < p.length)
        {
          if (!zero (p[i]))
    	{
    	  divisor = divisor.gcd(p[i].abs());
    	}
          i++;
        }

      for (i = 0; i < p.length; i++)
        if (!zero(p[i]))
          p[i] = p[i].divide(divisor);
    }
    
    /**
	 * Compare the product of Na*Nb to Nc*Nd
	 * @return
	 * +1 if Na*Nb > Nc*Nd,
	 * -1 if Na*Nb < Nc*Nd,
	 *  0 if Na*Nb = Nc*Nd  
	 */
	public static int comprod (BigInteger Na, BigInteger Nb, BigInteger Nc, BigInteger Nd)	
	{
		BigInteger mc = (Na.multiply(Nb)).subtract(Nc.multiply(Nd));
		if (positive(mc))
			return (1);
		if (negative(mc))
			return (-1);
		return (0);
	}
	
	public static boolean positive(BigInteger a) {
		return a.compareTo(BigInteger.ZERO) > 0;
	}
	
	public static boolean negative(BigInteger a) {
		return a.compareTo(BigInteger.ZERO) < 0;
	}
	
	public static boolean zero(BigInteger a) {
		return a.compareTo(BigInteger.ZERO) == 0;
	}
	
	public static boolean one(BigInteger a) {
		return a.compareTo(BigInteger.ONE) == 0;
	}
	
	public static boolean greater(BigInteger left, BigInteger right) {
		return left.compareTo(right) > 0;
	}
}
