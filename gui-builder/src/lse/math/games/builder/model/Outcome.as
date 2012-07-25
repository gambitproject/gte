package lse.math.games.builder.model 
{
	import flash.utils.Dictionary;
	
	import util.Log;
	
	/**
	 * This class represents a set of payoffs, one for player, which should
	 * be at a terminal node in the tree. </p>
	 * 
	 * To add an outcome to a node, you must call node.makeTerminal();
	 * to eliminate it, node.makeNonTerminal().
	 * 
	 * @author Mark
	 */
	public class Outcome
	{
		private var _payoffs:Dictionary = new Dictionary(); 		
		
		private var log:Log = Log.instance;
		
		
		
		public function Outcome() { }
				
		/** Set a player's payoff (as a Rational) */
		public function setPay(player:Player, payoff:Rational):void
		{			
			_payoffs[player] = payoff;
		}
		
		/** Get a player's payoff, or zero if it hadn't been set */
		public function pay(player:Player):Rational
		{
			if(_payoffs[player] == null)
			{
				log.add(Log.ERROR_HIDDEN, "Tried to access a payoff from player "+player.name+" which hadn't been set.");
				_payoffs[player] = Rational.ZERO;
			}
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
		
		public function getOutcomeAsString():String
		{
			var sb:Vector.<String> = new Vector.<String>();
			for (var pl:Object in _payoffs) {				
				sb.push(_payoffs[pl]);
			}
			return sb.join(",");
		}
		
		public function setOutcomeFromString(value:String):void
		{
			var a:Array=value.split(",");
			var i:int=0;
			for (var pl:Object in _payoffs) {
				if (i<a.length) {
					_payoffs[pl]=Rational.parse(a[i]);
				}
				i++;
			}
		}
	}
}