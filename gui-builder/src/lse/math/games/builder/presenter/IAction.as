package lse.math.games.builder.presenter 
{	
	import lse.math.games.builder.viewmodel.TreeGrid;
	
	public interface IAction 
	{
		function doAction(grid:TreeGrid):void;
		
		function get changesData():Boolean;
		function get changesSize():Boolean;
		function get changesDisplay():Boolean;
	}	
}