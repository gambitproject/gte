package lse.math.games.builder.viewmodel 
{
	import flash.events.StatusEvent;
	import flash.text.engine.TextLine;
	import flash.text.engine.FontWeight;
	import flash.text.engine.FontPosture;
	import lse.math.games.builder.model.Move;
	import lse.math.games.builder.model.Rational;
	
	import flash.utils.Dictionary;
	
	import lse.math.games.builder.model.NormalForm;
	import lse.math.games.builder.model.Player;
	import lse.math.games.builder.model.Strategy;
	import lse.math.games.builder.view.IGraphics;	
	import lse.math.games.builder.view.AbstractPainter;
	
	/**
	 * @author Mark Egesdal
	 */
	public class MatrixPainter extends AbstractPainter
	{		
		private static const PADDING_VERT:Number = 5;
		private static const PADDING_HORT:Number = 5;		
		
		private var styleOutcome:Dictionary = new Dictionary();
		private var styleStrategy:Dictionary = new Dictionary();
		private var stylePlayer:Dictionary = new Dictionary();
		
		private var _grid:TreeGrid = null;		
				
		private var colWidth:Number;
		private var rowHeight:Number;
		
		private var cornerWidth:Number;
		private var cornerHeight:Number;
		
		private var rowHeaderWidth:Number;
		private var colHeaderHeight:Number;
		
		private var numCols:int;
		private var numRows:int;
		
		private var nf:NormalForm;
		
		public function MatrixPainter() 
		{
			super(this);
			
			styleStrategy["fontWeight"] = FontWeight.BOLD;
			styleStrategy["fontStyle"] = FontPosture.ITALIC;
			styleStrategy["fontSize"] = 15.0;
						
			styleOutcome["fontWeight"] = FontWeight.NORMAL;
			styleOutcome["fontStyle"] = FontPosture.NORMAL;
			styleOutcome["fontSize"] = 15.0;

			stylePlayer["fontWeight"] = FontWeight.BOLD;
			stylePlayer["fontStyle"] = FontPosture.NORMAL;
			stylePlayer["fontSize"] = 20.0;
		}
		
		public function set grid(value:TreeGrid):void {
			_grid = value;
		}
		
		override public function get drawWidth():Number {
			return rowHeaderWidth + colWidth * numCols + this.scale * TreeGrid.MIN_MARGIN_LEFT + this.scale * TreeGrid.MIN_MARGIN_RIGHT;
		}
		
		override public function get drawHeight():Number {
			return colHeaderHeight + rowHeight * numRows + this.scale * TreeGrid.MIN_MARGIN_TOP + this.scale * TreeGrid.MIN_MARGIN_BOTTOM;
		}
		
		override public function measureCanvas():void
		{
			//var nf:NormalForm = new NormalForm(_grid); // expensive to keep creating this...
			
			colWidth = getColWidth(nf);
			rowHeight = getRowHeight(nf);
			
			var angle:Number = Math.atan(rowHeight / colWidth);
			var cornerDiagonal:Number = getCornerDiagonal(nf, angle);
			cornerWidth = cornerDiagonal * Math.cos(angle);
			cornerHeight = cornerDiagonal * Math.sin(angle);
			
			var rows:Vector.<Strategy> = nf.strategies(nf.firstPlayer);		
			rowHeaderWidth = getRowHeaderWidth(rows, cornerWidth);
			
			var cols:Vector.<Strategy> = nf.strategies(nf.firstPlayer.nextPlayer);
			colHeaderHeight = getColHeaderHeight(cols, cornerHeight);
		}
		
		override public function assignLabels():void
		{
			nf = new NormalForm(_grid, _grid.isNormalReduced);
			this.clearLabels();			
			assignLabelsForMatrix(nf, _grid.player1Color, _grid.player2Color, _grid.fontFamily);
		}
		
		override public function paint(g:IGraphics, width:Number, height:Number):void
		{
			//var nf:NormalForm = new NormalForm(_grid); // expensive to keep creating this...
			
			g.color = 0xFFFFFF;
			g.fillRect(0, 0, width, height);
			
			g.color = 0x000000;
			g.stroke = this.scale * _grid.linewidth;
			
			paintMatrix(g, width, height, nf);
		}
		
		private function assignLabelsForMatrix(nf:NormalForm, colorRows:uint, colorCols:uint, fontFamily:String):void 
		{
			var rows:Vector.<Strategy> = nf.strategies(nf.firstPlayer); // could return a vector of strategies?
			var cols:Vector.<Strategy> = nf.strategies(nf.firstPlayer.nextPlayer); // could return a vector of strategies?
			
			numRows = 0;
			for each (var row:Strategy in rows) {				
				this.registerLabel("r" + numRows, row.toString(), colorRows, fontFamily, styleStrategy);				
				++numRows;
			}
			
			numCols = 0;
			for each (var col:Strategy in cols) {				
				this.registerLabel("c" + numCols, col.toString(), colorCols, fontFamily, styleStrategy);
				++numCols;
			}
			
			for (var pl:Player = nf.firstPlayer; pl != null; pl = pl.nextPlayer)
			{
				var color:uint = pl == nf.firstPlayer ? colorRows : colorCols;
				this.registerLabel(getPlayerKey(pl), pl.name, color, fontFamily, stylePlayer);
				var matrix:Object = nf.payMatrixMap[pl];         // could return a matrix, given as input 2 players to intersect								
				for each (row in rows) {					
					for each (col in cols) 
					{												
						var pairKey:String = Strategy.key([row, col]);
						var outcomeText:String = getNumberText(matrix, pairKey);
						this.registerLabel(pl.name + "_" + pairKey, outcomeText, color, fontFamily, styleOutcome);
					}						
				}
			}			
		}
		
		private function getNumberText(map:Object, key:String):String
		{
			var text:String = "?";			
			if (map[key] != undefined) 
			{
				var number:Rational = map[key];
				if (!number.isNaN) {
					text = number.toString();
				}
			}
			return text;
		}
		
		private function paintMatrix(g:IGraphics, width:Number, height:Number, nf:NormalForm):void
		{
			// find the the margins...
			var marginLeft:Number = (width - drawWidth) / 2 + this.scale * TreeGrid.MIN_MARGIN_LEFT;
			var marginTop:Number = (height - drawHeight) / 2 + this.scale * TreeGrid.MIN_MARGIN_TOP;
			
			var rows:Vector.<Strategy> = nf.strategies(nf.firstPlayer);
			var cols:Vector.<Strategy> = nf.strategies(nf.firstPlayer.nextPlayer);
			
			var xpos:Number = marginLeft + rowHeaderWidth;
			var ypos:Number = marginTop + colHeaderHeight;
			for (var j:int = 0; j < cols.length; ++j) 
			{
				var col:Strategy = cols[j];
				if (this.labels["c" + j] != undefined) 
				{
					var colLabel:TextLine = this.labels["c" + j];
					this.moveLabel(colLabel, 
						xpos + colWidth/2 - colLabel.width/2,
						ypos - colLabel.descent);
				}
				
				g.drawLine(xpos, ypos, xpos + colWidth, ypos);
				xpos += colWidth;
			}			
			
			var nplay:int = 0;
			for (var pl:Player = nf.firstPlayer; pl != null; pl = pl.nextPlayer) 
			{
				var diagX:Number = rowHeaderWidth > cornerWidth ? rowHeaderWidth - cornerWidth : 0;
				diagX += marginLeft;
				
				var diagY:Number = colHeaderHeight > cornerHeight ? colHeaderHeight - cornerHeight : 0;
				diagY += marginTop;
				
				g.drawLine(diagX, diagY, diagX + cornerWidth, diagY + cornerHeight);
				
				var plLabel:TextLine = this.labels[getPlayerKey(pl)];
				this.moveLabel(plLabel,
					diagX + (cornerWidth - plLabel.width)* (nplay),				
					diagY + cornerHeight * (1 - nplay) + plLabel.ascent * nplay);
				
				var matrix:Object = nf.payMatrixMap[pl];
				ypos = marginTop + colHeaderHeight;
				
				for (var i:int = 0; i < rows.length; ++i) {
					xpos = marginLeft + rowHeaderWidth;
					if (nplay == 0) {
						if (this.labels["r" + i] != undefined) {
							var rowLabel:TextLine = this.labels["r" + i];
							this.moveLabel(rowLabel,
								xpos - rowLabel.width - rowLabel.descent, //descent is to buffer the same as top
								ypos + rowHeight/2 + rowLabel.ascent/2); 
						}
						g.drawLine(xpos, ypos, xpos, ypos + rowHeight);
					}
					
					var row:Strategy = rows[i];
					for (j = 0; j < cols.length; ++j) {
						col = cols[j];
						
						var pairKey:String = Strategy.key([row, col]);
						var outcomeLabel:TextLine = this.labels[pl.name + "_" + pairKey];
						this.moveLabel(outcomeLabel,							
							xpos + colWidth * nplay - outcomeLabel.width * nplay + this.scale * PADDING_HORT - this.scale * PADDING_HORT * 2 * nplay,
							ypos + outcomeLabel.ascent * nplay + rowHeight - rowHeight * nplay - this.scale * PADDING_VERT + this.scale * PADDING_VERT * 2 * nplay);
						
						g.drawLine(xpos + colWidth, ypos, xpos + colWidth, ypos + rowHeight);
						g.drawLine(xpos, ypos + rowHeight, xpos + colWidth, ypos + rowHeight);
						
						xpos += colWidth;
					}
					ypos += rowHeight;
				}
				++nplay;
			}
		}
		
		private function getColWidth(nf:NormalForm):Number
		{
			var width:Number = 0;
			var rows:Vector.<Strategy> = nf.strategies(nf.firstPlayer);
			var cols:Vector.<Strategy> = nf.strategies(nf.firstPlayer.nextPlayer);
			
			for (var j:int = 0; j < cols.length; ++j) {
				if (this.labels["c" + j] != undefined) {
					var colLabel:TextLine = this.labels["c" + j];
					if (colLabel.width + PADDING_HORT * 2 * scale > width) {
						width = colLabel.width + PADDING_HORT * 2 * scale;
					}
				}
			}
			for (var pl:Player = nf.firstPlayer; pl != null; pl = pl.nextPlayer)
			{
				var matrix:Object = nf.payMatrixMap[pl];				
				for each (var row:Strategy in rows) {					
					for each (var col:Strategy in cols) 
					{						
						var pairKey:String = Strategy.key([row, col]);
						var outcomeLabel:TextLine = this.labels[pl.name + "_" + pairKey];
						
						if (outcomeLabel.width * 2 + this.scale * PADDING_HORT * 3 > width) {
							width = outcomeLabel.width*2 + this.scale * PADDING_HORT * 3;
						}
					}
				}
			}
			return width;
		}
		
		private function getRowHeight(nf:NormalForm):Number
		{
			var height:Number = 0;
			var rows:Vector.<Strategy> = nf.strategies(nf.firstPlayer);
			var cols:Vector.<Strategy> = nf.strategies(nf.firstPlayer.nextPlayer);
			
			for (var i:int = 0; i < rows.length; ++i) {
				if (this.labels["r" + i] != undefined) {
					var rowLabel:TextLine = this.labels["r" + i];
					if (rowLabel.height + this.scale * PADDING_VERT * 2 > height) {
						height = rowLabel.height + this.scale * PADDING_VERT * 2;
					}
				}
			}
			
			for (var pl:Player = nf.firstPlayer; pl != null; pl = pl.nextPlayer) 
			{
				var matrix:Object = nf.payMatrixMap[pl];
				for each (var row:Strategy in rows) {					
					for each (var col:Strategy in cols) 
					{						
						var pairKey:String = Strategy.key([row, col]);
						var outcomeLabel:TextLine = this.labels[pl.name + "_" + pairKey];
						
						if (outcomeLabel.height * 2 + this.scale * PADDING_VERT * 3 > height) {
							height = outcomeLabel.height * 2 + this.scale * PADDING_VERT * 3;
						}
					}					
				}
			}
			return height;
		}
		
		private function getCornerDiagonal(nf:NormalForm, angle:Number):Number
		{
			var maxDiag:Number = 0;			
			for (var pl:Player = nf.firstPlayer; pl != null; pl = pl.nextPlayer) 
			{				
				var plLabel:TextLine = this.labels[getPlayerKey(pl)];
				var diag:Number = plLabel.height / Math.sin(angle) + plLabel.width / Math.cos(angle);
				if (diag > maxDiag) {
					maxDiag = diag;
				}
			}
			return maxDiag;
		}
		
		private function getCornerHeight(players:Vector.<Player>):Number
		{
			var height:Number = 0;
			for each (var pl:Player in players) {
				var plLabel:TextLine = this.labels[getPlayerKey(pl)];
				if (plLabel.width + plLabel.height > height) {
					height = plLabel.width + plLabel.height;
				}
			}
			return height;
		}		
		
		private function getRowHeaderWidth(rows:Vector.<Strategy>, cornerWidth:Number):Number
		{			
			var maxWidth:Number = cornerWidth;			
			for (var i:int = 0; i < rows.length; ++i) {
				if (this.labels["r" + i] != undefined) 
				{
					var rowLabel:TextLine = this.labels["r" + i];
					if (rowLabel.width + rowLabel.descent > maxWidth) {
						maxWidth = rowLabel.width + rowLabel.descent; //descent is just to buffer same as top
					}
				}
			}
			return maxWidth;
		}
		
		private function getColHeaderHeight(cols:Vector.<Strategy>, cornerHeight:Number):Number
		{			
			var maxHeight:Number = cornerHeight;
			for (var j:int = 0; j < cols.length; ++j) {
				if (this.labels["c" + j] != undefined) {
					var colLabel:TextLine = this.labels["c" + j];
					if (colLabel.height > maxHeight) {
						maxHeight = colLabel.height;
					}
				}
			}
			return maxHeight;
		}		
		
		private function getPlayerKey(pl:Player):String
		{
			return "player_" + pl.name;
		}
	}
}