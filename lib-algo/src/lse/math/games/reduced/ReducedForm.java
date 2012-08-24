package lse.math.games.reduced;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.lang.reflect.Array;
import java.math.BigInteger;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

import lse.math.games.LogUtils;
import lse.math.games.LogUtils.LogLevel;
import lse.math.games.Rational;
import lse.math.games.io.ColumnTextWriter;
import lse.math.games.tree.ExtensiveForm;
import lse.math.games.tree.Iset;
import lse.math.games.tree.Move;
import lse.math.games.tree.Player;
import lse.math.games.tree.SequenceForm;
import lse.math.games.tree.SequenceForm.ImperfectRecallException;

public class ReducedForm
{
	/*// variables //*/	
	private String lrsPath = ".";
	
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
	
	private class Equilibria {
		public RationalMatrix x;
		public RationalMatrix y;
		
		public Equilibria(RationalMatrix tx, RationalMatrix ty) {
			x = tx;
			y = ty;
		}

		@Override
		public int hashCode() {
			final int prime = 31;
			int result = 1;
			result = prime * result + getOuterType().hashCode();
			result = prime * result + ((x == null) ? 0 : x.hashCode());
			result = prime * result + ((y == null) ? 0 : y.hashCode());
			return result;
		}

		@Override
		public boolean equals(Object obj) {
			if (this == obj)
				return true;
			if (obj == null)
				return false;
			if (getClass() != obj.getClass())
				return false;
			Equilibria other = (Equilibria) obj;
			if (!getOuterType().equals(other.getOuterType()))
				return false;
			if (x == null) {
				if (other.x != null)
					return false;
			} else if (!x.equals(other.x))
				return false;
			if (y == null) {
				if (other.y != null)
					return false;
			} else if (!y.equals(other.y))
				return false;
			return true;
		}

		private ReducedForm getOuterType() {
			return ReducedForm.this;
		}		
		
	}
    
    /* > **** FOR 2-PERSON EXTENSIVE GAME IN REDUCED FORM **** > */
	/* ORIGINAL SYSTEM */
	RationalMatrix A;
	RationalMatrix B;
	RationalMatrix E;
	RationalMatrix F;
	RationalMatrix e;
	RationalMatrix f;
	int nSizeForPlayer1;
	int nSizeForPlayer2;
	List<Integer> basisHeadT1;
	List<Integer> basisHeadT2;
	
	/* REDUCED SYSTEM */
	RationalMatrix p;
	RationalMatrix P;
	RationalMatrix q;
	RationalMatrix Q;
	RationalMatrix a_;
	RationalMatrix b_;
	RationalMatrix A_;
	RationalMatrix B_;
	
	RationalMatrix p1;
	RationalMatrix p2;
	RationalMatrix P1;
	RationalMatrix P2;
	RationalMatrix q1;
	RationalMatrix q2;
	RationalMatrix Q1;
	RationalMatrix Q2;
	
	List<Equilibria> equilibriums;
    /* < **** FOR 2-PERSON EXTENSIVE GAME IN REDUCED FORM **** < */
    	
    
	/*// methods //*/
	public ReducedForm(ExtensiveForm tree) throws ImperfectRecallException
	{
		this(new SequenceForm(tree));	
	}
	
	public ReducedForm(SequenceForm seq)
	{
		LogUtils.logi(LogLevel.SHORT, "~~~~~ Reduced form >>> ~~~~~");
		LogUtils.logi(LogLevel.DEBUG, "Making reduced form...");
		
		/* Make deep copy from sequence form */
		/* Temporary dictionary about players */
		Map<Player, Player> oldNewPlayers = new HashMap<Player, Player>();
		
		/* Clone players */
		LogUtils.logi(LogLevel.DEBUG, "Clone players...");
		firstPlayer = new Player(seq.getFirstPlayer().toString());
		oldNewPlayers.put(seq.getFirstPlayer(), firstPlayer);
		
		for (Player pl = firstPlayer, orig = seq.getFirstPlayer().next; 
				orig != null; orig = orig.next) {
			pl.next = new Player(orig.toString());
			oldNewPlayers.put(orig, pl.next);	
		}
		
		/* Clone pay adjust */
		LogUtils.logi(LogLevel.DEBUG, "Clone pay adjust...");
		LogUtils.logi(LogLevel.DEBUG, "Orig pay adjust: %s", seq.getPayAdjust());
		payAdjust = new HashMap<Player,Rational>();
		for (Player pl : seq.getPayAdjust().keySet()) {
			/* Look up our player from the dictionary
			 * and set a new Rational to it */
			payAdjust.put(oldNewPlayers.get(pl), new Rational(seq.getPayAdjust().get(pl)));
		}

		/* Temporary dictionary about moves */
		Map<Move, Move> oldNewMoves = new HashMap<Move, Move>();
		
		/* Clone sequences map */
		LogUtils.logi(LogLevel.DEBUG, "Clone seqsmap...");
		LogUtils.logi(LogLevel.DEBUG, "Orig seqs map: %s", seq.getSeqsMap());
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
    	LogUtils.logi(LogLevel.DEBUG, "Clone isetsMap...");
    	LogUtils.logi(LogLevel.DEBUG, "Orig isetsMap: %s", seq.getIsetsMap());
		isetsMap = new HashMap<Player,List<Iset>>();
		for (Player orig : seq.getIsetsMap().keySet()) {
			Player pl = oldNewPlayers.get(orig);
			
			List<Iset> isets  = new LinkedList<Iset>();
			for (Iset origIset : seq.getIsetsMap().get(orig)) {
				Iset iset = new Iset(origIset.uid(), pl);
				iset.setName(origIset.name());
				
				if (origIset.moves != null) {
					LogUtils.logi(LogLevel.DEBUG, "\tOrig iset: %s %s", origIset, origIset.moves);
					
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
		LogUtils.logi(LogLevel.DEBUG, "Clone seqin...");
		LogUtils.logi(LogLevel.DEBUG, "Orig seqin: %s", seq.getSeqin());
		seqin = new HashMap<Iset,Move>();	    
	    for (Iset origIset : seq.getSeqin().keySet()) {
	    	Iset iset = oldNewIsets.get(origIset);
	    	Move move = oldNewMoves.get(seq.getSeqin().get(origIset));
	    	seqin.put(iset, move);
	    }
		
		/* Clone payoffs */
	    LogUtils.logi(LogLevel.DEBUG, "Clone payoffs...");
	    LogUtils.logi(LogLevel.DEBUG, "Orig payoffs: %s", seq.getPayoffs());
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
		LogUtils.logi(LogLevel.DEBUG, "Clone constraintsMap...");
		LogUtils.logi(LogLevel.DEBUG, "Orig constraint map: %s", seq.getConstraintsMap());
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
	    
	    LogUtils.logi(LogLevel.SHORT, "~~~~~ <<< Reduced form ~~~~~\n");
	}

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
		
		/* Nonterminals for Player1 */
		nSizeForPlayer1 = 0;
		for (int i = 0; i < E.getColumnSize(); i++) {
			for (int j = 0; j < E.getRowSize(); j++) {
				if (E.getElement(j,  i).negate().isOne()) {
					nSizeForPlayer1++;
					break;
				}
			}			
		}
		
		nSizeForPlayer2 = 0;
		for (int i = 0; i < F.getColumnSize(); i++) {
			for (int j = 0; j < F.getRowSize(); j++) {
				if (F.getElement(j,  i).negate().isOne()) {
					nSizeForPlayer2++;
					break;
				}
			}			
		}
		
		{
			RationalMatrix t1 = E.copy();
			t1 = t1.appendAfter(e);
//			LogUtils.logi(LOGLEVEL.DETAILED, "t1 before:\n%s", t1.toString());
			t1.makeBasisForm();
//			LogUtils.logi(LOGLEVEL.DETAILED, "t1 after:\n%s", t1.toString());
			basisHeadT1 = t1.getBasisHead();
			
			RationalMatrix E_B = t1.getBasis();
			RationalMatrix E_I0 = t1.getNonBasis();
			RationalMatrix E_I = E_I0.getSubmatrix(0, 0, E_I0.getRowSize(), E_I0.getColumnSize()-1);
			RationalMatrix e_  = E_I0.getSubmatrix(0, E_I0.getColumnSize()-1, E_I0.getRowSize(), E_I0.getColumnSize());

//			LogUtils.logi(LOGLEVEL.DETAILED, "E_b:\n%s", E_B.toString());
//			LogUtils.logi(LOGLEVEL.DETAILED, "E_i:\n%s", E_I.toString());
//			LogUtils.logi(LOGLEVEL.DETAILED, "e_:\n%s", e_.toString());
			
			RationalMatrix t2 = F.copy();
			t2 = t2.appendAfter(f);
			t2.makeBasisForm();
			
			basisHeadT2 = t2.getBasisHead();
			
			RationalMatrix F_B = t2.getBasis();
			RationalMatrix F_I0 = t2.getNonBasis();
			RationalMatrix F_I = F_I0.getSubmatrix(0, 0, F_I0.getRowSize(), F_I0.getColumnSize()-1);
			RationalMatrix f_  = F_I0.getSubmatrix(0, F_I0.getColumnSize()-1, F_I0.getRowSize(), F_I0.getColumnSize());
			
//			LogUtils.logi(LOGLEVEL.DETAILED, "F_b:\n%s", F_B.toString());
//			LogUtils.logi(LOGLEVEL.DETAILED, "F_i:\n%s", F_I.toString());
//			LogUtils.logi(LOGLEVEL.DETAILED, "f_:\n%s", f_.toString());
			
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
		
		{
			p1 = p.getSubmatrix(0, 0, nSizeForPlayer1, p.getColumnSize());
			p2 = p.getSubmatrix(nSizeForPlayer1, 0, p.getRowSize(), p.getColumnSize());
			P1 = P.getSubmatrix(0, 0, nSizeForPlayer1, P.getColumnSize());
			P2 = P.getSubmatrix(nSizeForPlayer1, 0, P.getRowSize(), P.getColumnSize());
			
			q1 = q.getSubmatrix(0, 0, nSizeForPlayer2, q.getColumnSize());
			q2 = q.getSubmatrix(nSizeForPlayer2, 0, q.getRowSize(), q.getColumnSize());
			Q1 = Q.getSubmatrix(0, 0, nSizeForPlayer2, Q.getColumnSize());
			Q2 = Q.getSubmatrix(nSizeForPlayer2, 0, Q.getRowSize(), Q.getColumnSize());
		}
	}

	private void printIndependentVariables(LogLevel l, Player player) {
		String iString = "";
		List<Move> moves = seqsMap.get(player);
		List<Integer> basisHead = (player == firstPlayer) ? basisHeadT1 : basisHeadT2; 
		
		for (int i = 0; i < moves.size(); i++) {
			if (basisHead.contains(i) == false) {
				iString += " " + moves.get(i);
			}
		}
		LogUtils.logi(l, "Independent %s: %s", ((player == firstPlayer) ? "x" : "y"), iString );
	}
	
	private void printAllVariables(LogLevel l, Player player) {
		LogUtils.logi(l, "All %s: %s", ((player == firstPlayer) ? "x" : "y"), seqsMap.get(player));
	}
	
	private void printAllVariableValues(LogLevel l, Player player, RationalMatrix valuesOfIndependents) {
		ColumnTextWriter colpp = new ColumnTextWriter();
		
		List<Move> moves = seqsMap.get(player);
 		for (int i = 0; i < moves.size(); i++) {
 			Move m = moves.get(i);
			colpp.writeCol((m==null)?"null":m.toString());
		}
		colpp.endRow();
		
		RationalMatrix allValues = calculateAllVariableValues(player, valuesOfIndependents);
		for (int i = 0; i < allValues.getRowSize(); i++) {
			colpp.writeCol(allValues.getElement(i, 0).toString());
		}
		
		LogUtils.logi(l, "%s", colpp);
	}
	
	private RationalMatrix calculateAllVariableValues(Player player, RationalMatrix valuesOfIndependents) {
		
		RationalMatrix ret;
		if (player == firstPlayer) {
			RationalMatrix xI = valuesOfIndependents.transpose();
			RationalMatrix xN = p1.add(P1.multiply(xI));
			RationalMatrix xD = p2.add(P2.multiply(xI));
			RationalMatrix x = xN.appendBelow(xD).appendBelow(xI);
			ret = x;
		} else {
			RationalMatrix yI = valuesOfIndependents.transpose();
			RationalMatrix yN = q1.add(Q1.multiply(yI));
			RationalMatrix yD = q2.add(Q2.multiply(yI)); 
			RationalMatrix y = yN.appendBelow(yD).appendBelow(yI);
			ret = y;
		}
		
		return ret;
	}

	public void findEqLrs() {
		
		equilibriums = new LinkedList<ReducedForm.Equilibria>();
		
		RationalMatrix d1, d2;
		{
			String input = makeHRepForLrs1();
			String output = runLrs(input);
			d1 = makeVRepFromLrs(firstPlayer, output);
		}
		
		{
			String input = makeHRepForLrs2();
			String output = runLrs(input);
			d2 = makeVRepFromLrs(firstPlayer.next, output);
		}
		
		LogUtils.logi(LogLevel.SHORT, "~~~~~ Searching for completely labelled pairs >>> ~~~~~");
		RationalMatrix vertices1 = d1.getSubmatrix(0, 0, d1.getRowSize(), d1.getColumnSize()-1);
		RationalMatrix labels1  = d1.getSubmatrix(0, d1.getColumnSize()-1, d1.getRowSize(), d1.getColumnSize());
		RationalMatrix vertices2 = d2.getSubmatrix(0, 0, d2.getRowSize(), d2.getColumnSize()-1);
		RationalMatrix labels2  = d2.getSubmatrix(0, d2.getColumnSize()-1, d2.getRowSize(), d2.getColumnSize());
		
		for (int i = 0; i < d1.getRowSize(); i++) {
			Integer l1 = Integer.parseInt(labels1.getElement(i, 0).toString());
//			LogUtils.logi(LOGLEVEL.DETAILED, "X #%d %s: %s", i, vertices1.rowtoString(i), Integer.toBinaryString(l1));
			
			for (int j = 0; j < d2.getRowSize(); j++) {
				Integer l2 = Integer.parseInt(labels2.getElement(j, 0).toString());
//				LogUtils.logi(LOGLEVEL.DETAILED, "Y #%d %s: %s", j, vertices2.rowtoString(j), Integer.toBinaryString(l2));
				
				if ( (l1|l2) == Integer.MAX_VALUE) {
					
					RationalMatrix xRow = vertices1.getSubmatrix(i, 0, i+1, vertices1.getColumnSize() - Q2.getRowSize());
					RationalMatrix yRow = vertices2.getSubmatrix(j, 0, j+1, vertices2.getColumnSize() - P2.getRowSize());
					
					LogUtils.logi(LogLevel.DETAILED, "EQUILIBRIUM at [x %s] and [y %s]", xRow.rowtoString(0), yRow.rowtoString(0));
					printAllVariableValues(LogLevel.DETAILED, firstPlayer, xRow);
					printAllVariableValues(LogLevel.DETAILED, firstPlayer.next, yRow);
					LogUtils.logi(LogLevel.DETAILED, "\n");
					
					calculateEq(xRow, yRow);
				}
			}
		}
		
		LogUtils.logi(LogLevel.SHORT, "~~~~~ <<< Searching for completely labelled pairs ~~~~~\n");
		
		LogUtils.logi(LogLevel.MINIMAL, "===================================================");
		LogUtils.logi(LogLevel.MINIMAL, "||             EQUILIBRIUMS                      ||");
		LogUtils.logi(LogLevel.MINIMAL, "===================================================");
		
		
		printAllVariables(LogLevel.MINIMAL, firstPlayer);
		printAllVariables(LogLevel.MINIMAL, firstPlayer.next);
		
		LogUtils.logi(LogLevel.MINIMAL, "");
		for (int i = 0; i < equilibriums.size(); i++) {
			LogUtils.logi(LogLevel.MINIMAL, "(%d) x: %s && y: %s", i, equilibriums.get(i).x.transpose().rowtoString(0), equilibriums.get(i).y.transpose().rowtoString(0));
		}
	}
	
	private void calculateEq(RationalMatrix xI, RationalMatrix yI) {
	
		RationalMatrix x = calculateAllVariableValues(firstPlayer, xI);
		RationalMatrix y = calculateAllVariableValues(firstPlayer.next, yI); 
		
		Equilibria solution = new Equilibria(x,y);
		if (equilibriums.contains(solution)) {
			return;
		}
		
		equilibriums.add(solution);
	}
	
	private String makeHRepForLrs1() {
		
		LogUtils.logi(LogLevel.SHORT, "~~~~~ 1st player: H representation for lrs >>> ~~~~~");
		
		int m = b_.getColumnSize() + p2.getRowSize() + B_.getRowSize() + Q2.getRowSize();
		int n = b_.getRowSize() + B_.getRowSize() + Q2.getRowSize();
		
		String constraints = "";
		RationalMatrix ineqN = b_.transpose().
									appendAfter(B_.transpose()).
									appendAfter(Q2.transpose()).multiply(Rational.NEGONE);
		
		RationalMatrix ineqS = p2.	appendAfter(P2).
									appendAfter(new RationalMatrix(p2.getRowSize(), Q2.getRowSize(), false));
		RationalMatrix ineqT = new RationalMatrix(Q2.getRowSize(), n - Q2.getRowSize(), false).
									appendAfter(new RationalMatrix(Q2.getRowSize(), Q2.getRowSize(), true));

		RationalMatrix ineqM = new RationalMatrix(B_.getRowSize(), b_.getRowSize(), false).
									appendAfter(new RationalMatrix(B_.getRowSize(), B_.getRowSize(), true)).
									appendAfter(new RationalMatrix(B_.getRowSize(), Q2.getRowSize(), false));

		constraints = ineqS.appendBelow(ineqT).appendBelow(ineqM).appendBelow(ineqN).toString();
		
		String ret = makeHOutput(m, n, constraints);
		LogUtils.logi(LogLevel.DETAILED, "%s", ret);
		LogUtils.logi(LogLevel.SHORT, "~~~~~ <<< 1st player: H representation for lrs ~~~~~\n");
		return ret;
	}

	private String makeHRepForLrs2() {
		
		LogUtils.logi(LogLevel.SHORT, "~~~~~ 2nd player: H representation for lrs >>> ~~~~~");
		
		int m = a_.getRowSize() + q2.getRowSize() + A_.getColumnSize() + P2.getRowSize();
		int n = a_.getColumnSize() + A_.getColumnSize() + P2.getRowSize();
		
		String constraints = "";
		RationalMatrix ineqM = a_.	appendAfter(A_).
									appendAfter(P2.transpose()).multiply(Rational.NEGONE);
		
		RationalMatrix ineqT = q2.	appendAfter(Q2).
									appendAfter(new RationalMatrix(q2.getRowSize(), P2.getRowSize(), false));
		
		RationalMatrix ineqS = new RationalMatrix(P2.getRowSize(), n - P2.getRowSize(), false).
									appendAfter(new RationalMatrix(P2.getRowSize(), P2.getRowSize(), true));
		
		RationalMatrix ineqN = new RationalMatrix(A_.getColumnSize(), a_.getColumnSize(), false).
									appendAfter(new RationalMatrix(A_.getColumnSize(), A_.getColumnSize(), true)).
									appendAfter(new RationalMatrix(A_.getColumnSize(), P2.getRowSize(), false));
		
		constraints = ineqS.appendBelow(ineqT).appendBelow(ineqM).appendBelow(ineqN).toString();
		
		String ret = makeHOutput(m, n, constraints);
		LogUtils.logi(LogLevel.DETAILED, "%s", ret);
		LogUtils.logi(LogLevel.SHORT, "~~~~~ <<< 2nd player: H representation for lrs ~~~~~\n");
		return ret;
	}
	
	private String makeHOutput(int m, int n, String constraints) {
		String output = "";
		output += "Temporary_problem\n";
		output += "H-representation\n";
		output += "begin\n"; 
		output += m + " " + n + " rational\n";
		output += constraints;
		output += "end\n";
		output += "printslack"; 
		return output;		
	}
	
	public void setLrsPath(String path) {
		if (path.isEmpty() == false) {
			lrsPath = path;
		}
	}
	
	private String runLrs(String input) {
		LogUtils.logi(LogLevel.SHORT, "~~~~~ Output of the lrs binary >>> ~~~~~");

		String output = "";
		try {
			BufferedWriter out = new BufferedWriter(new FileWriter("temp.ine"));
			out.write(input);
			out.close();
		}
		catch (IOException e) {
			LogUtils.logi(LogLevel.DETAILED, "Error while writing the temporary output file.");		
		}
				
		ProcessBuilder pb = new ProcessBuilder(lrsPath + "/lrs", "temp.ine");
		Process p;
		try {
			p = pb.start();
			p.waitFor();
			
			InputStream is = p.getInputStream();
			InputStreamReader isr = new InputStreamReader(is);
			BufferedReader br = new BufferedReader(isr);

			String line;
			while ((line = br.readLine()) != null || p.exitValue() != 0) {
			    output += "\t" + line + "\n";
			}
			
			LogUtils.logi(LogLevel.DETAILED, "%s", output);
			
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (InterruptedException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} finally {
			File temp = new File("temp.ine");
			temp.delete();
		}
		
		LogUtils.logi(LogLevel.SHORT, "~~~~~ <<< Output of the lrs binary ~~~~~\n");
		return output;
	}

	private RationalMatrix makeVRepFromLrs(Player player, String output) {
		LogUtils.logi(LogLevel.SHORT, "~~~~~ Processing vertex representation from lrs >>> ~~~~~");
		int firstIdx = 0, lastIdx = 0;
		
		String[] lines = output.split("\n");
		for (int i = 0; i < lines.length; i++) {
			String line = lines[i];
			if (line.contains("rational") == true) {
				firstIdx = i+1;
			} else if (line.contains("end") == true) {
				lastIdx = i-1;
			}
		}
		
		int n = 0;
		RationalMatrix vertices = null;
		List<Integer> labels = new LinkedList<Integer>();
		
		/* Process items */
		for (int i = firstIdx; i <= lastIdx; i++) {
			String line = lines[i];
			String[] items = line.replaceFirst("^\\s+",  "").split("\\s+");
			
			/* Check row type */
			if (items[0].equalsIgnoreCase("0")) {
				labels.remove(labels.size()-1);
				continue;
			}
			if (items[0].equalsIgnoreCase("slack")) {
				Integer label = Integer.MAX_VALUE;
				for (int j = 2; j < items.length; j++) {
					int l = Integer.parseInt(items[j]);
					label &= ~(1 << l);
				}
				
//				LogUtils.logi(LOGLEVEL.DETAILED, "\tSlack: %s = %s", Arrays.toString(items), Integer.toBinaryString(label));
				
				labels.add(label);
				continue;
			}
			
			if (n == 0) {
				n = items.length - 1;
			}
			
			RationalMatrix row = new RationalMatrix(1, n);
			for (int j = 1; j < n+1; j++) {
				String[] item = items[j].split("/");
				
				BigInteger num = new BigInteger(item[0]);
				BigInteger den = BigInteger.ONE;
				if (item.length > 1) {
					den = new BigInteger(item[1]);
				}

				Rational number = new Rational(num, den);
				row.setElement(0, j-1, number);
			}
			
			if (vertices == null) {
				vertices = row;
			} else {
				vertices = vertices.appendBelow(row);
			}
		}
		
		printIndependentVariables(LogLevel.SHORT, player);
		LogUtils.logi(LogLevel.SHORT, "Vertices:");
		
		for (int i = 0; i < vertices.getRowSize(); i++) {
			
			LogUtils.logi(LogLevel.SHORT, "(%d) : %s, which means:", i, vertices.rowtoString(i));	
			LogUtils.logi(LogLevel.SHORT, "Label: %s, all values:", Integer.toBinaryString(labels.get(i)));
			
			int dualVarSize = (player==firstPlayer) ? Q2.getRowSize() : P2.getRowSize();
			RationalMatrix row = vertices.getSubmatrix(i, 0, i+1, vertices.getColumnSize() - dualVarSize);
			printAllVariableValues(LogLevel.SHORT, player, row);
			LogUtils.logi(LogLevel.SHORT, "");
		}
		
		
		RationalMatrix labelCol = new RationalMatrix(labels.size(), 1);
		for (int i = 0; i < labels.size(); i++) {
			labelCol.setElement(i, 0, new Rational(labels.get(i)));
		}
		vertices = vertices.appendAfter(labelCol);
		
		LogUtils.logi(LogLevel.SHORT, "~~~~~ <<< Processing vertex representation from lrs ~~~~~\n");
		
		return vertices;
	}
	
	
	void testRationalMatrices() {
		LogUtils.logi(LogLevel.DETAILED, "Test rational matrices...");
		
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
		LogUtils.logi(LogLevel.DETAILED, "\tORIG matrix:\n%s", matrix.toString());
		matrix.invert();
		LogUtils.logi(LogLevel.DETAILED, "\tINVE matrix:\n%s", matrix.toString());
		
	}
	
	void printPayoffMatrices() {
		LogUtils.logi(LogLevel.DETAILED, "Payoff matrices:");
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
		
		LogUtils.logi(LogLevel.DETAILED, colpp);
	}
	
	void printConstraintMatrices() {
		LogUtils.logi(LogLevel.DETAILED, "Constraint matrices:");
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
		
		LogUtils.logi(LogLevel.DETAILED, colpp);
	}

	public void printOriginalSystem() {
		LogUtils.logi(LogLevel.SHORT, "~~~~~ Reduced form: ORIGINAL SYSTEM >>> ~~~~~");
		LogUtils.logi(LogLevel.SHORT, "A:\n%s", A.toString());
		LogUtils.logi(LogLevel.SHORT, "B:\n%s", B.toString());
		LogUtils.logi(LogLevel.SHORT, "E:\n%s", E.toString());
		LogUtils.logi(LogLevel.SHORT, "F:\n%s", F.toString());
		LogUtils.logi(LogLevel.SHORT, "e:\n%s", e.toString());
		LogUtils.logi(LogLevel.SHORT, "f:\n%s", f.toString());
		LogUtils.logi(LogLevel.SHORT, "~~~~~ <<< Reduced form: ORIGINAL SYSTEM ~~~~~\n");
	}
	
	public void printReducedSystem() {
		LogUtils.logi(LogLevel.SHORT, "~~~~~ Reduced form: REDUCED SYSTEM >>> ~~~~~");
		LogUtils.logi(LogLevel.SHORT, "p:\n%s", p.toString());
		LogUtils.logi(LogLevel.SHORT, "P:\n%s", P.toString());
		LogUtils.logi(LogLevel.SHORT, "q:\n%s", q.toString());
		LogUtils.logi(LogLevel.SHORT, "Q:\n%s", Q.toString());
		LogUtils.logi(LogLevel.SHORT, "a_:\n%s", a_.toString());
		LogUtils.logi(LogLevel.SHORT, "b_:\n%s", b_.toString());
		LogUtils.logi(LogLevel.SHORT, "A_:\n%s", A_.toString());
		LogUtils.logi(LogLevel.SHORT, "B_:\n%s", B_.toString());
		LogUtils.logi(LogLevel.SHORT, "~~~~~ <<< Reduced form: REDUCED SYSTEM ~~~~~\n");
	}
	
	/*// utils //*/
	private static final String EMPTY = "\u00D8";
	
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
