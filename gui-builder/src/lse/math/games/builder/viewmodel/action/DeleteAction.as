package lse.math.games.builder.viewmodel.action 
{
	import lse.math.games.builder.model.Node;
	import lse.math.games.builder.presenter.IAction;
	import lse.math.games.builder.viewmodel.TreeGrid;
	
	/**
	 * @author Mark Egesdal
	 */
	public class DeleteAction implements IAction
	{			
		private var _nodeId:int = -1;

		public function DeleteAction(node:Node) 
		{
			if (node != null) _nodeId = node.number;
		}
		
		public function doAction(grid:TreeGrid):void
		{
			var node:Node = grid.getNodeById(_nodeId);
			if (node != null) {
				node.remove();
			}				
		}
		
		public function get undoable():Boolean {
			return true;
		}
		
		public function get changesData():Boolean {
			return true;
		}
		
		public function get changesSize():Boolean {
			return true;
		}
		
		public function get changesDisplay():Boolean {
			return true;
		}		
	}
}