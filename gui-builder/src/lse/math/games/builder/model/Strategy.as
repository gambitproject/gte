package lse.math.games.builder.model 
{		
	/**
	 * @author Mark
	 */
	public class Strategy
	{		
		private var _sequence:Vector.<Move> = null;
		private var _player:Player = null;
		private var _isReduced:Boolean = false; // TODO: should this be a vector of the missing isets, so it knows how to expand itself?
		private var _isSorted:Boolean = false;
		
		public function Strategy(player:Player, sequence:Vector.<Move>)
		{
			_player = player;
			_sequence = sequence;  //TODO: deep copy?
		}
		
		// TODO: sort by lowest depth (toward the root) first
		private static function compareMoves(a:Move, b:Move):int {
			var nodeA:Node = a.iset.firstNode;
			var nodeB:Node = b.iset.firstNode;			
			var cmp:int = Node.compare(nodeA, nodeB);
			if (cmp == 0) {
				cmp = a.idx - b.idx;
			} 
			return cmp;
		}
		
		public static function compare(a:Strategy, b:Strategy):int
		{
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
		
		public function get sequence():Vector.<Move> {			
			// TODO: should this be a copy?
			if (!_isSorted) {
				_sequence.sort(compareMoves); // TODO: this sort is really expensive... we can get rid of it if there are no multi-row isets in the sequence
				_isSorted = true;
			}
			return _sequence;
		}
		
		public function get isReduced():Boolean {			
			return _isReduced;
		}
		
		public function set isReduced(value:Boolean):void {			
			_isReduced = value;
		}
		
		public function toString():String
		{
			return seqStr(true);
		}
		
		public function seqStr(addStar:Boolean = false, delim:String = " "):String
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
		}
		
		// TODO: key could be based on reduced form strategies of players
		public static function key(strats:Array):String
		{
			var buf:Vector.<String> = new Vector.<String>();
			for each (var o:* in strats) {
				var strat:Strategy = o as Strategy;
				if (strat != null) {
					buf.push(strat._player.name);
					buf.push(strat.seqStr());
				}
			}
			return buf.join("_");
		}
	}
}