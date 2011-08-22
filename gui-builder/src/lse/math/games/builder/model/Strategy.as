package lse.math.games.builder.model 
{		
	import flash.utils.getTimer;
	
	import util.Log;

	/**
	 * A Strategy is the minimum unit of information in a game-matrix.
	 * <br> It contains information about:
	 * <ul><li>The player it belongs to</li>
	 * <li>The sequence of moves which form the strategy.</li>
	 * <li>Information on if the strategy is reduced and is sorted</li> 
	 * <li>Functions to compare Strategies</li>
	 * <li>Functions to get String representations of the sequence of moves</li>
	 * <li>A function to get a Stirng key corresponding to an array of Strategies</li>
	 * </ul>
	 * 
	 * @author Mark
	 */
	public class Strategy
	{		
		private var log:Log = Log.instance;
		
		// TODO: sort by lowest depth (toward the root) first
		/*
		* Compares positions of two moves in the tree. One move below another one is considered to its right.<br>
		* <ul><li>returns <0 if a is to the left of b</li>
		* <li>returns >0 if a is to the right of b</li>
		* <li>returns 0 if a and b are the same move</li></ul>
		*/
		private static function compareMoves(a:Move, b:Move):int {
			var nodeA:Node = a.iset.firstNode;
			var nodeB:Node = b.iset.firstNode;			
			var cmp:int = Node.compare(nodeA, nodeB);
			if (cmp == 0) {
				cmp = a.idx - b.idx;
			} 
			return cmp;
		}
		
		/**
		 * Compares the sequence of moves of two strategies, move by move.<br>
		 * <ul><li>returns <0 if when a and b start differing, a is to the left of b, or a ends first</li>
		 * <li>returns >0 if when a and b start differing, a is to the right of b, or b ends first</li>
		 * <li>returns 0 if a and b have the same sequence</li></ul>
		 */
		public static function compare(a:Strategy, b:Strategy):int
		{
			if(a.sequence == null || b.sequence == null)
			{
				return 0; // Comparing strategies with no sequence, which aren't comparable
			}
			
			var i:int = 0;
			var cmp:int = 0;
			while (cmp == 0) {
				if (a.sequence.length > i && b.sequence.length > i) {
					var moveA:Move = a.sequence[i];
					var moveB:Move = b.sequence[i];					
					cmp = compareMoves(moveA, moveB);					
				} else if (a.sequence.length > i) {
					cmp = 1;
				} else if (b.sequence.length > i) {
					cmp = -1;
				} else {
					break;
				}
				++i;
			}
			return cmp;
		}
		
		// TODO: key could be based on reduced form strategies of players
		/** 
		 * Returns a String key used to access and save payoffs from player payMatrixMaps.<br/>
		 * The param 'strats' should be an array of Strategies, one for each player, and in the 
		 * same order as players are, which lead to a payoff.
		 */
		public static function key(strats:Array):String
		{
			var buf:Vector.<String> = new Vector.<String>();
			for each (var o:* in strats) {
				var strat:Strategy = o as Strategy;
				if (strat != null) {
					buf.push(strat._player.name);
					buf.push(strat.getNameOrSeq());
				}
			}
			return buf.join("_");
		}
		
		
		
		private var _player:Player = null;
		
		//Var only for Strategies formed directly, and not from tree sequences
		private var _name:String = null;
		
		//Vars for Strategies formed from tree sequences of moves, useless if not
		private var _sequence:Vector.<Move> = null;
		private var _isReduced:Boolean = false; // TODO: should this be a vector of the missing isets, so it knows how to expand itself?
		private var _isSorted:Boolean = false;
		

		
		public function Strategy(player:Player)	{
			_player = player;
		}
		
		/** Player to whom the strategy belongs */
		public function get player():Player { return _player; }
		
		/** Name of the Strategy, just settable in strategies not formed from tree move sequences */
		public function set name(value:String):void {
			if(_sequence ==  null)
				_name = value;
			else
				log.add(Log.ERROR, "A name was tried to be set on a Strategy" +
					"that already had the sequence: "+_sequence);
		}
		
		/** Vector of moves, ordered from top (root) to bottom */
		public function get sequence():Vector.<Move> {			
			// TODO: should this be a copy?
			if (!_isSorted) {
				_sequence.sort(compareMoves); // TODO: this sort is really expensive... we can get rid of it if there are no multi-row isets in the sequence
				_isSorted = true;
			}
			return _sequence;
		}
		
		public function set sequence(value:Vector.<Move>):void { 
			if(_name==null) 
				_sequence = value; 
			else
				log.add(Log.ERROR_HIDDEN, "A sequence was tried to be set on a Strategy" +
					" that already had the name: "+_name);
		}  //TODO: deep copy?

		/** If the strategy is in the 'reduced' form */
		public function get isReduced():Boolean {return _isReduced;	}
		public function set isReduced(value:Boolean):void {	_isReduced = value; }
		

		
		/** Returns a String with the strategy name, or with a string representation of the sequence, if appliable */
		public function getNameOrSeq(addStar:Boolean = false, delim:String = "-"):String
		{
			if(_sequence!=null)
			{
				var buf:Vector.<String> = new Vector.<String>();
				if (!_isSorted) {
					_sequence.sort(compareMoves); // TODO: this sort is really expensive... we can get rid of it if there are no multi-row isets in the sequence
					_isSorted = true;
				}
				for (var i:int = 0, n:int = _sequence.length; i < n; ++i) {			
					buf.push(_sequence[i].label);				
				}
				return buf.join(delim) + (_isReduced && addStar ? "*" : "");
			} else
				return _name;
		}
				
		public function toString():String {	return getNameOrSeq(true); }
	}
}