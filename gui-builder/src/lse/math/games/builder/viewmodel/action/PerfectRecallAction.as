package lse.math.games.builder.viewmodel.action 
{
	import flash.utils.getTimer;
	
	import lse.math.games.builder.presenter.IAction;
	import lse.math.games.builder.viewmodel.AutoLabeller;
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
		private var _timeElapsed:int = 0;
		
		
		
		public function get timeElapsed():int {return _timeElapsed; }
		
		public function PerfectRecallAction() { }
		
		public function doAction(grid:TreeGrid):void 
		{
			var prevTime:int = getTimer();
			
			grid.makePerfectRecall();
			
			var labeler:AutoLabeller = new AutoLabeller;
			labeler.doAction(grid);
			
			grid.orderIds();
			
			_timeElapsed = getTimer() - prevTime;
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