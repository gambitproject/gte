package lse.math.games.tree;

import java.io.StringWriter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.logging.Logger;

import lse.math.games.Rational;
import lse.math.games.io.ColumnTextWriter;

public class ReducedForm
{
	/*// variables //*/
	private static final Logger log = Logger.getLogger(ReducedForm.class.getName());
	
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
		
		logi("PRINT");
		
		/* Print the payoff matrices */
	    printPayoffMatrices();
	    
	    /* Print the constraint matrices */
	    printConstraintMatrices();
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
