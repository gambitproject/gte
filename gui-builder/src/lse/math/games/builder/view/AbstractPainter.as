package lse.math.games.builder.view 
{
	import flash.display.DisplayObject;
	import flash.text.engine.DigitWidth;
	import flash.text.engine.ElementFormat;
	import flash.text.engine.FontDescription;
	import flash.text.engine.FontLookup;
	import flash.text.engine.TextBlock;
	import flash.text.engine.TextElement;
	import flash.text.engine.TextLine;
	import flash.text.engine.FontWeight;
	import flash.text.engine.FontPosture;
	import lse.math.games.builder.viewmodel.TreeGrid;
	
	/**
	 * @author Mark Egesdal
	 */
	public class AbstractPainter implements IPainter
	{
		private var _labels:Object = null;
		private var _scale:Number = 1.0;
		
		public function AbstractPainter(self:AbstractPainter) 
		{
			if(self != this)
			{
				//only a subclass can pass a valid reference to self
				throw new Error("Abstract class did not receive reference to self. AbstractPainter cannot be instantiated directly.");
			}			
		}
		
		public function get labels():Object { 
			return _labels; 
		}
		
		public function get drawWidth():Number {
			throw new Error("AbstractPainter does not implement drawWidth()");
		}
		
		public function get drawHeight():Number {
			throw new Error("AbstractPainter does not implement drawHeight()");
		}
		
		public function paint(g:IGraphics, width:Number, height:Number):void
		{
			throw new Error("AbstractPainter does not implement paint()");
		}
		
		public function measureCanvas():void 
		{
			throw new Error("AbstractPainter does not implement measureCanvas()");				
		}
		
		public function assignLabels():void
		{
			throw new Error("AbstractPainter does not implement assignLabels()");
		}
		
		protected function clearLabels():void
		{
			_labels = new Object();
		}
		
		[Bindable]
		public function get scale():Number {
			return _scale;
		}
		
		public function set scale(value:Number):void {
			_scale = value;
		}
		
		protected function moveLabel(label:DisplayObject, x:Number, y:Number):void
		{
			label.x = x ;
			label.y = y ;
		}		
		
		protected function registerLabel(key:String, text:String, color:uint, fontFamily:String, styles:Object):void
		{
			if (text.length > 0) {
				var fontDescription:FontDescription = new FontDescription(fontFamily, styles["fontWeight"], styles["fontStyle"], FontLookup.EMBEDDED_CFF);				
				var format:ElementFormat = new ElementFormat(fontDescription, Number(styles["fontSize"]) * scale, color);
				
				var tb:TextBlock = new TextBlock();
				tb.content = new TextElement(text, format);
				_labels[key] = tb.createTextLine();
			}
		}		
	}
}