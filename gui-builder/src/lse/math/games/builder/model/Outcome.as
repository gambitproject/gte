package lse.math.games.builder.model 
{
	import flash.utils.Dictionary;
	
	/**
	 * @author Mark
	 */
	public class Outcome
	{
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
	}
}