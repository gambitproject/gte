package lse.math.games.lcp;

import java.util.logging.Logger;

import lse.math.games.Rational;

public class LemkeAlgorithm 
{
	private static final Logger log = Logger.getLogger(LemkeAlgorithm.class.getName());
	
	//region State
    private int pivotcount;
    private int record_size = 0; /* MP digit record */  //MKE: TODO
    private long duration;

    private boolean z0leave;
    
    public long getDuration() { return duration; }
    public int getPivotCount() { return pivotcount; } /* no. of Lemke pivot iterations, including the first to pivot z0 in    */
    public int getRecordDigits() { return record_size; }          
    public Tableau A;
    public LexicographicMethod lex; // Performs MinRatio Test


    //region Event Callbacks
    public LeavingVariableDelegate leavingVarHandler;       //interactivevar OR lexminvar
    public OnCompleteDelegate onComplete;                   //chain: binitabl (secondcall), boutsol, blexstats
    public OnInitDelegate onInit;                           //binitabl (first call)
    public OnPivotDelegate onPivot;                         //bdocupivot
    public OnTableauChangeDelegate onTableauChange;         //bouttabl
    public OnLexCompleteDelegate onLexComplete;             //blexstats
    public OnLexRayTerminationDelegate onLexRayTermination;


    private void init(LCP lcp)
    	throws InvalidLCPException, TrivialSolutionException
    {
        checkInputs(lcp.q(), lcp.d());
        A = new Tableau(lcp.d().length);
        A.fill(lcp.M(), lcp.q(), lcp.d());
        if (onInit != null)
        	onInit.onInit("After filltableau", A);
        lex = new LexicographicMethod(A.vars().size());

        this.leavingVarHandler = new LeavingVariableDelegate() {
			public int getLeavingVar(int enter) throws RayTerminationException {
				return lex.lexminratio(A, enter);
			}
			public boolean canZ0Leave() {
				return lex.z0leave();
			}
        };
    }

    /** 
     * asserts that  d >= 0  and not  q >= 0  (o/w trivial sol) 
     * and that q[i] < 0  implies  d[i] > 0
     */
    public void checkInputs(Rational[] rhsq, Rational[] vecd)
    	throws InvalidLCPException, TrivialSolutionException
    {
        boolean isQPos = true;
        for (int i = 0, len = rhsq.length; i < len; ++i) {
            if (vecd[i].compareTo(0) < 0) {
              throw new InvalidLCPException(String.format("Covering vector  d[%d] = %s negative. Cannot start Lemke.", i + 1, vecd[i].toString()));
            } else if (rhsq[i].compareTo(0) < 0) {
                isQPos = false;
                if (vecd[i].isZero()) {
                	throw new InvalidLCPException(String.format("Covering vector  d[%d] = 0  where  q[%d] = %s  is negative. Cannot start Lemke.", i + 1, i + 1, rhsq[i].toString()));
                }
            }
        }
        if (isQPos) {
            throw new TrivialSolutionException("No need to start Lemke since  q>=0. Trivial solution  z=0.");
        }
    }       
   
    private boolean complementaryPivot(int enter, int leave)
    {
        if (onPivot != null)
            onPivot.onPivot(leave, enter, A.vars());

        A.pivot(leave, enter);
        return z0leave;
    }

    /**
     * solve LCP via Lemke's algorithm,
     * solution in  solz [0..lcpdim-1]
     * exit with error if ray termination
     */
    public Rational[] run(LCP lcp) 
    	throws RayTerminationException, InvalidLCPException, TrivialSolutionException 
	{ 
    	return run(lcp, 0); 
	}
    
    public Rational[] run(LCP lcp, int maxcount)
    	throws RayTerminationException, InvalidLCPException, TrivialSolutionException
    {
    	init(lcp);

        z0leave = false;            
        int enter = A.vars().z(0);                        /* z0 enters the basis to obtain lex-feasible solution      */
        int leave = nextLeavingVar(enter);

        A.negCol(A.RHS());                                /* now give the entering q-col its correct sign             */
        if (onTableauChange != null) {              
            onTableauChange.onTableauChange("After negcol", A);
        }

        pivotcount = 1;
        long before = System.currentTimeMillis();
        while (true) {
            if (complementaryPivot(enter, leave)) {
            	break; // z0 will have a value of zero but may still be basic... amend?
            }             
            
            if (onTableauChange != null)
            	onTableauChange.onTableauChange("", A); //TODO: Is there a constant for the empty string? 

            // selectpivot
            enter = A.vars().complement(leave);
            leave = nextLeavingVar(enter);

            if (pivotcount++ == maxcount)               /* maxcount == 0 is equivalent to infinity since pivotcount starts at 1 */
            {
                log.warning(String.format("------- stop after %d pivoting steps --------", maxcount));
                break;
            }
        }
        duration = System.currentTimeMillis() - before;

        if (onComplete != null)
        	onComplete.onComplete("Final tableau", A); // hook up two tabl output functions to a chain delegate where the flags are analyzzed

        if (onLexComplete != null)
        	onLexComplete.onLexComplete(lex);

        return getLCPSolution();               // LCP solution  z  vector        
    }

    /**
     * LCP result
     * current basic solution turned into  solz [0..n-1]
     * note that Z(1)..Z(n)  become indices  0..n-1
     * gives a warning if conversion to ordinary rational fails
     * and returns 1, otherwise 0
     */
    private Rational[] getLCPSolution()
    {
        Rational[] z = new Rational[A.vars().size()];
        for (int i = 1; i <= z.length; i++)
        {
            int var = A.vars().z(i);
            z[i - 1] = A.result(var);                
        }
        return z;
    }

    private int nextLeavingVar(int enter)
    	throws RayTerminationException
    {
        try {
            int rv = leavingVarHandler.getLeavingVar(enter);
            z0leave = leavingVarHandler.canZ0Leave();
            return rv;
        } catch (RayTerminationException ex) {
            if (onLexRayTermination != null)
                onLexRayTermination.onLexRayTermination(enter, A);
            throw ex;
        }
    }
    
    //delegates
    public interface LeavingVariableDelegate { 
    	public int getLeavingVar(int enter) throws RayTerminationException; 
    	public boolean canZ0Leave();
	}
    public interface OnInitDelegate { public void onInit(String message, Tableau A); }
    public interface OnCompleteDelegate { public void onComplete(String message, Tableau A); }
    public interface OnPivotDelegate { public void onPivot(int leave, int enter, TableauVariables vars); }
    public interface OnTableauChangeDelegate { public void onTableauChange(String message, Tableau A); }
    public interface OnLexCompleteDelegate { public void onLexComplete(LexicographicMethod lex); }
    public interface OnLexRayTerminationDelegate { public void onLexRayTermination(int enter, Tableau A); }
    
    @SuppressWarnings("serial")
    public static class LemkeException extends Exception {    	
		public LemkeException(String message) {
    		super(message);
    	}
    }
    
    @SuppressWarnings("serial")
    public static class InvalidLCPException extends LemkeException {
		public InvalidLCPException(String message) {
    		super(message);
    	}
    }
    
    @SuppressWarnings("serial")
	public static class TrivialSolutionException extends LemkeException 
    {    			
		public TrivialSolutionException(String message) {
    		super(message);
    	}
    }
    
    @SuppressWarnings("serial")
    public static class RayTerminationException extends LemkeException {
		public Tableau A;

		public RayTerminationException(String error, Tableau A) 
		{ 
			super(error);
			this.A = A;
		}
		
		@Override
		public String getMessage()
		{
			StringBuilder sb = new StringBuilder()
				.append(super.getMessage())
				.append(System.getProperty("line.separator"))
				.append(A.toString());
			return sb.toString();
		}
    }
}
