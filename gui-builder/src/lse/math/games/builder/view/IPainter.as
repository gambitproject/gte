package lse.math.games.builder.view 
{	
	/**
	 * Bridge between tree structure and its graphical representation.
	 * Performs operations necessary to draw everything based in a tree representation model
	 * @author Mark
	 */
	public interface IPainter 
	{
		/** Assigns the graphic 'renderers' for labels by taking them from the part of the model the painter corresponds to */
		function assignLabels():void;
		
		/** Does the necessary measurements to do the graphic operations correctly, according of the number, size and
		 * disposition of the elements in the model */
		function measureCanvas():void;
		
		/** Paints its part of the model ;) */
		function paint(g:IGraphics, width:Number, height:Number):void;
		
		/** Returns an object with all of its corresponding labels (which are normally TextLines) */
		function get labels():Object;
		
		/** Returns the width of its drawing part */
		function get drawWidth():Number;
		
		/** Returns the height of its drawing part */
		function get drawHeight():Number;
				
		//TODO: I believe scale should be removed from painters and just taken from TreeGrid, 
		//as there it is necessary for selecting correctly things
		/** Returns the current scale (modified by the zoom tool) */
		function get scale():Number;
		
		/** Sets the current scale (which affects to the size at which things are being drawn)*/
		function set scale(value:Number):void;
	}	
}