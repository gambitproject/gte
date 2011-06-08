package lse.math.games.builder.model 
{	
	import org.flexunit.Assert;

	/**	 
	 * @author alfongj
	 */
	public class ExtensiveFormTest
	{			
		//TODO: Remove all commented code from Extensvie Form (by now it's there until the testing is finished
		
		//private var _root:Node;
		//private var _firstPlayer:Player = null;
		//
		//private var lastNodeNumber:int = 0;
		//
		//public function ExtensiveForm() { }
		//
		//public function get root():Node { return _root; }
		//public function set root(value:Node):void { _root = value; }
		//
		//public function get numNodes():int {
			//return root.numNodesInSubtree();
		//}
		//
		//public function get numIsets():int {
			//var count:int = 0;
			//for (var h:Iset = root.iset; h != null; h = h.nextIset) {
				//++count;
			//}
			//return count;
		//}
		//
		//internal function setFirstPlayer(player:Player):void
		//{
			//_firstPlayer = player;
		//}
		//
		//public function get firstPlayer():Player {
			//return _firstPlayer;
		//}
		//
		//public function newPlayer(name:String):Player {
			//return new Player(name, this);
		//}
		//
		//private function getNextNodeNumber():int {			
			//return lastNodeNumber++;
		//}
		//
		//public function createNode():Node {						
			//return newNode(getNextNodeNumber());
		//}
		//
		//protected function newNode(number:int):Node {
			//return new Node(this, number);
		//}
			
		
		[Test]
		public function testAddIset():void 
		{
			var tree:ExtensiveForm = new ExtensiveForm();
			var root:Node = tree.createNode();
			tree.root = root;
			var player:Player = new Player("test player", tree);
			root.makeNonTerminal();
			
			//After setting the root correctly (following the previous steps)
			//there should be an initial iset in it (necessary for adding more Isets
			Assert.assertEquals(tree.numIsets, 1);
						
			var child1:Node = root.newChild();
			var child2:Node = root.newChild();
						
			
			var iset1:Iset = new Iset(player, tree);
			iset1.insertNode(child1);
			iset1.insertNode(child2);
			
			tree.addIset(iset1);
			
			//Checks if iset1 has been added correctly
			Assert.assertEquals(tree.numIsets, 2);
			Assert.assertEquals(tree.getIsetById(1).firstNode, child1);

		}
		
		

		
		/*// currently just adds iset to the end of the linked list of isets
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

		*/
		
		[Ignore("Not ready")]
		[Test]
		public function testMakePerfectRecall():void
		{
			//TODO: Fill it after understanding what it should do & what is 'merging' exactly
		}
		
		/*
		public function makePerfectRecall():void
		{
			for (var h:Iset = _root.iset; h != null; h = h.nextIset) {
				if (!h.hasPerfectRecall())
				{
					var nodesInIset:Vector.<Node> = new Vector.<Node>();					
					for (var node:Node = h.firstNode; node != null; node = node.nextInIset) {
						nodesInIset.push(node);						
					}					
					h.dissolve();
					mergeNodesWithSameOwnMoveSequence(nodesInIset); 
				}				
			}			
		}
		
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

		*/

		[Test]
		public function testMaxDepth():void
		{
			var tree:ExtensiveForm = new ExtensiveForm();
			var root:Node = tree.createNode();
			tree.root = root;
			var player:Player = new Player("test player", tree);
			root.makeNonTerminal();
						
			Assert.assertEquals(tree.maxDepth(), 0);
			
			var child1:Node = root.newChild();
			var child2:Node = root.newChild();
			
			Assert.assertEquals(tree.maxDepth(), 1);
			
			var child11:Node = child1.newChild();
			var child111:Node = child11.newChild();
			
			Assert.assertEquals(tree.maxDepth(), 3);			
		}
		
		/*
		
		public function maxDepth():int
		{
			return recMaxDepth(root);
		}
		
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
		
		public function numberLeaves():int
		{
			return recNumberLeaves(_root, 0);
		}*/
	
		[Test]
		public function testNumberLeaves():void
		{		
			var tree:ExtensiveForm = new ExtensiveForm();
			tree.clearTree();
			var root:Node = tree.createNode();
			tree.root = root;
			var player:Player = new Player("test player", tree);
			
			Assert.assertEquals(tree.numberLeaves(), 1);
			
			var child1:Node = root.newChild();
			var child2:Node = root.newChild();
			
			tree.printTree();
			
			Assert.assertEquals(tree.numberLeaves(), 2);

			
			var child11:Node = child1.newChild();
			var child111:Node = child11.newChild();
			
			Assert.assertEquals(tree.numberLeaves(), 2);
		}
		
		/**
		 * number the leaves of the subtree starting at this node
		 * where drawcurrnum is the first number to be used,
		 * and the return value is the next number that can be used
		 * non-leaf nodes of the subtree won't have their number affected
		 */
		/* 
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

		public function getNodeById(number:int):Node
		{
			return recGetNodeById(root, number);
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
		}*/
	}
}