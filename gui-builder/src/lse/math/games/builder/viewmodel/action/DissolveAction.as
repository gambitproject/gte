package lse.math.games.builder.viewmodel.action 
{
	import flash.utils.getTimer;
	
	import lse.math.games.builder.model.Iset;
	import lse.math.games.builder.presenter.IAction;
	import lse.math.games.builder.viewmodel.AutoLabeller;
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

		private var _timeElapsed:int = 0;
		
		
		
		public function get timeElapsed():int {return _timeElapsed; }
		
		public function DissolveAction(iset:Iset) 
		{			
			if (iset != null) _isetId = iset.idx;			
		}
		
		public function doAction(grid:TreeGrid):void
		{			
			var prevTime:int = getTimer();
			
			var iset:Iset = grid.getIsetById(_isetId);
			if (iset != null) {
				iset.dissolve();
				
				var labeler:AutoLabeller = new AutoLabeller;
				labeler.doAction(grid);
			}
			
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