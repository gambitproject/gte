package lse.math.games.builder.io
{
	import flash.utils.Dictionary;
	
	import lse.math.games.builder.fig.FigFontManager;
	import lse.math.games.builder.model.ExtensiveForm;
	import lse.math.games.builder.model.Iset;
	import lse.math.games.builder.model.Move;
	import lse.math.games.builder.model.Node;
	import lse.math.games.builder.model.NormalForm;
	import lse.math.games.builder.model.Outcome;
	import lse.math.games.builder.model.Player;
	import lse.math.games.builder.model.Rational;
	import lse.math.games.builder.settings.FileSettings;
	import lse.math.games.builder.settings.SCodes;
	import lse.math.games.builder.viewmodel.TreeGrid;
	
	import util.Log;
	
	/**	 
	 * XMLImporter loads trees and matrixes from XML data. <p/>
	 * 
	 * Instructions to use it:
	 * <ol><li>Make an instance of it calling the constructor with the xml you want to read</li>
	 * <li>Check the type of info stored: an Ext Form Tree, a Strat Form Matri, or UNKNOWN (Broken)</li>
	 * <li>Call the corresponding loader</li></ol>
	 * 
	 * @author Mark Egesdal & alfongj
	 */
	//TODO: Do something with gameDescription info
	//TODO: In the future, load node and iset names & maybe? payoffs in non-outcomes
	//TODO #33 loadMatrix
	public class XMLImporter
	{		
		//Types of info contained:
		/** The XML file is not of a known type */
		public const UNKNOWN:int = -1; 
		/** The XML file represents a tree in Extensive Form */
		public const EF:int = 1;
		/** The XML file represents a matrix in Strategic Form */
		public const SF:int = 2;
		
		//File header properties
		private var _version:Number; 
		private var _type:int;
		private var _numPlayers:int;
		private var _displayInfo:Boolean = false; //If the XML contains the <display> tag
		private var _gameDescInfo:Boolean = false; //If the XML contains the <gameDescription> tag
		
		//Objects contained
		private var isets:Dictionary;
		private var isetObjToId:Dictionary;
		private var singletons:Vector.<Iset>;
		private var moves:Dictionary;
		private var players:Dictionary;
		
		private var xml:XML = null;
		private var fileSettings:FileSettings;
		private var tree:ExtensiveForm = null;
		private var matrix:NormalForm = null;
		private var log:Log = Log.instance;
		private var lastIsetIdx:int = 0;

		
		
		/** Stores a reference to the xml to be loaded and analyses the data in it */
		public function XMLImporter(xml:XML)
		{
			this.xml = xml;	
			
			analyseData();
		}
		
		/**
		 * Version number of the XML file being read. <br>
		 * List of versions:
		 * <ul><li> -1 : Undetermined version </li>
		 * <li> 0 : Old tree version (Mark Egesdal's) </li>
		 * <li> 0.1 : First draft of unified XML version (Karen Bletzer's) </li></ul>
		 */ 
		public function get version():Number { return _version; }
		
		/** 
		 * Type of the file being read. It can be: 
		 * <ul><li>'EF': Extensive Form</li>
		 * <li>'SF': Strategic Form</li>
		 * <li>'BROKEN': None of them</li>
		 */
		public function get type():int { return _type; }
		
		/** If the xml file contains any display info (i.e., inside <display> tags) */
		public function get displayInfo():Boolean { return _displayInfo; }
		
		/** If the xml file contains any game description info (i.e., inside <gameDescription> tags) */
		public function get gameDescInfo():Boolean { return _gameDescInfo; }
		
		
		
		//Populates version, type, gameDescInfo and displayInfo properties
		private function analyseData():void {
			//ANALYSE VERSION INFO
			var firstChild:XML = xml[0];
			if(firstChild.name() == "extensiveForm")
			{
				_version = 0;
				log.add(Log.ERROR, "Warning: This file is of an old format. Although gte is still "+
					"capable of opening it, it may not be supported in future versions, so please overwrite "+
					"it now with an updated file by pressing the 'Save' button (Ctrl+S)");
			}
			else if(firstChild.name() == "gte")
			{
				if(xml.@version != undefined)
				{
					var vers:String = xml.@version;
					_version = parseFloat(vers);
					if(_version < 0)
						_version = -1;
				}
			} else _version = -1;
			
			//ANALYSE TYPE, DISPINFO & GAMEDESCRIPTIONINFO
			if(_version == -1)
				_type = UNKNOWN;
			if(_version == 0)
				_type = EF;
			else {
				var ef:Boolean = false;
				var sf:Boolean = false;
				
				for each(var header:XML in firstChild.children())
				{
					var name:String = header.name(); 
					if(name==null)
						log.add(Log.ERROR_THROW, "Corrupt XML file: empty child of <gte>");
					
					if(name == "gameDescription")
						if(header.text().length()>0)
							_gameDescInfo = true;
					if(name == "players")
						_numPlayers = header.child("player").length();
					if(name == "display")
						if(header.child("*").length()>0)
							_displayInfo = true;
					if(name == "extensiveForm")
						ef = true;
					if(name == "strategicForm")
						sf = true;
				}
				
				if(ef){
					_type = EF;
					
					if(sf)
						log.add(Log.ERROR_HIDDEN, "The XML file being loaded contained info for "+
							"both an EF and a SF game. Ignoring the lattest");
				} else {
					if(sf)
						_type = SF;
					else {
						log.add(Log.ERROR, "Corrupt XML file: couldn't find any game information.");
						_type = UNKNOWN;
					}
				}	
			}
		}
				
		/** Loads into a extensive form tree the xml data */
		public function loadTree(tree:ExtensiveForm):ExtensiveForm
		{
			//Clear previous file settings (from another file, possibly)
			fileSettings = FileSettings.instance;
			fileSettings.clear();
			
			lastIsetIdx = 0;
			
			if(_type != EF)
			{
				log.add(Log.ERROR_THROW, "Tried to load a tree from a non-tree game file");
				return null;
			}
			else {		
				if(_displayInfo) //Load settings, if any
				{
					loadSettingsOnTree(tree as TreeGrid);
				}			
								
				this.tree = tree;
				tree.clearTree();
				
				isets = new Dictionary();
				isetObjToId = new Dictionary();
				singletons = new Vector.<Iset>();
				moves = new Dictionary();
				players = new Dictionary();			
				
				loadPlayersOnTree(tree);
				
				//Depending on the version, the tree data will be in a different part
				var childrenList:XMLList;
				if(_version == 0)
					childrenList = xml.children();
				else if(_version == 0.1)
					childrenList = xml.extensiveForm.children();
								
				//Start processing the tree
				for each(var child:XML in childrenList) { 
					if (child.name() == "node") {
						processNode(child, null);
					} else if (child.name() == "outcome") {
						processOutcome(child, null);
					} else {
						log.add(Log.ERROR_HIDDEN, "Ignoring unknown element: " + child);
					}
				}
				
				//Add the found isets to the tree
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
				
				//TODO: 3PL
				while(tree.numPlayers<2)
				{
					tree.newPlayer(""+(tree.numPlayers+1));
				}
				
				return tree;
			}
		}	
		
		//Parses all settings found under the <display> tags and loads them into the tree
		//Mustn't be called if _displayInfo is false
		private function loadSettingsOnTree(tree:TreeGrid):void
		{			
			for each(var child:XML in xml.display.children())
			{
				if (child.name() == "color") {
					var player:XMLList = child.@player;
					if(player!=null)
					{
						if(player.toString()=="1")
						{
							fileSettings.setValue(SCodes.FILE_PLAYER_1_COLOR, getColorFromHexString(child.text()));
						} else if(player.toString()=="2")
							fileSettings.setValue(SCodes.FILE_PLAYER_2_COLOR, getColorFromHexString(child.text()));
					}	
				} else if (child.name() == "font") {
					var fontFamily:String = child.text();
					if(FigFontManager.isFontAvailable(fontFamily))
						fileSettings.setValue(SCodes.FILE_FONT, fontFamily);
				} else if (child.name() == "strokeWidth") {
					var width:int = int(child.text());
					if(width>=1)
						fileSettings.setValue(SCodes.FILE_STROKE_WIDTH, width);
				} else if (child.name() == "nodeDiameter") { 
					var nDiam:Number = Number(child.text());
					if(nDiam>0)
						fileSettings.setValue(SCodes.FILE_NODE_DIAMETER, nDiam);
				} else if (child.name() == "isetDiameter") { 
					var iDiam:Number = Number(child.text());
					if(iDiam>0)
						fileSettings.setValue(SCodes.FILE_ISET_DIAMETER, iDiam);
				} else if (child.name() == "levelDistance") {
					var distance:int = int(child.text());
					if(distance>=1)
						fileSettings.setValue(SCodes.FILE_LEVEL_DISTANCE, distance);				
				} else {
					log.add(Log.ERROR_HIDDEN, "Ignoring unknown settings element: " + child);
				}
			}
		}
		
		//Loads from the header the player information
		private function loadPlayersOnTree(tree:ExtensiveForm):void
		{
			if(_numPlayers == 0)
				log.add(Log.ERROR, "Warning: The tree contained no information about players. " +
					"The loading can have errors");
			else
			{
				for(var i:int = 0; i<_numPlayers; i++)
				{
				 	getPlayer(xml.players.player.(@playerId==""+(i+1))[0]);
				}
			}
		}
				
		/* Parses a node with its move and iset info, adds it to the tree, 
		 * and acts recursively by processing its children nodes and outcomes
		 */
		private function processNode(elem:XML, parentNode:Node):void
		{
			//init
			var node:Node = null;				
			node = tree.createNode();
			
			//assign parent			
			if (parentNode != null) {
				parentNode.addChild(node);
			} else {
				tree.root = node;
			}
			
			// set up the iset data
			processIset(elem, node);
			
			// set up the moves
			processMove(elem, node, parentNode);
			
			for each (var child:XML in elem.children()) {
				if (child.name() == "node") {
					processNode(child, node);
				} else if (child.name() == "outcome") {
					processOutcome(child, node);
				} else if (child.name() == "payoff") {
					log.add(Log.HINT, "The tree contained interior payoffs, which aren't currently "+
						"supported in gte and therefore have been ignored.");
				} else {
					log.add(Log.ERROR_HIDDEN, "Ignoring unknown element: " + child);
				}
			}
		}
		
		/* Parses an outcome, creates it and its wrapping node, and inserts it to its parent */
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
			
			if(elem.child("*").length() == 0)
			{				
				// set up the iset data
				processIset(elem, wrapNode);				
			} else
			{
				var outcome:Outcome = wrapNode.makeTerminal();
				for each (var child:XML in elem.children()) {
					if (child.name() == "payoff") {
						var playerId:String = child.@player;
						
						var payoff:Rational;
						if(child.attribute("value").length()==0)
							payoff = Rational.parse(child[0]);
						else
							payoff = Rational.parse(child.@value);
						
						var player:Player = players[playerId];
						if (player == null) {
							player = new Player(playerId, tree);
							players[playerId] = player;
						}
						outcome.setPay(player, payoff);
					} else {
						log.add(Log.ERROR_HIDDEN, "Ignoring unknown element: " + child);
					}
				}
			}
		}
		
		/* Parses, creates, processes and inserts a move into its node */
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
		
		/* Parses iset and player data from the element's attributes and loads it */
		private function processIset(elem:XML, node:Node):void
		{
			var isetId:String = null;	
			if (elem.@iset != undefined) {
				isetId = elem.@iset;
			}
			
			var iset:Iset = null;
			var player:Player = (elem.@player != undefined) ? getPlayer(elem.@player) : Player.CHANCE;
			if (isetId == null) {								
				iset = new Iset(player);
				iset.idx = lastIsetIdx++; //This idx is different from isetId. It's not useful inside this class
				singletons.push(iset); // root is already taken care of				
			} else {				
				//look it up in the map, if it doesn't exist create it and add it
				iset = isets[isetId];
				if (iset == null) {
					iset = new Iset(player);
					iset.idx = lastIsetIdx++; //This idx is different from isetId. It's not useful inside this class
					isets[isetId] = iset;
					isetObjToId[iset] = isetId;
				} else {
					if (player != Player.CHANCE) {
						if (iset.player != Player.CHANCE && player != iset.player) {
							log.add(Log.ERROR_HIDDEN, "Warning: @player attribute conflicts with earlier iset player assignment.  Ignored.");	
						}
						while (iset.player != player) {
							iset.changePlayer(tree.firstPlayer);
						}
					}
				}				
			}
			iset.insertNode(node);
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
								log.add(Log.ERROR_THROW, "node does not contain an incoming move");
							} else {
								log.add(Log.ERROR_THROW, "Iset " + iset.idx + " is inconsistent for node " + baselineMate.number /*+ " at " + baselineMate.setIdx*/ + " for child " + mateChild.number + " at " + childIdx + " with move " + mateChild.reachedby);
							}
						}						
					}
				}
			}
		}
		
		//Returns in a uint a color from the following hex formats:
		//#RRGGBB, 0xRRGGBB, RRGGBB
		private function getColorFromHexString(hex:String):uint
		{
			if(hex.indexOf("#")==0)
				hex = hex.substr(1);
			
			if(hex.indexOf("0x")!=0)
				hex = "0x"+hex;
			
			return uint(hex);
		}
		
		//Returns a player from a String ID
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
	}
}
