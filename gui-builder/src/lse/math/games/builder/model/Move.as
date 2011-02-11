package lse.math.games.builder.model 
{
	/**	 
	 * @author Mark Egesdal
	 */
	public class Move
	{
		private var _iset:Iset; //where the move emanates from		
		private var _label:String;
	
		public function Move() {}
		
		public function set label(value:String):void {
			if (_iset != null && _iset.player == Player.CHANCE) {
				assignProb(Number(value));
			} else if (value == defaultLabel) {
				_label = null;
			} else {
				_label = value;
			}
		}
		
		public function get iset():Iset {
			return _iset;
		}		
		
		public function get hasLabel():Boolean {
			return _label != null;
		}
		
		public function get label():String {
			if (_iset.player == Player.CHANCE) {
				var str:String = (Math.round(_prob * 100) / 100).toString();
				//if (str.length > 3) str = str.substr(1, 3);
				//else str = str.substr(1);
				return str;				
			} else if (_label != null) {
				return _label;
			} else {
				return defaultLabel;
			}
		}
		
		public function toString():String
		{
			return label;
		}
		
		private function get defaultLabel():String {
			if (_iset != null) {
				return _iset.idx.toString() + ":" + idx.toString();
			} else {
				return "unassigned";
			}
		}
		
		public function get idx():int {
			var count:int = 0;
			for (var n:Node = _iset.firstNode.firstchild; n != null; n = n.sibling) {
				if (n.reachedby == this) {
					break;
				}
				++count;
			}
			return count;
		}
				
		internal function setIset(iset:Iset):void {
			_iset = iset;
			if (_iset.player == Player.CHANCE) {
				assignProb(_prob);
			}
		}
				
		//CHANCE
		public function get isChance():Boolean {
			return _iset.player == Player.CHANCE;
		}
		
		private var _prob:Number = 0; //TODO: should this be a rational class?	
		
		public function get prob():Number {
			return _prob;
		}
		
		public function set prob(value:Number):void {
			assignProb(value);
		}		
		
		private function assignProb(desiredProb:Number):void {			
			if (desiredProb > 1) desiredProb = 1;
			_prob = desiredProb;
			if (iset != null) {
				var pie:Number = 1 - _prob;
				for (var n:Node = iset.firstNode.firstchild; n != null; n = n.sibling) {
					var move:Move = n.reachedby;
					if (move != null && move != this) 
					{
						var toAssign:Number = move._prob;
						if (pie - toAssign < 0) {
							toAssign = pie;
						} else if (n.sibling == null && pie - toAssign > 0) {
							toAssign = pie;
						}
						move._prob = toAssign;
						pie -= toAssign;
					}
				}
			}
		}
	}
}