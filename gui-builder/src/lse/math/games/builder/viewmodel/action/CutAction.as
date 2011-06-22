package lse.math.games.builder.viewmodel.action 
{
	import lse.math.games.builder.model.Node;
	import lse.math.games.builder.presenter.IAction;
	import lse.math.games.builder.viewmodel.TreeGrid;
	/**	
	 * Divides the iset of selected node into two parts, one on the left ending in the Iset, 
	 * another on the right with the rest of nodes
	 * <li>Changes Data</li>
	 * <li>Changes Size</li>
	 * <li>Changes Display</li>
	 * @author Mark Egesdal
	 */
	public class CutAction implements IAction
	{
		private var _nodeId:int = -1;
		
		public function CutAction(node:Node) 
		{
			if (node != null) _nodeId = node.number;
		}
		
		public function doAction(grid:TreeGrid):void
		{
			var node:Node = grid.getNodeById(_nodeId);
			if (node != null) {
				node.makeLastInIset();				
			}
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