package lse.math.games.builder.view 
{
	
	/**
	 * Graphic adapter with basic painting operations
	 * @author Mark
	 */
	public interface IGraphics 
	{
		/** Draws a filled rectangle being 'x' and 'y' the coords of its top-left corner */
		function fillRect(x:Number, y:Number, width:Number, height:Number):void;
		
		/** Draws a filled circle being 'x' 'y' its center coords */
		function fillCircle(x:Number, y:Number, radius:Number):void;
		
		/** Draws a line between the two points specified */
		function drawLine(x1:Number, y1:Number, x2:Number, y2:Number):void;

		/** Draws a dashed line between the two points specified */
		function drawDashedLine(x1:Number, y1:Number, x2:Number, y2:Number):void;
		
		/** Draws a non-filled rectangle with rounded corners, being 'x' and 'y' 
		 * the coords of its top-left corner and 'arcDiam' the diameter of the circles of its corners
		 */
		function drawRoundRect(x:Number, y:Number, width:Number, height:Number, arcDiam:Number):void;	
		
		/** Sets the width of the stroke for all the following drawing operations, until it is changed again*/
		function set stroke(linewidth:Number):void;
		
		/** Sets the color to be used for all the following drawing operations, until it is changed again*/
		function set color(color:uint):void;
	}
}