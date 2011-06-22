package lse.math.games.builder.viewmodel.action 
{
	import lse.math.games.builder.model.Iset;
	import lse.math.games.builder.presenter.IAction;
	import lse.math.games.builder.viewmodel.TreeGrid;
	
	/**	
	 * Dissolves selected Iset
	 * <li>Changes Data</li>
	 * <li>Changes Size</li>
	 * <li>Changes Display</li>
	 * @author Mark Egesdal
	 */
	public class DissolveAction implements IAction
	{		
		private var _isetId:int = -1;		

		public function DissolveAction(iset:Iset) 
		{			
			if (iset != null) _isetId = iset.idx;			
		}
		
		public function doAction(grid:TreeGrid):void
		{			
			var iset:Iset = grid.getIsetById(_isetId);
			if (iset != null) {
				iset.dissolve();				
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