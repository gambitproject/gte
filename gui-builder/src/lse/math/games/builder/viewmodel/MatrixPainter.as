package lse.math.games.builder.viewmodel 
{
	import flash.text.engine.FontPosture;
	import flash.text.engine.FontWeight;
	import flash.text.engine.TextLine;
	import flash.utils.Dictionary;
	
	import lse.math.games.builder.model.Player;
	import lse.math.games.builder.model.Rational;
	import lse.math.games.builder.model.StrategicForm;
	import lse.math.games.builder.model.Strategy;
	import lse.math.games.builder.settings.FileSettings;
	import lse.math.games.builder.settings.UserSettings;
	import lse.math.games.builder.settings.SCodes;
	import lse.math.games.builder.view.AbstractPainter;
	import lse.math.games.builder.view.IGraphics;
	
	import util.Log;
	import mx.controls.Alert;
	
	/**
	 * @author Mark Egesdal
	 */
	//TODO: 3PL Adapt all the painter to a new way to display everything, maybe using an intermediate
	//bimatrix class, and drawing here all the bimatrixes inside one canvas
	public class MatrixPainter extends AbstractPainter
	{				
		private var styleOutcome:Dictionary = new Dictionary();
		private var styleStrategy:Dictionary = new Dictionary();
		private var stylePlayer:Dictionary = new Dictionary();
						
		private var colWidth:Number;
		private var rowHeight:Number;
		
		private var cornerWidth:Number;
		private var cornerHeight:Number;
		
		private var rowHeaderWidth:Number;
		private var colHeaderHeight:Number;
		
		private var numCols:int;
		private var numRows:int;
		
		private var _matrix:StrategicForm = null; 
		
		private var fileSettings:FileSettings = FileSettings.instance;
		private var glbSettings:UserSettings = UserSettings.instance;
		
		private var log:Log = Log.instance;
		
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
		
		public function set matrix(value:StrategicForm):void {
			_matrix = value;
		}
		
		override public function get drawWidth():Number {
			return rowHeaderWidth + colWidth * numCols + this.scale * TreeGrid.MIN_MARGIN_LEFT + this.scale * TreeGrid.MIN_MARGIN_RIGHT;
		}
		
		override public function get drawHeight():Number {
			return colHeaderHeight + rowHeight * numRows + this.scale * TreeGrid.MIN_MARGIN_TOP + this.scale * TreeGrid.MIN_MARGIN_BOTTOM;
		}
		
		/* <--- --- GRAPHIC SETTINGS GETTERS --- ---> */
		
		/* Color of nodes, labels and payoffs of the first player */
		private function get player1Color():uint { return fileSettings.getValue(SCodes.FILE_PLAYER_1_COLOR) as uint; }		
		
		/* Color of nodes, labels and payoffs of the second player */
		private function get player2Color():uint { return fileSettings.getValue(SCodes.FILE_PLAYER_2_COLOR) as uint; }	
				
		/* Font family used as a default for labels in nodes, isets, labels and payoffs */
		private function get fontFamily():String { return fileSettings.getValue(SCodes.FILE_FONT) as String; }
		
		/* Vertical cell padding */
		private function get vertPadding():Number { return fileSettings.getValue(SCodes.FILE_CELL_PADDING_VERT) as Number;}
		
		/* Horizontal cell padding */
		private function get horPadding():Number { return fileSettings.getValue(SCodes.FILE_CELL_PADDING_HOR) as Number;}

		/* Width in points/pixels of lines connecting nodes and lines forming isets */
		private function get strokeWidth():Number { return fileSettings.getValue(SCodes.FILE_STROKE_WIDTH) as Number; }	
		
		
		
		
		
		override public function measureCanvas():void
		{		
			colWidth = getColWidth();
			rowHeight = getRowHeight();
			log.add(Log.ERROR_HIDDEN, String(colWidth), "Settings");
			log.add(Log.ERROR_HIDDEN, String(rowHeight), "Settings");
			
			//Set width and height of each cell in the strategic form matrix to be equal			
			if (colWidth>rowHeight)
				rowHeight=colWidth;
			else if (colWidth<rowHeight)
				colWidth=rowHeight;
			//By default the remaining width and height of each cell from the point of view of the
			//label of each player is double. Assume the payoff label for play 1 has a width of
			//30. Than the total length of the cell is 60. Now it is adjustedt by 2/3 and is only 45.
			//For large number like 123123 the width of the cell does not fit optical to the height of the row
			
			colWidth=int(colWidth/3*2);
			rowHeight=int(rowHeight/3*2);
			
			
			var angle:Number = Math.atan(rowHeight / colWidth);
			var cornerDiagonal:Number = getCornerDiagonal(angle);
			cornerWidth = cornerDiagonal * Math.cos(angle);
			cornerHeight = cornerDiagonal * Math.sin(angle);
			
			var rows:Vector.<Strategy> = _matrix.strategies(_matrix.firstPlayer);		
			rowHeaderWidth = getRowHeaderWidth(rows, cornerWidth);
			
			var cols:Vector.<Strategy> = _matrix.strategies(_matrix.firstPlayer.nextPlayer);
			colHeaderHeight = getColHeaderHeight(cols, cornerHeight);
		}
		
		override public function assignLabels():void
		{
			if(!_matrix.isUpdated)
				_matrix.populateFromTree();
			
			this.clearLabels();	
			assignLabelsForMatrix();
		}
		
		override public function paint(g:IGraphics, width:Number, height:Number):void
		{			
			if(!_matrix.isUpdated)
				_matrix.populateFromTree();
			
			g.color = 0xFFFFFF;
			g.fillRect(0, 0, width, height);
			
			g.color = 0x000000;
			g.stroke = this.scale * strokeWidth;
			
			paintMatrix(g, width, height);
		}
		
		private function assignLabelsForMatrix():void 
		{
			var colorRows:uint = player1Color;
			var rows:Vector.<Strategy> = _matrix.strategies(_matrix.firstPlayer); // could return a vector of strategies?
			var colorCols:uint = player2Color;
			var cols:Vector.<Strategy> = _matrix.strategies(_matrix.firstPlayer.nextPlayer); // could return a vector of strategies?
			
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
			
			for (var pl:Player = _matrix.firstPlayer; pl != null; pl = pl.nextPlayer)
			{
				var color:uint = pl == _matrix.firstPlayer ? colorRows : colorCols;
				this.registerLabel(getPlayerKey(pl), pl.name, color, fontFamily, stylePlayer);
				var matrix:Object = _matrix.payMatrixMap[pl];         // could return a matrix, given as input 2 players to intersect								
				for each (row in rows) {					
					for each (col in cols) 
					{												
						var pairKey:String = Strategy.key([row, col]);
						var outcomeText:String = getNumberText(matrix, pairKey);
						
						
						if (glbSettings.getValue("SYSTEM_DECIMAL_LAYOUT")){
							var dp:int=glbSettings.getValue("SYSTEM_DECIMAL_PLACES") as int;
							outcomeText=String(roundTodecimal(Rational.parse(outcomeText).floatValue,dp));
						}	
						this.registerLabel(pl.name + "_" + pairKey, outcomeText, color, fontFamily, styleOutcome);
					}						
				}
			}			
		}
		
		private function roundTodecimal(n:Number, p:int = 0):Number
		{
			var dp:Number = Math.pow(10, p);
			return Math.round(dp * n) / dp;
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
		
		private function paintMatrix(g:IGraphics, width:Number, height:Number):void
		{
			// find the the margins...
			var marginLeft:Number = (width - drawWidth) / 2 + this.scale * TreeGrid.MIN_MARGIN_LEFT;
			var marginTop:Number = (height - drawHeight) / 2 + this.scale * TreeGrid.MIN_MARGIN_TOP;
			
			var rows:Vector.<Strategy> = _matrix.strategies(_matrix.firstPlayer);
			var cols:Vector.<Strategy> = _matrix.strategies(_matrix.firstPlayer.nextPlayer);
			
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
			for (var pl:Player = _matrix.firstPlayer; pl != null; pl = pl.nextPlayer) 
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
				
				var matrix:Object = _matrix.payMatrixMap[pl];
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
							xpos + colWidth * nplay - outcomeLabel.width * nplay + this.scale * horPadding - this.scale * horPadding * 2 * nplay,
							ypos + outcomeLabel.ascent * nplay + rowHeight - rowHeight * nplay - this.scale * vertPadding + this.scale * vertPadding * 2 * nplay);
						
						g.drawLine(xpos + colWidth, ypos, xpos + colWidth, ypos + rowHeight);
						g.drawLine(xpos, ypos + rowHeight, xpos + colWidth, ypos + rowHeight);
						
						xpos += colWidth;
					}
					ypos += rowHeight;
				}
				++nplay;
			}
		}
		
		private function getColWidth():Number
		{
			var width:Number = 0;
			var rows:Vector.<Strategy> = _matrix.strategies(_matrix.firstPlayer);
			var cols:Vector.<Strategy> = _matrix.strategies(_matrix.firstPlayer.nextPlayer);
			
			//Updated the width scale from 2 to 2.5 to have more space between the player payoffs
			for (var j:int = 0; j < cols.length; ++j) {
				if (this.labels["c" + j] != undefined) {
					var colLabel:TextLine = this.labels["c" + j];
					if (colLabel.width + horPadding * 2.5 * scale > width) {
						width = colLabel.width + horPadding * 2.5 * scale;
					}
				}
			}
			for (var pl:Player = _matrix.firstPlayer; pl != null; pl = pl.nextPlayer)
			{
				var matrix:Object = _matrix.payMatrixMap[pl];				
				for each (var row:Strategy in rows) {					
					for each (var col:Strategy in cols) 
					{						
						var pairKey:String = Strategy.key([row, col]);
						var outcomeLabel:TextLine = this.labels[pl.name + "_" + pairKey];
						
						if (outcomeLabel.width * 2.5 + this.scale * horPadding * 3 > width) {
							width = outcomeLabel.width*2.5 + this.scale * horPadding * 3;
						}
					}
				}
			}
			return width;
		}
		
		private function getRowHeight():Number
		{
			var height:Number = 0;
			var rows:Vector.<Strategy> = _matrix.strategies(_matrix.firstPlayer);
			var cols:Vector.<Strategy> = _matrix.strategies(_matrix.firstPlayer.nextPlayer);
			
			//Updated the height scale from 2 to 2.5 to have more space between the player payoffs
			
			for (var i:int = 0; i < rows.length; ++i) {
				if (this.labels["r" + i] != undefined) {
					var rowLabel:TextLine = this.labels["r" + i];
					if (rowLabel.height + this.scale * vertPadding * 2.5 > height) {
						height = rowLabel.height + this.scale * vertPadding * 2.5;
					}
				}
			}
			
			for (var pl:Player = _matrix.firstPlayer; pl != null; pl = pl.nextPlayer) 
			{
				var matrix:Object = _matrix.payMatrixMap[pl];
				for each (var row:Strategy in rows) {					
					for each (var col:Strategy in cols) 
					{						
						var pairKey:String = Strategy.key([row, col]);
						var outcomeLabel:TextLine = this.labels[pl.name + "_" + pairKey];
						
						if (outcomeLabel.height * 2.5 + this.scale * vertPadding * 3 > height) {
							height = outcomeLabel.height * 2.5 + this.scale * vertPadding * 3;
						}
					}					
				}
			}
			return height;
		}
		
		private function getCornerDiagonal(angle:Number):Number
		{
			var maxDiag:Number = 0;			
			for (var pl:Player = _matrix.firstPlayer; pl != null; pl = pl.nextPlayer) 
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
		
		private function getPlayerKey(pl:Player):String	{
			return "player_" + pl.name;
		}
	}
}