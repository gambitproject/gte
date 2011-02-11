package lse.math.games.lcp;

// TODO: Make inner static class of Tableau
public class TableauVariables {
	/* VARS   = 0..2n = Z(0) .. Z(n) W(1) .. W(n)           */
    /* ROWCOL = 0..2n,  0 .. n-1: tabl rows (basic vars)    */
    /*                  n .. 2n:  tabl cols  0..n (cobasic) */
    private int[] bascobas;          /* VARS  -> ROWCOL                      */
    private int[] whichvar;          /* ROWCOL -> VARS, inverse of bascobas  */
    private int n;        

    /* init tableau variables:                      */
    /* Z(0)...Z(n)  nonbasic,  W(1)...W(n) basic    */
    /* This is for setting up a complementary basis/cobasis */
    public TableauVariables(int sizeBasis)
    {
        n = sizeBasis;            

        bascobas = new int[2 * n + 1];
        whichvar = new int[2 * n + 1];

        for (int i = 0; i <= n; i++)
        {
            bascobas[z(i)] = n + i;
            whichvar[n + i] = z(i);
        }
        for (int i = 1; i <= n; i++)
        {
            bascobas[w(i)] = i - 1;
            whichvar[i - 1] = w(i);
        }
    }
    

    /* create string  s  representing  v  in  VARS,  e.g. "w2"    */
    /* return value is length of that string                      */
    public String toString(int var)
    {
        if (!isZVar(var))
            return String.format("w%d", var - n);
        else
            return String.format("z%d", var);
    }

    @Override
    public String toString()
    {
        StringBuilder output = new StringBuilder();
        output.append("bascobas: [");
        for (int i = 0; i < bascobas.length; i++)
        {
            output.append(String.format(" %d", bascobas[i]));
        }
        output.append(" ]");
        return output.toString();
    }

    public void swap(int enterVar, int leaveVar, int leaveRow, int enterCol)
    {
        bascobas[leaveVar] = enterCol + n;
        whichvar[enterCol + n] = leaveVar;

        bascobas[enterVar] = leaveRow;
        whichvar[leaveRow] = enterVar;
    }

    public int z(int idx)
    {
        return idx;
    }

    public int w(int idx)
    {
        return idx + n;
    }

    public int rowVar(int row)
    {
        return whichvar[row];
    }

    int colVar(int col)
    {
        return whichvar[col + n];
    }

    int row(int var)
    {
        return bascobas[var];
    }

    int col(int var)
    {
        return bascobas[var] - n;
    }

    public boolean isBasic(int var)
    {
        return (bascobas[var] < n);
    }

    public boolean isZVar(int var)
    {
        return (var <= n);
    }
    
    public int size()
    {
        return n;
    }

    /**
     * TODO: This might belong in the Lemke Algorithm and not here.
     * complement of  v  in VARS, error if  v==Z(0).
     * this is  W(i) for Z(i)  and vice versa, i=1...n
     */
    public int complement(int var)
    {
        if (var == z(0))
            throw new RuntimeException("Attempt to find complement of z0."); //TODO
        return (!isZVar(var)) ? z(var - n) : w(var);
    }


    
    /* assert that  v  in VARS is a basic variable         */
    /* otherwise error printing  info  where               */
    public void assertBasic(int var)
    {
        if (!isBasic(var))
        {
            String error = String.format("Cobasic variable %s should be basic.", toString(var));
            throw new RuntimeException(error); //TODO
        }
    }

    /* assert that  v  in VARS is a cobasic variable       */
    /* otherwise error printing  info  where               */
    public void assertNotBasic(int var)
    {
        if (isBasic(var))            
        {
            String error = String.format("Basic variable %s should be cobasic.", toString(var));
            throw new RuntimeException(error); //TODO
        }
    }

    /* test tableau variables: error => msg only, continue  */
    //MKE: should this be put in a unit test and be removed from runtime?
    public void testTablVars()
    {
    	String newline = System.getProperty("line.separator");
        for (int i = 0; i <= 2 * n; i++) {                                        /* check if somewhere tableauvars wrong */
            if (bascobas[whichvar[i]] != i || whichvar[bascobas[i]] != i) {       /* found an inconsistency, print everything      */                
                StringBuilder output = new StringBuilder();
                output.append("Inconsistent tableau variables:"); 
                output.append(newline);
                for (int j = 0; j <= 2 * n; j++) {
                    output.append(String.format(
                        "var j:%3d bascobas:%3d whichvar:%3d  b[w[j]]==j: %1d  w[b[j]]==j: %1d",
                        j, bascobas[j], whichvar[j], bascobas[whichvar[j]] == j, whichvar[bascobas[j]] == j));
                    output.append(newline);
                }
                //throw new Exception(output.ToString());
                System.err.print(output.toString());
                break;
            }
        }
    }
}
