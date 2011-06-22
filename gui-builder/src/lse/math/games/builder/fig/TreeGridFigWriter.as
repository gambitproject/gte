package lse.math.games.builder.fig
{
	import flash.text.engine.FontPosture;	
	import flash.text.engine.FontWeight;	
	import flash.text.engine.TextLine;
	
	import lse.math.games.builder.viewmodel.TreeGrid;	
	import lse.math.games.builder.view.IPainter;	
	
	
	/**	 
	 * Writer of tree grids into FIG format
	 * @author Mark Egesdal
	 */
	public class TreeGridFigWriter
	{				
		public function TreeGridFigWriter() {}
		
		public static const newline:String = "\n"; // Since FIG is mostly used on UNIX I am assuming that \n is the newline character to write regardless of machine
		
		public function set orient(value:String):void { _orient = value; }
		public function set justif(value:String):void { _justif = value; }		
		public function set units(value:String):void { _units = value; }
		public function set psize(value:String):void { _psize = value; }
		public function set magni(value:String):void { _magni = value; }
		public function set mltiPage(value:String):void { _mltiPage = value; }
		public function set tColor(value:String):void { _tColor = value; }
		public function set resolution(value:String):void { _resolution = value; }
		
		//TODO: hook these 2 up to a popup with selections?
		private var _orient:String = "Landscape";
		private var _psize:String = "A4";
		
		//TODO: figure out the right values here
		private var _justif:String = "Center";
		private var _units:String = "Metric";		
		private var _magni:String = "100";
		private var _mltiPage:String = "Single";
		private var _tColor:String = "Default";
		private var _resolution:String = "1200";
		
		/** Returns a String containing, in FIG format, a tree drawn by the 'painter' param */
		public function paintFig(painter:IPainter, width:Number, height:Number, grid:TreeGrid):String
		{  
			var buffer:Vector.<String> = new Vector.<String>();
			//Writes the header of the file
			buffer.push("#FIG 3.2");
			buffer.push(_orient);
			buffer.push(_justif);
			buffer.push(_units);
			buffer.push(_psize);
			buffer.push(_magni);
			buffer.push(_mltiPage);
			buffer.push(_tColor);
			buffer.push(_resolution + " 2");
				
			//Adds the colors that will be used on the file
			var graphics:FigGraphics = new FigGraphics(buffer);
			graphics.addColor(grid.player1Color);
			graphics.addColor(grid.player2Color);
			//graphics.addColor(0x000000);
			
			// TODO: clear any temp state (merge and selected nodes) and restore it after
			//UPdate: It seems that selected nodes automatically deselect when exporting. Same should happen with merging
			
			//Saves onto the file the results of all the painter operations that form the tree
			painter.paint(graphics, width, height);
			
			//Finally also adds all the text labels
			for each (var label:TextLine in painter.labels) {
				if (label.visible) 
				{
					var color:uint = label.textBlock.content.elementFormat.color;
					var fontName:String = label.textBlock.content.elementFormat.fontDescription.fontName;
					var fontWeight:String = label.textBlock.content.elementFormat.fontDescription.fontWeight;
					var fontPosture:String = label.textBlock.content.elementFormat.fontDescription.fontPosture;
					var fontSize:Number = label.textBlock.content.elementFormat.fontSize;
					graphics.color = color;
					graphics.setFont(fontName, fontWeight, fontPosture, fontSize);						
					graphics.drawString(label.x, label.y, label.width, label.height, label.textBlock.content.text);						
				}				
			}
			
			return buffer.join(newline);
		}
	}
}