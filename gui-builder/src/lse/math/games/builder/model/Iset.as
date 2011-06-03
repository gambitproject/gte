package lse.math.games.builder.model
{
	/**	 
	 * @author Mark Egesdal
	 * Class representing an information set
	 */
	public class Iset
	{		
		private var _firstNode:Node;
		private var _lastNode:Node;				
		private var _player:Player;
		private var _tree:ExtensiveForm;

		public function Iset(player:Player, tree:ExtensiveForm) 
		{
			if (player == null) throw new Error("Cannot instanciate an Iset for a null player");
			_player = player;
			_tree = tree;
		}
		
		public function get player():Player { return _player; }		
		public function get firstNode():Node { return _firstNode; }
		public function get lastNode():Node { return _lastNode; }
		
		public function get isChildless():Boolean {			
			return _firstNode.isLeaf; // if the first one is a leaf... they all have to be leaves			
		}
		
		public function get numNodes():int {
			return indexOf(_lastNode) + 1;
		}
				
		public function get numMoves():int {
			return _firstNode.numChildren;
		}
				
		public function nodeAt(idx:int):Node
		{
			var node:Node = null;
			if (idx < numNodes / 2) {
				//trace("searching forward in iset " + _idx + " for node at idx " + idx);
				node = _firstNode;
				for (var i:int = 0; i < idx && node != null; ++i) {
					node = node.nextInIset;
				}
			} else {
				//trace("searching backward in iset " + _idx + " for node at idx " + idx);
				node = _lastNode;
				for (var j:int = numNodes - 1; j > idx && node != null; --j) {
					node = node.prevInIset;
				}
			}
			return node;
		}
		
		// a measure of the breadth of an iset
		// Returns numNodes-1
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
					throw new Error("Iset.span(): node was null before reached the last node " + _lastNode.number + " in iset " + _idx + ":" + debugTrace.join(" "));
				}
				++span;
			}
			return span;
		}
		
		
		// this absorbs nodes in other
		public function merge(other:Iset):void
		{
			//make the moves of other the same as those of this
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
		
		//false if all Nodes do not define same sequence of own moves
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
				
		public function insertNode(toAdd:Node):Boolean
		{
			return insertNodeRightOf(_firstNode, toAdd);
		}
		
		private function insertNodeRightOf(left:Node, toAdd:Node):Boolean
		{			
			if (left != null && left.isRightOf(toAdd)) {
				throw new Error("left should be a known node to the left of the add (for perf)");
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
		
		public function assignMove(move:Move):void
		{
			move.setIset(this);	
		}
		
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
		
		// TODO: this only makes sense if dest is a childless iset
		// unless we make children for the node that is being added equal to the number of moves in the destination iset
		public function addMoveTo(dest:Iset):Move
		{
			var move:Move = newMove();
			var left:Node = dest.firstNode;
			for (var n:Node = _firstNode; n != null; n = n.nextInIset)
			{
				var child:Node = n.newChild();
				child.reachedby = move;
				// TODO: add children for move
				dest.insertNodeRightOf(left, child);
				left = child;
			}
			return move;
		}
		
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
		
		public function dissolve():void
		{			
			var h:Iset = this;		  
			while (h != null) {
				h = h._firstNode.makeLastInIset();						
			}
		} 
		
		public function indexOf(node:Node):int
		{
			var idx:int = 0;			
			for (var n:Node = _firstNode; n != null; n = n.nextInIset) {
				if (n == node) { 
					return idx; 
				}
				++idx;		
			}
			throw new Error("node not found in iset");			
		}
		
		public function canMergeWith(h:Iset):Boolean
		{
			if (this == h)
			{
				//trace("Same Iset");
				return false;				
			}
			if (this.player != h.player)
			{
				//trace("Different players");
				return false;
			}			
			if (numMoves != h.numMoves)
			{
				//trace("Different number of choices");
				return false;
			}
			return true;
		}
				
		internal function createNewMoves():void
		{
			var numChildren:int = _firstNode.numChildren;
			var newMoves:Vector.<Move> = new Vector.<Move>(numChildren);
			for (var mate:Node = _firstNode; mate != null; mate = mate.nextInIset) {
				for (var child:Node = mate.firstChild, i:int = 0; child != null; child = child.sibling, ++i)
				{
					var m:Move = newMoves[i];
					if (m == null) {
						trace("creating new moves for new iset " + _idx);
						m = createMove(numChildren);						
						newMoves[i] = m;
					}
					child.reachedby = m;
				}
			}
		}
		
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
		
		private function createMove(numSiblings:int):Move 
		{
			var m:Move = new Move();
			if (_player == Player.CHANCE) {
				m.prob = new Rational(1, numSiblings);
			}
			m.setIset(this);
			return m;
		}

		public function changeplayer():void
		{			
			if (_player == Player.CHANCE) _player = _tree.firstPlayer;
			else if (_player.nextPlayer == null) _player = _tree.firstPlayer; //should go around in a circle
			else _player = _player.nextPlayer; 
		}
		
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
		
		public function toString():String
		{
			var buf:Vector.<String> = new Vector.<String>();
			for (var n:Node = _firstNode; n != null; n = n.nextInIset) {
				buf.push(n.number.toString());
			}
			return buf.join(" ");
		}
		
		public function sort():void
		{
			var nodes:Vector.<Node> = new Vector.<Node>();
			//trace ("Iset.sort");
			for (var unsorted:Node = _firstNode; unsorted != null; unsorted = unsorted.nextInIset) {
				//trace("old " + unsorted.number);
				nodes.push(unsorted);
			}
			/*for (var unsortedRev:Node = _lastNode; unsortedRev != null; unsortedRev = unsortedRev.prevInIset) {
				trace("rev old " + unsortedRev.number);				
			}*/
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
				//trace("new " + sorted.number);
			}
			
			/*for (var after:Node = _firstNode; after != null; after = after.nextInIset) {
				trace("after " + after.number);				
			}
			for (var sortedRev:Node = _lastNode; sortedRev != null; sortedRev = sortedRev.prevInIset) {
				trace("rev new " + sortedRev.number);				
			}*/
		}

		internal function setFirstNode(first:Node):void {
			_firstNode = first;
		}
		
		internal function setLastNode(last:Node):void {
			_lastNode = last;
		}
		
		
		//Linked List Functionality				
		private var _nextIset:Iset;
		private var _prevIset:Iset;
		private var _idx:int = 0;
		
		public function get nextIset():Iset { return _nextIset; }
		public function get prevIset():Iset { return _prevIset; }		
		public function get idx():int { return _idx; }
		
		//adds new Iset by appending to end of linked list
		public function newIset(player:Player):Iset
		{
			var newIset:Iset = new Iset(player, _tree);
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
		
		public function insertAfter(toAdd:Iset):void
		{
			toAdd._nextIset = _nextIset;
			_nextIset = toAdd;
			
			if (toAdd._nextIset != null) {
				toAdd._nextIset._prevIset = toAdd;
			}
			
			toAdd._prevIset = this;
			
			toAdd._idx = _idx + 1;
			for (var h:Iset = toAdd._nextIset; h != null; h = h._nextIset) {					
				++h._idx;
			}
		}
		
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
			//trace("removing iset " +_idx);
		}
		
		private function replace(other:Iset):void
		{
			_idx = other._idx;
			_nextIset = other._nextIset;
			_prevIset = other._prevIset;
			if (_nextIset != null) _nextIset._prevIset = this;
			if (_prevIset != null) _prevIset._nextIset = this;
		}
	}
}