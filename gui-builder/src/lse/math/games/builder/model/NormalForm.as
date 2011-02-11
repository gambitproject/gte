package lse.math.games.builder.model 
{
	import flash.utils.Dictionary;
	import mx.utils.StringUtil;
	
	/**	 
	 * @author Mark Egesdal
	 */
	public class NormalForm
	{
		private var _payMatrixMap:Dictionary = new Dictionary() // Player => String (Strategy_Tuple_Key) => Number
		private var _strategyMap:Dictionary = new Dictionary(); // Player => String (Strategy_Key) => Strategy
		private var _firstPlayer:Player = null;
		
		// TODO: selected node		
		// TODO: optimize reduced form, less object creation wasted... get rid of sorting when there are no multi-row isets in the sequence		
		public function NormalForm(tree:ExtensiveForm, reduce:Boolean)
		{
			_firstPlayer = tree.firstPlayer;

			// iterate over the leaves of the tree
			for (var leaf:Node = tree.root.firstLeaf; leaf != null; leaf = leaf.nextLeaf)
			{				
				var z:Outcome = leaf.outcome; // TODO: what if this is null?								
				var map:Dictionary = new Dictionary();
				for (var pl:Player = _firstPlayer; pl != null; pl = pl.nextPlayer) {
					map[pl] = processStrategiesForLeaf(pl, leaf, reduce);					
				}
				
				var prob:Number = realprob(leaf);								
				recAddPayoffs(tree.firstPlayer, null, z, prob, map);				
			}
		}
		
		public function get firstPlayer():Player {
			return _firstPlayer;
		}
		
		private function recAddPayoffs(player:Player, sofar:Array, z:Outcome, prob:Number, map:Dictionary):void 
		{			
			var strategies:Vector.<Strategy> = map[player];
			for each (var strategy:Strategy in strategies) {
				var combo:Array = new Array();
				if (sofar != null) {
					for each (var other:Strategy in sofar) {
						combo.push(other);					
					}
				}
				combo.push(strategy);
				if (player.nextPlayer == null) {					
					addPayoff(combo, z, prob);					
				} else {					
					recAddPayoffs(player.nextPlayer, combo, z, prob, map);
				}
			}		
		}
		
		private function addPayoff(combo:Array, z:Outcome, prob:Number):void
		{
			var pairKey:String = Strategy.key(combo);
			for (var pl:Player = _firstPlayer; pl != null; pl = pl.nextPlayer) {					
				var payMatrix:Object = _payMatrixMap[pl];
				if (payMatrix == null) {
					payMatrix = new Object();
					_payMatrixMap[pl] = payMatrix;					
				}
				if (payMatrix[pairKey] == undefined) {					
					payMatrix[pairKey] = 0.0; //Number
				}
				var pay:Number = (z != null) ? prob * z.pay(pl) : NaN;				
				payMatrix[pairKey] += pay;
			}			
		}
		
		private function sortStrategies(stratMap:Object):Vector.<Strategy>
		{
			var stratVec:Vector.<Strategy> = new Vector.<Strategy>();
			for each (var strat:Strategy in stratMap) {				
				stratVec.push(strat);				
			}
			stratVec.sort(Strategy.compare);
			return stratVec;
		}
		
		public function strategies(pl:Player):Vector.<Strategy>
		{
			return sortStrategies(_strategyMap[pl]);			
		}
		
		// TODO: bimatix class to take intersection instead
		// create and sort a row vector of strategies and a col vector of strategies
		//public function get strategyMap():Dictionary {
		//	return _strategyMap;
		//}
		
		// requires an entry for each player in the game
		public function get payMatrixMap():Dictionary {
			return _payMatrixMap;
		}
		
		private function processStrategiesForLeaf(player:Player, leaf:Node, reduce:Boolean):Vector.<Strategy>
		{			
			var strategies:Object = _strategyMap[player];
			if (strategies == null) {
				strategies = new Object();
				_strategyMap[player] = strategies;
			}
			var list:Vector.<Strategy> = getStrategiesForLeaf(player, leaf, reduce);
			
			for each (var strat:Strategy in list) 
			{
				var key:String = Strategy.key([strat]);
				
				if (strategies[key] == undefined) {
					strategies[key] = strat;
					//trace("adding new strategy " + strat.toString() + " for leaf " + leaf.number + (leaf.outcome != null ? " with outcome " + leaf.outcome.pay(_firstPlayer) + " " + leaf.outcome.pay(_firstPlayer.nextPlayer) : " with no outcome"));					
				} else {
					strat = strategies[key];
					//trace("found existing strategy " + strat.toString() + " for leaf " + leaf.number + (leaf.outcome != null ? " with outcome " + leaf.outcome.pay(_firstPlayer) + " " + leaf.outcome.pay(_firstPlayer.nextPlayer) : " with no outcome"));
				}				
			}
			return list;
		}
		
		private function getStrategiesForLeaf(player:Player, leaf:Node, reduce:Boolean):Vector.<Strategy>
		{			
			var seen:Vector.<Iset> = new Vector.<Iset>();
			
			// set up the base sequence...
			var baseSequence:Vector.<Move> = new Vector.<Move>();			
			for (var n:Node = leaf; n.parent != null; n = n.parent) {
				if (n.parent.iset.player == player) {
					var toAdd:Move = n.reachedby;
					if (seen.indexOf(toAdd.iset) < 0) {
						baseSequence.push(toAdd);
						seen.push(toAdd.iset);
					} else {						
						// make sure we do not add a move for the same iset twice...
						for each (var existingMove:Move in baseSequence) {
							if (existingMove.iset == toAdd.iset && existingMove != toAdd) {
								// same iset with different moves is not allowed...
								// return the empty list
								return new Vector.<Strategy>();
							}
						}
					}
				}				
			}
			//trace("sequence in for player " + player.name + " at leaf " + leaf.number + " is " + baseSequence.toString());
			
			var list:Vector.<Strategy> = new Vector.<Strategy>();
			list.push(new Strategy(player, baseSequence));
			
			// create an unseen iset vector and sort by min depth
			// TODO: this would be unnecessary and would be faster if isets were already sorted this way
			var unseen:Vector.<Iset> = new Vector.<Iset>();
			for (var h:Iset = n.iset; h != null; h = h.nextIset) {
				if (h.player == player && seen.indexOf(h) < 0) {
					unseen.push(h);
				}
			}
			
			// sort unseen by depth
			//trace ("unseen before " + unseen);
			unseen.sort(isetDepthSort);
			//trace ("unseen after " + unseen);
			
			// n is now the root... n.iset = tree.root.iset
			while (unseen.length > 0) 
			{
				h = unseen.shift();
				var newList:Vector.<Strategy> = new Vector.<Strategy>();
				for each (var baseStrat:Strategy in list) {
					var shouldExpand:Boolean = true;
					if (reduce) {
						// TODO: this check isn't good enough... it is possible to prevent an expansion here, but
						// what if the iset is reachable but previous additions mean not all expansions are possible
						// can we solve this problem by expanding top down breadth-first, ltr
						shouldExpand = isIsetReachable(h, baseStrat.sequence);
					}
					
					//trace("expanding " + baseStrat.toString());
					if (shouldExpand) {
						var expansion:Vector.<Strategy> = expand(baseStrat, h);						
						for each (var expandedStrat:Strategy in expansion) {
							//trace("expansion is " + expandedStrat.toString());
							expandedStrat.isReduced = baseStrat.isReduced;
							newList.push(expandedStrat);
						}
					} else {
						baseStrat.isReduced = true;
						newList.push(baseStrat);
					}
				}
				list = newList;					
				//seen.push(h);
			}
			//trace("returning list of size " + list.length);
			return list;
		}
		
		private function isetDepthSort(a:Iset, b:Iset):int {
			var aMinDepth:int = -1, bMinDepth:int = -1;
			for (var an:Node = a.firstNode; an != null; an = an.nextInIset) {
				if (aMinDepth < 0) {
					aMinDepth = an.depth;
				} else if (an.depth < aMinDepth) {
					aMinDepth = an.depth;
				}
			}
			for (var bn:Node = b.firstNode; bn != null; bn = bn.nextInIset) {
				if (bMinDepth < 0) {
					bMinDepth = bn.depth;
				} else if (bn.depth < bMinDepth) {
					bMinDepth = bn.depth;
				}
			}
			if (aMinDepth < bMinDepth) return -1;
			else if (aMinDepth > bMinDepth) return 1;
			else if (a.firstNode.isRightOf(b.firstNode)) return 1;
			else return -1;
		}
		
		private function isIsetReachable(h:Iset, baseSequence:Vector.<Move>):Boolean
		{
			var reachable:Boolean = false;
			var isetInCommon:Function = function(item:Move, index:int, vector:Vector.<Move>):Boolean {
				//trace("checking iset " + this.idx + " against move " + item.label + " returning " + (item.iset.idx == this.idx));
				return (item.iset.idx == this.idx);
			};
			
			// we will skip expanding if all the nodes in the iset meet the following condition:
			for (var n:Node = h.firstNode; n != null; n = n.nextInIset) {
				
				// the ascendancy of the node has an iset in common with the base sequence, but the move differs 
				// (making reaching this decision impossible by this own player's actions)
				// with multi-row isets, I cannot think of a quick and clever way to trace through the sequences comparing isets				
				// since they might have reached the same iset at different rows (periods in time), so I'll climb the tree
				// but if I know that there are no multi-row isets, I can optimize this compare
				var canReachNode:Boolean = true;
				for (var ascent:Node = n; ascent.parent != null; ascent = ascent.parent) {
					//see if it has an iset is in common with the base sequence, but a different move
					if (ascent.parent.iset.player == h.player && 
						baseSequence.some(isetInCommon, ascent.parent.iset) &&						
						baseSequence.indexOf(ascent.reachedby) < 0) 
					{
						//trace("we can never get to node " + n.number + " in iset " + h.idx);
						canReachNode = false;
						break;
					}								
				}
				if (canReachNode) {
					//trace("we can get to node " + n.number + " so we should expand");
					reachable = true;
					break;
				}
			}
			//if (!reachable) {
			//	trace("we cannot reach any of the nodes in iset " + h.idx + ", so we should NOT expand");
			//}
			return reachable;
		}
		
		private function expand(baseStrategy:Strategy, iset:Iset):Vector.<Strategy>
		{		
			var expansion:Vector.<Strategy> = new Vector.<Strategy>();
			if (!iset.isChildless) {
				for (var child:Node = iset.firstNode.firstchild; child != null; child = child.sibling) {
					var expansionSequence:Vector.<Move> = new Vector.<Move>();
					for each (var move:Move in baseStrategy.sequence) {
						expansionSequence.push(move);
					}
					expansionSequence.push(child.reachedby);				
					expansion.push(new Strategy(iset.player, expansionSequence));
				}
			} else {				
				expansion.push(baseStrategy);				
			}
			return expansion;
		}
		
		// TODO: this requires 2-players... perhaps get rid or move this to a bimatrix class
		public function toString():String
		{
			var lines:Vector.<String> = new Vector.<String>();
			for (var pl:Player = _firstPlayer; pl != null; pl = pl.nextPlayer) {				
				lines.push("Player " + pl.name);					
				
				var matrix:Object = _payMatrixMap[pl];
				var rows:Object = _strategyMap[_firstPlayer];
				var cols:Object = _strategyMap[_firstPlayer.nextPlayer];
				var line:Vector.<String> = new Vector.<String>();
				line.push("");
				for (var colKey:String in cols) {
					var col:Strategy = cols[colKey];						
					line.push(col);
				}
				lines.push(line.join("\t| "));					
				for (var rowKey:String in rows) {
					var row:Strategy = rows[rowKey];
					line = new Vector.<String>();
					line.push(" " + row);
					for (colKey in cols) {
						col = cols[colKey];
						var pairKey:String = Strategy.key([row, col]);							
						line.push(matrix[pairKey]);
					}
					lines.push(line.join("\t| "));
				}
				lines.push("");				
			}
			return lines.join("\n");
		}
		
		private function realprob(n:Node):Number
		{
			var prob:Number = 1;
			while (n != null) {
				if (n.parent != null && n.parent.iset.player == Player.CHANCE) {
					prob *= n.reachedby.prob;
				}
				n = n.parent;
			}
			return prob;			
		}		
	}
}