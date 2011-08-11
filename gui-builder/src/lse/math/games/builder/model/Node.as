package lse.math.games.builder.model 
{
	import util.Log;

	/**
	 * A Node is the minimum unit of information in a tree.
	 * <br> It contains information about:
	 * <ul><li>Its correlative nodes: father, brother (node at its right, pertaining to the same father), and first and last of its children</li>
	 * <li>The Iset to which it belongs, as well as his neighbours in this Iset</li>
	 * <li>The move it is reached by</li>
	 * <li>Its depth</li>
	 * <li>Its outcome (if it is a terminal node)</li>
	 * </ul>
	 * 
	 * @author Mark
	 */
	public class Node
	{
		private var _tree:ExtensiveForm;				
		private var _number:int;		
		
		private var _father:Node;
		private var _brother:Node;
		private var _firstchild:Node;
		private var _lastchild:Node;		

		private var _iset:Iset;
		private var _nextInIset:Node = null;
		private var _prevInIset:Node = null;
		
		private var _reachedby:Move;
		private var _depth:int = 0;
		private var _outcome:Outcome;
		
		private var log:Log = Log.instance;
		
		
		
		public function Node(extensiveForm:ExtensiveForm, number:int) 
		{
			_tree = extensiveForm;
			_number = number;
		}
		
		/** Move which leads to this node */
		public function get reachedby():Move { return _reachedby; }
		public function set reachedby(value:Move):void { _reachedby = value; }
		
		/** Outcome of this node, just valid if this node is a leaf */
		public function get outcome():Outcome { return _outcome; }
		
		/** Information set to which this node blongs */
		public function get iset():Iset { return _iset; }
		internal function setIset(iset:Iset):void { _iset = iset; }
		
		/** Next node in the iset */
		public function get nextInIset():Node { return _nextInIset; }
		/** Previous node in the Iset */
		public function get prevInIset():Node { return _prevInIset; }

		/** Number (or id) of this node inside the tree */
		public function get number():int { return _number; }          	// for specification of tree
		public function set number(value:int):void { _number = value; }
		
		/** First child of this node. Can be null if there isn't any */
		public function get firstChild():Node { return _firstchild; }
		
		/** Last child of this node. Can be null if there isn't any */
		public function get lastChild():Node { return _lastchild; }
		
		/** Node from which this one is child. Can be null if this is the root */
		public function get parent():Node { return _father; }
		public function set parent(value:Node):void { 
			_father = value;
			_depth = value.depth+1;
		}
		
		/** 
		 * First brother at the right of this node (First child after this one, 
		 * from this node's parent). Can be null if this is the only child.
		 */ 
		public function get sibling():Node { return _brother; }		
				
		/** 
		 * Distance, in nodes, from this node to the root. <br>
		 * i.e., <i>root's depth = 0; root children's depth = 1;</i>
		 */
		public function get depth():int { return _depth; }
		
		/** Number of children this node has */
		public function get numChildren():int { 
			var count:int = 0;
			var y:Node = _firstchild;
			while(y != null) {
				++count;
				y = y.sibling;
			}
			return count; 
		}	
		
		/** If this node is childless */
		public function get isLeaf():Boolean {
			return _firstchild == null;
		}
		
		/** 
		 * Returns the first (most to the left) leaf that can be found among 
		 * this node's descendants (including itself)
		 */
		public function get firstLeaf():Node {
			if (isLeaf) {
				return this;
			} else {
				return _firstchild.firstLeaf;
			}
		}
		
		/**
		 * Returns the last (most to the right) leaf that can be found 
		 * among this node's descendants (inculding itself)
		 */
		public function get lastLeaf():Node {
			if (isLeaf) {
				return this;
			} else {
				return _lastchild.lastLeaf;
			}
		}

		// TODO: maintain a linked list of leaves for quicker iteration?
		/** Returns the next leaf (or null if there isn't) of this node, which must be a leaf */
		public function get nextLeaf():Node {
			if(isLeaf)
				return recNextLeaf(this);
			else
			{
				log.add(Log.ERROR_THROW, "nextLeaf() called from node "+_number+" which isn't, and must be, a leaf");
				return null;
			}
		}
		
		//Searches recursively for the next leaf in the tree
		private function recNextLeaf(node:Node):Node {
			if (node.sibling != null) {
				return node.sibling.firstLeaf;
			} else {
				if (node.parent == null) {
					return null;
				} else {
					return recNextLeaf(node.parent);
				}
			}
		}
		
		/** Returns the first node at the right of this one */
		public function get right():Node
		{
			return getNextNodeToRightAt(-1);
		}
		
		/** Returns the first node at the right of this one at a certain depth */
		//TODO: Check this function is complete
		public function getNextNodeToRightAt(depth:int):Node
		{	
			var right:Node = null;
			
			// first check children
			for (var child:Node = _firstchild; child != null && right == null; child = child.sibling) {
				right = child.getFirstNodeInSubtreeAt(depth);
			}
			
			// then check younger siblings of self and ancestors
			if (_father != null) 
			{			
				var elder:Node = this;
				while (elder != null && right == null) {
					//trace("checking younger siblings of node " + elder.number);
					for (var younger:Node = elder.sibling; younger != null && right == null; younger = younger.sibling) {
						//trace("    sibling node " + elder.number);
						right = younger.getFirstNodeInSubtreeAt(depth);
					}		
					elder = elder.parent;
				}
			}
			
			// then go up a parent and look at parent's younger siblings firstchild
			// then go up to grandparent and look at grandparent's younger siblings firstchild's firstchild
			// etc...
			//if (right == null) {
				
			//	right = _father.getNextNodeToRightAt(depth);
			//}			
			
			// if nothing then return null, this means node is rightmost node at this depth
			return right;
		}
		
		/** 
		 * Returns the first node of the descendants of this 
		 * one, which is at a certain depth level.
		 */
		public function getFirstNodeInSubtreeAt(depth:int):Node
		{
			if (depth >= 0 && this.depth > depth) {
				//This node is on a lower level than the one we're lookign for,
				//so can't get a descendant there
				return null;
			}
			else if (this.depth == depth || depth < 0) {
				return this;
			}
					
			var left:Node = null;
			for (var child:Node = _firstchild; child != null && left == null; child = child.sibling) {
				left = child.getFirstNodeInSubtreeAt(depth);
			}	
			return left;
		}	
		
		/** Returns next node in the Iset at a determinate depth */
		public function nextInIsetAt(depth:int):Node
		{			
			var next:Node = _nextInIset;			
			while (next != null) {				
				if (next.depth == depth) {
					break;
				}
				next = next.nextInIset;
			}
			return next;
		}
		
		/** 
		 * Makes the current node terminal: eliminates its iset, if any, and if it doesn't 
		 * have an outcome, it creates a new one for it.
		 * @return This node's new (or not) Outcome
		 */
		public function makeTerminal():Outcome
		{
			if (_iset != null) {
				removeFromIset();
				_iset.remove();
				_iset = null;
			}
			if (_outcome == null) {
				_outcome = new Outcome();
			}
			return _outcome;
		}
		
		/** 
		 * Makes the current node non terminal: eliminates its outcome, if any, and if it doesn't 
		 * belong to an Iset, it creates a new one for him, according to these rules:
		 * <ul><li>If the node is root, if the previous player was CHANCE, or if there is just 
		 * one player defined, the Iset belongs to the first player</li>
		 * <li>Else, the Iset belongs to the last player's next player</li></ul>
		 * @return This node's new (or not) Iset
		 */
		public function makeNonTerminal():Iset
		{
			if (outcome != null) {
				_outcome = null;
			}
			if (_iset == null) {
				if (_father != null) {
					_iset = new Iset(
						(_father.iset.player != Player.CHANCE && _father.iset.player.nextPlayer != null) ? _father.iset.player.nextPlayer : _tree.firstPlayer);
					_father.iset.insertAfter(_iset, true);
				} else {			
					_iset = new Iset(_tree.firstPlayer);
					//trace("Node.makeNonTerminal():  new root iset");
				}
				_iset.insertNode(this);
			}
			return _iset;
		}		
		
		/** Deletes a node from the children, if found among them */
		public function deleteChild(toDelete:Node):void
		{
			if(toDelete == null)
				log.add(Log.ERROR_THROW, "Tried to delete a null child");
			else {
				if (toDelete == _firstchild) {
					_firstchild = toDelete._brother;
					if (toDelete == _lastchild) {
						_lastchild = null; // deleting the last node
					}
				} else {
					for (var z:Node = _firstchild; z._brother != null; z = z._brother) {
						if(z._brother == toDelete) {
							z._brother = toDelete._brother;
							if (_lastchild == toDelete) {
								_lastchild = z;
							}
							break;
						}
					}
				}
			}
		}
		
		/** Creates a new child and adds it at the end of the list of children */
		public function newChild():Node  // the new child becomes the lastchild of (this) node
		{
			var y:Node = _tree.createNode();
			addChild(y);
			return y;
		}

		/** Adds a node as a child at the end of teh list of children */
		public function addChild(child:Node):void  // the new child becomes the lastchild of (this) node
		{
			child.parent = this;
			if (_firstchild == null) {
				_firstchild = child;
				_lastchild = child;
			} else {
				_lastchild._brother = child;
				_lastchild = child;  
			}
		}

		/** Checks if this node is to the right of 'b' */
		public function isRightOf(b:Node):Boolean
		{
			// strict inequality since same node is NOT right of itself
			return compare(this, b) > 0;
		}
		
		/** 
		 * Compares positions of two nodes in the tree. A node descendant of another is considered to its right.<br>
		 * <ul><li>returns <0 if a is to the left of b</li>
		 * <li>returns >0 if a is to the right of b</li>
		 * <li>returns 0 if a and b are the same node</li></ul>
		 */
		public static function compare(a:Node, b:Node):int
		{
			var aList:Vector.<Node> = new Vector.<Node>();
			var bList:Vector.<Node> = new Vector.<Node>();
			
			for (; a != null; a = a.parent) {
				aList.push(a);
			}
			for (; b != null; b = b.parent) {
				bList.push(b);
			}
			
			var aDepth:int = aList.length;
			var bDepth:int = bList.length;
			
			while (aList.length > bList.length) {
				aList.shift();
			}
			while (bList.length > aList.length) {
				bList.shift();
			}
			// now both lists have root at the top of the stack and are at the same depth (length)
			while (true)
			{
				a = aList.shift();
				b = bList.shift();
				if (a.parent == b.parent) {
					break;
				}
			}
			//now they have the same parent (could be null if they are both root)
			var parent:Node = a.parent;
			if (parent != b.parent) Log.instance.add(Log.ERROR_THROW, "Problem in Node.compare() method... parents are not the same");			
			if (parent != null) {
				for (var child:Node = parent.firstChild; child != null; child = child.sibling) {
					if (child == a) {
						if (child == b) {
							break;
						} else {
							return -1;
						}
					} else if (child == b) {
						return 1;
					}					
				}
			}

			// they are direct ancestors... 
			// children considered right of parent, so longer depth returns 1
			return aDepth - bDepth;
		}

		/** 
		 * Checks if the own (from the player this iset belogns to) 
		 * moves that lead to this node are the same as the ones 
		 * that lead to another. Useful for checking perfect recall.
		 */
		public function hasSameOwnMoveSequenceAs(other:Node):Boolean
		{
			var ascendants:Vector.<Move> = getOwnMoveSequence();
			var otherAscendants:Vector.<Move> = other.getOwnMoveSequence();

			if (ascendants.length != otherAscendants.length) {
				return false;
			}
			while (ascendants.length > 0) 
			{
				var baseline:Move = ascendants.pop();
				var toCompare:Move = otherAscendants.pop();
				if (baseline != toCompare) {
					return false;
				}					
			}
			return true;
		}
		
		/**
		 * Makes the current node the last of its Iset. <br> 
		 * @return (Iset) with the nodes from the current node's Iset 
		 * that came after it before making it the last
		 */
		public function makeLastInIset():Iset
		{			
			var h:Iset = null;
			if (_nextInIset != null) {
				h = _iset.newIset(_iset.player);
				h.setLastNode(_iset.lastNode);
				
				var after:Node = _nextInIset;						
				h.setFirstNode(after);
				after._prevInIset = null;
				
				while(after != null) {
					after.setIset(h);
					after = after.nextInIset;
				}
				h.createNewMoves();
				_nextInIset = null;
			}
			if (_iset != null) {
				_iset.setLastNode(this);
			}			
			
			return h;
		}
		
		/** Remove this node from the tree, iset and everything */
		public function remove():void
		{
			//trace("removing node " + _number + (_iset != null ? " in iset " + _iset.idx + " at index " + reachedby.idx : ""));
			//trace("prev in iset is " + (_prevInIset != null ? _prevInIset.number : "null") + " next in iset is " + (_nextInIset != null ? _nextInIset.number : "null"));
			if (isLeaf && _iset != null) {
				//trace("removing leaf node " + _number + " from iset " + _iset.idx);
				//removeFromIset(); // this is already done by depth first children removal, but not for leaves
				var newIset:Iset = removeFromIset();
				//trace("iset with node removed is now " + (newIset != null ? newIset.idx : "null"));
			} else if (!isLeaf) {
				//trace("removing all the children of " + _number);
				removeChildren(); 		//removes all children of x
			}
			if (_iset != null) { 
				//trace("removing iset " + _iset.idx);
				_iset.remove();
			}
			if (parent != null) {
				if (parent._iset.numNodes > 1) { // father can't belong to same iset anymore with less children
					//trace("removing parent node " + parent.number + " for from iset " + parent._iset.idx);
					var newParentIset:Iset = parent.removeFromIset();
					//trace("iset that used to contain " + parent.number + " is now " + (newParentIset != null ? newParentIset.idx : "null"));
				}
				//trace("deleting " + _number + " as the child of " + parent.number);
				parent.deleteChild(this);	
			}
		}
		
		public function toString():String
		{
			return "node " + _number + (iset != null ? " in iset " + _iset.idx  + "(" + _iset.player + ")" /*+ (_iset.numNodes > 1 ? "[" + _setIdx + "]" : "")*/ : "")
			+ " with depth " + depth + (_father != null ? " reached " + ((reachedby.iset.player == Player.CHANCE) ? "with prob " : "by move ") + reachedby + " from node " + _father.number : "")
			+ (_outcome != null ? " has payoffs " + _outcome : "");
		}
		
		//Make this node the first on the iset
		internal function makeFirstInIset():Iset
		{
			//trace("making node " + _number + " first in iset " + _iset.idx);
				
			var h:Iset = null;
			if (_prevInIset != null) {			
				h = _iset.newIset(_iset.player);
				h.setFirstNode(_iset.firstNode);
				
				var before:Node = _prevInIset;						
				h.setLastNode(before);
				before._nextInIset = null;
				
				while(before != null) {
					before.setIset(h);
					before = before.prevInIset;
				}
				h.createNewMoves();
			} else {
				//trace("prev in iset is null");
			}
			_iset.setFirstNode(this);
			_prevInIset = null;
			
			/*if (h != null) {
				trace("returning new iset " + h.idx + " that starts with " + h.firstNode.number);
			}*/
			return h;
		}		
		
		/** Removes from the current node, and deletes, from their isets and including their Moves, all the children */
		internal function removeChildren():void
		{			
			for (var child:Node = _firstchild;  child != null; child = child._brother) {
				child.remove();				
			}
		}
		
		/** Inserts 'toAdd' before this node */
		internal function insertBefore(toAdd:Node):void
		{
			if (toAdd != null) {
				toAdd._prevInIset = _prevInIset;
				toAdd._nextInIset = this;
			}
			if (_prevInIset != null) {
				_prevInIset._nextInIset = toAdd;
			}
			_prevInIset = toAdd;
		}
		
		/** Inserts 'toAdd'  after this node */
		internal function insertAfter(toAdd:Node):void
		{
			if (toAdd != null) {
				toAdd._nextInIset = _nextInIset;				
				toAdd._prevInIset = this;
			}
			if (_nextInIset != null) {
				_nextInIset._prevInIset = toAdd;
			}
			_nextInIset = toAdd;
		}
		
		// Returns the number of descendants of this node, including itself
		internal function numNodesInSubtree():int
		{
			var count:int = 1;
			if (!isLeaf) { 
				for (var child:Node = _firstchild; child != null; child = child.sibling) {
					count += child.numNodesInSubtree();
				}
			}
			return count;
		}
		
		// Removes the node from the Iset and returns the previous iset
		private function removeFromIset():Iset
		{
			//trace("removing node " + _number + " from iset " + _iset.idx); 
			var oldIset:Iset = _iset;
			var tmp:Iset = null;			

			oldIset = makeFirstInIset();			
			tmp = makeLastInIset();
			if (tmp != null) {
				if (oldIset != null) {			
					oldIset.merge(tmp);
					//trace("merging old iset " + oldIset.idx + " with tmp iset " + tmp.idx); 
				} else {
					oldIset = tmp;
					//trace("setting old iset equal to tmp iset" + tmp.idx);
				}
			}
			
			/*if (oldIset != null) {
				trace("returning old iset now with idx " + oldIset.idx);
			}*/
			
			return oldIset;
		}
		
		// Returns the sequence of moves played by the player this node's iset belongs to
		private function getOwnMoveSequence():Vector.<Move>
		{
			var ownMovesIn:Vector.<Move> = new Vector.<Move>();
			if (_iset != null) {
				for (var node:Node = this; node.parent != null; node = node.parent) {
					if (node.parent.iset.player == _iset.player) {
						ownMovesIn.push(node.reachedby);
					}				
				}
			}
			return ownMovesIn;
		}
		
		//Eliminates links to next and previous nodes in Iset
		internal function clearSetLinks():void
		{
			this._prevInIset = null;
			this._nextInIset = null;
		}
	}
}