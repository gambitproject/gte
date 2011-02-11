package lse.math.games.builder.viewmodel.action 
{
	import lse.math.games.builder.model.Iset;
	import lse.math.games.builder.model.Node;
	import lse.math.games.builder.presenter.IAction;
	import lse.math.games.builder.viewmodel.TreeGrid;
	
	/**	 
	 * @author Mark Egesdal
	 */
	public class ChangePlayerAction implements IAction
	{
		private var _isetId:int = -1;		
		private var _nodeId:int = -1;		
		
		
		public function ChangePlayerAction(iset:Iset, node:Node) 
		{
			if (iset != null) _isetId = iset.idx;
			if (node != null) _nodeId = node.number;
		}
		
		
		public function doAction(grid:TreeGrid):void
		{			
			var iset:Iset = grid.getIsetById(_isetId);
			if (iset == null) {
				var node:Node = grid.getNodeById(_nodeId);
				if (node != null) {
					iset = node.makeNonTerminal();
				}
			} else {
				iset.changeplayer();						
			}
		}
		
		public function get changesData():Boolean {
			return true;
		}
		
		public function get changesSize():Boolean {
			return false;
		}
		
		public function get changesDisplay():Boolean {
			return true;
		}		
	}
}