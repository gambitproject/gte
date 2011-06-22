package lse.math.games.builder.model 
{
	/**
	 * @author Mark
	 */
	public class Node
	{
		private var _number:int;		
		
		private var _father:Node;
		private var _brother:Node;
		private var _firstchild:Node;
		private var _lastchild:Node;		

		private var _nextInIset:Node = null;
		private var _prevInIset:Node = null;
		
		private var _tree:ExtensiveForm;				
		private var _iset:Iset;
		private var _reachedby:Move;
		private var _outcome:Outcome;		     	
		
		
		public function Node(extensiveForm:ExtensiveForm, number:int) 
		{
			_tree = extensiveForm;
			_number = number;
		}
		
		public function get reachedby():Move { return _reachedby; }
		public function set reachedby(value:Move):void { _reachedby = value; }
		
		public function get outcome():Outcome { return _outcome; }
		public function get iset():Iset { return _iset; }
		
		public function get nextInIset():Node { return _nextInIset; }
		public function get prevInIset():Node { return _prevInIset; }

		public function get number():int { return _number; }          	// for specification of tree
		
		public function get firstChild():Node { return _firstchild; }
		public function get lastChild():Node { return _lastchild; }
		public function get parent():Node { return _father; }
		public function get sibling():Node { return _brother; }		
		
		public function get depth():int {
			if (_father == null) return 0;
			else return _father.depth + 1;
		}
		
		public function get numChildren():int { 
			var count:int = 0;
			var y:Node = _firstchild;
			while(y != null) {
				++count;
				y = y.sibling;
			}
			return count; 
		}	
		
		public function get numAncestors():int {
			var count:int = 0;
			var y:Node = _father;
			while(y != null) {
				++count;
				y = y._father;
			}
			return count; 
		}
		
		public function get isLeaf():Boolean {
			return _firstchild == null;
		}
		
		public function get firstLeaf():Node {
			if (isLeaf) {
				return this;
			} else {
				return _firstchild.firstLeaf;
			}
		}
		
		public function get lastLeaf():Node {
			if (isLeaf) {
				return this;
			} else {
				return _lastchild.lastLeaf;
			}
		}

		// TODO: maintain a linked list of leaves for quicker iteration?
		public function get nextLeaf():Node {
			if (sibling != null) {
				return sibling.firstLeaf;
			} else {
				if (this.parent == null) {
					return null;
				} else {
					return parent.nextLeaf;
				}
			}
		}
		
		public function get right():Node
		{
			return getNextNodeToRightAt(-1);
		}
		
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
		
		public function getFirstNodeInSubtreeAt(depth:int):Node
		{
			if (depth >= 0 && this.depth > depth) {
				//trace ("not found for depth " + depth + " at node " + number + " with depth " + this.depth);
				return null;
			}
			else if (this.depth == depth || depth < 0) {	
				//trace ("found for depth " + depth + " at node " + number);
				return this;
			}
					
			var left:Node = null;
			for (var child:Node = _firstchild; child != null && left == null; child = child.sibling) {
				left = child.getFirstNodeInSubtreeAt(depth);
			}	
			return left;
		}	
		
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
		
		public function makeTerminal():Outcome
		{
			if (_iset != null) {
				removeFromIset();
				_iset.remove();
				_iset = null;
			}
			if (_outcome == null) {
				_outcome = new Outcome(this);
			}
			return _outcome;
		}
		
		public function makeNonTerminal():Iset
		{
			if (outcome != null) {
				_outcome = null;
			}
			if (_iset == null) {
				if (_father != null) {
					_iset = new Iset(
						(_father.iset.player != Player.CHANCE && _father.iset.player.nextPlayer != null) ? _father.iset.player.nextPlayer : _tree.firstPlayer, 
						_tree);
					_father.iset.insertAfter(_iset);
				} else {			
					_iset = new Iset(_tree.firstPlayer, _tree);
					//trace("Node.makeNonTerminal():  new root iset");
				}
				_iset.insertNode(this);
			}
			return _iset;
		}		
		
		public function deleteChild(toDelete:Node):void
		{
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
		
		public function newChild():Node  // the new child becomes the lastchild of (this) node
		{
			var y:Node = _tree.createNode();
			addChild(y);
			return y;
		}

		public function addChild(child:Node):void  // the new child becomes the lastchild of (this) node
		{
			child._father = this;
			if (_firstchild == null) {
				_firstchild = child;
				_lastchild = child;
			} else {
				_lastchild._brother = child;
				_lastchild = child;  
			}
		}

		public function isRightOf(b:Node):Boolean
		{
			// strict inequality since same node is NOT right of itself
			return compare(this, b) > 0;
		}
		
		/** Compares positions of two nodes in the tree. A node descendant of another is considered to its right
		 * returns <0 if a is to the left of b
		 * returns >0 if a is to the right of b
		 * returns 0 if a and b are the same node
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
			if (parent != b.parent) throw new Error("Problem in Node.compare() method... parents are not the same");			
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
		 * Makes the current node the last of is ISet 
		 * @return new Iset with the nodes from the current node's Iset that came after it before making it the last
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
		
		internal function removeChildren():void
		{
			if (_father == null) { // really simple for root node
				_firstchild = null;
				_lastchild = null;
			}
			
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
		
		internal function setIset(iset:Iset):void
		{
			_iset = iset;
		}
		
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
		
		// Returns the previous iset
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
		
		internal function clearSetLinks():void
		{
			this._prevInIset = null;
			this._nextInIset = null;
		}
	}
}