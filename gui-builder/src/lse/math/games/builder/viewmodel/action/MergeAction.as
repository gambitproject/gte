package lse.math.games.builder.viewmodel.action
{
	import lse.math.games.builder.model.Iset;
	import lse.math.games.builder.presenter.IAction;
	import lse.math.games.builder.viewmodel.TreeGrid;
	
	/**	
	 * @author Mark
	 */
	public class MergeAction implements IAction
	{				
		private var _mergeId:int = -1;
		private var _baseId:int = -1;		
		
		private var _onMerge:IAction;
		
		public function MergeAction(grid:TreeGrid, toMerge:Iset) 
		{			
			if (toMerge != null) _mergeId = toMerge.idx;
			if (grid.mergeBase != null) {
				_baseId = grid.mergeBase.idx;			
				if (!grid.mergeBase.canMergeWith(toMerge)) {
					_mergeId = -1;
				}
			}
		}
		
		public function set onMerge(value:IAction):void {
			_onMerge = value;
		}
		
		public function doAction(grid:TreeGrid):void 
		{
			var toMerge:Iset = grid.getIsetById(_mergeId);
			if (toMerge != null) 
			{
				var base:Iset = grid.getIsetById(_baseId);
				if (base == null) {
					grid.mergeBase = toMerge;
				} else {					
					base.merge(toMerge);
					_onMerge.doAction(grid);					
					grid.mergeBase = null;					
				}
			} else {
				grid.mergeBase = null;	
			}			
		}
		
		public function get changesData():Boolean {
			return _baseId >= 0 && _mergeId >= 0;
		}
		
		public function get changesSize():Boolean {
			return _baseId >= 0 && _mergeId >= 0;
		}
		
		public function get changesDisplay():Boolean {
			return true;
		}
	}
}