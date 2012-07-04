package lse.math.games.tree;

import lse.math.games.Rational;

public class Move {
	
	private int _uid;
	private Iset _iset; // where this move emanates from
	
    Move(int uid) { 
    	_uid = uid;
    } 
    
    Move(int uid, Rational prob)
    {
    	this(uid);
    	this.prob = prob;
    }
    
    /* idx in the iset's move array */
    public int setIdx() {
    	if (_iset == null) return -1;
    	
    	int idx = 0;
    	for (Node child = _iset.firstNode().firstChild(); child != null; child = child.sibling()) {
    		if (child.reachedby == this) {
    			break;
    		}
    		++idx;
    	}
    	return idx;
    }

    public Rational prob = null;      /* behavior probability                 */
    private String _label;
    
    public void setLabel(String value) { _label = value; }
    public String getLabel() { return _label; }
    
    public int uid() { return _uid; }
    
    public Iset iset() {
    	return _iset;
    }
    
    public void setIset(Iset iset) {
    	_iset = iset;
    }
    
    @Override
    public String toString()
    {
    	if (_label != null) {
    		return _label;
    	} else if (prob != null && _iset.player() == Player.CHANCE) {
    		return String.format("%s(%s)", Player.CHANCE_NAME, prob.toString());
    	}
    	int setIdx = setIdx();
        if (setIdx < 0) return "()";
        return String.format("%s%d", _iset.name(), setIdx); //index in the parent iset array
    }    
}
