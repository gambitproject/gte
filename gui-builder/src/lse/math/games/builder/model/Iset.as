package lse.math.games.builder.model
{
	import util.Log;
	
	/**	  
	 * This class represents an information set.</p>
	 * It contains:
	 * <ul><li>An internal linked list of its nodes, with reference to the first and 
	 * last ones, as well as functions for adding, sorting and accessing them, and getting 
	 * their number, the number of children, etc.</li>
	 * <li>The player it belongs to, and a method to change to the next player</li>
	 * <li>Functions to create and assign moves</li>
	 * <li>Functions for merging and dissolving isets</li>
	 * <li>Other functions: for making perfect recall & checking if one iset has descendants in another</li>
	 * <li>Functions for using the Iset as a node in a linked list of isets</li></ul>
	 * 
	 * @author Mark Egesdal
	 */
	public class Iset
	{		
		private var _firstNode:Node;
		private var _lastNode:Node;				
		private var _player:Player;
		
		private var log:Log = Log.instance;

		
		
		public function Iset(player:Player) 
		{
			if (player == null) log.add(Log.ERROR_THROW, "Cannot instanciate an Iset for a null player");
			_player = player;
		}
		
		/** Player to which this information set belongs */
		public function get player():Player { return _player; }	
		
		/** First node of the Iset */
		public function get firstNode():Node { return _firstNode; }
		internal function setFirstNode(first:Node):void {
			_firstNode = first;
		}
		
		/** Last node of the Iset */
		public function get lastNode():Node { return _lastNode; }
		internal function setLastNode(last:Node):void {
			_lastNode = last;
		}
		
		/** If the nodes don't have children */
		public function get isChildless():Boolean {			
			return _firstNode.isLeaf; // if the first one is a leaf... they all have to be leaves			
		}
		
		/** Number of nodes of the Iset */
		public function get numNodes():int {
			return indexOf(_lastNode) + 1;
		}
		
		/** Number of moves that can be taken from each node of the Iset (its the same number for all of them) */
		public function get numMoves():int {
			if(_firstNode == null)
				return 0;
			else
				return _firstNode.numChildren;
		}
		
		/** 
		 * A measure of the breadth of an iset (number of nodes, not necessarily inside 
		 * the iset, between the first and the last of it) 
		 */
		// TODO: spanAt(depth)
		public function get span():int
		{
			var span:int = 0;			
			for (var node:Node = _firstNode; node != _lastNode; node = node.right) {
				if (node == null) {
					
					var debugTrace:Vector.<String> = new Vector.<String>();
					for (node = _firstNode; node != null; node = node.right) {
						debugTrace.push(node.number);
					}					
					log.add(Log.ERROR_THROW, "Iset.span(): node was null before reached the last node " + _lastNode.number + " in iset " + _idx + ":" + debugTrace.join(" "));
				}
				++span;
			}
			return span;
		}
		
		
		
		/** Returns a node in a determinate position ('idx') inside the Iset, or null if there isn't one*/
		public function nodeAt(idx:int):Node
		{
			var node:Node = null;
			if (idx < numNodes / 2) { //Searching forward in Iset
				node = _firstNode;
				for (var i:int = 0; i < idx && node != null; ++i) {
					node = node.nextInIset;
				}
			} else { //Searching backward
				node = _lastNode;
				for (var j:int = numNodes - 1; j > idx && node != null; --j) {
					node = node.prevInIset;
				}
			}
			return node;
		}		
		
		/** Returns the index of 'node' in the Iset */
		public function indexOf(node:Node):int
		{
			var idx:int = 0;			
			for (var n:Node = _firstNode; n != null; n = n.nextInIset) {
				if (n == node) { 
					return idx; 
				}
				++idx;		
			}
			log.add(Log.ERROR_THROW, "Node "+node.toString()+" not found in iset");
			return -1;
		}
				
		/** Inserts a node in its place in the linked list of nodes */
		public function insertNode(toAdd:Node):Boolean
		{
			return insertNodeRightOf(_firstNode, toAdd);
		}
		
		//Inserts a node in the iset at its corresponding position, looking for it starting from the 'left' node
		private function insertNodeRightOf(left:Node, toAdd:Node):Boolean
		{			
			if (left != null && left.isRightOf(toAdd)) {
				log.add(Log.ERROR_THROW, "left should be a known node to the left of the add (for perf)");
				return false;
			}
			for (var a:Node = left, idx:int = 0; a != null; ++idx, a = a.nextInIset)
			{
				if (/*toAdd != null && */a.isRightOf(toAdd)) // insert b before a, and increment b
				{			
					toAdd.setIset(this/*, idx*/);					
					a.insertBefore(toAdd);
					if (_firstNode == a) {
						_firstNode = toAdd;
					}
					
					toAdd = null;
					break;
				}
			}
			if (toAdd != null)
			{
				appendNode(toAdd);
			}
			return true;
		}
		
		//Adds a node at the end of the linked list of this Iset 
		private function appendNode(toAdd:Node):void
		{
			if (_firstNode == null) {				
				toAdd.setIset(this);
				toAdd.makeFirstInIset();				
			} else {
				var oldLast:Node = _lastNode;
				oldLast.insertAfter(toAdd);
				toAdd.setIset(this);
			}			
			toAdd.makeLastInIset();			
		}
		
		/** Sorts the nodes in the Iset to be ordered from left-most to right-most */
		public function sort():void
		{
			var nodes:Vector.<Node> = new Vector.<Node>();
			
			for (var unsorted:Node = _firstNode; unsorted != null; unsorted = unsorted.nextInIset) {
				nodes.push(unsorted);
			}
			
			nodes.sort(Node.compare);
			
			var prev:Node = null;
			while (true) {
				var sorted:Node = nodes.shift();
				if (sorted == null) {
					_lastNode = prev;
					break;
				}				
				sorted.clearSetLinks();
				
				if (prev == null) {			
					_firstNode = sorted;				
				} else {
					prev.insertAfter(sorted);	
				}				
				prev = sorted;
			}
		}
		
		/** Assign a new move originating from this Iset's nodes */
		public function assignMove(move:Move):void
		{
			move.setIset(this);	
		}
		
		//Creates new move and assigns it this iset. Updates probs if player is CHANCE
		private function newMove():Move
		{			
			var move:Move = new Move();			
			if (_player == Player.CHANCE) 
			{				
				var n:int = _firstNode.numChildren + 1;
				
				if (n > 1) {
					// don't assign the last node yet, let it keep the residual... it will even out when the new node is added
					// otherwise it will push the residual back to the node before
					for (var child:Node = _firstNode.firstChild; child.sibling != null; child = child.sibling) {					
						child.reachedby.prob = new Rational(1, n);
					}
				}
				move.prob = new Rational(1, n);
			}
			assignMove(move);			
			return move;
		}

		/**
		 * Creates a new move, and therefore a new child for each of the nodes in this Iset, assigning all them 
		 * to a 'dest' Iset.<br>
		 * 'dest' Iset must be empty, or have nodes with no children.
		 */
		public function addMoveAndAssignChildrenTo(dest:Iset):Move
		{
			if(dest.numMoves != 0)
				log.add(Log.ERROR_THROW, "Error in addMoveTo(): the destination Iset should be childless");
			
			var move:Move = newMove(); 
			var left:Node = dest.firstNode;
			for (var n:Node = _firstNode; n != null; n = n.nextInIset)
			{
				var child:Node = n.newChild();
				child.reachedby = move;
				dest.insertNodeRightOf(left, child);
				left = child;
			}
			return move;
		}
		
		/**
		 * Creates a new move, and therefore a new child for each of the nodes in this Iset.
		 * @param destPlayer: The player to which the new children created will belong to
		 * @return (Move): the move
		 */
		public function addMove(destPlayer:Player):Move		
		{
			var move:Move = newMove();
			for (var n:Node = _firstNode; n != null; n = n.nextInIset)
			{
				var child:Node = n.newChild();
				child.reachedby = move;
				
				var iset:Iset = newIset(destPlayer);
				iset.appendNode(child);
			}
			return move;
		}

		/**
		 * Checks if the 'b' Iset has at least one node that is descendant 
		 * of at least one node of this Iset
		 */
		[Unused]
		public function has_descendant(b:Iset):Boolean
		{
			if (b == this) {
				return true;
			}
			for (var x:Node = b.firstNode; x != null; x = x.nextInIset)
			{
				var y:Node =  x.parent;
				if (y != null) {
					if(has_descendant(y.iset)) {
						return true;
					}
				}
			}
			return false;
		}
		
		/**
		 * Separates all of the nodes from the Iset, making each of them
		 * belong to a new Iset
		 */
		public function dissolve():void
		{			
			var h:Iset = this;		  
			while (h != null) {
				h = h._firstNode.makeLastInIset();						
			}
		}
		
		/** Checks if this Iset can be merged with another */
		public function canMergeWith(h:Iset):Boolean
		{
			if (this == h)
			{
				log.add(Log.HINT, "Couldn't merge the Isets: please select two different ones");
				return false;				
			}
			if (this.player != h.player)
			{
				log.add(Log.ERROR, "Couldn't merge the Isets: please select two of the same player");
				return false;
			}			
			if (numMoves != h.numMoves)
			{
				log.add(Log.ERROR, "Couldn't merge the Isets: please select two with the same number of moves");
				return false;
			}
			if (this.player == Player.CHANCE)
			{
				log.add(Log.HINT, "Chance nodes aren't mergeable into an Iset");
			}
			return true;
		}
		
		/** Absorbs nodes from 'other' Iset into this one, applying to all of them this one's moves. */
		public function merge(other:Iset):void
		{			
			// make the moves of other the same as those of this
			for (var p:Node = other.firstNode; p != null; p = p.nextInIset)
			{				
				var s:Node = _firstNode.firstChild; //we can just use the first node, since all moves in iset are the same
				for (var r:Node = p.firstChild; r != null; r = r.sibling) {
					r.reachedby = s.reachedby;					
					s = s.sibling;
				}
			}
			
			// add Nodes from other into nextInIset list of this
			var a:Node = _firstNode;
			var b:Node = other._firstNode;
			var bNext:Node = null;
			var idx:int = 0;
			
			while (b != null)
			{
				if (a == null) { // add b's to the end
					bNext = b.nextInIset;
					appendNode(b);
					b = bNext;
				} else if (a.isRightOf(b)) { // insert b before a, and increment b
					b.setIset(this);		
					++idx;
					bNext = b.nextInIset;					
					a.insertBefore(b);
					if (_firstNode == a) {
						_firstNode = b;
					}
					b = bNext;
				} else {
					a.setIset(this);
					++idx;
					a = a.nextInIset;
				}
			}
			while (a != null) {
				a.setIset(this);
				++idx;
				a = a.nextInIset;
			}
			
			// correct nextIset list
			if (this._idx < other._idx) {
				other.remove();
			} else {
				remove();				
				replace(other);
			}			
		}
		
		/** 
		 * Checks if all the nodes in the Iset have the same own move sequence,
		 * if one hasn't, returns false, if all have, returns true
		 */
		public function hasPerfectRecall():Boolean		
		{
			var baseline:Node = _firstNode;						
			for (var toCheck:Node = _firstNode.nextInIset; toCheck != null; toCheck = toCheck.nextInIset) {
				if (!baseline.hasSameOwnMoveSequenceAs(toCheck)) {					
					return false;
				}				
			}			
			return true;
		}
		
		/** 
		 * Creates new moves in replacement to the ones that already existed,
		 * that continue originating from this Iset and ending in the same nodes.
		 */
		internal function createNewMoves():void
		{
			var numChildren:int = _firstNode.numChildren;
			var newMoves:Vector.<Move> = new Vector.<Move>(numChildren);
			for (var mate:Node = _firstNode; mate != null; mate = mate.nextInIset) {
				for (var child:Node = mate.firstChild, i:int = 0; child != null; child = child.sibling, ++i)
				{
					var m:Move = newMoves[i];
					if (m == null) {
						m = createMove(numChildren);						
						newMoves[i] = m;
					}
					child.reachedby = m;
				}
			}
		}
		
		//Same as createNewMoves() but only creates the new moves in the first node
		[Unused]
		private function createNewMovesForSingleton():void
		{
			//create new moves for chopped off first node of the new set				
			var child:Node = _firstNode.firstChild;
			for (var i:int = 0, n:int = _firstNode.numChildren; i < n; ++i)
			{
				//create new move for that child
				var m:Move = createMove(n);
				child.reachedby = m;
				child = child.sibling;
			}
		}
		
		// Create a new move assigned to this Iset, and with the prob it should have if being a CHANCE move
		private function createMove(numSiblings:int):Move 
		{
			var m:Move = new Move();
			if (_player == Player.CHANCE) {
				m.prob = new Rational(1, numSiblings);
			}
			m.setIset(this);
			return m;
		}

		/** 
		 * Change the player of this Iset to the next one, or to the first 
		 * one if there isn't next, or if the player was CHANCE.<br>
		 * @param 'firstPlayer': Reference to the first player of the tree
		 */
		public function changePlayer(firstPlayer:Player):void
		{			
			if (_player == Player.CHANCE) _player = firstPlayer;
			else if (_player.nextPlayer == null) _player = firstPlayer; //should go around in a circle
			else _player = _player.nextPlayer; 
		}
		
		/**
		 * Convert the player to CHANCE, dissolving the Iset first, 
		 * and then applying probability to each of the children
		 */
		public function makeChance():void
		{			
			_player = Player.CHANCE;
			dissolve();
			
			// new isets are fine, but we need to adjust probs for original iset
			var n:int = _firstNode.numChildren;
			for (var child:Node = _firstNode.firstChild; child != null; child = child.sibling)
			{
				child.reachedby.prob = new Rational(1, n);				
			}			
		}
		
		
		
		//Linked-List-Node functionality				
		private var _nextIset:Iset;
		private var _prevIset:Iset;
		private var _idx:int = 0;
		
		public function get nextIset():Iset { return _nextIset; }
		public function get prevIset():Iset { return _prevIset; }		
		public function get idx():int { return _idx; }
		public function set idx(value:int):void { _idx = value; }
		
		/** Creates a new iset and appends it at the end of the linked list */
		public function newIset(player:Player):Iset
		{
			var newIset:Iset = new Iset(player);
			var newIdx:int = _idx;
			var last:Iset = this;
			while (true)
			{
				++newIdx;
				if (last._nextIset == null) {
					break;
				}
				last = last._nextIset;
			}
			newIset._idx = newIdx;
			newIset._prevIset = last;
			last._nextIset = newIset;			
			return newIset;
		}
		
		/**
		 * Inserts an Iset after this one in the linked list of Isets,
		 * updating the idx's accordingly if modifyIdx is true
		 */
		public function insertAfter(toAdd:Iset, modifyIdx:Boolean):void
		{
			toAdd._nextIset = _nextIset;
			_nextIset = toAdd;
			
			if (toAdd._nextIset != null) {
				toAdd._nextIset._prevIset = toAdd;
			}
			
			toAdd._prevIset = this;
			
			if(modifyIdx)
			{
				toAdd._idx = _idx + 1;
				for (var h:Iset = toAdd._nextIset; h != null; h = h._nextIset) {					
					++h._idx;
				}
			}
		}
		
		
		//Removes this Iset from the LinkedList
		internal function remove():void
		{
			if (_prevIset != null) { 
				_prevIset._nextIset = _nextIset;
			}
			if (_nextIset != null) {
				_nextIset._prevIset = _prevIset;
								
				for (var h:Iset = _nextIset; h != null; h = h._nextIset) {					
					--h._idx;
				}
			}
		}
		
		//Replaces this Iset for other one, in the linked list only
		private function replace(other:Iset):void
		{
			_idx = other._idx;
			_nextIset = other._nextIset;
			_prevIset = other._prevIset;
			if (_nextIset != null) _nextIset._prevIset = this;
			if (_prevIset != null) _prevIset._nextIset = this;
		}
		
		public function toString():String
		{
			var buf:Vector.<String> = new Vector.<String>();
			for (var n:Node = _firstNode; n != null; n = n.nextInIset) {
				buf.push(n.number.toString());
			}
			return buf.join(" ");
		}
	}
}