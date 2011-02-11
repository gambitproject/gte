package lse.math.games.builder.view 
{	
	/**
	 * @author Mark
	 */
	public class PainterChain implements IPainter
	{
		private var _start:PainterChainLink;
		private var _end:PainterChainLink;
		
		public function PainterChain() {}
		
		public function set links(value:Vector.<IPainter>):void {
			for each (var painter:IPainter in value) 
			{
				var link:PainterChainLink = new PainterChainLink(painter);			
				if (_start == null) {
					_start = link;
				}
				if (_end != null) {
					_end.next = link;
				}
				_end = link;
			}
		}
		
		public function paint(g:IGraphics, width:Number, height:Number):void 
		{			
			for (var link:PainterChainLink = _start; link != null; link = link.next) {
				link.painter.paint(g, width, height);
			}			
		}
		
		public function assignLabels():void 
		{
			for (var link:PainterChainLink = _start; link != null; link = link.next) {
				link.painter.assignLabels();
			}				
		}
		
		public function measureCanvas():void 
		{
			for (var link:PainterChainLink = _start; link != null; link = link.next) {
				link.painter.measureCanvas();
			}				
		}
		
		public function get labels():Object {
			var labels:Object = new Object();
			for (var link:PainterChainLink = _start; link != null; link = link.next) {				
				for (var labelKey:String in link.painter.labels) {
					labels[labelKey] = link.painter.labels[labelKey]
				}
			}
			return labels;
		}
		
		public function get drawWidth():Number {
			var maxWidth:Number = 0;
			for (var link:PainterChainLink = _start; link != null; link = link.next) {
				if (link.painter.drawWidth > maxWidth) {
					maxWidth = link.painter.drawWidth;
				}
			}
			return maxWidth;
		}
		
		public function get drawHeight():Number {
			var maxHeight:Number = 0;
			for (var link:PainterChainLink = _start; link != null; link = link.next) {
				if (link.painter.drawHeight > maxHeight) {
					maxHeight = link.painter.drawHeight;
				}
			}
			return maxHeight;			
		}
		
		[Bindable]
		public function get scale():Number {
			return _start != null ? _start.painter.scale : 1.0;			
		}
		
		public function set scale(value:Number):void {			
			for (var link:PainterChainLink = _start; link != null; link = link.next) {				
				link.painter.scale = value;
			}		
		}
	}
}

import lse.math.games.builder.view.IPainter;
class PainterChainLink
{
	private var _painter:IPainter;
	public var next:PainterChainLink;	
	
	public function PainterChainLink(painter:IPainter)
	{
		_painter = painter;
	}
	
	public function get painter():IPainter {
		return _painter;
	}
}