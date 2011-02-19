package lse.math.games.builder.model 
{
	import org.flexunit.Assert;
	
	/**	 
	 * @author Mark Egesdal
	 */
	public class NodeTest
	{
		[Test]
		public function testSimpleNodeRemoval():void
		{			
			var tree:ExtensiveForm = new ExtensiveForm();			
			var player:Player = new Player("test player", tree);
			
			var parent:Node = new Node(tree, 0);
			var parentIset:Iset = new Iset(player, tree);
			parentIset.insertNode(parent);
			
			var iset:Iset = new Iset(player, tree);
			var child1:Node = parent.newChild();
			var child2:Node = parent.newChild();
			iset.insertNode(child1);
			iset.insertNode(child2);
			
			child1.remove();
			
			Assert.assertEquals(1, parent.numChildren);
			Assert.assertEquals(parent.firstChild, child2);
		}	
	}
}