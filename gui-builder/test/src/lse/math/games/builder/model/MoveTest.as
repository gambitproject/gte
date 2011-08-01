package lse.math.games.builder.model 
{		
	import org.flexunit.Assert;
	
	/**
	 * @author Mark
	 */
	public class MoveTest
	{
		[Test]
		public function testProbPropertyAssignment():void
		{
			var tree:ExtensiveForm = new ExtensiveForm();
			var node:Node = new Node(tree, 0);			
			var iset:Iset = new Iset(Player.CHANCE);
			iset.insertNode(node);
			
			var a:Move = iset.addMove(Player.CHANCE);
			var b:Move = iset.addMove(Player.CHANCE);
			
			Assert.assertEquals(1, a.prob.num);
			Assert.assertEquals(2, a.prob.den);			
			Assert.assertEquals(1, b.prob.num);
			Assert.assertEquals(2, b.prob.den);
			
			a.prob = new Rational(2, 6);
			
			Assert.assertEquals(1, a.prob.num);
			Assert.assertEquals(3, a.prob.den);
			Assert.assertEquals(2, b.prob.num);
			Assert.assertEquals(3, b.prob.den);
		}
		
		[Test]
		public function testProbLabelAssignment():void
		{
			var tree:ExtensiveForm = new ExtensiveForm();
			var node:Node = new Node(tree, 0);			
			var iset:Iset = new Iset(Player.CHANCE);
			iset.insertNode(node);
			
			var a:Move = iset.addMove(Player.CHANCE);
			var b:Move = iset.addMove(Player.CHANCE);
			
			Assert.assertEquals("1/2", a.label);
			Assert.assertEquals("1/2", b.label);
			
			a.label = "2/6";
			
			Assert.assertEquals("1/3", a.label);
			Assert.assertEquals("2/3", b.label);
		}
	}	
}