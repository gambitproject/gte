package lse.math.games.builder.view 
{	
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.events.MouseEvent;
	import flash.text.engine.ContentElement;
	import flash.text.engine.DigitWidth;
	import flash.text.engine.ElementFormat;
	import flash.text.engine.FontDescription;
	import flash.text.engine.GraphicElement;
	import flash.text.engine.GroupElement;
	import flash.text.engine.TextBlock;
	import flash.text.engine.TextElement;
	import flash.text.engine.TextLine;
	import flash.utils.getTimer;
	
	import mx.controls.Alert;
	
	import mx.core.UIComponent;
	
	/**	 
	 * @author Mark Egesdal
	 */
	public class Canvas extends UIComponent
	{	
		private var _painter:IPainter;
		private var _graphics:IGraphics;		
		
		public function Canvas() 
		{
			super();									
			_graphics = new FlashGraphicsAdapter(this.graphics);
		}
		
		public function set painter(value:IPainter):void {
			_painter = value;
		}
		
		public function get painter():IPainter {
			return _painter;
		}
		
		public function updateLabels():void
		{
			while (this.numChildren > 0) {
				this.removeChildAt(0);
			}
			
			if (_painter != null) {
				_painter.assignLabels();
								
				for each (var label:DisplayObject in _painter.labels) {
					this.addChild(label);
				}
			}			
		}
				
		override protected function commitProperties():void 
		{
			super.commitProperties();			
		}
		
		override protected function measure():void 
		{
			super.measure();
			
			if (_painter != null) {
				_painter.measureCanvas();
				this.measuredMinWidth = _painter.drawWidth;
				this.measuredMinHeight = _painter.drawHeight;
			}
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void 
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);

			this.graphics.clear();
			if (_painter != null) {
				_painter.paint(_graphics, unscaledWidth, unscaledHeight);
			}
		}
	}
}