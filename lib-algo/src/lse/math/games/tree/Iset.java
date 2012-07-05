package lse.math.games.tree;

public class Iset 
{	
	private Iset _next;
	private Node _firstNode;
	private Node _lastNode;
	private int _uid;
	
    public Iset(int uid, Player player)
    {
    	_uid = uid;
        _player = player;
    }

    private Player _player;
    private String _name;
    public Move[] moves;

    public String name() {
    	if (_name != null) return _name;
    	else return String.valueOf(_uid);
    }
    
    public int uid() { return _uid; }
    
    public void setName(String value) {
    	_name = value;
    }
    
    public Iset next() {
    	return _next;
    }
    
    public Node firstNode() {
    	return _firstNode;
    }
    
    public void setNext(Iset h) {
    	_next = h;
    }

	public void setPlayer(Player player) {
		_player = player;
	}
	
	public Player player() {
		return _player;
	}

	public void sort() {
		// TODO Auto-generated method stub
		throw new RuntimeException("Not impl");
	}
	
	public int nmoves() {
    	int count = 0;
    	for (Node child = _firstNode.firstChild(); child != null; child = child.sibling()) {
    		++count;
    	}
    	return count;
	}

	void insertNode(Node node) {				
		if (_firstNode == null) {
			_firstNode = node;
		}
		if (_lastNode != null) {
			_lastNode.nextInIset = node;
		}
		node.nextInIset = null;
		_lastNode = node;
	}
	
	public String toString()
	{
		return name();
	}
}
