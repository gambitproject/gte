package lse.math.games.builder.viewmodel.action 
{
	import flash.utils.getTimer;
	
	import lse.math.games.builder.model.Move;
	import lse.math.games.builder.model.Node;
	import lse.math.games.builder.presenter.IAction;
	import lse.math.games.builder.viewmodel.TreeGrid;
	
	import util.Log;
		
	/**	
	 * Changes a selected node's label to a new one
	 * <li>Changes Data</li>
	 * <li>NOT <strike>Changes Size</strike></li>
	 * <li>Changes Display</li>
	 * @author Mark Egesdal
	 */
	public class LabelChangeAction implements IAction
	{
		private var _nodeId:int;
		private var _label:String;
		private var log:Log = Log.instance;
		
		private var _timeElapsed:int = 0;
		
		
		
		public function get timeElapsed():int {return _timeElapsed; }
		
		public function LabelChangeAction(nodeId:int, label:String) 
		{
			_nodeId = nodeId;
			_label = label;
		}
		
		public function doAction(grid:TreeGrid):void
		{
			var prevTime:int = getTimer();
			
			var node:Node = grid.getNodeById(_nodeId);
			if (node != null) {
				var move:Move = node.reachedby;
				if (move != null) {
					move.label = _label;
				}
			} else 
				log.add(Log.ERROR, "Couldn't find any node with idx "+_nodeId, "LabelChangeAction");
			
			_timeElapsed = getTimer() - prevTime;
		}
				
		public function get changesData():Boolean {
			return true;
		}
		
		public function get changesSize():Boolean {
			return false; //TODO: if measurements are done by label widths, this will need to change
		}
		
		public function get changesDisplay():Boolean {
			return true;
		}
	}
}