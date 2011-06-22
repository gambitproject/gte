package lse.math.games.builder.model 
{	
	/**	 
	 * @author Mark Egesdal
	 * Represents a full game-tree in its extensive form
	 */
	public class ExtensiveForm
	{										
		private var _root:Node;
		private var _firstPlayer:Player = null;
		
		private var lastNodeNumber:int = 0;
		
		public function ExtensiveForm() { }
		
		public function get root():Node { return _root; }
		public function set root(value:Node):void { _root = value; }
		
		public function get numNodes():int {
			return root.numNodesInSubtree();
		}
		
		public function get numIsets():int {
			var count:int = 0;
			for (var h:Iset = root.iset; h != null; h = h.nextIset) {
				++count;
			}
			return count;
		}
		
		internal function setFirstPlayer(player:Player):void
		{
			_firstPlayer = player;
		}
		
		public function get firstPlayer():Player {
			return _firstPlayer;
		}
		
		public function newPlayer(name:String):Player {
			return new Player(name, this);
		}
		
		/** Creates a new node assigning it an autoincreasing ID*/
		public function createNode():Node {						
			return newNode(getNextNodeNumber());
		}
		
		private function getNextNodeNumber():int {			
			return lastNodeNumber++;
		}
		
		protected function newNode(number:int):Node {
			return new Node(this, number);
		}
		
		/** Returns a node with the corresponding id number, or null if it can't find any */
		public function getNodeById(number:int):Node
		{
			return recGetNodeById(root, number);
		}
		
		private function recGetNodeById(node:Node, number:int):Node
		{
			if (node.number == number) {
				return node;
			} 
			
			var child:Node = node.firstChild;
			while (child != null) {
				var rv:Node = recGetNodeById(child, number);
				if (rv != null) {
					return rv;
				}
				child = child.sibling;
			}
			return null;
		}
		
		/**
		 * Adds an Iset at the end of the linked list of isets.
		 * If the Iset was already in the list, it does nothing
		 * @return: The added isets' idx after insertion
		 */
		public function addIset(toAdd:Iset):int
		{
			if (root == null) throw new Error("Cannot add isets until root is set");
			
			var h:Iset = root.iset;		
			var idx:int = -1; //index if the iset already exists
			while (true) {
				if (h == toAdd) {
					idx = h.idx;
					break;
				} else if (h.nextIset == null) {
					break;
				}
				h = h.nextIset;
			}
			if (idx == -1) {
				h.insertAfter(toAdd);
			}
			return toAdd.idx;
		}

		public function getIsetById(iset:int):Iset
		{
			var h:Iset = root.iset;
			while (h != null) {
				if (h.idx == iset) {
					return h;
				}
				h = h.nextIset;
			}
			return null;
		}		

		/**
		 * It rearranges the tree to make sure that every node follows
		 * the principles of perfect recall: that every node in its Iset
		 * comes from the same own move sequence
		 */
		public function makePerfectRecall():void
		{
			for (var h:Iset = _root.iset; h != null; h = h.nextIset) {
				if (!h.hasPerfectRecall())
				{
					var nodesInIset:Vector.<Node> = new Vector.<Node>();					
					for (var node:Node = h.firstNode; node != null; node = node.nextInIset) {
						nodesInIset.push(node);						
					}		
					//The Iset is disolved
					h.dissolve();
					//New Isets are formed in groups with same own move sequence
					mergeNodesWithSameOwnMoveSequence(nodesInIset); 
				}				
			}			
		}
		
		//Creates isets for each group of nodes in the vector with the same own move sequence
		private function mergeNodesWithSameOwnMoveSequence(nodesToMerge:Vector.<Node>):void
		{
			while (nodesToMerge.length > 1)
			{
				var base:Node = nodesToMerge.shift();
				var numToCheck:int = nodesToMerge.length;
				for (var i:int = 0; i < numToCheck; ++i) {
					var toMerge:Node = nodesToMerge.shift(); 
					if (base.hasSameOwnMoveSequenceAs(toMerge)) {						
						base.iset.merge(toMerge.iset);
					} else {						
						nodesToMerge.push(toMerge); // add it back to the end
					}
				}
			}			
		}
		
		public function clearTree():void
		{
			_root = null;
			_firstPlayer = null;
			lastNodeNumber = 0;
		}

		/** @return The maximum depth (distance from root to leaf) of the tree */
		public function maxDepth():int
		{
			return recMaxDepth(root);
		}
		
		//returns the maximum depth out of the children of a certain node, recursively
		private function recMaxDepth(node:Node):int
		{
			if (node.isLeaf) {
				return node.depth;
			}
			else
			{
				var max:int = 0;				
				for (var child:Node = node.firstChild; child != null; child = child.sibling)
				{
					var submax:int = recMaxDepth(child);
					if (submax > max) {
						max = submax;
					}					
				}
				return max;
			}
		}
		
		/** @return the number of leaves (nodes without children) of the tree */
		public function numberLeaves():int
		{
			return recNumberLeaves(_root, 0);
		}
	
		/** //?
		 * number the leaves of the subtree starting at this node
		 * where drawcurrnum is the first number to be used,
		 * and the return value is the next number that can be used
		 * non-leaf nodes of the subtree won't have their number affected
		 */
		protected function recNumberLeaves(node:Node, count:int):int
		{			
			if (node.isLeaf) {
				return count + 1;
			}
			else
			{
				var leafcurrnum:int = count;
				var y:Node = node.firstChild;
				while (y != null)
				{
					leafcurrnum = recNumberLeaves(y, leafcurrnum);
					y = y.sibling;
				}
				return leafcurrnum;
			}
		}
			
		//used for debugging
		public function printTree():void
		{
			recPrintTree(root);
		}
		
		private function recPrintTree(x:Node):void  // preorder: node, then children
		{
			var indent:String = "";
			for (var i:int = 0; i < x.depth; ++i) {
				indent += "    ";
			}
						
			var y:Node = x.firstChild;
			trace(indent + x.toString() + ((y == null) ? " (leaf)" : ""));
			
			while (y != null)
			{
				recPrintTree(y);
				y = y.sibling;
			}			
		}
		
		public function toString():String
		{
			var numIsets:int = 0;
			var numNodes:int = root.numNodesInSubtree();
			var numLevels:int = maxDepth();
			
			for (var h:Iset = root.iset; h != null; h = h.nextIset)
			{
				++numIsets;
			}
			
			return "numIsets: " + numIsets + ", numNodes: " + numNodes + ", numLevels: " + numLevels;
		}
	}
}