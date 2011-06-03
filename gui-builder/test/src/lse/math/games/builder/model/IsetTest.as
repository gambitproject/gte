package lse.math.games.builder.model 
{
	import org.flexunit.Assert;
	
	/**
	 * ...
	 * @author Mark
	 */
	public class IsetTest
	{
		[Test]
		public function testSimpleMerge():void
		{			
			
			var tree:ExtensiveForm = new ExtensiveForm();
			var root:Node = new Node(tree, 0);
			var player:Player = new Player("test player", tree);		
			
			var child11:Node = root.newChild();
			var child21:Node = root.newChild();
			
			var child12:Node = root.newChild();			
			var child22:Node = root.newChild();			
			
			var iset1:Iset = new Iset(player, tree);
			iset1.insertNode(child11);
			iset1.insertNode(child12);
			
			var iset2:Iset = new Iset(player, tree);
			iset2.insertNode(child21);
			iset2.insertNode(child22);
			
			Assert.assertEquals(2, iset1.numNodes);
			Assert.assertEquals(2, iset2.numNodes);
						
			iset1.merge(iset2);
			
			Assert.assertEquals(4, iset1.numNodes);
		}		
	}

}