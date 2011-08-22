package lse.math.games.builder.presenter 
{	
	import lse.math.games.builder.viewmodel.TreeGrid;
	
	/**
	 * Represents an Action that changes something in the tree or any of its nodes
	 * i.e., Adding a child, or even rotating the tree changes things, so they're actions. Zooming in
	 * or saving aren't actions.
	 * @author Mark
	 */
	public interface IAction 
	{
		/** Execute the action over the game model*/
		function doAction(grid:TreeGrid):void;
		
		/** Check if the action changes any data*/
		function get changesData():Boolean;
		/** Check if the action potentially changes size of something in screen*/
		function get changesSize():Boolean;
		/** Check if the action potentially modifies something that needs to display again*/
		function get changesDisplay():Boolean;
		/** Time elapsed when running the action */
		function get timeElapsed():int;
	}	
}