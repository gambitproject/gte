package lse.math.games.builder.io 
{	
	import lse.math.games.builder.model.ExtensiveForm;
	import lse.math.games.builder.model.Iset;
	import lse.math.games.builder.model.Node;
	import lse.math.games.builder.model.Player;
	
	/**	
	 * This class should be removed once XMLReader in the Java part is updated to the new format
	 * 
	 * @author Mark Egesdal
	 */
	public class OldExtensiveFormXMLWriter
	{			
		public function write(tree:ExtensiveForm):XML
		{
			var xml:XML = <extensiveForm />;
			
			var isets:Vector.<Iset> = new Vector.<Iset>();
			xml.appendChild(getNodeElem(tree.root, isets, tree));						
			
			/* Suspending writing Ahmad's way... perhaps I can be more clever with how I order the isets, but this way
			 * seems to lose the left-to-right ordering of the tree
			for (var h:Iset = tree.root.iset; h != null; h = h.nextIset) {
				xml.appendChild(getIsetElem(h, tree));
			}*/
			return xml;
		}
		
		private function getNodeElem(n:Node, isets:Vector.<Iset>, tree:ExtensiveForm):XML
		{
			var nodeElem:XML;			
			if (n.outcome == null) {
				nodeElem = <node />;
				
				if (n.iset != null && n.iset.numNodes > 1) {
					nodeElem.@iset = n.iset.idx;
				}				
				if (isets.indexOf(n.iset) < 0 && n.iset.player != Player.CHANCE) {
					nodeElem.@player = n.iset.player.name;
					isets.push(n.iset);
				}
				
				for (var child:Node = n.firstChild; child != null; child = child.sibling) {
					nodeElem.appendChild(getNodeElem(child, isets, tree));
				}
			} else {
				nodeElem = <outcome />;
				
				for (var player:Player = tree.firstPlayer; player != null; player = player.nextPlayer) 
				{
					var payoffElem:XML = <payoff/>;
					payoffElem.@player = player.name;
					payoffElem.@value = n.outcome.pay(player); // TODO: write out as fraction?					
					nodeElem.appendChild(payoffElem);
				}
			}
			
			if (n.reachedby != null && n.parent.iset.player == Player.CHANCE) {
				nodeElem.@prob = n.reachedby.label; // TODO: write out as a fraction
			} else if (n.reachedby != null) {
				nodeElem.@move = n.reachedby.label; // TODO: add a unique constraint in the program to prevent errors here?
			}
			return nodeElem;
		}
		
		private function getIsetElem(h:Iset, tree:ExtensiveForm):XML
		{
			var isetElem:XML;
			if (h.numNodes > 1) {
				isetElem = <iset />
				isetElem.@id = h.idx;
				if (h.player != Player.CHANCE) isetElem.@player = h.player.name;
				
				for (var n:Node = h.firstNode; n != null; n = n.nextInIset) {												
					isetElem.appendChild(getNodeElemForIset(n, tree));
				}
			} else {
				isetElem = getNodeElemForIset(h.firstNode, tree);
				if (h.player != Player.CHANCE) isetElem.@player = h.player.name;
			}
			return isetElem;
		}
		
		private function getNodeElemForIset(node:Node, tree:ExtensiveForm):XML
		{
			var nodeElem:XML = <node />;
			nodeElem.@id = node.number;
			if (node.parent != null) {
				nodeElem.@parent = node.parent.number;
			}
			if (node.reachedby != null && node.reachedby.isChance) {
				nodeElem.@prob = node.reachedby.prob; // TODO: write out as a fraction
			} else if (node.reachedby != null) {
				nodeElem.@move = node.reachedby.label; // TODO: add a unique constraint in the program to prevent errors here?
			}
			
			for (var child:Node = node.firstChild; child != null; child = child.sibling) {
				if (child.outcome != null) {
					var outcomeElem:XML = <outcome/>;
					if (child.reachedby != null && child.reachedby.isChance) {
						outcomeElem.@prob = child.reachedby.prob; // TODO: write out as a fraction
					} else {
						outcomeElem.@move = child.reachedby.label; // TODO: add a unique constraint in the program to prevent errors here?
					}					
					for (var player:Player = tree.firstPlayer; player != null; player = player.nextPlayer) {
						var payoffElem:XML = <payoff/>;
						payoffElem.@player = player.name;
						payoffElem.@value = child.outcome.pay(player); // TODO: write out as fraction?
						outcomeElem.appendChild(payoffElem);
						
						var parameter1Elem:XML = <parameter/>;
						if (child.parameterPlayer1!=null) {
							parameter1Elem.@player =  tree.firstPlayer;
							parameter1Elem.@value = child.parameterPlayer1;
							outcomeElem.appendChild(parameter1Elem);
						}

						var parameter2Elem:XML = <parameter/>;
						if (child.parameterPlayer2!=null) {
							parameter2Elem.@player =  tree.firstPlayer.nextPlayer();
							parameter2Elem.@value = child.parameterPlayer2; 
							outcomeElem.appendChild(parameter2Elem);
						}

						
					}					
					nodeElem.appendChild(outcomeElem);
				}
			}			
			return nodeElem;
		}
	}
}