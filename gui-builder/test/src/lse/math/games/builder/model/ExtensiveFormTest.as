package lse.math.games.builder.model 
{	
	import org.flexunit.Assert;

	/**	 
	 * @author alfongj
	 */
	public class ExtensiveFormTest
	{				
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
						
			
			var iset1:Iset = new Iset(player);
			iset1.insertNode(child1);
			iset1.insertNode(child2);
			iset1.idx=1;
			
			tree.addIset(iset1);
			
			//Checks if iset1 has been added correctly
			Assert.assertEquals(tree.numIsets, 2);
			Assert.assertEquals(tree.getIsetById(1).firstNode, child1);

		}

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
						
			Assert.assertEquals(tree.numberLeaves(), 2);

			
			var child11:Node = child1.newChild();
			var child111:Node = child11.newChild();
			
			Assert.assertEquals(tree.numberLeaves(), 2);
		}		
	}
}