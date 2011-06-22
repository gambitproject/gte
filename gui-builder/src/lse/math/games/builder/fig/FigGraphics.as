package lse.math.games.builder.fig 
{
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import mx.utils.HexEncoder;
	
	import lse.math.games.builder.view.IGraphics;
	
	/**
	 * Graphic adapter with basic painting operations. It 'paints' in a buffer String with FIG format
	 * @author Mark Egesdal
	 * @see IGraphics parent class IGraphics for reference on the implemented methods
	 */
	public class FigGraphics implements IGraphics
	{
		private static const UNITS_PER_PIXEL:Number = 1200 / 80; //1200 units_per_inch * (1/80) inches_per_pixel = 15 upp
		private static const DASH_LEN:int = 5; //in pixels (1/80 inch)
		
		private var _buffer:Vector.<String>;
		private var _colors:Dictionary;
		private var _numColors:int;
		private var _colorEnum:int; //Current color internal FIG code
		private var _linewidth:Number;
		
		private var _fontEnum:int = -1;
		private var _fontSize:Number;
		private var _curDepth:int = 999;
		
		private static const COLOR_ENUMS:Object = {
			"#000000" : 0, //Black
			"#0000FF" : 1, //Blue
			"#00FF00" : 2, //Green
			"#00FFFF" : 3, //Cyan
			"#FF0000" : 4, //Red
			"#FF00FF" : 5, //Magenta
			"#FFFF00" : 6, //Yellow
			"#FFFFFF" : 7  //White
		};
		
		public function FigGraphics(buffer:Vector.<String>) 
		{
			_buffer = buffer;
			_colors = new Dictionary();
			_numColors = 0;
		}
		
		public function fillRect(x:Number, y:Number, width:Number, height:Number):void
		{
			_buffer.push("2 2 0 " + int(_linewidth) + " " + _colorEnum + " " + _colorEnum + " " + _curDepth + " -1 20 0.000 0 0 -1 0 0 5");
			_buffer.push("\t" + int(x * UNITS_PER_PIXEL) + " " + int(y * UNITS_PER_PIXEL) + " " 
							  + int((x + width) * UNITS_PER_PIXEL) + " " + int(y * UNITS_PER_PIXEL) + " " 
							  + int((x + width) * UNITS_PER_PIXEL) + " " + int((y + height) * UNITS_PER_PIXEL) + " "
							  + int(x * UNITS_PER_PIXEL) + " " + int((y + height) * UNITS_PER_PIXEL) + " "
							  + int(x * UNITS_PER_PIXEL) + " " + int(y * UNITS_PER_PIXEL));	
		}		
		
		public function fillCircle(x:Number, y:Number, radius:Number):void {
			_buffer.push("1 3 0 " + int(_linewidth) + " " + _colorEnum + " " + _colorEnum + " " + _curDepth + " 0 20 0.000 1 0.0000 " 
							+ int(x * UNITS_PER_PIXEL) + " " + int(y * UNITS_PER_PIXEL) + " "
							+ int(radius * UNITS_PER_PIXEL) + " " + int(radius * UNITS_PER_PIXEL) + " " 
							+ int(x * UNITS_PER_PIXEL) + " " + int(y * UNITS_PER_PIXEL) + " "
							+ int(x * UNITS_PER_PIXEL) + " " + int(y * UNITS_PER_PIXEL));
		}

		public function drawLine(x1:Number, y1:Number, x2:Number, y2:Number):void
		{
			drawPolyline(x1, y1, x2, y2, 0);
		}
		
		public function drawDashedLine(x1:Number, y1:Number, x2:Number, y2:Number):void
		{
			drawPolyline(x1, y1, x2, y2, 1);
		}
		
		//Draws a line between two points with a determinate style
		private function drawPolyline(x1:Number, y1:Number, x2:Number, y2:Number, styleEnum:int):void
		{
			_buffer.push("2 1 " + styleEnum + " " + int(_linewidth) + " " + _colorEnum + " " + _colorEnum + " " + _curDepth + " 0 -1 " + DASH_LEN + " 0 0 -1 0 0 2");
			_buffer.push("\t" + int(x1 * UNITS_PER_PIXEL) + " " + int(y1 * UNITS_PER_PIXEL) + " " + int(x2 * UNITS_PER_PIXEL) + " " + int(y2 * UNITS_PER_PIXEL));		
		}

		public function drawRoundRect(x:Number, y:Number, width:Number, height:Number, arcDiam:Number):void
		{
			_buffer.push("2 4 0 " + int(_linewidth) + " " + _colorEnum + " " + _colorEnum + " " + _curDepth + " -1 -1 0.000 0 0 " + int(arcDiam/2) + " 0 0 5");
			_buffer.push("\t" + int(x * UNITS_PER_PIXEL) + " " + int(y * UNITS_PER_PIXEL) + " "
							 + int((x + width) * UNITS_PER_PIXEL) + " " + int(y * UNITS_PER_PIXEL) + " "
							 + int((x + width) * UNITS_PER_PIXEL) + " " + int((y + height) * UNITS_PER_PIXEL) + " "
							 + int(x * UNITS_PER_PIXEL) + " " + int((y + height) * UNITS_PER_PIXEL) + " " 
							 + int(x * UNITS_PER_PIXEL) + " " + int(y * UNITS_PER_PIXEL));
		}
		
		// alignment in fig is to the lower left, but our coords are to upper left, so we adjust y by height
		// the problem is that their coords are to the baseline not the bottom of the text area...
		// This is fixed by using the TextLine class instead of Label class as the Canvas children.
		/** Draws a String starting on coords 'x' 'y' as the upper left corner of the textbox */
		public function drawString(x:Number, y:Number, width:Number, height:Number, str:String):void
		{			
			_buffer.push("4 0 " + _colorEnum + " " + _curDepth + " 0 " + _fontEnum + " " + _fontSize + " 0.000 4 " 
							+ height * UNITS_PER_PIXEL + " " + width * UNITS_PER_PIXEL + " " 
							+ int(x * UNITS_PER_PIXEL) + " " + int(y * UNITS_PER_PIXEL) + " " + str + "\\001");			
		}
	
		public function set stroke(linewidth:Number):void 
		{			
			_linewidth = linewidth;
			if (_linewidth < 1) {
				_linewidth = 1;
			}
		}
		
		/** Sets the font, including its format and size for all the following drawing operations, until it is changed again*/
		public function setFont(name:String, weight:String, posture:String, size:Number):void 
		{							
			_fontEnum = FigFontManager.figEnumValue(name, weight, posture);
			_fontSize = size * (72 / 80); //convert from pixels to points
		}
		
		public function set color(color:uint):void 
		{		
			if (_colors[color] != null) {				
				_colorEnum = _colors[color] as int;
			} else {				
				var colorHex:String = hexStr(color);
				if (COLOR_ENUMS.hasOwnProperty(colorHex)) {
					_colorEnum = COLOR_ENUMS[colorHex];
				} else {
					_colorEnum = -1; //TODO: Should Log an error also.
				}
			}
			if (_curDepth > 0) {
				--_curDepth;
			}
		}
		
		/** Adds a new color to the list of existing ones in the fig. 
		 * If a color wants to be used and is not in the COLOR_ENUM list, it needs to be added first using this function.
		 */
		public function addColor(color:uint):void
		{
			var colorHex:String = hexStr(color);
			if (!COLOR_ENUMS.hasOwnProperty(colorHex) && _colors[color] == null) {				
				var colorEnum:int = 32 + _numColors++;				
				_colors[color] = colorEnum;
				_buffer.push("0 " + colorEnum + " " + colorHex);				
			}			
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