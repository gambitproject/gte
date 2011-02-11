package lse.math.games.builder.view 
{	
	/**
	 * @author Mark
	 */
	public interface IPainter 
	{
		function assignLabels():void;
		function measureCanvas():void;
		function paint(g:IGraphics, width:Number, height:Number):void;
		
		function get labels():Object;		
		function get drawWidth():Number;
		function get drawHeight():Number;
				
		function get scale():Number;
		function set scale(value:Number):void;
	}	
}