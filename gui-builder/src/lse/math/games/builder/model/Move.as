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
				var ratValue:Rational = Rational.parse(value);
				if (!ratValue.isNaN) {					
					assignProb(Rational.parse(value));
				}
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
				//var str:String = (Math.round(_prob * 100) / 100).toString();
				//if (str.length > 3) str = str.substr(1, 3);
				//else str = str.substr(1);
				return _prob.toString();				
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
			for (var n:Node = _iset.firstNode.firstChild; n != null; n = n.sibling) {
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
		
		private var _prob:Rational = Rational.ONE;
		
		public function get prob():Rational {
			return _prob;
		}
		
		public function set prob(value:Rational):void {
			assignProb(value);
		}		
		
		private function assignProb(desiredProb:Rational):void {
			//trace("desired prob is " + desiredProb + " for move " + defaultLabel);
			if (desiredProb.isGreaterThan(Rational.ONE)) {
				desiredProb = Rational.ONE;
				//trace("prob greater than 1 set to " + desiredProb);
			} else if (desiredProb.isLessThan(Rational.ZERO)) {
				desiredProb = Rational.ZERO;
				//trace("prob less than 0 set to " + desiredProb);
			}
			
			_prob = desiredProb;			
			if (iset != null) {
				var pie:Rational = Rational.ONE.subtract(_prob);
				//trace("pie starts at " + pie);
				for (var n:Node = iset.firstNode.firstChild; n != null; n = n.sibling) {
					var move:Move = n.reachedby;
					if (move != null && move != this && move.iset == _iset) // last condition is to cover a temp state reached during dissolve
					{
						var toAssign:Rational = move._prob;
						//trace("prob to assign is " + toAssign + " to move " + move.defaultLabel);
						if (pie.isLessThan(toAssign)) {
							//trace("adjusting prob from " + toAssign + " to " + pie);
							toAssign = pie;
						} else if ((n.sibling == null || (n.sibling.reachedby == this && n.sibling.sibling == null)) 
							&& pie.isGreaterThan(toAssign)) 
						{
							//trace("adjusting prob from " + toAssign + " to " + pie);
							toAssign = pie;
						}
						move._prob = toAssign;
						pie = pie.subtract(toAssign);
						//trace("pie is now " + pie);
					}
				}
				if (pie.isGreaterThan(Rational.ZERO)) {
					_prob = _prob.add(pie);
				}
			}
		}
	}
}