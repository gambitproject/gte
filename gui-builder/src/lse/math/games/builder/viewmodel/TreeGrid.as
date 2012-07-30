package lse.math.games.builder.viewmodel 
{	
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	
	import lse.math.games.builder.model.ExtensiveForm;
	import lse.math.games.builder.model.Iset;
	import lse.math.games.builder.model.Move;
	import lse.math.games.builder.model.Node;
	import lse.math.games.builder.model.Outcome;
	import lse.math.games.builder.model.Player;
	import lse.math.games.builder.model.StrategicForm;
	import lse.math.games.builder.model.Strategy;
	import lse.math.games.builder.settings.FileSettings;
	import lse.math.games.builder.settings.SCodes;
	import lse.math.games.builder.settings.UserSettings;
	
	import mx.containers.ControlBar;
	
	import util.Log;
	
	/**
	 * Class extending the ExtensiveForm tree model, adding it extra functions
	 * and properties, most of them related to the graphical representation. </p>
	 * 
	 * It contains:
	 * <ul><li>Global graphical settings: Stroke widths, drawing diameters, margins, scale, rotation and distance between levels</li>
	 * <li>Containers for selected items</li>
	 * <li>The following 'special properties': If zeroSum is activated, if normal form is reduced, and the maxPayoff</li>
	 * <li>Functions, apart from getters and setters, to create a TreeGrid, and to find, from
	 * coordinates, nodes and isets<li></ul>
	 * 
	 * @author Mark Egesdal
	 */
	public class TreeGrid extends ExtensiveForm
	{				
		//TODO: Let rotation adjust these margins... or at least account 
		//for the label sizes in the min measurements
		public static const MIN_MARGIN_TOP:Number = 24;
		public static const MIN_MARGIN_BOTTOM:Number = 24;
		public static const MIN_MARGIN_LEFT:Number = 24;
		public static const MIN_MARGIN_RIGHT:Number = 24;
		
		public var scale:Number = 1.0; //Current scale of the canvas. 
									   //Could be changed to somewhere more suitable
		private var _rotate:int = 0;

		private var _mergeBase:Iset = null;
		private var _selectedNodeId:int = -1;
		
		private var _isZeroSum:Boolean = true;
		private var _isStrategicReduced:Boolean = true;
		
		
		private var _matrix:StrategicForm = null;
		private var _isSecondary:Boolean = false; //This must change to true if it is decided 
												  //that MATRIX_MODE will be the one the GUI loads on
		private var _isUpdated:Boolean = false;

		private var fileSettings:FileSettings = FileSettings.instance;
		private var log:Log = Log.instance;
		
		private var settings:UserSettings = UserSettings.instance;
		
		
		public function TreeGrid() 
		{
			defaultTree();
		}
		
		/** Direction of the tree, being 0 root-up, 1 root-left, 2 root-down, 3 root-right */
		public function get rotate():int { return _rotate; }
		public function set rotate(value:int):void
		{
			if(value < 0 || value > 3){
				log.add(Log.ERROR_HIDDEN, "Bad rotation code: "+value);
				_rotate = 0;
			}
			else
				_rotate = value;
		}
		
		/* <--- --- GRAPHIC SETTINGS GETTERS --- ---> */
		
		/** Color of nodes, labels and payoffs of the first player */
		public function get player1Color():uint { return fileSettings.getValue(SCodes.FILE_PLAYER_1_COLOR) as uint; }		
		
		/** Color of nodes, labels and payoffs of the second player */
		public function get player2Color():uint { return fileSettings.getValue(SCodes.FILE_PLAYER_2_COLOR) as uint; }	
		
		//TODO: 3PL Check wherever player1Color was used, and those might all have to be modified to adapt to a 3rd one
		
		/** Font family used as a default for labels in nodes, isets, labels and payoffs */
		public function get fontFamily():String { return fileSettings.getValue(SCodes.FILE_FONT) as String; }
		
		/** Diameter in pixels of node points */
		public function get nodeDiameter():Number  { return fileSettings.getValue(SCodes.FILE_NODE_DIAMETER) as Number;}
		
		/** Diameter in pixels of iset rounded ends */
		public function get isetDiameter():Number { return fileSettings.getValue(SCodes.FILE_ISET_DIAMETER) as Number;}
		
		/** Vertical distance in points/pixels between nodes in two consecutive levels */ 
		public function get leveldistance():int { return fileSettings.getValue(SCodes.FILE_LEVEL_DISTANCE) as int; }
		
		/** Width in points/pixels of lines connecting nodes and lines forming isets */
		public function get strokeWidth():Number { return fileSettings.getValue(SCodes.FILE_STROKE_WIDTH) as Number; }	
		
		/*<--- --- SELECTED THINGS --- ---> */
		
		/** Id corresponding to the selected node. -1 if there is no node currently selected */
		public function get selectedNodeId():int { return _selectedNodeId; }
		public function set selectedNodeId(value:int):void { _selectedNodeId = value; }
		
		/** Iset 'selected' as a base for merging with another. Null if there isn't one selected */
		public function get mergeBase():Iset { return _mergeBase; }
		public function set mergeBase(value:Iset):void { _mergeBase = value; }	
		
		/* <--- --- OTHERS --- ---> */
		
		/** If each pair of payoffs sum 0 (two player only) */
		//TODO: 3PLAYERCHECK 
		public function get isZeroSum():Boolean { return _isZeroSum; }		
		public function set isZeroSum(value:Boolean):void { _isZeroSum = value; }
		
		/** When creating random payoffs, maximum payoff possible to be created */
		public function get maxPayoff():Number { return settings.getValue("SYSTEM_MAX_PAYOFF") as Number; }		
					
		
		/** If the grid is the secondary model. That happens in [MATRIX_MODE] */
		public function set isSecondary(value:Boolean):void { _isSecondary = value; }
		
		/** If the grid is up-to-date with its matrix primary source. Just appliable if this is the secondary source */
		public function get isUpdated():Boolean {
			if(_isSecondary) return _isUpdated;
			else return true;
		}
		public function set isUpdated(value:Boolean):void { _isUpdated = value; }
		
		/** Matrix as a primary source of data for populating the grid, appliable if this is secondary source */
		public function set matrix(value:StrategicForm):void { _matrix = value; }
		
		
		
		/* <--- --- MODEL FUNCTIONS --- ---> */
		
		/** Creates a new tree with two players: 1 and 2, and one node */
		public function defaultTree():void
		{			
			this.newPlayer("1");
			this.newPlayer("2");
			
			this.root = createNode();	
			this.root.makeNonTerminal();
			
			if (settings.getValue("SYSTEM_ENABLE_GUIDANCE")){
				this.root.iset.makeChance();
				addChildTo(this.root.iset,this);
				
			}
			
		}
		
		private function addChildTo(parent:Iset, grid:TreeGrid):void
		{			
			var player:Player = null;
			var lastPlayableNode:Node = parent.firstNode;
			while (true) {
				if (lastPlayableNode.iset.player != Player.CHANCE) {
					player = lastPlayableNode.iset.player.nextPlayer;
					break;
				} else if (lastPlayableNode.parent == null) {
					break;
				}
				lastPlayableNode = lastPlayableNode.parent;
			}
			if (player == null) {
				player = grid.firstPlayer;
			}
			
			
			if (parent.isChildless)
				parent.addMove(player);	
			
			parent.addMove(player);	
		}	
		
		
		// Creates a TreeGridNode with a determinate 'number' (id)
		override protected function newNode(number:int):Node {			
			return new TreeGridNode(this, number);
		}		
		
		/** Makes all the leaves in the tree non-terminal. It isn't needed currently */
		public function leavesNonTerminal():void
		{
			var n:Node = this.root.firstLeaf;
			while (n != null) {				
				n.makeNonTerminal();
				n = n.nextLeaf;
			}
		}
		
		/** Populates the grid using the matrix as a model source */
		public function populateFromMatrix():void
		{
			if(!_isSecondary)
				log.add(Log.ERROR_THROW, "Tried to populate TreeGrid without it being the secondary model.");
			
			if(_matrix!=null)
			{
				clearTree();
				this._firstPlayer = _matrix.firstPlayer;

				this.root = createNode();
				var rootIset:Iset = this.root.makeNonTerminal();

				var leaves:Vector.<Node> = new Vector.<Node>();
				recPopulateNodes(rootIset, _firstPlayer);
				
				_isUpdated = true;
			} else
				log.add(Log.ERROR_THROW, "The matrix primary source has not been set. Couldn't " +
					"populate the tree.");
		}
		
		//Recursive function that creates a new iset from the strategies of one player
		//Useful only when populating the tree from a matrix
		private function recPopulateNodes(parent:Iset, pl:Player):void
		{
			var strategies:Vector.<Strategy> = _matrix.strategies(pl);
						
			if(!pl.isLast)
			{
				var newIset:Iset = parent.newIset(pl.nextPlayer);

				for each(var st:Strategy in strategies)
				{
					var move:Move = parent.addMoveAndAssignChildrenTo(newIset);
					move.label = st.getNameOrSeq();
				}
				
				recPopulateNodes(newIset, pl.nextPlayer);
			} else	{
				for each(st in strategies)
				{
					var finalMove:Move = parent.addMove(pl);
					finalMove.label = st.getNameOrSeq();
				}
				
				populatePayoffs(parent);
			}
		}
		
		//Populates the payoffs from a the matrix's paymatrix into
		//the children of a given iset (which should be the last non
		//singleton Iset in a canonical tree)
		private function populatePayoffs(parent:Iset):void 
		{			
			var payMatrixes:Dictionary = _matrix.payMatrixMap;
			var i:int = 0;
			
			for(var node:Node = parent.firstNode; node!=null; node=node.nextInIset)
			{
				for(var child:Node = node.firstChild; child!=null; child = child.sibling)
				{
					var outcome:Outcome = child.makeTerminal();
					
					for(var pl:Player = _firstPlayer, k:int = 0; k<numPlayers; pl=pl.nextPlayer, k++) {
						outcome.setPay(pl, payMatrixes[pl][getKeyNumber(i)]);
					}
					
					i++;
				}
			}
		}
		
		//Get the key for the payoffs corresponding to the i'th node
		private function getKeyNumber(num:int):String
		{
			var combo:Array = new Array();
			var cumulativeProd:int = 1; //Number of total strategies

			for(var pl:Player = _firstPlayer, i:int = 0; i<numPlayers; i++)
			{
				cumulativeProd *= _matrix.strategies(pl).length;
				pl = pl.nextPlayer;
			}
			
			for(pl = _firstPlayer, i = 0; i<numPlayers; i++)
			{
				var vecStr:Vector.<Strategy> = _matrix.strategies(pl);
				var numSt:int = vecStr.length; 

				cumulativeProd /= numSt;
				
				var strNumber:int = (num / cumulativeProd) % numSt;
				
				combo.push(_matrix.strategies(pl)[strNumber]);
				
				pl = pl.nextPlayer;
			}
						
			return Strategy.key(combo);
		}
		

		
//		/** 
//		 * Rotates clockwise one step the display of the tree
//		 */
//		[Deprecated(replacement="set rotate()")]
//		public function rotateRight():void
//		{
//			_rotate = ((_rotate + 3) % 4);
//		}
//
//		/** 
//		 * Rotates counterclockwise one step the display of the tree
//		 */
//		[Deprecated(replacement="set rotate()")]
//		public function rotateLeft():void
//		{
//			_rotate = ((_rotate + 1) % 4);
//		}		
		
		
		
		/* <--- --- FINDING NODES AND ISET FUNCTIONS --- ---> */
		
		/** 
		 * Looks if the point (x,y) given is inside the bounds of the iset.<br>
		 * If it is, it returns the first node in the iset which is at the same depth level as the click.
		 */ 
		public function getNodeInIsetBeforeCoords(h:Iset, x:Number, y:Number, radius:Number):Node
		{
			//Gets all depths from nodes in the Iset
			var depths:Vector.<int> = new Vector.<int>();
			for (var mate:Node = h.firstNode; mate != null; mate = mate.nextInIset) {
				if (depths.indexOf(mate.depth) < 0) {
					depths.push(mate.depth);
				}
			}
			
			//Checks depth by depth, if the click is in bounds of the nodes in that level
			var node:Node = null;
			while (depths.length > 0 && node == null) {
				node = getNodeInIsetBeforeCoordsAt(h, x, y, radius, depths.pop());
			}
			return node;
		}
		
		/** 
		 * Looks if the point (x,y) given is inside the bounds of the iset, at the depth level given. <br>
		 * If it is, it returns the first node in the iset which is at the same depth level as the click.
		 */
		public function getNodeInIsetBeforeCoordsAt(h:Iset, x:Number, y:Number, radius:Number, depth:int):Node
		{
			var before:TreeGridNode = h.firstNode as TreeGridNode;
			while (before.depth != depth) {
				before = before.nextInIset as TreeGridNode;
				if (before == null) {
					return null; 
				}
			}
						
			while (true) 
			{
				var after:TreeGridNode = before.nextInIsetAt(before.depth) as TreeGridNode;
				if (after == null) {
					//Checks if the point is inside the bounds of the last node (checking it using a square box
					//instead of its real circular representation)
					if ((before.xpos - radius < x)&&
						(x < radius + before.xpos) &&
						(before.ypos - radius < y)&&
						(y < radius + before.ypos))
						return before;
					else
						break;
				}
				var found:Boolean = true;				
				
				// see if it is even in the greater bounding box				
				if (before.ypos > after.ypos) {
					if (y > before.ypos + radius) found = false;
					if (y < after.ypos - radius) found = false;
				} else {
					if (y < before.ypos - radius) found = false;
					if (y > after.ypos + radius) found = false;					
				}
				if (before.xpos > after.xpos) {
					if (x > before.xpos + radius) found = false;
					if (x < after.xpos - radius) found = false;
				} else {
					if (x < before.xpos - radius) found = false;
					if (x > after.xpos + radius) found = false;					
				}
				
				if (found) {
					// refine search		
					// get line before before and after... find slope
					var m:Number = (after.ypos - before.ypos) / (after.xpos - before.xpos);
					// handle common special cases
					if (!isFinite(m)) {
						if (before.ypos > after.ypos) {
							if (y > before.ypos) found = false;
							if (y < after.ypos) found = false;
						} else {
							if (y < before.ypos) found = false;
							if (y > after.ypos) found = false;					
						}
					} else if (m == 0) {
						if (before.xpos > after.xpos) {
							if (x > before.xpos) found = false;
							if (x < after.xpos) found = false;
						} else {
							if (x < before.xpos) found = false;
							if (x > after.xpos) found = false;					
						}
					} else {									
						// get the normal to that line through the click and find intersection point
						var intX:Number = (m * y + x - m * m * before.xpos - m * before.ypos) / (1 + m * m);
						var intY:Number = (m * m * y + m * x + m * before.xpos + before.ypos) / (1 + m * m);						
						
						// see if the length of the click to the line is less than the desired radius
						var deltaX:Number = x - intX;
						var deltaY:Number = y - intY;
						
						if (deltaX * deltaX + deltaY * deltaY > radius * radius) {
							found = false;
						}
					}
				}
				
				if (found) {
					return before;
				}
				before = after;				
			}			
			return null;
		}
		
		/** Searches for a node pertaining to the Iset 'h' in coordinates ('x','y'). If found, returns it, else returns null */
		public function findNodeInIset(h:Iset, x:Number, y:Number):Node
		{
			var node:Node = h.firstNode;
			while(node != null)
			{
				if (coordsInNode(node, x, y)) {
					return node;
				} else {
					node = node.nextInIset;
				}
			}
			return null;
		}
		
		/** Searches for a node in coordinates ('x', 'y'). If found, returns it, else returns null */
		public function findNode(x:Number, y:Number):Node
		{
			return recFindNode(root, x, y);			
		}
		
		//TODO: Improve this using binary search implemented with x coordinate, if possible
		/*
		* Recursive function that looks for a node near the pair of coords ('x', 'y')
		* Stopping criteria: that the current node is near the coordinates
		* Recursive expansion: to all of the node's children
		*
		* @return: the current node, if it is the one we're looking for; the found node coming 
		* from a children return, or null if none of the before apply
		*/
		private function recFindNode(node:Node, x:Number, y:Number):Node
		{
			if (coordsInNode(node, x, y)) {				
				return node;
			}
						
			var rv:Node = null;
			for (var child:Node = node.firstChild; child != null; child = child.sibling)
			{
				rv = recFindNode(child, x, y);
				if (rv != null) {
					break;
				}
			}
			return rv;
		}

		/* 
		 * Checks if the coordinates given correspond to a square 
		 * around each node which has a side of double the node diameter
		 */ 
		private function coordsInNode(node:Node, x:int, y:int):Boolean
		{
			var halfSide:Number = nodeDiameter*scale;
			var n:TreeGridNode = node as TreeGridNode;
			return ((n.xpos - halfSide < x)&&
					(x < halfSide + n.xpos) &&
					(n.ypos - halfSide < y)&&
					(y < halfSide + n.ypos));
		}

		/** Looks for an Iset in the given coords of the canvas, and returns it, or null if there isn't one */
		public function findIset(x:int, y:int):Iset
		{
			var h:Iset = null;
			for (h = this.root.iset; h != null; h = h.nextIset) {
				if (coordsInIset(h, x, y)) {
					break;
				}
			}			
			return h;
		}
		
		/* 
		 * Checks if the coordinates given are within
		 * to the area representing the given Iset
		 */
		private function coordsInIset(h:Iset, x:Number, y:Number):Boolean
		{
			var found:Boolean = true;
			var radius:Number = isetDiameter * scale / 2;			
			var node:Node = getNodeInIsetBeforeCoords(h, x, y, radius);
			
			if (node == null) {
				found = false; // but check the ends...				
				var f:TreeGridNode = h.firstNode as TreeGridNode;
				var l:TreeGridNode = h.lastNode as TreeGridNode;
				if ((Math.abs(f.xpos - x) <= radius &&
					Math.abs(f.ypos - y) <= radius) ||
					(Math.abs(l.xpos - x) <= radius &&
					Math.abs(l.ypos - y) <= radius))
				{
					found = true;
				}
			}			
			return found;
		}
	}
}