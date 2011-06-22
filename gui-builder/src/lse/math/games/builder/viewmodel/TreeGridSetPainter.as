package lse.math.games.builder.viewmodel 
{
	import flash.text.engine.TextLine;
	import flash.text.engine.FontWeight;
	import flash.text.engine.FontPosture;
	
	import flash.utils.Dictionary;
	
	import lse.math.games.builder.view.IGraphics;
	import lse.math.games.builder.view.AbstractPainter;
	
	import lse.math.games.builder.model.Iset;
	import lse.math.games.builder.model.Node;
	import lse.math.games.builder.model.Outcome;
	import lse.math.games.builder.model.Player;
	
	/**
	 * Painter in charge of ISets
	 * @author Mark Egesdal
	 */
	public class TreeGridSetPainter extends AbstractPainter
	{		
		private var styleIset:Object = new Object();
		
		private var _grid:TreeGrid;
		
		public function TreeGridSetPainter() 
		{
			super(this);
			
			styleIset["fontWeight"] = FontWeight.BOLD;
			styleIset["fontStyle"] = FontPosture.NORMAL;
			styleIset["fontSize"] = 20.0;
		}
		
		public function set grid(value:TreeGrid):void {
			_grid = value;
		}
		
		override public function get drawWidth():Number {
			return 0; // handled by TreeGridPainter
		}
		
		override public function get drawHeight():Number {
			return 0; // handled by TreeGridPainter
		}
		
		override public function assignLabels():void
		{
			this.clearLabels();
			assignLabelsForGrid(_grid);
		}
		
		override public function measureCanvas():void
		{
			return; // handled by TreeGridPainter
		}
		
		override public function paint(g:IGraphics, width:Number, height:Number):void
		{
			g.stroke = this.scale * _grid.ovallinewidth;
			paintGrid(g, width, height, _grid);
		}
		
		private function assignLabelsForGrid(grid:TreeGrid):void
		{			
			var h:Iset = grid.root.iset;
			while (h != null)
			{
				if (h.player != Player.CHANCE) // not chance
				{	
					var color:uint = getSetColor(h, grid);
					registerLabel(getSetLabelKey(h), h.player.name, color, grid.fontFamily, styleIset);
					//registerLabel(getSetLabelKey(h), h.idx.toString(), color, grid.fontFamily, styleIset); //for debugging
				}
				h = h.nextIset;
			}
		}
		
		private function paintGrid(g:IGraphics, width:Number, height:Number, grid:TreeGrid):void
		{
			var h:Iset = grid.root.iset;
			while (h != null) {	
				if (h.player != Player.CHANCE) 
				{
					var label:TextLine = this.labels[getSetLabelKey(h)] as TextLine;				
					if (h.numNodes > 1) // not singleton (includes chance nodes)				
					{
						// group nodes in iset by (1) depth, (2) LtR
						var depthGroups:Dictionary = new Dictionary();
						for (var n:Node = h.firstNode; n != null; n = n.nextInIset) {
							if (depthGroups[n.depth] == undefined) {
								depthGroups[n.depth] = new Vector.<TreeGridNode>();
							}
							depthGroups[n.depth].push(n);
						}				
						
						// for each group draw at the same level as before
						g.color = getSetColor(h, grid);
						var keys:Vector.<int> = new Vector.<int>();
						for (var key:Object in depthGroups) 
						{
							var group:Vector.<TreeGridNode> = depthGroups[key];											
							var first:TreeGridNode = group[0];
							var last:TreeGridNode = group[group.length - 1];
							paintSameDepthGroup(g, first, last);						
							keys.push(key);
						}
						// extract and sort the keys by depth				
						keys.sort(Array.NUMERIC);
						// then draw the links between the levels
						var isLabelPositioned:Boolean = false;						
						while (true) 
						{
							var top:Vector.<TreeGridNode> = depthGroups[keys.shift()];
							
							// if top has len > 1, draw label here
							if (top.length > 1 && !isLabelPositioned) {
								positionGroupSetLabel(top[0], top[(top.length % 2 == 1) ? top.length - 2 : top.length - 1], grid, label);
								isLabelPositioned = true;
							}
							
							if (keys.length == 0) {
								break;
							}
							
							// find the intersection of the span between two levels
							var bottom:Vector.<TreeGridNode> = depthGroups[keys[0]];
							paintGroupConnectingLine(g, grid, top, bottom);
						}
						
						// else draw at the top of the first group
						if (!isLabelPositioned) {
							positionSingletonSetLabel(h, grid, label, this.scale * TreeGrid.ISET_DIAM/2);
						}
					} else {
						positionSingletonSetLabel(h, grid, label, this.scale * TreeGrid.NODE_DIAM/2);
					}
				}
				h = h.nextIset;
			}
		}
		
		/*private function positionSetLabel(h:Iset, grid:TreeGrid):void
		{
			if (h.player != Player.CHANCE) {
				var label:TextLine = grid.labels[getSetLabelKey(h)] as TextLine;
				if (h.numNodes > 1) {
					positionGroupSetLabel(h, grid, label);
				} else {
					positionSingletonSetLabel(h, grid, label);
				}
			}
		}*/
		
		private function positionGroupSetLabel(first:TreeGridNode, last:TreeGridNode, grid:TreeGrid, label:TextLine):void
		{			
			var x:Number, y:Number;
			if (grid.rotate == 0 || grid.rotate == 2) {
				x = first.xpos != last.xpos ? (first.xpos + last.xpos) / 2 - label.width / 2 : first.xpos + this.scale * TreeGrid.ISET_DIAM;
				y = first.ypos + label.ascent / 2;						
			} else {
				x = first.xpos - label.width / 2;
				y = first.ypos != last.ypos ? (first.ypos + last.ypos) / 2 + label.ascent / 2 : first.ypos + this.scale * TreeGrid.ISET_DIAM;
			}
			this.moveLabel(label, x, y);
		}
						
		private function positionSingletonSetLabel(h:Iset, grid:TreeGrid, label:TextLine, radius:Number):void
		{
			var node:TreeGridNode = h.firstNode as TreeGridNode;
			var parent:TreeGridNode = node.parent as TreeGridNode;						
			var adjust:Number = (radius + 1) * 0.708; // 0.708 ~= sqrt(2)/2 (rounded up)
			
			var x:Number =
				(grid.rotate == 0 && parent == null)
				|| ((grid.rotate == 0 || grid.rotate == 2) && parent != null && parent.xpos < node.xpos)
				|| grid.rotate == 3
			? x = node.xpos + adjust
			: x = node.xpos - label.width - adjust;
			
			var y:Number;
			if ((grid.rotate == 1 && parent == null) || 
				((grid.rotate == 1 || grid.rotate == 3) && parent != null && parent.ypos > node.ypos) ||
				grid.rotate == 0) 
			{
				y = node.ypos /*- label.descent*/ - adjust;
			} else {
				y = node.ypos + label.ascent + adjust;
			}
			this.moveLabel(label, x, y);
		}
		
		private function paintGroupConnectingLine(g:IGraphics, grid:TreeGrid, top:Vector.<TreeGridNode>, bottom:Vector.<TreeGridNode>):void
		{
			var intersectionLeft:Number, intersectionRight:Number;
						
			if (grid.rotate == 0 || grid.rotate == 2) {
				intersectionLeft = top[0].xpos > bottom[0].xpos ? top[0].xpos : bottom[0].xpos;
				intersectionRight = top[top.length - 1].xpos > bottom[bottom.length - 1].xpos ?
					bottom[bottom.length - 1].xpos : top[top.length - 1].xpos;
			} else {
				intersectionLeft = top[0].ypos > bottom[0].ypos ? top[0].ypos : bottom[0].ypos;
				intersectionRight = top[top.length - 1].ypos > bottom[bottom.length - 1].ypos ?
					bottom[bottom.length - 1].ypos : top[top.length - 1].ypos;
			}
			//trace("left " + int(intersectionLeft) + " right " + int(intersectionRight));
			
			// if there exists an intersection draw a vertical line between the two levels as the midpoint of the intersection
			// if not draw from upper side edge to lower top edge (to try to avoid collisions with child lines)
			// drawn from the edge of the radius of the node or iset (not middle of node as with child lines)						
			var startX:Number, startY:Number, endX:Number, endY:Number;
			if (intersectionRight >= intersectionLeft) {
				var mid:Number = (intersectionRight + intersectionLeft) / 2;
				if (grid.rotate == 0 || grid.rotate == 2) {
					startX = mid;
					startY = top[0].ypos + (grid.rotate == 0 ? this.scale * TreeGrid.ISET_DIAM / 2 : - this.scale * TreeGrid.ISET_DIAM / 2);
					endX = mid;
					endY = bottom[0].ypos + (grid.rotate == 2 ? this.scale * TreeGrid.ISET_DIAM / 2 : - this.scale * TreeGrid.ISET_DIAM / 2);
				} else {
					startY = mid;
					startX = top[0].xpos + (grid.rotate == 1 ? this.scale * TreeGrid.ISET_DIAM / 2 : - this.scale * TreeGrid.ISET_DIAM / 2);
					endY = mid;
					endX = bottom[0].xpos + (grid.rotate == 3 ? this.scale * TreeGrid.ISET_DIAM / 2 : - this.scale * TreeGrid.ISET_DIAM / 2);
				}
			} else {
				// we go node to node
				// pick which edge
				if (top[0].xpos > bottom[bottom.length - 1].xpos) {
					// left edge top to right edge bottom
					startX = top[0].xpos;
					endX = bottom[bottom.length - 1].xpos;
				} else {
					// right edge top to left edge bottom
					startX = top[top.length - 1].xpos;
					endX = bottom[0].xpos;
				}

				if (top[0].ypos > bottom[bottom.length - 1].ypos) {
					// left edge top to right edge bottom
					startY = top[0].ypos;
					endY = bottom[bottom.length - 1].ypos;
				} else {
					// right edge top to left edge bottom
					startY = top[top.length - 1].ypos;
					endY = bottom[0].ypos;
				}

				var slope:Number = (endY - startY) / (endX - startX);
				var angle:Number = Math.atan(slope);
				var deltaX:Number = Math.cos(angle) * this.scale * TreeGrid.ISET_DIAM / 2;				
				var deltaY:Number = Math.sin(angle) * this.scale * TreeGrid.ISET_DIAM / 2;
				//trace("angle " + int(angle/Math.PI * 180) + " deltaX " + int(deltaX) + " deltaY " + int(deltaY) + " startX " + int(startX) + " startY " + int(startY) + " endX " + int(endX) + " endY " + int(endY));
				
				if (endX < startX) {	// quadrant 2 & 3				
					deltaY = -deltaY;
					deltaX = -deltaX;
				}				
								
				startX += deltaX;
				endX -= deltaX;
				startY += deltaY;
				endY -= deltaY;
			}			
			g.drawDashedLine(startX, startY, endX, endY);
		}
		
		private function paintSameDepthGroup(g:IGraphics, first:TreeGridNode, last:TreeGridNode):void
		{
			var x:Number = (first.xpos < last.xpos ? first.xpos : last.xpos) - this.scale * TreeGrid.ISET_DIAM / 2;
			var y:Number = (first.ypos < last.ypos ? first.ypos : last.ypos) - this.scale * TreeGrid.ISET_DIAM / 2;
			var width:Number = Math.abs(last.xpos - first.xpos) + this.scale * TreeGrid.ISET_DIAM;
			var height:Number = Math.abs(last.ypos - first.ypos) + this.scale * TreeGrid.ISET_DIAM;					

			g.drawRoundRect(x, y, width, height, this.scale * TreeGrid.ISET_DIAM);
		}
		
		private function getSetColor(h:Iset, grid:TreeGrid):uint
		{
			var color:uint = h.player == Player.CHANCE ? 0x000000 : (grid.firstPlayer == h.player ? grid.player1Color : grid.player2Color);			
			if (h == grid.mergeBase) { 
				color ^= 0xFFFFFF; // complement
				color &= 0x7FFF7F; // not too bright, and greenish
			}			
			return color;
		}
		
		private function getSetLabelKey(h:Iset):String
		{
			return "iset_" + h.idx;
		}
	}
}