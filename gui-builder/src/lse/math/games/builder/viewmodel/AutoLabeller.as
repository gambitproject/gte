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
		
		//TODO: Implement different alphabets
		
		private var alpha:Vector.<String> = new Vector.<String>();	
//		private var alpha:Vector.<String> = { "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", " " };
		private var count1:int;
		private var count2:int;
		private var _uniqueLabelNum:int;
		private var inUse:Vector.<String> = new Vector.<String>();		
		private var log:Log = Log.instance;
		
		public function AutoLabeller()
		{
			alpha.push("A");
			alpha.push("B");
			alpha.push("C");
			alpha.push("D");
			alpha.push("E");
			alpha.push("F");
			alpha.push("G");
			alpha.push("H");
			alpha.push("I");
			alpha.push("J");
			alpha.push("K");
			alpha.push("L");
			alpha.push("M");
			alpha.push("N");
			alpha.push("O");
			alpha.push("P");
			alpha.push("Q");
			alpha.push("R");
			alpha.push("S");
			alpha.push("T");
			alpha.push("U");
			alpha.push("V");
			alpha.push("W");
			alpha.push("X");
			alpha.push("Y");
			alpha.push("Z");
			alpha.push(" ");
		}
		
		/** Next label from an auto-label sequence */		
		public function getNextAutoLabel(player:Player, game:Game):String
		{
			var label:String = alpha[count1] + (count2 != 26 ? alpha[count2] : "");
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
		
		
		
		/** Auto labels a tree */
		public function doAction(grid:TreeGrid):void
		{										
			init(grid);
			recLabel(grid.root, grid);
		}
		
		private function init(tree:ExtensiveForm):void
		{
			_uniqueLabelNum = 0;
			number_of_uniqueLabelname(tree);
			
			initCounts();		
		}
		
		//Reset the counters accordingly to the number of unique labels needed
		private function initCounts():void
		{
			count1 = 0;
			if(_uniqueLabelNum < 26) {
				count2 = 26;
			} else {
				count2 = 0;
			}	
		}
		
		// Increment the counters
		private function incrementCounts():void
		{
			if (count2 < 26) {
				++count2;
				if (count2 == 26) {
					++count1;
					count2 = 0;
					if (count1 == 26) {
						log.add(Log.ERROR_THROW, "Ran out of auto labels");
					}
				}
			} else {				
				++count1;
				if (count1 == 26) {
					count2 = 0;
					count1 = 0;
				}
			}
		}
		
		private function recLabel(x:Node, tree:ExtensiveForm):void
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
				recLabel(y, tree);
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