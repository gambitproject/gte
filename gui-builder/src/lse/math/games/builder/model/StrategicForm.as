package lse.math.games.builder.model 
{
	import flash.utils.Dictionary;
	
	import lse.math.games.builder.viewmodel.AutoLabeller;
	
	import util.Log;
	
	/**	 
	 * @author Mark Egesdal & alfongj
	 */
	public class StrategicForm extends Game
	{
		private var _payMatrixMap:Dictionary = new Dictionary() // Player => String (Strategy_Tuple_Key) => Number
		
		/* Depending on whether the StForm was populated from a tree or not,
		 * _strategyMap[player] returns:
		 * 	 - From a tree: A map with Strategies stored with Strategy.key as keys
		 *	 - Not from a tree: A vector with Strategies in order
		 */			
		private var _strategyMap:Dictionary = new Dictionary(); // Player => String (Strategy_Key) => Strategy
		private var _reduced:Boolean = true;
		
		private var _grid:ExtensiveForm = null;
		private var _isSecondary:Boolean = true; //This must change if the gui starts in MATRIX_MODE with a setting or something
		private var _isUpdated:Boolean = false;
		
		private var log:Log = Log.instance;
		
		// TODO: selected node		
		// TODO: optimize reduced form, less object creation wasted... get rid of sorting when there are no multi-row isets in the sequence		
		

		[Bindable]
		/** If the matrix is in reduced form */
		public function get isStrategicReduced():Boolean { return _reduced; }
		public function set isStrategicReduced(value:Boolean):void { _reduced = value; }
		
		/** If the matrix is the secondary model. That happens in [TREE_MODE] */
		public function set isSecondary(value:Boolean):void { _isSecondary = value; }
		
		/** If the matrix is up-to-date with its grid primary source. Just appliable if this is the secondary source */
		public function get isUpdated():Boolean {
			if(_isSecondary) return _isUpdated;
			else return true;
		}
		public function set isUpdated(value:Boolean):void { 
			_isUpdated = value; }
		
		/** Grid as a primary source of data for populating the matrix, appliable if this is secondary source */
		public function set grid(value:ExtensiveForm):void { _grid = value; }
		
	    /** 
		 * Dictionary containing paymatrixes for each player. </br>
		 * Instructions:
		 * <ol><li>Obtain the pay matrix of one player with payMatrixMap(player) as Object</li>
		 * <li>Obtain the key for the coordinate you want to access the payoff from
		 * with Strategy.key([strategy_from_pl_1, strategy_from_pl_2, ...])</li>
		 * <li>Access the payoff (as a number) with playerMatrix[strategy_tuple_key]</li>		 * 
		 */
		public function get payMatrixMap():Dictionary { return _payMatrixMap; }
		
		/** 
		 * Dictionary containing maps of strategies for each player. </br>
		 * Instructions:
		 * <ol><li>Obtain the pay matrix of one player with payMatrixMap(player) as Object</li>
		 * <li>Obtain the key for the coordinate you want to access the payoff from
		 * with Strategy.key([strategy_from_pl_1, strategy_from_pl_2, ...])</li>
		 * <li>Access the payoff (as a number) with playerMatrix[strategy_tuple_key]</li>		 * 
		 */
		public function get strategyMap():Dictionary { return _strategyMap; }
		
		// TODO: bimatix class to take intersection instead
		// create and sort a row vector of strategies and a col vector of strategies
		//public function get strategyMap():Dictionary {
		//	return _strategyMap;
		//}
		
		/** 
		 * Returns a vector of the strategies of a certain player in order.
		 */
		public function strategies(pl:Player):Vector.<Strategy>	{
			if(_isSecondary)
				return sortStrategies(_strategyMap[pl]);
			else
				return _strategyMap[pl];
		}
		
		
		
		/** Restarts the matrix to a new one without any information */
		public function clearMatrix():void
		{
			_firstPlayer = null;
			_payMatrixMap = new Dictionary();
			_strategyMap = new Dictionary();
		}
		
		/** Creates a default matrix with two players and one strategy each */
		public function defaultMatrix():void
		{
			var pl1:Player = newPlayer("1");
			var pl2:Player = newPlayer("2");
			
			var al:AutoLabeller = new AutoLabeller();
			al.uniqueLabelNum = 2;
			
			var st1:Strategy = new Strategy(pl1);
			st1.name = al.getNextAutoLabel(pl1, this);
			addStrategy(st1);
			
			var st2:Strategy = new Strategy(pl2);
			st2.name = al.getNextAutoLabel(pl2, this);
			addStrategy(st2);	
			
			addPayoff([st1, st2], null, Rational.ONE);
		}
		
		/** Creates a new player, assigning it as moving next of the last one currently existing in this game */
		public function newPlayer(name:String):Player {
			return new Player(name, this);
		}
		
		/** 
		 * Adds a new strategy at the end of the list of strategies of a certain player.<br/>
		 * This function mustn't be called when the Strategic Form was created from a tree.
		 */
		public function addStrategy(s:Strategy):void
		{
			var pl:Player = s.player;
			var strVector:Vector.<Strategy> = _strategyMap[pl];
			if(strVector == null)
			{
				strVector = new Vector.<Strategy>();
				_strategyMap[pl] = strVector;
			}
			
			strVector.push(s);
		}
		
		/** 
		 * Adds a payoff (multiplied by 'prob' if necessary) to the paymatrixes,
		 * on the cell marked by a key obtained from a 'combo' array of Strategies
		 */
		public function addPayoff(combo:Array, z:Outcome, prob:Rational):void
		{
			var pairKey:String = Strategy.key(combo);
			for (var pl:Player = _firstPlayer; pl != null; pl = pl.nextPlayer) {					
				var payMatrix:Object = _payMatrixMap[pl];
				if (payMatrix == null) {
					payMatrix = new Object();
					_payMatrixMap[pl] = payMatrix;					
				}
				if (payMatrix[pairKey] == undefined) {					
					payMatrix[pairKey] = Rational.ZERO;
				}
				var pay:Rational = (z != null) ? prob.multiply(z.pay(pl)) : Rational.NaN;				
				payMatrix[pairKey] = payMatrix[pairKey].add(pay);
			}			
		}
		
		
		
		/* <--- --- FUNCTIONS FOR CREATION FROM TREE --- --->*/
		
		/** Loads the data of this Game from an existing extensive form tree */
		public function populateFromTree():void
		{			
			if(!_isSecondary)
				log.add(Log.ERROR_THROW, "Tried to populate Matrix without it being the secondary model");
			
			if(_grid!=null)
			{
				clearMatrix();

				_firstPlayer = _grid.firstPlayer;
				
				// iterate over the leaves of the tree
				for (var leaf:Node = _grid.root.firstLeaf; leaf != null; leaf = leaf.nextLeaf)
				{				
					var z:Outcome = leaf.outcome; // TODO: what if this is null?								
					var map:Dictionary = new Dictionary();
					
					//Store in a map vectors of strategies per player
					for (var pl:Player = _firstPlayer; pl != null; pl = pl.nextPlayer) {
						map[pl] = processStrategiesForLeaf(pl, leaf);					
					}
					
					var prob:Rational = realprob(leaf);								
					recAddPayoffs(_grid.firstPlayer, null, z, prob, map);
				}
				
				_isUpdated = true;
			} else
				log.add(Log.ERROR_THROW, "The tree primary source has not been set. Couldn't " +
					"populate the matrix.");
		}
		
		// Looks for the strategies of a certain leaf & player, saves 
		// them into the strategy map, and returns them as a list
		private function processStrategiesForLeaf(player:Player, leaf:Node):Vector.<Strategy>
		{			
			var strategies:Object = _strategyMap[player];
			if (strategies == null) {
				strategies = new Object();
				_strategyMap[player] = strategies;
			}
			var list:Vector.<Strategy> = getStrategiesForLeaf(player, leaf);
			
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
		
		// Returns a list of all the strategies that end up in a certain leaf and player
		private function getStrategiesForLeaf(player:Player, leaf:Node):Vector.<Strategy>
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
			
			var list:Vector.<Strategy> = new Vector.<Strategy>();
			var st:Strategy = new Strategy(player);
			st.sequence = baseSequence;
			list.push(st);
			
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
					if (_reduced) {
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
			return list;
		}
		
		// Recursively adds to all the combos of strategies in 'map' the outcome 'z' multiplied by 'prob' 
		private function recAddPayoffs(player:Player, sofar:Array, z:Outcome, prob:Rational, map:Dictionary):void 
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
		
		// Returns strategies in a vector, sorted -from the stratMap created when
		// loading from a tree- following Strategy.compare criteria
		private function sortStrategies(stratMap:Object):Vector.<Strategy>
		{
			var stratVec:Vector.<Strategy> = new Vector.<Strategy>();
			for each (var strat:Strategy in stratMap) {				
				stratVec.push(strat);				
			}
			
			stratVec.sort(Strategy.compare);
			
			return stratVec;
		}
				
		// Function for comparing, or sorting, isets by their depths
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
		
		// Boolean that returns true if a certain iset is reachable
		private function isIsetReachable(h:Iset, baseSequence:Vector.<Move>):Boolean
		{
			var reachable:Boolean = false;
			var isetInCommon:Function = function(item:Move, index:int, vector:Vector.<Move>):Boolean {
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
		
		// 'Expands' by creating new strategies from a base one and the iset it should start expanding from
		// Returns them in a vector of strategies
		private function expand(baseStrategy:Strategy, iset:Iset):Vector.<Strategy>
		{		
			var expansion:Vector.<Strategy> = new Vector.<Strategy>();
			if (!iset.isChildless) {
				for (var child:Node = iset.firstNode.firstChild; child != null; child = child.sibling) {
					var expansionSequence:Vector.<Move> = new Vector.<Move>();
					for each (var move:Move in baseStrategy.sequence) {
						expansionSequence.push(move);
					}
					expansionSequence.push(child.reachedby);
					
					var st:Strategy = new Strategy(iset.player);
					st.sequence = expansionSequence;
					expansion.push(st);
				}
			} else {				
				expansion.push(baseStrategy);				
			}
			return expansion;
		}
		
		
		
		/* <--- --- OTHER FUNCTIONS --- ---> */
		
		// TODO: 3PL this requires 2-players... perhaps get rid or move this to a bimatrix class
		public function toString():String
		{
			if(_isSecondary)
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
			else return "Feature not ready yet";
		}
		
		/* 
		 * Returns the probability of reaching a node, as the product
		 * of all chance moves in the node's move sequence. 
		 */
		private function realprob(n:Node):Rational
		{
			var prob:Rational = Rational.ONE;
			while (n != null) {
				if (n.parent != null && n.parent.iset.player == Player.CHANCE) {
					prob = prob.multiply(n.reachedby.prob);
				}
				n = n.parent;
			}
			return prob;			
		}		
	} 
}