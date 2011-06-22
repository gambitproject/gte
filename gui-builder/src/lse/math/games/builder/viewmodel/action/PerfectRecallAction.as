package lse.math.games.builder.viewmodel.action 
{
	import lse.math.games.builder.presenter.IAction;
	import lse.math.games.builder.viewmodel.TreeGrid;
	
	/**	
	 * Re-arranges the tree for it to follow the perfect recall principle
	 * <li>Changes Data</li>
	 * <li>Changes Size</li>
	 * <li>Changes Display</li>
	 * @author Mark Egesdal
	 */
	public class PerfectRecallAction implements IAction
	{		
		public function PerfectRecallAction() { }
		
		public function doAction(grid:TreeGrid):void 
		{
			grid.makePerfectRecall();					
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