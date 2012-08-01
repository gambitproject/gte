package lse.math.games.builder.model 
{
	import util.Log;
	import lse.math.games.builder.settings.UserSettings;
	

	/**	 
	 * This class represents a move, which can be: 
	 * <ul><li>A possible player choice, from an Iset, in which 
	 * case its _label represents its name.</li>
	 * <li>A random probable choice, in which case its _label is 
	 * meaningless, and _prob contains the desired probability</li></ul>
	 * </p>
	 * It contains:
	 * <ul><li>Reference to Iset it emanates from, and variables to store its label or prob.</li>
	 * <li>Functions to add and assign labels and probabilities.</li></ul></p>
	 * 
	 * @author Mark Egesdal
	 */
	public class Move
	{
		private var _iset:Iset;		
		private var _label:String=" ";
	
		private var log:Log = Log.instance;
		private var settings:UserSettings = UserSettings.instance;	
		
		
		public function Move() {}
		
		/** Index of the move in the Iset */
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
		
		/** Information set from where the move emanates from */
		public function get iset():Iset { return _iset; }
		
		internal function setIset(iset:Iset):void {
			_iset = iset;
			if (_iset.player == Player.CHANCE) {
				assignProb(_prob);
			}
		}
		
	    /** If the move has a label defined */
		public function get hasLabel():Boolean {
			return _label != null;
		}
		
		public function get hasLabelEmpty():Boolean {
			return _label != " ";
		}
		
		/** Set either the name of the move, or the probability of it, if the player is CHANCE */
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
		
		//Default label for moves: 'Iset_idx:move_idx'
		private function get defaultLabel():String {
			if (_iset != null) {
				return _iset.idx.toString() + ":" + idx.toString();
			} else {
				return "unassigned";
			}
		}
				
		
		
		/* <---------- CHANCE FUNCTIONS ----------> */
		/** If the move is a probability */
		public function get isChance():Boolean {
			return _iset.player == Player.CHANCE;
		}
		
		private var _prob:Rational = Rational.ONE;
		
		/** Probability associated with the move, if it isChance */
		public function get prob():Rational {
			if(_prob==null)
				return Rational.ONE;
			else
				return _prob;
		}
		
		public function set prob(value:Rational):void {
			assignProb(value);
		}		
		
		//Assigns probability accordingly
		private function assignProb(desiredProb:Rational):void {
			if (desiredProb.isNaN){
				_prob = desiredProb;
			} else if (desiredProb.isGreaterThan(Rational.ONE)) {
				desiredProb = Rational.ONE;
				_prob = desiredProb;
				log.add(Log.ERROR_HIDDEN, "prob greater than 1 set to " + desiredProb);
			} else if (desiredProb.isLessThan(Rational.ZERO)) {
				desiredProb = Rational.ZERO;
				_prob = desiredProb;
				log.add(Log.ERROR_HIDDEN, "prob less than 0 set to " + desiredProb);
			} else {
				_prob = desiredProb;
			}

			if (iset != null) {
				var pie:Rational=Rational.ONE.subtract(_prob);
				//trace("pie starts at " + pie);
				for (var n:Node = iset.firstNode.firstChild; n != null; n = n.sibling) {
					var move:Move = n.reachedby;
					if (move != null && move != this && move.iset == _iset) // last condition is to cover a temp state reached during dissolve
					{
						var toAssign:Rational = move.prob;
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
						
						if (desiredProb.isNaN) {
							move._prob = Rational.NaN;
						} else {
							move._prob = toAssign;	
						}
					
						pie = pie.subtract(toAssign);
						//trace("pie is now " + pie);
					}
				}
				if (pie.isGreaterThan(Rational.ZERO)) {
						if (desiredProb.isNaN) {
							_prob = Rational.NaN;
						} else {
							_prob = _prob.add(pie);
						}


				}
			}
		}
		
		
		
		public function toString():String
		{
			return label;
		}
	}
}