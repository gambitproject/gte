package lse.math.games.builder.view 
{
	
	/**
	 * @author Mark
	 */
	public interface IGraphics 
	{
		function fillRect(x:Number, y:Number, width:Number, height:Number):void;		
		function fillCircle(x:Number, y:Number, radius:Number):void;
		function drawLine(x1:Number, y1:Number, x2:Number, y2:Number):void;
		function drawDashedLine(x1:Number, y1:Number, x2:Number, y2:Number):void;
		function drawRoundRect(x:Number, y:Number, width:Number, height:Number, arcDiam:Number):void;	
		function set stroke(linewidth:Number):void;
		function set color(color:uint):void;
	}
}