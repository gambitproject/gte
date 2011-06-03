package lse.math.games.builder.model 
{
	import org.flexunit.Assert;

	import flash.utils.Dictionary;
	
	/**
	 * @author alfongj
	 */
	public class OutcomeTest
	{
		//TODO: Remove all commented code from Extensvie Form (by now it's there until teh testing is finished

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
		/*
		private var _whichnode:Node;
		public function get whichnode():Node { return _whichnode; }
		
		private var _payoffs:Dictionary = new Dictionary(); 		
		
		public function Outcome(whichnode:Node) { _whichnode = whichnode; }
		
		public function setPay(player:Player, payoff:Rational):void
		{			
			_payoffs[player] = payoff;
		}
		
		public function pay(player:Player):Rational
		{			
			return _payoffs[player] as Rational;
		}
		
		public function toString():String
		{
			var sb:Vector.<String> = new Vector.<String>();
			for (var pl:Object in _payoffs) {				
				sb.push(pl + "=" + _payoffs[pl]);
			}
			return sb.join(" ");
		}
		*/
	}
}