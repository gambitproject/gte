package lse.math.games.builder.io 
{	
	import flash.utils.ByteArray;
	
	import mx.utils.HexEncoder;
	
	import lse.math.games.builder.model.ExtensiveForm;
	import lse.math.games.builder.model.Iset;
	import lse.math.games.builder.model.Node;
	import lse.math.games.builder.model.Player;
	import lse.math.games.builder.settings.FileSettings;
	import lse.math.games.builder.settings.SCodes;
	
	import util.Log;
	
	/**	 
	 * XMLImporter saves trees and matrixes from XML data. <p/>
	 * 
	 * Instructions to use it:<br/>
	 * Just call writeTree or writeMatrix (depending on what you want to save)
	 * 
	 * @author Mark Egesdal & alfongj
	 */
	//TODO: Do something with gameDescription info
	//TODO: In the future, write node and iset names & maybe? payoffs in non-outcomes
	//TODO #33 writeMatrix
	public class XMLExporter
	{			
		private var VERSION:Number = 0.1;
		
		private var log:Log = Log.instance;
		
		
		
		/** Writes an ExtensiveForm tree into the latest xml format representation */
		public function writeTree(tree:ExtensiveForm):XML
		{
			var xml:XML = 
				<gte>
					<gameDescription/>
					<display/>
					<players/>
					<extensiveForm/>				
				</gte>;
			
			xml.@version = VERSION;
			
			writeDispSettings(xml.display, true);
			writePlayers(xml.players, tree);
			
			xml.extensiveForm.appendChild(getNodeElem(tree.root, tree));						
			
			return xml;
		}
		
		//Writes the settings as children of a parent XMLList (which should be <display>)
		private function writeDispSettings(parent:XMLList, isEF:Boolean):void 
		{
			var fileSettings:FileSettings = FileSettings.instance;

			var setting:XML;
			
			//Player colors //TODO: 3PL
			setting = <color />
			setting.@player = "1";
			setting.appendChild(hexStr(fileSettings.getValue(SCodes.FILE_PLAYER_1_COLOR) as uint));
			parent.appendChild(setting);
			
			setting = <color />
			setting.@player = "2";
			setting.appendChild(hexStr(fileSettings.getValue(SCodes.FILE_PLAYER_2_COLOR) as uint));
			parent.appendChild(setting);
			
			setting = <font />
			setting.appendChild(fileSettings.getValue(SCodes.FILE_FONT) as String);
			parent.appendChild(setting);
			
			setting = <strokeWidth />
			setting.appendChild(fileSettings.getValue(SCodes.FILE_STROKE_WIDTH) as int);
			parent.appendChild(setting);
			
			if(isEF)
			{
				setting = <nodeDiameter />
				setting.appendChild(fileSettings.getValue(SCodes.FILE_NODE_DIAMETER) as Number);
				parent.appendChild(setting);
				
				setting = <isetDiameter />
				setting.appendChild(fileSettings.getValue(SCodes.FILE_ISET_DIAMETER) as Number);
				parent.appendChild(setting);
				
				setting = <levelDistance />
				setting.appendChild(fileSettings.getValue(SCodes.FILE_LEVEL_DISTANCE) as int);
				parent.appendChild(setting);
			}
		}
		
		//Writes the players as elements of a parent XMLList (which should be <players>)
		//NOTE: This is 3PL+ prepared
		private function writePlayers(parent:XMLList, tree:ExtensiveForm):void
		{
			var player:Player = tree.firstPlayer;
			for(var i:int = 0; i<tree.numPlayers; i++)
			{
				var playerNode:XML = <player />;
				playerNode.@playerId = ""+(i+1);
				playerNode.appendChild(player.name);
				parent.appendChild(playerNode);
				
				player = player.nextPlayer;
			}
		}	
		
		//Returns an xml subtree of the original tree, starting from the node 'n',
		//including all valuable model info: nodes with their attributes (isets and
		//players), outcomes with payoffs
		private function getNodeElem(n:Node, tree:ExtensiveForm):XML
		{
			var nodeElem:XML;			
			if (!n.isLeaf) {
				nodeElem = <node />;
				
				//Add iset attributes
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
				
				//Add iset attributes
				if (n.iset != null)
				{ 
					if(n.iset.numNodes > 1) 
						nodeElem.@iset = n.iset.idx;
					
					if (n.iset.player != Player.CHANCE) {
						nodeElem.@player = n.iset.player.name;
					}
				}
				
				if(n.outcome != null)
					for (var player:Player = tree.firstPlayer; player != null; player = player.nextPlayer) 
					{
						var payoffElem:XML = <payoff/>;
						payoffElem.@player = player.name;
						payoffElem.@value = n.outcome.pay(player).toString();					
						nodeElem.appendChild(payoffElem);
					}
			}
			
			//Add moves
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
				
		//Returns a String with the Hex value of a color in the format: #RRGGBB 
		private function hexStr(color:uint):String
		{
			var h:HexEncoder = new HexEncoder(); 
			var ba:ByteArray = new ByteArray();
			ba.writeUnsignedInt(color);
			h.encode(ba);
			return "#" + h.flush().substring(2);			
		}
	}
}