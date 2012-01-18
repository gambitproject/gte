package lse.math.games.builder.viewmodel
{
	import util.Log;

	/**
	 * Class that AutoLabels the tree nodes basing in a predefined alphabet, based in the deprecated AutoLabelAction
	 * @author alfongj based on Mark Egesdal's work
	 */
	public class AutoLabeller
	{
		import lse.math.games.builder.model.*;
		

		
		private var _alpha:Vector.<String> = new Vector.<String>();	
		private var count1:int;
		private var count2:int;
		private var _uniqueLabelNum:int;
		private var inUse:Vector.<String> = new Vector.<String>();		
		private var log:Log = Log.instance;
		
		
		
		public function AutoLabeller(alpha:Vector.<String> =  null)
		{
			if(alpha != null) {
				for each(var label:String in alpha)
					_alpha.push(label);
			} else {
				_alpha.push("A");
				_alpha.push("B");
				_alpha.push("C");
				_alpha.push("D");
				_alpha.push("E");
				_alpha.push("F");
				_alpha.push("G");
				_alpha.push("H");
				_alpha.push("I");
				_alpha.push("J");
				_alpha.push("K");
				_alpha.push("L");
				_alpha.push("M");
				_alpha.push("N");
				_alpha.push("O");
				_alpha.push("P");
				_alpha.push("Q");
				_alpha.push("R");
				_alpha.push("S");
				_alpha.push("T");
				_alpha.push("U");
				_alpha.push("V");
				_alpha.push("W");
				_alpha.push("X");
				_alpha.push("Y");
				_alpha.push("Z");
			}
		}
		
		/** Next label from an auto-label sequence */		
		public function getNextAutoLabel(player:Player, game:Game):String
		{
			var label:String = _alpha[count1] + (count2 != _alpha.length ? _alpha[count2] : "");
			if (player != game.firstPlayer) {
				label = label.toLowerCase();
			}
			
			incrementCounts();
			
			return label;
		}
		
		/** Number of unique labels needed */
		public function set uniqueLabelNum(value:int):void
		{
			_uniqueLabelNum = value;
			initCounts();
		}
		
		
		
		//Reset the counters accordingly to the number of unique labels needed
		private function initCounts():void
		{
			count1 = 0;
			if(_uniqueLabelNum < _alpha.length) {
				count2 = _alpha.length;
			} else {
				count2 = 0;
			}	
		}
		
		// Increment the counters
		private function incrementCounts():void
		{
			if (count2 < _alpha.length) {
				++count2;
				if (count2 == _alpha.length) {
					++count1;
					count2 = 0;
					if (count1 == _alpha.length) {
						log.add(Log.ERROR_THROW, "Ran out of auto labels");
					}
				}
			} else {				
				++count1;
				if (count1 == _alpha.length) {
					count2 = 0;
					count1 = 0;
				}
			}
		}
		
		/* <--- --- TREE AUTO LABELLING --- ---> */
		
		/** Auto labels a tree */
		public function autoLabelTree(grid:TreeGrid):void
		{										
			initFromTree(grid);
			recLabelTree(grid.root, grid);
		}
		
		private function initFromTree(tree:ExtensiveForm):void
		{
			_uniqueLabelNum = 0;
			number_of_uniqueLabelname(tree);
			
			initCounts();		
		}
		
		private function recLabelTree(x:Node, tree:ExtensiveForm):void
		{			
			if (x.parent != null && !x.reachedby.hasLabel)    // if father exists and I am not assigned, then label
			{	
				var labGen:Boolean = true;						
				var player:Player = x.parent.iset.player;
				
				if (player != Player.CHANCE)
				{	
					var n1:Node = x.parent;
					var n2:Node = x.parent.iset.firstNode;
					
					while (n2 != null && n1 != n2) {
						if (n1.iset == n2.iset) {
							labGen = false;
							break;
						}
						n2 = n2.sibling;
					}
					
					if (!labGen) {
						n1 = x.parent.firstChild;
						n2 = x.parent.iset.firstNode.firstChild;
						
						var n:int = 0;
						while (n1 != x) {
							n1 = n1.sibling;
							n2 = n2.sibling;
							n++;
						}
						x.reachedby.label = n2.reachedby.label;						
					} 
					else 
					{
						var autoLabel:String = null;
						while (true) {
							autoLabel = getNextAutoLabel(player, tree);
							if (inUse.indexOf(autoLabel.toLowerCase()) < 0) {
								break;
							}
						}						
						x.reachedby.label = autoLabel;					}
				}
			}
			
			var y:Node = x.firstChild;
			while (y != null) {
				recLabelTree(y, tree);
				y = y.sibling;
			}
		}
		
		//Stores number of autolabels
		private function number_of_uniqueLabelname(tree:ExtensiveForm):void
		{
			var i:Iset = tree.root.iset;			
			while (i!=null) {
				if (i.player != Player.CHANCE) {
					for (var child:Node = i.firstNode.firstChild; child != null; child = child.sibling) {
						if (child.reachedby.hasLabel) { //not checking if child.reachedby is null, since that is an error we want to know about				
							inUse.push(child.reachedby.label.toLowerCase());
						} else {
							++_uniqueLabelNum;
						}
					}
				}
				i = i.nextIset;
			}
		}
	
	}
}