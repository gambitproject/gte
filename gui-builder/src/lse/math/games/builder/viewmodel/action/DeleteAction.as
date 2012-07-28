package lse.math.games.builder.viewmodel.action 
{
	import flash.utils.getTimer;
	
	import lse.math.games.builder.model.Node;
	import lse.math.games.builder.presenter.IAction;
	import lse.math.games.builder.viewmodel.AutoLabeller;
	import lse.math.games.builder.viewmodel.TreeGrid;
	
	import util.Log;
	
	/**	
	 * Removes a node and its children
	 * <li><b>Is undoable</b></li>
	 * <li>Changes Data</li>
	 * <li>Changes Size</li>
	 * <li>Changes Display</li>
	 * @author Mark Egesdal
	 */
	public class DeleteAction implements IAction
	{			
		private var _nodeId:int = -1;
		private var log:Log = Log.instance;
		
		private var _timeElapsed:int = 0;
		
		
		
		public function get timeElapsed():int {return _timeElapsed; }

		public function DeleteAction(node:Node) 
		{
			if (node != null) _nodeId = node.number;
		}
		
		public function doAction(grid:TreeGrid):void
		{
			var prevTime:int = getTimer();
			
			var node:Node = grid.getNodeById(_nodeId);
			if (node != null) {
				node.remove();
				
				var labeler:AutoLabeller = new AutoLabeller;
				labeler.autoLabelTree(grid,false);
			} else
				log.add(Log.ERROR, "Couldn't find any node with idx "+_nodeId, "DeleteAction");
			
			grid.orderIds();
			
			_timeElapsed = getTimer() - prevTime;
		}
		
//		public function get undoable():Boolean {
//			return true;
//		}
		
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