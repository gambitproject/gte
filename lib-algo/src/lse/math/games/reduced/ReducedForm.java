package lse.math.games.reduced;

import java.io.StringWriter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.logging.Logger;

import lse.math.games.Rational;
import lse.math.games.io.ColumnTextWriter;
import lse.math.games.tree.Iset;
import lse.math.games.tree.Move;
import lse.math.games.tree.Player;
import lse.math.games.tree.SequenceForm;

public class ReducedForm
{
	/*// variables //*/
	private static final Logger log = Logger.getLogger(ReducedForm.class.getName());
	
	/* > **** FOR COMPATIBILITY **** > */
	/* Pointer to the head of the player list */
    private Player firstPlayer; 
	
    /* Value with the original payoff values were adjusted */
    Map<Player,Rational> payAdjust;
    
	/* Storing A and B */
    private Map<Player,Rational[][]> payoffs;
    
    /* Storing E and F */
    private Map<Player,Integer[][]> constraintsMap;
	
    /* Information sets - Moves pairs */
    private Map<Iset,Move> seqin = new HashMap<Iset,Move>();
    
    /* Player - Moves pairs */
    private Map<Player,List<Move>> seqsMap = new HashMap<Player,List<Move>>();

    /* Players - Information sets pairs */
    private Map<Player,List<Iset>> isetsMap = new HashMap<Player,List<Iset>>();
    /* < **** FOR COMPATIBILITY **** < */   	
	
    
    /* > **** FOR 2-PERSON EXTENSIVE GAME IN REDUCED FORM **** > */
	//    class Matrix
    /* < **** FOR 2-PERSON EXTENSIVE GAME IN REDUCED FORM **** < */
    
    
	/*// methods //*/
	public ReducedForm(SequenceForm seq)
	{
		logi("Making reduced form...");
		
		/* Make deep copy from sequence form */
		/* Temporary dictionary about players */
		Map<Player, Player> oldNewPlayers = new HashMap<Player, Player>();
		
		/* Clone players */
		logi("Clone players...");
		firstPlayer = new Player(seq.getFirstPlayer().toString());
		oldNewPlayers.put(seq.getFirstPlayer(), firstPlayer);
		
		for (Player pl = firstPlayer, orig = seq.getFirstPlayer().next; 
				orig != null; orig = orig.next) {
			pl.next = new Player(orig.toString());
			oldNewPlayers.put(orig, pl.next);	
		}
		
		/* Clone pay adjust */
		logi("Clone pay adjust...");
		logi("Orig pay adjust: %s", seq.getPayAdjust());
		payAdjust = new HashMap<Player,Rational>();
		for (Player pl : seq.getPayAdjust().keySet()) {
			/* Look up our player from the dictionary
			 * and set a new Rational to it */
			payAdjust.put(oldNewPlayers.get(pl), new Rational(seq.getPayAdjust().get(pl)));
		}

		/* Temporary dictionary about moves */
		Map<Move, Move> oldNewMoves = new HashMap<Move, Move>();
		
		/* Clone sequences map */
		logi("Clone seqsmap...");
		logi("Orig seqs map: %s", seq.getSeqsMap());
	    seqsMap = new HashMap<Player,List<Move>>();
		/*  Fill in seqsMap */
    	for (Player orig : seq.getSeqsMap().keySet()) {
    		Player pl = oldNewPlayers.get(orig);
    		
	    	List<Move> plMoves = new ArrayList<Move>();
	    	
	    	for (Move origMove : seq.getSeqsMap().get(orig)) {
	    		Move move = null;
	    		if (origMove != null) {
		    		move = new Move(origMove.uid(), origMove.prob);
		    		move.setLabel(origMove.getLabel());
	    		}
	    		plMoves.add(move);
	    		oldNewMoves.put(origMove, move);
	    	}
	    		    	
	    	seqsMap.put(pl, plMoves);
    	}
    	/* Add chance player's move */
    	List<Move> chanceMoves = new ArrayList<Move>();
    	chanceMoves.add(null);
    	seqsMap.put(Player.CHANCE, chanceMoves);
    	
		
		/* Temporary dictionary about information sets */
    	Map<Iset,Iset> oldNewIsets = new HashMap<Iset,Iset>();
		
		/* Clone information sets */
    	logi("Clone isetsMap...");
    	logi("Orig isetsMap: %s", seq.getIsetsMap());
		isetsMap = new HashMap<Player,List<Iset>>();
		for (Player orig : seq.getIsetsMap().keySet()) {
			Player pl = oldNewPlayers.get(orig);
			
			List<Iset> isets  = new LinkedList<Iset>();
			for (Iset origIset : seq.getIsetsMap().get(orig)) {
				Iset iset = new Iset(origIset.uid(), pl);
				iset.setName(origIset.name());
				
				if (origIset.moves != null) {
					logi("\tOrig iset: %s %s", origIset, origIset.moves);
					
					iset.moves = new Move[origIset.moves.length];
					for (int i = 0; i < origIset.moves.length; i++) {
						Move move = oldNewMoves.get(origIset.moves[i]);
						iset.moves[i] = move;
						move.setIset(iset);
					}
				}
				isets.add(iset);
				oldNewIsets.put(origIset, iset);
			}
			
			isetsMap.put(pl, isets);
			
			for (Iset origIset : seq.getIsetsMap().get(orig)) {
				Iset iset = oldNewIsets.get(origIset);
				iset.setNext(oldNewIsets.get(origIset).next());
			}
		}
		
		/* Clone moves leading to information sets */
		logi("Clone seqin...");
		logi("Orig seqin: %s", seq.getSeqin());
		seqin = new HashMap<Iset,Move>();	    
	    for (Iset origIset : seq.getSeqin().keySet()) {
	    	Iset iset = oldNewIsets.get(origIset);
	    	Move move = oldNewMoves.get(seq.getSeqin().get(origIset));
	    	seqin.put(iset, move);
	    }
		
		/* Clone payoffs */
	    logi("Clone payoffs...");
	    logi("Orig payoffs: %s", seq.getPayoffs());
		payoffs = new HashMap<Player,Rational[][]>();
		for (Player orig : seq.getPayoffs().keySet()) {
			Player pl = oldNewPlayers.get(orig);
			
			/* Get the payoff matrix of the current player */
			Rational[][] matrix = seq.getPayoffs().get(orig);
			
			/* Create the new matrix, */
			payoffs.put(pl, new Rational[nseqs(firstPlayer.next)][nseqs(firstPlayer)]);
			/* Copy values */
            for (int i = 0; i < nseqs(firstPlayer.next); i++) {
                for (int j = 0; j < nseqs(firstPlayer); j++) {
                	// TODO divide by chance then subtract then multiply by chance
                	payoffs.get(pl)[i][j] =	
                			matrix[j][i].compareTo(Rational.NEGONE) == 1 ?
                			new Rational(Rational.ZERO) :
                			new Rational(matrix[j][i].subtract(payAdjust.get(pl)));
                }
            }
		}
		
		/* Clone constraints */
		logi("Clone constraintsMap...");
		logi("Orig constraint map: %s", seq.getConstraintsMap());
		constraintsMap = new HashMap<Player,Integer[][]>();
		for (Player orig : seq.getConstraintsMap().keySet()) {
			Player pl = oldNewPlayers.get(orig);
			
			/* Get the constraint matrix of the current player */
			Integer[][] matrix = seq.getConstraintsMap().get(orig);
			
			/* Create the new matrix,
			 * with extra row for seq 0 */
			constraintsMap.put(pl, new Integer[nisets(pl) + 1][nseqs(pl)]); /* extra row for seq 0  */
			/* Copy values */
            for (int i = 0; i < nisets(pl) + 1; i++) {
                for (int j = 0; j < nseqs(pl); j++) {
                	constraintsMap.get(pl)[i][j] = new Integer(matrix[i][j]);
                }
            }
		}
		
//		/* Print the payoff matrices */
//	    printPayoffMatrices();
//	    
//	    /* Print the constraint matrices */
//	    printConstraintMatrices();
	    	   	    
	    makeReducedSystem();
	}

	
	/** ORIGINAL SYSTEM **/
	RationalMatrix A;
	RationalMatrix B;
	RationalMatrix E;
	RationalMatrix F;
	RationalMatrix e;
	RationalMatrix f;
	
	/** REDUCED SYSTEM **/
	RationalMatrix p;
	RationalMatrix P;
	RationalMatrix q;
	RationalMatrix Q;
	RationalMatrix a_;
	RationalMatrix b_;
	RationalMatrix A_;
	RationalMatrix B_;
	
	
	void makeReducedSystem() {
		
		/* Make matrix A */
		A = new RationalMatrix(payoffs.get(firstPlayer)).transpose();
		/* Make matrix B */
		B = new RationalMatrix(payoffs.get(firstPlayer.next)).transpose();
		
		/* Make matrix E */
		E = new RationalMatrix(constraintsMap.get(firstPlayer));
		/* Make matrix F */
		F = new RationalMatrix(constraintsMap.get(firstPlayer.next));
		
		/* Make vector e */
		e = new RationalMatrix(E.getRowSize(), 1);
		e.setElement(0, 0, Rational.ONE);
		
		/* Make vector f */
		f = new RationalMatrix(F.getRowSize(), 1);
		f.setElement(0, 0, Rational.ONE);
		
		printOriginalSystem();
		
		{
			RationalMatrix t1 = E.copy();
			t1 = t1.appendAfter(e);
			t1.gaussJordanElimination();
			RationalMatrix E_B = t1.getSubmatrix(0, 0, E.getRowSize(), E.getRowSize());
			RationalMatrix E_I = t1.getSubmatrix(0, E.getRowSize(), E.getRowSize(), E.getColumnSize());
			RationalMatrix e_ = t1.getSubmatrix(0, E.getColumnSize(), E.getRowSize(), E.getColumnSize()+1);
			
			RationalMatrix t2 = F.copy();
			t2 = t2.appendAfter(f);
			t2.gaussJordanElimination();
			RationalMatrix F_B = t2.getSubmatrix(0, 0, F.getRowSize(), F.getRowSize());
			RationalMatrix F_I = t2.getSubmatrix(0, F.getRowSize(), F.getRowSize(), F.getColumnSize());
			RationalMatrix f_ = t2.getSubmatrix(0, F.getColumnSize(), F.getRowSize(), F.getColumnSize()+1);
		
			p = E_B.inverse().multiply(e_);
			P = E_B.inverse().multiply(Rational.NEGONE).multiply(E_I);
	
			q = F_B.inverse().multiply(f_);
			Q = F_B.inverse().multiply(Rational.NEGONE).multiply(F_I);
		}
		
		{
			int s1 = A.getRowSize() - P.getRowSize(); 
			RationalMatrix t1 = new RationalMatrix(s1, P.getColumnSize(), true);
			int s2 = A.getColumnSize() - q.getRowSize(); 
			RationalMatrix t2 = new RationalMatrix(s2, q.getColumnSize(), false);

			a_ = P.appendBelow(t1).transpose().multiply(A).multiply(q.appendBelow(t2));
		}
		
		{
			int s1 = B.getRowSize() - p.getRowSize(); 
			RationalMatrix t1 = new RationalMatrix(s1, p.getColumnSize(), false);
			int s2 = B.getColumnSize() - Q.getRowSize(); 
			RationalMatrix t2 = new RationalMatrix(s2, Q.getColumnSize(), true);
			
			b_ = p.appendBelow(t1).transpose().multiply(B).multiply(Q.appendBelow(t2));
		}

		{
			int s1 = A.getRowSize() - P.getRowSize(); 
			RationalMatrix t1 = new RationalMatrix(s1, P.getColumnSize(), true);
			int s2 = A.getColumnSize() - Q.getRowSize(); 
			RationalMatrix t2 = new RationalMatrix(s2, Q.getColumnSize(), true);
			
			A_ = P.appendBelow(t1).transpose().multiply(A).multiply(Q.appendBelow(t2));
		}
		
		{
			int s1 = B.getRowSize() - P.getRowSize(); 
			RationalMatrix t1 = new RationalMatrix(s1, P.getColumnSize(), true);
			int s2 = B.getColumnSize() - Q.getRowSize(); 
			RationalMatrix t2 = new RationalMatrix(s2, Q.getColumnSize(), true);
			
			B_ = P.appendBelow(t1).transpose().multiply(B).multiply(Q.appendBelow(t2));
		}
		
		printReducedSystem();
	}
	
	void testRationalMatrices() {
		logi("Test rational matrices...");
		
		Rational[][] other = {	{	Rational.valueOf(1.),
									Rational.valueOf(0.),
									Rational.valueOf(2.)},
								{	Rational.valueOf(-2.),
									Rational.valueOf(1.),
									Rational.valueOf(0.)},
								{	Rational.valueOf(0.),
									Rational.valueOf(2.),
									Rational.valueOf(-1.)} };
		
		RationalMatrix matrix = new RationalMatrix(other);
		logi("\tORIG matrix:\n%s", matrix.toString());
		matrix.invert();
		logi("\tINVE matrix:\n%s", matrix.toString());
		
	}
	
	void printPayoffMatrices() {
		logi("Payoff matrices:");
		ColumnTextWriter colpp = new ColumnTextWriter();

		for (Player pl = firstPlayer; pl != null; pl = pl.next) {
			
			/* Get the payoff matrix of the current player */
			Rational[][] mat = payoffs.get(pl);
			
			/* This table will contain info about the current player,
			 * so let make her name in the top-left corner */
			colpp.writeCol(pl.toString());
			
			/* Make the horizontal header of the payoff matrix */
			for (int j = 0; j < nseqs(firstPlayer); ++j) {
				/* Get the available move of the firstPlayer */
				Move colMove = seqsMap.get(firstPlayer).get(j);
				/* Print its name (or empty) */
				colpp.writeCol(colMove == null ? EMPTY : colMove.toString());
			}
			
			/* Make new line */
			colpp.endRow();
			
			/* Fill-in the payoff matrix of the current player */
			for (int i = 0; i < mat.length; ++i) {
				
				/* Make the vertical header of the payoff matrix */
				/* Get the available move of the firstPlayer */
				Move rowMove = seqsMap.get(firstPlayer.next).get(i);
				/* Print its name (or empty) */
				colpp.writeCol(rowMove == null ? EMPTY : rowMove.toString());
				
				/* Print the payoff in the current leaf */
				for (int j = 0; j < mat[i].length; ++j) {
					/* Get the original payoff value (before adjustment) */
					Rational pay = mat[i][j];
					/* Print it if any */
					colpp.writeCol(pay.isZero() ? "." : pay.toString());
				}

				/* Make new line */
				colpp.endRow();
			}
			
			/* Make new line */
			colpp.endRow();
		}
		
		logi(colpp);
	}
	
	void printConstraintMatrices() {
		logi("Constraint matrices:");
		ColumnTextWriter colpp = new ColumnTextWriter();
		
		for (Player pl = firstPlayer; pl != null; pl = pl.next) {
			/* This table will contain info about the current player,
			 * so let make her name in the top-left corner */
			colpp.writeCol(pl.toString());
			
			/* Make the horizontal header of the payoff matrix */
			for (int j = 0; j < nseqs(pl); ++j) {
				/* Get the available move of the firstPlayer */
				Move colMove = seqsMap.get(pl).get(j);
				/* Print its name (or empty) */
				colpp.writeCol(colMove == null ? EMPTY : colMove.toString());
			}
			
			/* Make new line */
			colpp.endRow();
			
			/* Go through the information sets of the current player */			
			for (int j = 0; j < nisets(pl) + 1; ++j) {
				
				/* Make the vertical header of the constraint matrix */
				if (j == 0) {
					/* Print its name (or empty) */
					colpp.writeCol(EMPTY);
				} else {
					/* Get current information set */
					Iset h = isetsMap.get(pl).get(j-1);
					/* Get the move what leads to this information set */
					Move hseqin = seqin.get(h);
					/* Print its name (or empty) */
					colpp.writeCol(hseqin == null ? EMPTY : hseqin.toString());
				}
				
				/* Fill-in the current constraint */
				for (int i = 0; i < nseqs(pl); ++i) {
					Integer cstr = constraintsMap.get(pl)[j][i];
					colpp.writeCol(cstr == 0 ? "." : cstr.toString());
				}
				
				/* Make new line */
				colpp.endRow();
			}
			
			/* Make new line */
			colpp.endRow();
		}
		
		logi(colpp);
	}

	void printOriginalSystem() {
		logi("Original matrices:");
		logi("A:\n%s", A.toString());
		logi("B:\n%s", B.toString());
		logi("E:\n%s", E.toString());
		logi("F:\n%s", F.toString());
		logi("e:\n%s", e.toString());
		logi("f:\n%s", f.toString());
	}
	
	void printReducedSystem() {
		logi("Reduced matrices:");
		logi("p:\n%s", p.toString());
		logi("P:\n%s", P.toString());
		logi("q:\n%s", q.toString());
		logi("Q:\n%s", Q.toString());
		logi("a_:\n%s", a_.toString());
		logi("b_:\n%s", b_.toString());
		logi("A_:\n%s", A_.toString());
		logi("B_:\n%s", B_.toString());
	}
	
	/*// utils //*/
	private static final String EMPTY = "\u00D8";
	
	private void logi(String format, Object... args) {
		log.info(String.format(format, args));
	}

	private void logi(ColumnTextWriter colpp) {
		StringWriter output = new StringWriter();
		output.write(colpp.toString());
		
		log.info(String.format(output.toString()));
	}
	
    private int nseqs(Player pl) {    	
    	return seqsMap.get(pl).size();
    }
    
    private int nisets(Player pl) {
    	if (isetsMap.containsKey(pl)) {
    		return isetsMap.get(pl).size();
    	} else {
    		return 0;
    	}
    }
   
}
