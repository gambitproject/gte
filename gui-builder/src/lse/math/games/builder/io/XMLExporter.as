package lse.math.games.builder.io 
{	
	import lse.math.games.builder.model.ExtensiveForm;
	import lse.math.games.builder.model.Iset;
	import lse.math.games.builder.model.Node;
	import lse.math.games.builder.model.Player;
	
	import util.Log;
	
	/**	
	 * TODO: Document
	 * 
	 * @author Mark Egesdal
	 */
	//TODO: Do something with gameDescription info
	//TODO: In the future, write node and iset names & maybe? payoffs in non-outcomes
	//TODO #33 writeMatrix
	//TODO #33 write players first, when they are in the spec
	public class XMLExporter
	{			
		private var log:Log = Log.instance;
		
		
		
		public function writeTree(tree:ExtensiveForm):XML
		{
			var xml:XML = 
				<gte>
					<gameDescription/>
					<display/>
					<extensiveForm/>				
				</gte>;
			
			//TODO loadSettings
			
			xml.extensiveForm.appendChild(getNodeElem(tree.root, tree));						
			
			return xml;
		}
		
		private function getNodeElem(n:Node, tree:ExtensiveForm):XML
		{
			var nodeElem:XML;			
			if (!n.isLeaf) {
				nodeElem = <node />;
				
				if (n.iset != null)
				{ 
					if(n.iset.numNodes > 1) 
						nodeElem.@iset = n.iset.idx;
								
					if (n.iset.player != Player.CHANCE) {
						nodeElem.@player = n.iset.player.name;
					}
				}
				
				for (var child:Node = n.firstChild; child != null; child = child.sibling) {
					nodeElem.appendChild(getNodeElem(child, tree));
				}
			} else {
				nodeElem = <outcome />;
				
				if(n.outcome != null)
					for (var player:Player = tree.firstPlayer; player != null; player = player.nextPlayer) 
					{
						var payoffElem:XML = <payoff/>;
						payoffElem.@player = player.name;
						payoffElem.@value = n.outcome.pay(player).toString();					
						nodeElem.appendChild(payoffElem);
					}
			}
			
			if (n.reachedby != null)
			{ 
				if(n.parent.iset.player == Player.CHANCE) {
				nodeElem.@prob = n.reachedby.label;
			} else  {
				nodeElem.@move = n.reachedby.label; // TODO: add a unique constraint in the program to prevent errors here?
				}
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
					}					
					nodeElem.appendChild(outcomeElem);
				}
			}			
			return nodeElem;
		}
	}
}