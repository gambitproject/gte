package lse.math.games.tree;

import java.util.HashMap;
import java.util.Map;
import java.util.Set;

import lse.math.games.Rational;

public class Outcome
{
    private Node node;
    private Map<Player,Rational> pay;
    private Map<Player,String> parameter;
    private int _uid;
    
    Outcome(int uid, Node wrapNode)
    {
    	_uid = uid;
        this.node = wrapNode;
        wrapNode.terminal = true;
        wrapNode.outcome = this;
        pay = new HashMap<Player,Rational>();    
        parameter = new HashMap<Player,String>();    
    }
    
    public int uid() { return _uid; }
    
    public Node whichnode() { return node; }
    public int idx;
    
    public Set<Player> players() { return pay.keySet(); }

    
    public Rational pay(Player pl) {
    	return pay.get(pl);
    }
    
    public void setPay(Player pl, Rational value) {
    	pay.put(pl, value);
    }
    
    
    public String parameter(Player pl) {
    	return parameter.get(pl);
    }
    
    public void setParameter(Player pl, String value) {
    	parameter.put(pl, value);
    }
    
    @Override
    public String toString() {
    	return String.valueOf(_uid);
    }
}
