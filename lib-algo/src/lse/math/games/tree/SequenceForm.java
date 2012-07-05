package lse.math.games.tree;

import java.io.StringWriter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Random;
import java.util.logging.Logger;

import lse.math.games.Rational;
import lse.math.games.io.ColumnTextWriter;
import lse.math.games.lcp.LCP;
import lse.math.games.reduced.ReducedForm;

public class SequenceForm 
{	
	private static final Logger log = Logger.getLogger(SequenceForm.class.getName());

    private Player firstPlayer;    

    private Long _seed = null;
    
    Map<Player,Rational> payAdjust;
    private Map<Player,Rational[][]> payoffs = new HashMap<Player,Rational[][]>();
    private Map<Player,Integer[][]> constraintsMap = new HashMap<Player,Integer[][]>();
    
    
    private Map<Iset,Move> seqin = new HashMap<Iset,Move>();
    private Map<Node,Map<Player,Move>> defseq = new HashMap<Node,Map<Player,Move>>();
    
    private Map<Player,List<Move>> seqsMap = new HashMap<Player,List<Move>>();
    private Map<Move,Integer> seqsIdxMap = new HashMap<Move,Integer>();
    
    private List<Iset> isets = new ArrayList<Iset>(); // sorted top-to-bottom, left-to-right
    private Map<Player,List<Iset>> isetsMap = new HashMap<Player,List<Iset>>();
    private Map<Iset,Integer> isetsIdxMap = new HashMap<Iset,Integer>();
    
    private Map<Move,Rational> randomPriors = new HashMap<Move,Rational>();
       
    /***********************/
    /* getters and setters */
    /***********************/
    public Player getFirstPlayer() {
		return firstPlayer;
	}

	public Map<Player, Rational[][]> getPayoffs() {
		return payoffs;
	}

	public Map<Player, Integer[][]> getConstraintsMap() {
		return constraintsMap;
	}

	public Map<Iset, Move> getSeqin() {
		return seqin;
	}

	public Map<Node, Map<Player, Move>> getDefseq() {
		return defseq;
	}

	public Map<Player, List<Move>> getSeqsMap() {
		return seqsMap;
	}

	public Map<Move, Integer> getSeqsIdxMap() {
		return seqsIdxMap;
	}

	public List<Iset> getIsets() {
		return isets;
	}

	public Map<Player, List<Iset>> getIsetsMap() {
		return isetsMap;
	}

	public Map<Iset, Integer> getIsetsIdxMap() {
		return isetsIdxMap;
	}

	public Map<Player,Rational> getPayAdjust() {
		return payAdjust;
	}
	
	public Map<Move, Rational> getRandomPriors() {
		return randomPriors;
	}

    
    //static int oldnseqs1 = 0;
    //static int[] oldconstrows = new int[] {0, 0, 0};
    public SequenceForm(ExtensiveForm tree)
		throws ImperfectRecallException
	{     	
    	this(tree, null);
	}
    
	public SequenceForm(ExtensiveForm tree, Long seed)
    	throws ImperfectRecallException
    {    	
    	log.info("Making sequence form...");
    	
    	_seed = seed;
    	
    	log.info("\tSet players..");
    	firstPlayer = tree.firstPlayer();
    	new String();
		log.info(String.format("\t.. first player: %s", firstPlayer.toString()));
    	
		log.info("\tFill in seqsMap..");
    	seqsIdxMap.put(null, 0);
    	for (Player pl = firstPlayer; pl != null; pl = pl.next) {
	    	List<Move> plMoves = new ArrayList<Move>();
	    	plMoves.add(null);	    	
	    	seqsMap.put(pl, plMoves);
	    	log.info(String.format("\t.. add player: %s", pl.toString()));
    	}  
    	
    	log.info(String.format("\t.. add chance player"));
    	List<Move> chanceMoves = new ArrayList<Move>();
    	chanceMoves.add(null);
    	seqsMap.put(Player.CHANCE, chanceMoves);
    	    	
    	log.info(String.format("\tGen seq in"));
    	genseqin(tree); // TODO: adjust max pay?
        allocsf();
        
        log.info(String.format("\tSet pay adjust.."));
        payAdjust = getPayAdjust(tree);
        for (Player pl : payAdjust.keySet()) {
        	log.info(String.format("\t.. player's (%s) payAdjust: %s", pl.toString(), payAdjust.get(pl).toString()));	
        }
        
        // pre-process chance probs
        //behavtorealprob(Player.CHANCE);            

        /* sf payoff matrices                   */
        log.info(String.format("\tSet payoff matrices.."));
        for (Node u = tree.firstLeaf(); u != null; u = u.nextLeaf())
    	{        	
        	Map<Player,Move> udefseq = defseq.get(u);
        	log.info(String.format("\t\tNode %s, Defseq: %s", u.toString(), udefseq.toString()));
        	int row = seqsIdxMap.get(udefseq.get(firstPlayer));
        	int col = seqsIdxMap.get(udefseq.get(firstPlayer.next));
        	log.info(String.format("\t\t.. row: %d, col: %d", row, col));
            for (Player pl = tree.firstPlayer(); pl != null; pl = pl.next) {
                Rational pay = u.outcome.pay(pl).add(payAdjust.get(pl));                
                Rational prob = realprob(udefseq.get(Player.CHANCE)); // get probability of reaching this node even if both players trying to get here
                log.info(String.format("\t\tPlayer: %s, [%d][%d] = pay: %s * prop: %s, (orig pay: %s)", pl.toString(), row, col, pay.toString(), prob.toString(), u.outcome.pay(pl).toString()));
                payoffs.get(pl)[row][col] = payoffs.get(pl)[row][col].add(prob.multiply(pay));
            }
    	}
        /* sf constraint matrices, sparse fill  */
        log.info(String.format("\tSet constraint matrices.."));
        for (Player pl = tree.firstPlayer(); pl != null; pl = pl.next) {
        	initConstraints(pl);
    	}
    }
    
    private void initConstraints(Player pl)
    {
    	Integer[][] constraints = constraintsMap.get(pl);
    	List<Iset> isets = isetsMap.get(pl);
    	List<Move> seqs = seqsMap.get(pl);
    	int nisets = isets != null ? isets.size() : 0;
    	
        for (int i = 0; i < nisets + 1; ++i) {
            for (int j = 0; j < seqs.size(); j++) {
                constraints[i][j] = 0;
            }           
        }
    	
    	constraints[0][0] = 1;     /* empty sequence                       */
    	
        for (int i = 0; i < nisets; ++i)
        {
            int row = i + 1;
            int col = seqsIdxMap.get(seqin.get(isets.get(i)));
            constraints[row][col] = -1;            
        }
        for (int j = 1; j < seqs.size(); j++)
        {
            int row = isetsIdxMap.get(seqs.get(j).iset()) + 1;
            int col = j;
            constraints[row][col] = 1;
        }
    }

    // TODO: requires moves to be sorted by decision depth
    // this makes realprob method faster
    /*private void behavtorealprob(Player pl)
    {
        List<Move> moves = seqsMap.get(pl);
        moves.get(0).realprob = Rational.ONE;                  
        for (int i = 1; i < moves.size(); ++i)
        {
            Move c = moves.get(i);
            c.realprob = c.prob.multiply(seqin.get(c.iset()).realprob);
        }
    }*/
    
    // TODO: not as fast as pre-assigning based on sorted move list (see above)
    private Rational realprob(Move c)
    {
    	Rational prob = Rational.ONE;
    	while (c != null) {
    		prob = prob.multiply(behvprob(c));
    		c = seqin.get(c.iset());
    	}
    	return prob;
    }

    private void genseqin(ExtensiveForm tree)
    throws ImperfectRecallException
    {
    	Random prng = null;
    	if (_seed != null) prng = new Random(_seed);
    	recgenseqin(tree.root(), prng);
    }
    
    private void recgenseqin(Node node, Random prng)
    throws ImperfectRecallException
    {
        Map<Player,Move> defseqMap = new HashMap<Player,Move>();
        defseq.put(node, defseqMap);

        // update sequence triple, new only for move leading to  u
        log.info(String.format("\tRec gen seq in.."));
        for (Player pl = firstPlayer; pl != null; pl = pl.next) {
        	log.info(String.format("\tNode: %s, player: %s",  node.toString(), pl.toString()));
        	if (node.reachedby == null) {
        		log.info(String.format("\t.. reached by null"));
        		defseqMap.put(pl, null);
        	} else if (node.reachedby.iset().player() == pl) {
        		log.info(String.format("\t.. reached by %s, iset %s", node.reachedby, node.reachedby.iset()));
        		defseqMap.put(pl, node.reachedby);
        	} else {
        		log.info(String.format("\t.. reached by %s, parent node: %s", defseq.get(node.parent()).get(pl), node.parent()));
        		defseqMap.put(pl, defseq.get(node.parent()).get(pl));
        	}
        }
    	if (node.reachedby == null) {
    		defseqMap.put(Player.CHANCE, null);
    	} else if (node.reachedby.iset().player() == Player.CHANCE) {
    		defseqMap.put(Player.CHANCE, node.reachedby);
    	} else {
    		defseqMap.put(Player.CHANCE, defseq.get(node.parent()).get(Player.CHANCE));
    	}

        // update sequence for iset, check perfect recall, recurse on children
        Iset h = node.iset();
        if (h != null)                                         
    	{
    	    addIset(h, prng);
    	    
    	    Move seq = defseqMap.get(h.player());
    	    Move hseqin = this.seqin.get(h);
    	    if (hseqin == null) {
    		    seqin.put(h, seq);
    	    }
    	    else if (seq != hseqin)            		
    		{
        		String errorMsg = String.format(
                        "imperfect recall in info set no. %d named %s for player %s [different sequences no. %d, %d]", 
                        h.uid(), h.name(), h.player(), seq.setIdx(), hseqin.setIdx());
                log.warning(errorMsg);
        		throw new ImperfectRecallException(errorMsg);
    		}
    	    
    	    for (Node child = node.firstChild(); child != null; child = child.sibling()) {
    	    	recgenseqin(child, prng);
    	    }
	    }	    
    }

    private void addIset(Iset h, Random prng) {
    	if (h != null && !isets.contains(h)) {
    		isets.add(h);
    		assignPriors(h, prng); // TODO: do this at LCP gen time so we can reuse this obj for multi-priors
	    	Player pl = h.player();
	    	List<Iset> plIsets = isetsMap.get(pl);
	    	if (plIsets == null) {
	    		plIsets = new ArrayList<Iset>();
	    		isetsMap.put(pl, plIsets);
	    	}	    	
	    	isetsIdxMap.put(h, plIsets.size());
	    	plIsets.add(h);
	
	    	List<Move> plMoves = seqsMap.get(pl);
	    	for (Node child = h.firstNode().firstChild(); child != null; child = child.sibling()) {
	    		seqsIdxMap.put(child.reachedby, plMoves.size());
	    		plMoves.add(child.reachedby);
	    	}
    	}
	}
   
    private Map<Player,Rational> getPayAdjust(ExtensiveForm tree)
    {
    	Map<Player,Rational> maxpay = new HashMap<Player,Rational>();
    	
    	for (Node leaf = tree.firstLeaf(); leaf != null; leaf = leaf.nextLeaf()) 
	    {
	    	Outcome z = leaf.outcome;
	    	for (Player pl = firstPlayer; pl != null; pl = pl.next)
	    	{
    	    	if (!maxpay.containsKey(pl) || z.pay(pl).compareTo(maxpay.get(pl)) > 0) {
    		        maxpay.put(pl, z.pay(pl));    		        
    	    	}
	    	}
	    }
    	
        for (Player pl = firstPlayer; pl != null; pl = pl.next) {                                     
    	    log.info(String.format(
    	        "Player %s's maximum payoff is %s, normalize to -1.", pl.toString(), maxpay.get(pl).toString()));    	    
    	
    	    log.info(String.format(".. ( %s + 1 ) * -1 =", maxpay.get(pl).toString()));
            maxpay.put(pl, (maxpay.get(pl).add(1)).negate());
            log.info(String.format("\t=", maxpay.get(pl).toString()));
    	}
        return maxpay;
    }
    
    
    private void allocsf()
    {   
        /* payoff matrices, two players only here, init to pay 0        */
        for (Player pl = firstPlayer; pl != null; pl = pl.next) {
            payoffs.put(pl, new Rational[nseqs(firstPlayer)][nseqs(firstPlayer.next)]);
            for (int i = 0; i < nseqs(firstPlayer); i++)
                for (int j = 0; j < nseqs(firstPlayer.next); j++)
                	payoffs.get(pl)[i][j] = Rational.ZERO;
       	
    	    constraintsMap.put(pl, new Integer[nisets(pl) + 1][nseqs(pl)]); /* extra row for seq 0  */
    	}
    }
    
    private void assignPriors(Iset h, Random prng) {
    	Rational probToGive = Rational.ONE;
		int nNeedProb = 0;
		for (Node child = h.firstNode().firstChild(); child != null; child = child.sibling())
		{								
			if (child.reachedby.prob == null) {
				++nNeedProb;
			} else {
				probToGive = probToGive.subtract(child.reachedby.prob);
				if (probToGive.compareTo(0) < 0) {
					child.reachedby.prob = child.reachedby.prob.add(probToGive);
					probToGive = Rational.ZERO;
				}
			}
		}
		
		if (nNeedProb > 0) {
			if (prng != null) {
				Rational[] probs = Rational.probVector(nNeedProb, prng);
				int i = 0;
				for (Node child = h.firstNode().firstChild(); child != null; child = child.sibling()) {									
					if (child.reachedby.prob == null) {
						randomPriors.put(child.reachedby, probToGive.multiply(probs[i]));
						++i;
					}
				}
			} else {
				Rational prob = probToGive.divide(Rational.valueOf(nNeedProb));
				for (Node child = h.firstNode().firstChild(); child != null; child = child.sibling()) {									
					if (child.reachedby.prob == null) {
						randomPriors.put(child.reachedby, prob);
					}
				}
			}
		}
    }
    
    private Rational behvprob(Move c) {
    	if (c.prob != null) {    		
    		return c.prob;
    	} else {    		
    		return randomPriors.get(c);
    	}
    }

    @Override
    public String toString()
    {
    	// TODO: JUST TEMPORARY
    	ReducedForm reducedForm = new ReducedForm(this);
    	
    	// TODO: add matrices
		StringWriter output = new StringWriter();
		ColumnTextWriter colpp = new ColumnTextWriter();		
		for (Player pl = firstPlayer; pl != null; pl = pl.next) {
			Rational[][] mat = payoffs.get(pl);
			colpp.writeCol(pl.toString());
			for (int j = 0; j < nseqs(firstPlayer.next); ++j) {
				Move colMove = seqsMap.get(firstPlayer.next).get(j);
				colpp.writeCol(colMove == null ? "\u00D8" : colMove.toString());
			}
			if (pl == firstPlayer) {			
				for (int j = 0; j < nisets(firstPlayer); ++j) 
				{
					Iset h = isetsMap.get(firstPlayer).get(j);
					Move hseqin = seqin.get(h);
					colpp.writeCol(hseqin == null ? "\u00D8" : hseqin.toString());					
				}
			}
			colpp.endRow();
			for (int i = 0; i < mat.length; ++i) {
				Move rowMove = seqsMap.get(firstPlayer).get(i);
				colpp.writeCol(rowMove == null ? "\u00D8" : rowMove.toString());
				for (int j = 0; j < mat[i].length; ++j) {
					Rational pay = mat[i][j];
					colpp.writeCol(pay.isZero() ? "." : pay.toString());
				}
				if (pl == firstPlayer) {		
					for (int j = 0; j < nisets(firstPlayer); ++j) {
						Integer cstr = constraintsMap.get(firstPlayer)[j + 1][i];
						colpp.writeCol(cstr == 0 ? "." : cstr.toString());
					}
				}
				colpp.endRow();
			}
			if (pl == firstPlayer.next) {	
				for (int i = 0; i < nisets(firstPlayer.next); ++i) {
					Iset h = isetsMap.get(firstPlayer.next).get(i);
					Move hseqin = seqin.get(h);
					colpp.writeCol(hseqin == null ? "\u00D8" : hseqin.toString());
					
					for (int j = 0; j < nseqs(firstPlayer.next); ++j) {
						Integer cstr = constraintsMap.get(firstPlayer.next)[i + 1][j];
						colpp.writeCol(cstr == 0 ? "." : cstr.toString());
					}
					colpp.endRow();
				}
			}
			colpp.endRow();
		}
		
		output.write(colpp.toString());
		
		colpp = new ColumnTextWriter();
		colpp.writeCol("Priors");
		colpp.endRow();
		if (_seed != null) {
			colpp.writeCol("seed");
			colpp.writeCol(_seed.toString());
			colpp.endRow();
			colpp.endRow();
		}		
		for (int i = 1; i < nseqs(firstPlayer); ++i) {
			Move c = seqsMap.get(firstPlayer).get(i);
			Rational.printRow(c.toString(), behvprob(c), colpp, false);
		}
		colpp.endRow();
		for (int j = 1; j < nseqs(firstPlayer.next); ++j) {
			Move c = seqsMap.get(firstPlayer.next).get(j);
			Rational.printRow(c.toString(), behvprob(c), colpp, false);
		}
		colpp.alignLeft(0);
		output.write(colpp.toString());
				
		return output.toString();
    }
    
    public LCP getLemkeLCP()
    throws InvalidPlayerException
    {
    	if (firstPlayer == null || firstPlayer.next == null || firstPlayer.next.next != null) {
    		throw new InvalidPlayerException("Sequence Form must have two and only two players");
    	}
    	
        // preprocess priors here so that we can re-randomize the priors without having to reconstruct this object?
        //for (Player pl = firstPlayer; pl != null; pl = pl.next) {
    	//		behavtorealprob(pl); 
        //}
    	
    	LCP lcp = new LCP(nseqs(1) + nisets(2) + 1 + nseqs(2) + nisets(1) + 1);
    	Integer[][] constraints1 = constraintsMap.get(firstPlayer);
    	Integer[][] constraints2 = constraintsMap.get(firstPlayer.next);
    	Rational[][] pay1 = payoffs.get(firstPlayer);
    	Rational[][] pay2 = payoffs.get(firstPlayer.next);
    	
        /* fill  M  */
        /* -A       */
        //lcp.payratmatcpy(pay[0], true, false, nseqs(1), nseqs(2), 0, nseqs(1) + nisets(2) + 1);
        for (int i = 0; i < pay1.length; ++i) {
            for (int j = 0; j < pay1[i].length; ++j) {
                Rational value = pay1[i][j].negate();
                lcp.setM(i, j + nseqs(1) + nisets(2) + 1, value);
            }
        }
        
        /* -E\T     */
        //lcp.intratmatcpy(constraints[1], true, true, nisets(1) + 1, nseqs(1), 0, nseqs(1) + nisets(2) + 1 + nseqs(2));
        for (int i = 0; i < constraints1.length; ++i) {
            for (int j = 0; j < constraints1[i].length; ++j) {
                Rational value = Rational.valueOf(-constraints1[i][j]);
                lcp.setM(j, i + nseqs(1) + nisets(2) + 1 + nseqs(2), value);
            }
        } 
        
        /* F        */
        //lcp.intratmatcpy(constraints[2], false, false, nisets(2) + 1, nseqs(2), nseqs(1), nseqs(1) + nisets(2) + 1);
        for (int i = 0; i < constraints2.length; ++i) {
            for (int j = 0; j < constraints2[i].length; ++j) {
                Rational value = Rational.valueOf(constraints2[i][j]);
                lcp.setM(i + nseqs(1), j + nseqs(1) + nisets(2) + 1, value);
            }
        }
        
        /* -B\T     */        
        //lcp.payratmatcpy(pay[1], true, true, nseqs(1), nseqs(2), nseqs(1) + nisets(2) + 1, 0);
        for (int i = 0; i < pay2.length; ++i) {
            for (int j = 0; j < pay2[i].length; ++j) {
                Rational value = pay2[i][j].negate();
                lcp.setM(j + nseqs(1) + nisets(2) + 1, i, value);
            }
        } 
                
        /* -F\T     */        
        //lcp.intratmatcpy(constraints[2], true, true, nisets(2) + 1, nseqs(2), nseqs(1) + nisets(2) + 1, nseqs(1));
        for (int i = 0; i < constraints2.length; ++i) {
            for (int j = 0; j < constraints2[i].length; ++j) {
                Rational value = Rational.valueOf(-constraints2[i][j]);
                lcp.setM(j + nseqs(1) + nisets(2) + 1, i + nseqs(1), value);
            }
        }        
        
        /* E        */        
        //lcp.intratmatcpy(constraints[1], false, false, nisets(1) + 1, nseqs(1), nseqs(1) + nisets(2) + 1 + nseqs(2), 0);
        for (int i = 0; i < constraints1.length; ++i) {
            for (int j = 0; j < constraints1[i].length; ++j) {
                Rational value = Rational.valueOf(constraints1[i][j]);
                lcp.setM(i + nseqs(1) + nisets(2) + 1 + nseqs(2), j, value);
            }
        }
        
        /* define RHS q,  using special shape of SF constraints RHS e,f     */
        lcp.setq(nseqs(1), Rational.NEGONE);
        lcp.setq(nseqs(1) + nisets(2) + 1 + nseqs(2), Rational.NEGONE);

        return addCoveringVector(lcp);        
    }
    
    private LCP addCoveringVector(LCP lcp)
    {
    	// this is where priors come into play... 
        int dim1 = nseqs(1);
        int dim2 = nseqs(2);
        int offset = dim1 + 1 + nisets(2);

        /* covering vector  = -rhsq */
        for (int i = 0; i < lcp.size(); i++) {
            lcp.setd(i, lcp.q(i).negate());
        }

        /* first blockrow += -Aq    */
        for (int j = 0; j < dim2; j++) {
            Rational prob = realprob(seqsMap.get(firstPlayer.next).get(j));
            if (!prob.isZero()) {
                for (int i = 0; i < dim1; i++) {
                    lcp.setd(i, lcp.d(i).add(lcp.M(i, offset + j).multiply(prob)));
                }
            }
        }

        /* third blockrow += -B\T p */
        for (int j = 0; j < dim1; j++) {
            Rational prob = realprob(seqsMap.get(firstPlayer).get(j));
            if (!prob.isZero()) {
                for (int i = offset; i < offset + dim2; i++) {
                    lcp.setd(i, lcp.d(i).add(lcp.M(i, j).multiply(prob)));
                }
            }
        }        
        return lcp;
    }
   
    public Map<Player,Map<Move,Rational>> parseLemkeSolution(Rational[] solz)
    {
    	Map<Player,Map<Move,Rational>> probs = new HashMap<Player,Map<Move,Rational>>();
        int offset = nseqs(firstPlayer) + 1 + nisets(firstPlayer.next);

        Rational[] probs1 = new Rational[nseqs(firstPlayer)];
        System.arraycopy(solz, 0, probs1, 0, probs1.length);
                
        Map<Move,Rational> moves1 = createMoveMap(probs1, firstPlayer);      
        // how to find expected payoffs... traverse the tree after?
        probs.put(firstPlayer, moves1);
        
        Rational[] probs2 = new Rational[nseqs(firstPlayer.next)];                
        System.arraycopy(solz, offset, probs2, 0, probs2.length);
        
        Map<Move,Rational> moves2 = createMoveMap(probs2, firstPlayer.next);
        probs.put(firstPlayer.next, moves2);
        
        //log.info("returning probs");
        return probs;
    }
    
    // these are realization probabilities, not behavior probs...
    // need to convert back...
    private Map<Move,Rational> createMoveMap(Rational[] probs, Player pl)
    {
        Map<Move,Rational> moves = new HashMap<Move,Rational>();
        for (int i = 1; i < probs.length; ++i) {
        	if (!probs[i].isZero()) {        		
        		Move c = seqsMap.get(pl).get(i);
        		Rational baseProb = Rational.ONE;
        		if (seqin.get(c.iset()) != null) {
        			baseProb = probs[seqsIdxMap.get(seqin.get(c.iset()))];
        		}
        		Rational behvProb = probs[i].divide(baseProb);
        		log.fine("move " + c.toString() + " with prob " + behvProb.toString());
        		moves.put(c, behvProb);
        	}
        }
        return moves;
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
    
    private int nseqs(int plIdx) {    	
    	return nseqs(player(plIdx));
    }
    
    private int nisets(int plIdx) {    	
    	return nisets(player(plIdx));
    }
    
    private Player player(int idx) {
    	return idx == 1 ? firstPlayer : firstPlayer.next;
    }
    
    public static class InvalidPlayerException extends Exception
    {
		private static final long serialVersionUID = 1L;

		public InvalidPlayerException(String msg) {
    		super(msg);
    	}
    }
    
    public static class ImperfectRecallException extends Exception
    {
		private static final long serialVersionUID = 1L;

		public ImperfectRecallException(String msg) {
    		super(msg);
    	}
    }
    
    public static Map<Player,Rational> expectedPayoffs(Map<Player,Map<Move,Rational>> equilib, ExtensiveForm tree)
    {
    	Map<Player,Rational> epayoffs = new HashMap<Player,Rational>();
    	recExpectedPayoffs(tree.root(), Rational.ONE, equilib, epayoffs);
    	//log.info("returning payoffs");
    	return epayoffs;
    }

	private static void recExpectedPayoffs(Node node, Rational prob, Map<Player, Map<Move, Rational>> equilib, Map<Player, Rational> epayoffs) {
		if (node.outcome != null) {
			for (Player pl : node.outcome.players()){
				Rational payoff = epayoffs.get(pl);
				Rational fromThisOutcome = node.outcome.pay(pl).multiply(prob);
				if (payoff == null) {
					payoff = fromThisOutcome;
				} else {
					payoff = payoff.add(fromThisOutcome);
				}
				epayoffs.put(pl, payoff);
			}
		} else {
			Player pl = node.iset().player();
			// go through child nodes and recurse on moves that exist for the current player
			// with positive probability
			for (Node child = node.firstChild(); child != null; child = child.sibling()) {					
				if (pl == Player.CHANCE) {
					recExpectedPayoffs(child, prob.multiply(child.reachedby.prob), equilib, epayoffs);
				} else if (equilib.get(pl).containsKey(child.reachedby)) {					
					recExpectedPayoffs(child, prob.multiply(equilib.get(pl).get(child.reachedby)), equilib, epayoffs);
				}
			}
		}
	}
}
