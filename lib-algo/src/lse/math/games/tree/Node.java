package lse.math.games.tree;

public class Node 
{   
	private int _uid;
	
	private Node _firstChild;
	private Node _lastChild;
	
    private Node _parent;          // node closer to root
    private Node _sibling;         // sibling to the right
	
    private Iset _iset;
    
	Node(int uid) { 
		_uid = uid;
	}
    
    public int uid() {
    	return _uid;
    }
    public boolean terminal;
    
    public Iset iset() { return _iset; }
    void setIset(Iset iset) { _iset = iset; _iset.insertNode(this);}
    
    public Node nextInIset;
    
    public Move reachedby;      /* move of edge from father             */
    public Outcome outcome;
    
    public Node firstChild() { return _firstChild; }

	public void addChild(Node node) {
		if (_firstChild == null) {
			_firstChild = node;
		}
		if (_lastChild != null) {
			_lastChild._sibling = node;
		}
		node._parent = this;
		node._sibling = null;
		_lastChild = node;
	}
	
	public Node parent() {
		return _parent;
	}
	
	public Node sibling() {
		return _sibling;
	}
	
	Node firstLeaf() {
		if (_firstChild == null) {
			return this;
		} else {
			return _firstChild.firstLeaf();
		}
	}
	
	public Node nextLeaf() {
		if (_sibling != null) {
			return _sibling.firstLeaf();
		} else if (_parent != null) {
			return _parent.nextLeaf();
		} else {
			return null;			
		}
	}
	
	@Override
	public String toString()
	{
		return String.valueOf(_uid);
	}
}
