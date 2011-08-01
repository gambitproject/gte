package lse.math.games.builder.view 
{	
	import flash.display.Graphics;
	import flash.text.engine.FontWeight;
	import flash.utils.Dictionary;	
	
	/**
	 * @author Mark
	 * Graphic adapter with basic painting operations. It renders in a Flash canvas
	 */
	public class FlashGraphicsAdapter implements IGraphics
	{
		private static const DASH_LEN:Number = 5;
		private static const GAP_LEN:Number = 5; //setting the same to keep consistent with FIG (which only has one value)
		
		private var _graphics:Graphics;
		private var _linewidth:Number;
		private var _color:uint;
				
		public function FlashGraphicsAdapter(graphics:Graphics) 
		{
			_graphics = graphics;
		}
		
		public function fillRect(x:Number, y:Number, width:Number, height:Number):void
		{
			_graphics.lineStyle(_linewidth, _color);
			_graphics.beginFill(_color, 1);
			_graphics.drawRect(x, y, width, height);
			_graphics.endFill();
		}

		public function fillOval(x:Number, y:Number, width:Number, height:Number):void
		{
			_graphics.lineStyle(_linewidth, _color);
			_graphics.beginFill(_color, 1);
			_graphics.drawEllipse(x, y, width, height);
			_graphics.endFill();			
		}
		
		public function fillCircle(x:Number, y:Number, radius:Number):void
		{
			_graphics.lineStyle(_linewidth, _color);
			_graphics.beginFill(_color, 1);
			_graphics.drawCircle(x, y, radius);
			_graphics.endFill();			
		}

		public function drawLine(x1:Number, y1:Number, x2:Number, y2:Number):void
		{
			_graphics.lineStyle(_linewidth, _color);
			_graphics.moveTo(x1, y1);
			_graphics.lineTo(x2, y2);			
		}
		
		public function drawDashedLine(x1:Number, y1:Number, x2:Number, y2:Number):void
		{
			var dist:Number = Math.sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1));
			var numDashGapPairs:int = int((dist) / (DASH_LEN + GAP_LEN));
			var halfRemainder:Number = (dist - numDashGapPairs * (DASH_LEN + GAP_LEN))/2;			
			
			var gapX:Number = (GAP_LEN / dist) * (x2 - x1);
			var gapY:Number = (GAP_LEN / dist) * (y2 - y1);
			var dashX:Number = (DASH_LEN / dist) * (x2 - x1);
			var dashY:Number = (DASH_LEN / dist) * (y2 - y1);
			
			//end is half a dash plus halfRemainder
			var endX:Number = (halfRemainder / dist) * (x2 - x1) + dashX/2; 
			var endY:Number = (halfRemainder / dist) * (y2 - y1) + dashY/2;
			
			//draw first end and first gap
			drawLine(x1, y1, x1 + endX, y1 + endY);		
			x1 += endX + gapX;
			y1 += endY + gapY;
			
			//draw dashGapPairs (gap trails)
			for (var i:int = 0; i < numDashGapPairs - 1; ++i) {
				drawLine(x1, y1, x1 + dashX, y1 + dashY);
				x1 += dashX + gapX;
				y1 += dashY + gapY;
			}
			
			//draw second end
			drawLine(x1, y1, x2, y2);		
		}

		public function drawRoundRect(x:Number, y:Number, width:Number, height:Number, arcDiam:Number):void
		{
			_graphics.lineStyle(_linewidth, _color);
			_graphics.drawRoundRect(x, y, width, height, arcDiam);	
		}		
	
		public function set stroke(linewidth:Number):void
		{
			_linewidth = linewidth;
		}

		public function set color(color:uint):void
		{
			_color = color;			
		}
	}
}