package lse.math.games.tree;

import lse.math.games.io.ColumnTextWriter;

public class ExtensiveForm 
{
	char[] an1 = new char[] { '!', 'A', 'a' }; //Assumes 2 players in this array...
    char[] an2 = new char[] { '/', 'Z', 'z' }; //ditto...

    private Player _firstPlayer;
    private Player _lastPlayer;
    
    private Node _root;
    private int _nnodes = 0;
    
    public ExtensiveForm() {
    	_root = this.createNode();
    }
    
    public Node createNode()
    {
    	return new Node(_nnodes++);
    }
    
    public Node root() {
    	return _root;
    }
    
    public Player firstPlayer() {
    	return _firstPlayer;
    }
    
    public Node firstLeaf() {
    	return _root.firstLeaf();
    }
    
    public void autoname()
    {    
        for (Player pl = _firstPlayer; pl != null; pl = pl.next)    /* name isets of player pl      */
    	{
        	int idx = pl == Player.CHANCE ? 0 : pl == _firstPlayer ? 1 : 2;
    	    int anbase = an2[idx]-an1[idx]+1;
    	    
    	    int digits = 1;    	    
    	    for (int max = anbase, n = nisets(pl); max < n; max *= anbase) {
    	        ++digits;
    	    }
 
    	    int count = 0;
    	    for (Iset h = _root.iset(); h != null; h = h.next())
    	    {
    	    	if (h.player() == pl) {	        	            	    	 
	                StringBuilder sb = new StringBuilder();
	        	    for (int j = digits - 1, i = count; j >= 0; --j, i /= anbase)
	        		{
	                    char c = (char)(an1[idx] + (i % anbase));
	            		sb.append(c);	            		
	        		}
	                h.setName(sb.toString());
    	    	}
    	    	++count;
    	    }
    	}
    }
    
    private int nisets(Player pl) {
	    int count = 0;
    	for (Iset h = _root.iset(); h != null; h = h.next())
	    {
    		if (h.player() == pl) {
    			++count;
    		}
	    }
    	return count;
    }
    
    private int noutcome = 0;
	public Outcome createOutcome(Node wrapNode) { 
		return new Outcome(noutcome++, wrapNode);
	}
	
	private Iset _secondIset;
	private Iset _lastIset;
	private int _nisets = 0;
	
	public Iset createIset(Player player) {
		return createIset(null, player);
	}
	public Iset createIset(String isetId, Player player) {
		Iset h = new Iset(_nisets++, player);
		if (isetId != null) {
			h.setName(isetId);
		}
		if (_secondIset == null) {
			_secondIset = h;
		}
		if (_lastIset != null) {
			_lastIset.setNext(h);
		}
		h.setNext(null);
		_lastIset = h;
		return h;
	}
	public Player createPlayer(String playerId) 
	{
		if (playerId == Player.CHANCE_NAME) {
			return Player.CHANCE;
		}
		
		Player pl = new Player(playerId);
		if (_firstPlayer == null) {
			_firstPlayer = pl;
		}
		if (_lastPlayer != null) { 
			_lastPlayer.next = pl;
		}
		pl.next = null;
		_lastPlayer = pl;
		return pl;
	}
	
	public void addToIset(Node node, Iset iset) { 
		node.setIset(iset); 
		iset.insertNode(node);
		if (node == _root) {
			// pull iset out of list & make it the front
			for (Iset h = _secondIset; h != null; h = h.next()) {
				if (h.next() == iset) {
					h.setNext(iset.next());
				}
			}
			if (iset != _secondIset) { //avoid the infinite loop
				iset.setNext(_secondIset);
			}
		}
	}
	
	private int _nmoves = 0;
	public Move createMove(String moveId) {
		Move mv = new Move(_nmoves++);
		if (moveId != null) {
			mv.setLabel(moveId);
		}
		return mv;
	}
	public Move createMove() {
		return createMove(null);	
	}
	
	@Override
	public String toString() 
	{
		ColumnTextWriter colpp = new ColumnTextWriter();		
		
		colpp.writeCol("node");
		colpp.writeCol("leaf");
		colpp.writeCol("iset");
		colpp.writeCol("player");
		colpp.writeCol("parent");
		colpp.writeCol("reachedby");
		colpp.writeCol("outcome");
		colpp.writeCol("pay1");
		colpp.writeCol("pay2");
		colpp.endRow();
		
		recToString(_root, colpp);
		colpp.sortBy(0, 1);

		return colpp.toString();
	}
	
	private void recToString(Node n, ColumnTextWriter colpp)
	{		
		colpp.writeCol(n.uid());
		colpp.writeCol(n.outcome == null ? 0 : 1);
		colpp.writeCol(n.iset() != null ? n.iset().name() : "");
		colpp.writeCol(n.iset() != null ? n.iset().player().toString() : "");
		colpp.writeCol(n.parent() != null ? n.parent().toString() : "");
		colpp.writeCol(n.reachedby != null ? n.reachedby.toString() : "");
		colpp.writeCol(n.outcome != null ? n.outcome.toString() : "");
		colpp.writeCol(n.outcome != null ? n.outcome.pay(_firstPlayer).toString() : "");
		colpp.writeCol(n.outcome != null ? n.outcome.pay(_firstPlayer.next).toString() : "");
		colpp.endRow();
		
		for (Node child = n.firstChild(); child != null; child = child.sibling()) {
			recToString(child, colpp);
		}
	}
}
