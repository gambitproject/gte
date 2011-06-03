package lse.math.games.builder.model 
{
	import org.flexunit.Assert;
	
	/**
	 * @author alfongj
	 */
	public class OutcomeTest
	{
		[Test]
		public function testAddPays()
		{
			var tree:ExtensiveForm = new ExtensiveForm();
			var root:Node = new Node(tree, 0);
			var player:Player = new Player("1", tree);
			var player2:Player = new Player("2", tree);
			
			var outcome:Outcome = new Outcome(root);
			
			outcome.setPay(player, Rational.parse("5"));
			outcome.setPay(player2, Rational.parse("-1"));
			
			Assert.assertEquals(5, outcome.pay(player).num);
			Assert.assertEquals(1, outcome.pay(player).den);

			Assert.assertEquals(-1, outcome.pay(player2).num);
			Assert.assertEquals(1, outcome.pay(player2).den);

		}
	}
}