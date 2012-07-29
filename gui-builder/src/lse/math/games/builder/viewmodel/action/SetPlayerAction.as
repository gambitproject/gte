package lse.math.games.builder.viewmodel.action 
{
	import flash.utils.getTimer;
	
	import lse.math.games.builder.model.Iset;
	import lse.math.games.builder.model.Node;
	import lse.math.games.builder.model.Player;
	import lse.math.games.builder.presenter.IAction;
	import lse.math.games.builder.viewmodel.AutoLabeller;
	import lse.math.games.builder.viewmodel.TreeGrid;
	
	import util.Log;
	
	/**	
	 * Changes the player of all nodes inside selected Iset/selected node's Iset
	 * <li>Changes Data</li>
	 * <li>NOT <strike>Changes Size</strike></li>
	 * <li>Changes Display</li>
	 * @author Mark Egesdal
	 */
	public class SetPlayerAction implements IAction
	{
		private var _isetId:int = -1;		
		private var _nodeId:int = -1;
		private var log:Log = Log.instance;
		private var _player:Player=null;
		private var _timeElapsed:int = 0;
		
		
		
		public function get timeElapsed():int {return _timeElapsed; }
		
		public function SetPlayerAction(iset:Iset, node:Node, player:Player) 
		{
			if (iset != null) _isetId = iset.idx;
			if (node != null) _nodeId = node.number;
			_player=player;
		}
		
		public function doAction(grid:TreeGrid):void
		{				
			var prevTime:int = getTimer();
			
			var labeler:AutoLabeller = new AutoLabeller;
			
			var iset:Iset = grid.getIsetById(_isetId);
			if (iset == null) {
				if(_nodeId >= 0)
				{
					var node:Node = grid.getNodeById(_nodeId);
					if (node != null) {
						iset = node.makeNonTerminal();
						
						labeler.autoLabelTree(grid,false);
					} else
						log.add(Log.ERROR, "Couldn't find any node with idx "+_nodeId, "ChangePlayerAction");
				} else
					log.add(Log.ERROR, "Couldn't find any iset with idx "+_isetId, "ChangePlayerAction");
			} else {
				if (_player!=null) {
					iset.changeToSpecificPlayer(_player);
					
					labeler.autoLabelTree(grid,false);
				}
			}
			
			_timeElapsed = getTimer() - prevTime;
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