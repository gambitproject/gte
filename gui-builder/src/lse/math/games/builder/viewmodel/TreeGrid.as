package lse.math.games.builder.viewmodel 
{	
	import flash.events.Event;
	import lse.math.games.builder.model.Node;
	import lse.math.games.builder.model.Move;
	import lse.math.games.builder.model.Iset;
	import lse.math.games.builder.model.Outcome;
	import lse.math.games.builder.model.ExtensiveForm;
	import lse.math.games.builder.model.Player;	

	/**
	 * @author Mark Egesdal
	 */
	public class TreeGrid extends ExtensiveForm
	{
		public static const NODE_DIAM:Number = 10;
		public static const ISET_DIAM:Number = 25;
		
		//TODO: Let rotation adjust these margins... or at least account for the label sizes in the min measurements
		public static const MIN_MARGIN_TOP:Number = 24;
		public static const MIN_MARGIN_BOTTOM:Number = 24;
		public static const MIN_MARGIN_LEFT:Number = 24;
		public static const MIN_MARGIN_RIGHT:Number = 24;
		
		private var _rotate:int = 0;
		private var _leveldistance:int;

		private var _mergeBase:Iset = null;
		private var _selectedNodeId:int = -1;
		private var _isZeroSum:Boolean = true;
		private var _isNormalReduced:Boolean = true;
		private var _maxPayoff:Number = 25;
		
		private var _player1Color:uint;
		private var _player2Color:uint;
		
		private var _fontFamily:String;	
		
		private var _linewidth:Number;
		private var _ovallinewidth:Number;		

		
		public function TreeGrid() 
		{
			defaultTree();
			defaultSettings();	
		}
		
		
		public function get rotate():int { return _rotate; }	
		public function get leveldistance():int { return _leveldistance; }
		public function get linewidth():int { return _linewidth; }
		public function get ovallinewidth():int { return _ovallinewidth; }		
		
		public function get selectedNodeId():int { return _selectedNodeId; }
		public function set selectedNodeId(value:int):void { _selectedNodeId = value; }
		
		public function get mergeBase():Iset { return _mergeBase; }
		public function set mergeBase(value:Iset):void { _mergeBase = value; }
		
		public function get player1Color():uint { return _player1Color; }		
		public function set player1Color(value:uint):void { _player1Color = value; }
		
		public function get player2Color():uint { return _player2Color; }		
		public function set player2Color(value:uint):void { _player2Color = value; }
		
		public function get fontFamily():String { return _fontFamily; }		
		public function set fontFamily(value:String):void { _fontFamily = value; }
		
		public function get isZeroSum():Boolean { return _isZeroSum; }		
		public function set isZeroSum(value:Boolean):void { _isZeroSum = value; }
		
		public function get isNormalReduced():Boolean { return _isNormalReduced; }		
		public function set isNormalReduced(value:Boolean):void { _isNormalReduced = value; }
		
		public function get maxPayoff():Number { return _maxPayoff; }		
		public function set maxPayoff(value:Number):void { _maxPayoff = value; }			
		
		public function defaultTree():void
		{			
			this.newPlayer("1");
			this.newPlayer("2");
			
			this.root = createNode();	
			this.root.makeNonTerminal();
		}
		
		override protected function newNode(number:int):Node {			
			return new TreeGridNode(this, number);
		}		
		
		public function leavesNonTerminal():void
		{
			var n:Node = this.root.firstLeaf;
			while (n != null) {				
				n.makeNonTerminal();
				n = n.nextLeaf;
			}
		}

		public function defaultSettings():void
		{
			_rotate = 0;
			_leveldistance = 75;
			_linewidth = 1.0;  // line width for drawing Moves
			_ovallinewidth = 1.0; // line width for drawing Isets	
			
			player1Color = 0xFF0000; // Red
			player2Color = 0x0000FF; // Blue
			
			fontFamily = "Times";
		}
		
		public function rotateRight():void
		{
			_rotate = ((_rotate + 3) % 4);
		}

		public function rotateLeft():void
		{
			_rotate = ((_rotate + 1) % 4);
		}		
		
		public function getNodeInIsetBeforeCoords(h:Iset, x:Number, y:Number, radius:Number):Node
		{
			var depths:Vector.<int> = new Vector.<int>();
			for (var mate:Node = h.firstNode; mate != null; mate = mate.nextInIset) {
				if (depths.indexOf(mate.depth) < 0) {
					depths.push(mate.depth);
				}
			}
			var node:Node = null;
			while (depths.length > 0 && node == null) {
				node = getNodeInIsetBeforeCoordsAt(h, x, y, radius, depths.pop());
			}
			return node;
		}
		
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
		
		public function findNode(x:Number, y:Number):Node
		{
			return recFindNode(root, x, y);			
		}
		
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

		// checks if the coordinates given correspond
		// to a rectangle around each node defined by range
		private function coordsInNode(node:Node, x:int, y:int):Boolean
		{
			var n:TreeGridNode = node as TreeGridNode;
			return ((n.xpos - NODE_DIAM < x)&&
					(x < NODE_DIAM + n.xpos) &&
					(n.ypos - NODE_DIAM < y)&&
					(y < NODE_DIAM + n.ypos));
		}

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
		
		// checks if the coordinates given are within
		// to the area representing the given Iset
		private function coordsInIset(h:Iset, x:Number, y:Number):Boolean
		{
			var found:Boolean = true;
			var radius:Number = TreeGrid.ISET_DIAM / 2;			
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