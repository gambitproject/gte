package lse.math.games.builder.io
{
	import flash.utils.Dictionary;
		
	import lse.math.games.builder.model.ExtensiveForm;
	import lse.math.games.builder.model.Iset;
	import lse.math.games.builder.model.Move;
	import lse.math.games.builder.model.Node;
	import lse.math.games.builder.model.Outcome;
	import lse.math.games.builder.model.Player;
	import lse.math.games.builder.model.Rational;
	
	/**	 
	 * @author Mark Egesdal
	 */
	public class ExtensiveFormXMLReader
	{		
		private var nodes:Dictionary;
		private var isets:Dictionary;
		private var isetObjToId:Dictionary;
		private var singletons:Vector.<Iset>;
		private var moves:Dictionary;
		private var players:Dictionary;
		
		private var xml:XML = null;
		private var tree:ExtensiveForm = null;
		
		public function ExtensiveFormXMLReader(xml:XML)
		{
			this.xml = xml;
		}
		
		public function load(tree:ExtensiveForm):ExtensiveForm
		{
			this.tree = tree;
			tree.clearTree();
			
			nodes = new Dictionary();
			isets = new Dictionary();
			isetObjToId = new Dictionary();
			singletons = new Vector.<Iset>();
			moves = new Dictionary();
			players = new Dictionary();			
			
			for each(var child:XML in xml.children()) {
				if (child.name() == "iset") {
					processIset(child);
				} else if (child.name() == "node") {
					processNode(child, null);
				} else if (child.name() == "outcome") {
					processOutcome(child, null);
				} else {
					trace("Ignoring unknown element:\r\n" + child);
				}
			}
			
			var iset:Iset = null;
			for (var isetId:String in isets) {				
				iset = isets[isetId] as Iset;
				if (iset != tree.root.iset) {					
					tree.addIset(iset);
				}
			}
			for each (iset in singletons) {				
				if (iset != tree.root.iset) {					
					tree.addIset(iset);
				}
			}
			
			hookupAndVerifyMoves();
			
			return tree;
		}	
		
		//TODO: there has got to be a more efficient algorithm
		private function hookupAndVerifyMoves():void
		{
			for (var iset:Iset = tree.root.iset; iset != null; iset = iset.nextIset) {		
				
				iset.sort();
				
				//for each child of the first node, hook up move
				var baseline:Node = iset.firstNode;
				for (var baselineChild:Node = baseline.firstChild, childIdx:int = 0; baselineChild != null; baselineChild = baselineChild.sibling, ++childIdx)
				{					
					iset.assignMove(baselineChild.reachedby);
					
					// make sure all the rest of the nodes have the child with the same move
					// TODO: it does not necessarily need to be at the same index
					for (var baselineMate:Node = baseline.nextInIset; baselineMate != null; baselineMate = baselineMate.nextInIset)
					{
						var mateChild:Node = baselineMate.firstChild;
						for (var i:int = 0; i < childIdx; ++i) {
							mateChild = mateChild.sibling;
						}
						if (mateChild.reachedby != baselineChild.reachedby) {
							if (mateChild.reachedby == null) {						
								throw new Error("node does not contain an incoming move");
							} else {
								throw new Error("Iset " + iset.idx + " is inconsistent for node " + baselineMate.number /*+ " at " + baselineMate.setIdx*/ + " for child " + mateChild.number + " at " + childIdx + " with move " + mateChild.reachedby);
							}
						}						
					}
				}
			}
		}
		
		private function getPlayer(playerId:String):Player
		{
			if (playerId == Player.CHANCE_NAME) {
				return Player.CHANCE;
			}
			
			var player:Player = players[playerId];
			if (player == null) {
				player = new Player(playerId, tree);
				players[playerId] = player;
			}
			return player;
		}
		
		private function processIset(elem:XML):void
		{
			var id:String = elem.@id;
			var iset:Iset = isets[id];
			
			if (iset == null) {
				var player:Player = (elem.@player != undefined) ? getPlayer(elem.@player) : Player.CHANCE;
				iset = new Iset(player, tree);
				isets[id] = iset;
				isetObjToId[iset] = id;
			}
			
			for each (var child:XML in elem.children())
			{
				if (child.name() == "node") {
					processNode(child, null);
				} else {
					trace("Ignoring unknown element:\r\n" + child);
				}
			}
		}
		
		private function processNode(elem:XML, parentNode:Node):void
		{
			//init
			var node:Node = null;
			if (elem.@id != undefined) 
			{
				var id:String = elem.@id;
				node = nodes[id];
				
				if (node == null) {
					trace("XMLReader: creating new node " + id);	
					node = tree.createNode();
					nodes[id] = node;
				} else {
					trace("XMLReader: processing previously created node " + id);
					
				}
			} else {				
				node = tree.createNode();
			}
			
			//assign parent			
			if (parentNode == null && elem.@parent != undefined) 
			{
				var parentId:String = elem.@parent;
				parentNode = nodes[parentId];
				
				if (parentNode == null) {
					parentNode = tree.createNode();						
					nodes[parentId] = parentNode;
				}			 
			}
			if (parentNode != null) {
				parentNode.addChild(node);
			} else {
				tree.root = node;
			}
			
			// process iset
			var isetId:String = null;			
			if (elem.parent() != null && elem.parent().name() == "iset") {
				isetId = elem.parent().@id;
				if (elem.@iset != undefined) trace("Warning: @iset attribute is set for a node nested in an iset tag.  Ignored.");				
			} else if (elem.@iset != undefined) {
				isetId = elem.@iset;
			}
			
			var iset:Iset = null;
			var player:Player = (elem.@player != undefined) ? getPlayer(elem.@player) : Player.CHANCE;
			if (isetId == null) {								
				iset = new Iset(player, tree);
				singletons.push(iset); // root is already taken care of				
			} else {				
				//look it up in the map, if it doesn't exist create it and add it
				iset = isets[isetId];
				if (iset == null) {
					iset = new Iset(player, tree);
					isets[isetId] = iset;
					isetObjToId[iset] = isetId;
				} else {
					if (player != Player.CHANCE) {
						if (iset.player != Player.CHANCE && player != iset.player) {
							trace("Warning: @player attribute conflicts with earlier iset player assignment.  Ignored.");	
						}
						while (iset.player != player) {
							iset.changeplayer();
						}
					}
				}				
			}
			iset.insertNode(node);
			
			// set up the moves
			processMove(elem, node, parentNode);
/*		 	if (elem.@move != undefined) {
				var moveId:String = elem.@move;
				var moveIsetId:String = (parentNode != null && parentNode.iset != null) ? String(parentNode.iset.idx) : "";
				var move:Move = moves[moveIsetId + "::" + moveId];

				if (move == null) {
					move = new Move(); 
					move.label = moveId;
					moves[moveIsetId + "::" + moveId] = move;
				}
				node.reachedby = move;
			} else if (parentNode != null) {
				// assume this comes from a chance node with a probability of zero
				node.reachedby = new Move();
			}
			
			if (elem.@prob != undefined && node.reachedby != null) {				
				node.reachedby.prob = Rational.parse(elem.@prob);
			}
*/	
			for each (var child:XML in elem.children()) {
				if (child.name() == "node") {
					processNode(child, node);
				} else if (child.name() == "outcome") {
					processOutcome(child, node);
				} /*else {
					trace("Ignoring unknown element:\r\n" + child);
				}*/
			}
		}
		
		private function processOutcome(elem:XML, parent:Node):void
		{
			// Create wrapping node
			// get parent from dictionary... if it doesn't exist then the outcome must be the root
			var wrapNode:Node = parent != null ? parent.newChild() : tree.createNode();
			if (parent == null) {
				tree.root = wrapNode;
			}
			
			// set up the moves
			processMove(elem, wrapNode, parent);
		/*	if (elem.@move != undefined) {
				var moveId:String = elem.@move;
				var moveIsetId:String = (parent != null && parent.iset != null) ? String(parent.iset.idx) : "";
				var move:Move = moves[moveIsetId + "::" + moveId];
				if (move == null) {
					move = new Move();
					move.label = moveId;
					moves[moveIsetId + "::" + moveId] = move;
				}
				wrapNode.reachedby = move;
			}

			if (elem.@prob != undefined && wrapNode.reachedby != null) {				
				wrapNode.reachedby.prob = Rational.parse(elem.@prob);
			}*/

			var outcome:Outcome = wrapNode.makeTerminal();
			for each (var child:XML in elem.children()) {
				if (child.name() == "payoff") {
					var playerId:String = child.@player;
					var payoff:Rational = Rational.parse(child.@value);
					
					var player:Player = players[playerId];
					if (player == null) {
						player = new Player(playerId, tree);
						players[playerId] = player;
					}
					outcome.setPay(player, payoff);
				} /*else {
					trace("Ignoring unknown element:\r\n" + child);
				}*/
			}				
		}

		private function processMove(elem:XML, node:Node, parent:Node):void
		{
			if (elem.@move != undefined) {
				var moveId:String = elem.@move;
				var moveIsetId:String = (parent != null && parent.iset != null) ? String(isetObjToId[parent.iset]) : "";
				var move:Move = moves[moveIsetId + "::" + moveId];
				if (move == null) {
					move = new Move();
					move.label = moveId;
					moves[moveIsetId + "::" + moveId] = move;
				}
				node.reachedby = move;
			} else if (parent != null) {
				// assume this comes from a chance node with a probability of zero
				node.reachedby = new Move();
			}

			if (elem.@prob != undefined && node.reachedby != null) {				
				node.reachedby.prob = Rational.parse(elem.@prob);
			}
		}
	}
}
