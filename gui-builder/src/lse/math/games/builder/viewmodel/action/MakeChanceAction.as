package lse.math.games.builder.viewmodel.action 
{
	import flash.utils.getTimer;
	
	import lse.math.games.builder.model.Iset;
	import lse.math.games.builder.model.Node;
	import lse.math.games.builder.presenter.IAction;
	import lse.math.games.builder.viewmodel.TreeGrid;
	
	import util.Log;
	
	/**	
	 * Makes a node or all nodes in iset to be chances (eliminating player data and replacing move labels with probabilities)
	 * <li>Changes Data</li>
	 * <li>Changes Size</li>
	 * <li>Changes Display</li>
	 * @author Mark Egesdal
	 */
	public class MakeChanceAction implements IAction
	{
		private var _isetId:int = -1;		
		private var _nodeId:int = -1;
		private var log:Log = Log.instance;
		
		private var _onDissolve:IAction;
			
		private var _timeElapsed:int = 0;
		
		
		
		public function get timeElapsed():int {return _timeElapsed; }
		
		public function MakeChanceAction(iset:Iset, node:Node) 
		{			
			if (iset != null) _isetId = iset.idx;
			if (node != null) _nodeId = node.number;
		}
		
		
		public function set onDissolve(value:IAction):void {
			_onDissolve = value;
		}
		
		public function doAction(grid:TreeGrid):void
		{			
			var prevTime:int = getTimer();
			
			var iset:Iset = grid.getIsetById(_isetId);
			if (iset == null) {
				if(_nodeId >= 0)
				{
					var node:Node = grid.getNodeById(_nodeId);
					if (node != null) {
						iset = node.makeNonTerminal();
						iset.makeChance();
					} else
						log.add(Log.ERROR, "Couldn't find any node with idx "+_nodeId, "MakeChanceAction");
				} else
					log.add(Log.ERROR, "Couldn't find any iset with idx "+_isetId, "MakeChanceAction");
			} else {
				var dissolve:Boolean = iset.numNodes > 1;
				iset.makeChance();
				if (dissolve) {
					_onDissolve.doAction(grid);
				}
			}
			
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