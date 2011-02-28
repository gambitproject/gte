package lse.math.games.io;

import java.io.PrintWriter;

import lse.math.games.lcp.LexicographicMethod;
import lse.math.games.lcp.Tableau;
import lse.math.games.lcp.TableauVariables;
import lse.math.games.lcp.LCP;

public class LemkeWriter {
	private ColumnTextWriter colpp = new ColumnTextWriter();
	private PrintWriter output;
	
	public LemkeWriter(PrintWriter output) {  
		this.output = output;
	}    

    public void RayTerminationDump(int enter, Tableau A, LCP start)
    {
        output.println(String.format("Ray termination when trying to enter %s", A.vars().toString(enter)));        
	output.println("Starting LCP:");
	output.println(start.toString());
	output.println("Final Tableau:");
        output.println(A.toString());
        output.println("Current basis, not an LCP solution:");        
        WriteSolution(A);
    }

    /* output the current basic solution            */
    public void WriteSolution(Tableau A) { WriteSolution("", A); }
    public void WriteSolution(String message, Tableau A)
    {
        colpp.writeCol("basis=");
        for (int i = 0; i <= A.vars().size(); i++)              /* num Z plus z0 */
        {
            String s;
            if (A.vars().isBasic(A.vars().z(i)))                       /*  Z(i) is a basic variable        */                    
                s = A.vars().toString(A.vars().z(i));
            else if (i > 0 && A.vars().isBasic(A.vars().w(i)))         /*  W(i) is a basic variable, W(0) not valid        */                    
                s = A.vars().toString(A.vars().w(i));
            else
                s = "  ";
            colpp.writeCol(s);
        }
        colpp.endRow();
        
        colpp.writeCol("z=");
        for (int i = 0; i <= A.vars().size(); i++)          
        {
            int var = A.vars().z(i);
            colpp.writeCol(A.result(var).toString());                  /* value of Z(i)    */                
        }
        colpp.endRow();
        
        colpp.writeCol("w=");
        colpp.writeCol("");                                          /* for complementarity in place of W(0)             */
        for (int i = 1; i <= A.vars().size(); i++)
        {
            int var = A.vars().w(i);
            colpp.writeCol(A.result(var).toString());                  /* value of W(i)      */
        }                                                   /* end of  for (i=...)          */
        output.write(colpp.toString());
    }                                                       /* end of outsol                */

    /* output statistics of minimum ratio test */
    public void WriteLexStats(LexicographicMethod lex)
    {            
        int[] lextested = lex.tested;
        int[] lexcomparisons = lex.comparisons;
        
        colpp.writeCol("lex-column");
        colpp.alignLeft();        
        
        for (int i = 0; i < lextested.length; i++)
        	colpp.writeCol(i);
        colpp.endRow();
        colpp.writeCol("times tested");
        for (int i = 0; i < lextested.length; i++)
            colpp.writeCol(lextested[i]);
        colpp.writeCol("% times tested");
        if (lextested[0] > 0) {
        	colpp.writeCol("100");
            for (int i = 1; i < lextested.length; i++) {
                String s = String.format("%2.0",
                        (double)lextested[i] * 100.0 / (double)lextested[0]); //"%2.0f"
                colpp.writeCol(s);
            }
        }
        else
            colpp.endRow();
        colpp.writeCol("avg comparisons");
        for (int i = 0; i < lextested.length; i++) {
            if (lextested[i] > 0) {
                String s = String.format("%1.1f",
                    (double)lexcomparisons[i] / (double)lextested[i]); //"%1.1f"
                colpp.writeCol(s);
            }
            else {
                colpp.writeCol("-");
            }
        }
        output.write(colpp.toString());
    }

    /* leave, enter in  VARS.  Documents the current pivot. */
    /* Asserts  leave  is basic and  enter is cobasic.      */
    public void WritePivot(int leave, int enter, TableauVariables vars)
    {
        output.print(String.format("leaving: %-4s ", vars.toString(leave)));
        output.println(String.format("entering: %s", vars.toString(enter)));        
    }       
}
