package lse.math.games.builder.viewmodel.action 
{
	import lse.math.games.builder.model.ExtensiveForm;
	import lse.math.games.builder.model.Iset;
	import lse.math.games.builder.model.Node;
	import lse.math.games.builder.model.Player;
	import lse.math.games.builder.presenter.IAction;
	import lse.math.games.builder.viewmodel.TreeGrid;
	
	/**
	 * @author Mark Egesdal
	 */
	public class AutoLabelAction implements IAction
	{		
		//var alpha2:Vector.<String> = { "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", " " };;
		private var alpha:Vector.<String> = new Vector.<String>();
		private var count1:int;
		private var count2:int;
		private var uniqelabelnumber:int;
		private var inUse:Vector.<String> = new Vector.<String>();
		
		
		public function AutoLabelAction() 
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
				
		
		public function doAction(grid:TreeGrid):void
		{										
			init(grid);
			recLabel(grid.root, grid);
		}
		
		public function get changesData():Boolean {
			return true;
		}
		
		public function get changesSize():Boolean {
			return true;
		}
		
		public function get changesDisplay():Boolean {
			return true;
		}
		
		private function init(tree:ExtensiveForm):void
		{
			uniqelabelnumber = 0;
			number_of_uniqueLabelname(tree);
			count1 = 0;
			if(uniqelabelnumber < 26) {
				count2 = 26;
			} else {
				count2 = 0;
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
		
		private function getNextAutoLabel(player:Player, tree:ExtensiveForm):String
		{
			var label:String = (alpha[count1] + (count2 != 26 ? alpha[count2] : ""));
			if (player != tree.firstPlayer) {
				label = label.toLowerCase();
			}
			
			if (count2 < 26) {
				++count2;
				if (count2 == 26) {
					++count1;
					count2 = 0;
					if (count1 == 26) {
						throw new Error("Ran out of auto labels");
					}
				}
			} else {				
				++count1;
				if (count1 == 26) {
					count2 = 0;
					count1 = 0;
				}
			}
			
			return label;
		}
		
		private function number_of_uniqueLabelname(tree:ExtensiveForm):void
		{
			var i:Iset = tree.root.iset;			
			while (i!=null) {
				if (i.player != Player.CHANCE) {
					for (var child:Node = i.firstNode.firstChild; child != null; child = child.sibling) {
						if (child.reachedby.hasLabel) { //not checking if child.reachedby is null, since that is an error we want to know about				
							inUse.push(child.reachedby.label.toLowerCase());
						} else {
							++uniqelabelnumber;
						}
					}
				}
				i = i.nextIset;
			}
		}
	}

}