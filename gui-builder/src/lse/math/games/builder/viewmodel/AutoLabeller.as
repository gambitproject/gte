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
		import lse.math.games.builder.settings.UserSettings;
		import lse.math.games.builder.settings.SCodes;

		
		private var _alpha:Vector.<String> = new Vector.<String>();	
		private var _beta:Vector.<String> = new Vector.<String>();	
		private var count1_p1:int;
		private var count2_p1:int;
		private var count1_p2:int;
		private var count2_p2:int;
		
		private var _uniqueLabelNum:int;
		private var inUse:Vector.<String> = new Vector.<String>();	
		
		private var log:Log = Log.instance;
		private var bfs:Vector.<Node>= new Vector.<Node>();
		private var bfs_count:int;
		
		private var settings:UserSettings = UserSettings.instance;
		
		
		
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
				
				
				_beta.push("a");
				_beta.push("b");
				_beta.push("c");
				_beta.push("d");
				_beta.push("e");
				_beta.push("f");
				_beta.push("g");
				_beta.push("h");
				_beta.push("i");
				_beta.push("j");
				_beta.push("k");
				_beta.push("l");
				_beta.push("m");
				_beta.push("n");
				_beta.push("o");
				_beta.push("p");
				_beta.push("q");
				_beta.push("r");
				_beta.push("s");
				_beta.push("t");
				_beta.push("u");
				_beta.push("v");
				_beta.push("w");
				_beta.push("x");
				_beta.push("y");
				_beta.push("z");
			}
		}
		
		/** Next label from an auto-label sequence */		
		public function getNextAutoLabel_Player1(game:Game):String
		{
			var label:String = _alpha[count1_p1] + (count2_p1 != _alpha.length ? _alpha[count2_p1] : "");
			
			incrementCountsPlayer1();
			
			return label;
		}
		
		public function getNextAutoLabel_Player2(game:Game):String
		{
			var label:String = _beta[count1_p2] + (count2_p2 != _beta.length ? _beta[count2_p2] : "");
			
			incrementCountsPlayer2();
			
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
			count1_p1 = 0;
			if(_uniqueLabelNum < _alpha.length) {
				count2_p1 = _alpha.length;
			} else {
				count2_p1 = 0;
			}
			
			count1_p2 = 0;
			if(_uniqueLabelNum < _beta.length) {
				count2_p2 = _beta.length;
			} else {
				count2_p2 = 0;
			}	
		}
		
		// Increment the counters
		private function incrementCountsPlayer1():void
		{
			if (count2_p1 < _alpha.length) {
				++count2_p1;
				if (count2_p1 == _alpha.length) {
					++count1_p1;
					count2_p1 = 0;
					if (count1_p1 == _alpha.length) {
						log.add(Log.ERROR_THROW, "Ran out of auto labels");
					}
				}
			} else {				
				++count1_p1;
				if (count1_p1 == _alpha.length) {
					count2_p1 = 0;
					count1_p1 = 0;
				}
			}
		}
		
		private function incrementCountsPlayer2():void
		{
			if (count2_p2 < _beta.length) {
				++count2_p2;
				if (count2_p2 == _beta.length) {
					++count1_p2;
					count2_p2 = 0;
					if (count1_p2 == _beta.length) {
						log.add(Log.ERROR_THROW, "Ran out of auto labels");
					}
				}
			} else {				
				++count1_p2;
				if (count1_p2 == _beta.length) {
					count2_p2 = 0;
					count1_p2 = 0;
				}
			}
		}
		
		
		/* <--- --- TREE AUTO LABELLING --- ---> */
		
		/** Auto labels a tree */
		public function autoLabelTree(grid:TreeGrid, reset:Boolean):void
		{										
			initFromTree(grid,reset);
			
			
			if (settings.getValue(SCodes.SYSTEM_BFS_LABELING) as Boolean) {
				bfs = new Vector.<Node>();
				bfs.push(grid.root);
				bfs_count=0;
			
				recLabelTree_bfs(grid,reset,null);
			} else {
				recLabelTree_dfs(grid.root, grid,reset,null);
			}
			
		}
		
		public function autoLabelTreeSetEmptyMoves(grid:TreeGrid, reset:Boolean,specificIset:Iset):void
		{										
			initFromTree(grid,reset);
			if (settings.getValue(SCodes.SYSTEM_BFS_LABELING) as Boolean) {
				bfs = new Vector.<Node>();
				bfs.push(grid.root);
				bfs_count=0;
				recLabelTree_bfs(grid,reset,specificIset);
			} else {
				recLabelTree_dfs(grid.root, grid,reset,specificIset);
			}
		
		}
		
		private function initFromTree(tree:ExtensiveForm,reset:Boolean):void
		{
			_uniqueLabelNum = 0;
			if (!reset)
			 	number_of_uniqueLabelname(tree);
			
			initCounts();		
		}
		
		
		private function recLabelTree_bfs(tree:ExtensiveForm,reset:Boolean,specificIset:Iset):void {
			
			while (bfs.length>0) {
				var x:Node=bfs.shift()
				var labGen:Boolean = true;
				if (x.parent != null && (!x.reachedby.hasLabel || reset || !x.reachedby.hasLabelEmpty)) {
					var player:Player = x.parent.iset.player;
					//if ((player != Player.CHANCE) && (x.reachedby!=null)) {	
					if ((player != Player.CHANCE)) {		
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
							
							if ((specificIset!=null) && (x.parent.iset==specificIset)) {
								x.reachedby.label = " ";
								
							} else {
								while (true) {
									if (player==tree.firstPlayer) {
										autoLabel = getNextAutoLabel_Player1(tree);
									} else if (player==tree.firstPlayer.nextPlayer) {
										autoLabel = getNextAutoLabel_Player2(tree);
									}
									if (inUse.indexOf(autoLabel) < 0) {
										break;
									}
								}
								x.reachedby.label = autoLabel;
							}			
							
							//x.reachedby.label = bfs_count.toString();
							//bfs_count ++;
						}
					}
				}
				var y:Node = x.firstChild;
				
				
				if (y!=null) {
					bfs.push(y);
					while (y.sibling!=null) {
						y=y.sibling
						bfs.push(y);
					}
					
				}
			
			}
		
		}
		
		private function recLabelTree_dfs(x:Node, tree:ExtensiveForm,reset:Boolean,specificIset:Iset):void
		{			
			if (x.parent != null && (!x.reachedby.hasLabel || reset || !x.reachedby.hasLabelEmpty))    // if father exists and I am not assigned, then label
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

						if ((specificIset!=null) && (x.parent.iset==specificIset)) {
								x.reachedby.label = " ";
							
						} else {
							
								while (true) {
									if (player==tree.firstPlayer) {
										autoLabel = getNextAutoLabel_Player1(tree);
									} else if (player==tree.firstPlayer.nextPlayer) {
										autoLabel = getNextAutoLabel_Player2(tree);
									}
									if (inUse.indexOf(autoLabel.toLowerCase()) < 0) {
										break;
									}
								}
								x.reachedby.label = autoLabel;
							
							
						}
					}
				}
			}
			
			var y:Node = x.firstChild;
			while (y != null) {
				recLabelTree_dfs(y, tree,reset,specificIset);
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
							inUse.push(child.reachedby.label);
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