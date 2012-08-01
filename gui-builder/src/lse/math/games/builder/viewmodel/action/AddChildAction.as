package lse.math.games.builder.viewmodel.action 
{
	import flash.utils.getTimer;
	
	import lse.math.games.builder.model.Iset;
	import lse.math.games.builder.model.Node;
	import lse.math.games.builder.model.Player;
	import lse.math.games.builder.presenter.IAction;
	import lse.math.games.builder.viewmodel.AutoLabeller;
	import lse.math.games.builder.viewmodel.DepthAdjuster;
	import lse.math.games.builder.viewmodel.TreeGrid;
	import lse.math.games.builder.settings.UserSettings;

	
	import util.Log;
	
	/**	
	 * Adds a child to all the nodes in a selected iset/ in a selected node's iset.
	 * If the selected nodes are childless, then it adds two children instead
	 * <li>Changes Data</li>
	 * <li>Changes Size</li>
	 * <li>Changes Display</li>
	 * @author alfongj
	 */
	public class AddChildAction implements IAction
	{
		private var _isetId:int = -1;
		private var _nodeId:int = -1;
		private static var _depthAdjuster:IAction = new DepthAdjuster(); //TODO: remove and use ActionChain or onAdd decorator
		private var log:Log = Log.instance;
		
		private var settings:UserSettings = UserSettings.instance;
		
		private var _timeElapsed:int = 0;
		
		
		
		public function get timeElapsed():int {return _timeElapsed; }
		
		public function AddChildAction(iset:Iset, node:Node) 
		{
			if (iset != null) _isetId = iset.idx;
			if (node != null) _nodeId = node.number;
		}
		
		public function doAction(grid:TreeGrid):void
		{			
			var prevTime:int = getTimer();
			
			var iset:Iset = null;
			if (_isetId >= 0) {
				iset = grid.getIsetById(_isetId);			
			}
			
			if (iset != null) {
				addChildTo(iset, grid);
				_depthAdjuster.doAction(grid);
			} else if (_nodeId >= 0) {				
				var node:Node = grid.getNodeById(_nodeId);
				if (node != null) {
					node.makeNonTerminal();
					addChildTo(node.iset, grid);
					_depthAdjuster.doAction(grid);
				} else
					log.add(Log.ERROR, "Couldn't find any node with idx "+_nodeId, "AddChildAction");
			} else
				log.add(Log.ERROR, "Couldn't find any iset with idx "+_isetId, "AddChildAction");
			
			var labeler:AutoLabeller = new AutoLabeller;
			labeler.autoLabelTree(grid,false);
			
			grid.orderIds();
			
			_timeElapsed = getTimer() - prevTime;
		}
		
		private function addChildTo(parent:Iset, grid:TreeGrid):void
		{			
			var player:Player = null;
			var lastPlayableNode:Node = parent.firstNode;
			while (true) {
				if (lastPlayableNode.iset.player != Player.CHANCE) {
					player = lastPlayableNode.iset.player.nextPlayer;
					break;
				} else if (lastPlayableNode.parent == null) {
					break;
				}
				lastPlayableNode = lastPlayableNode.parent;
			}
			if (player == null) {
				player = grid.firstPlayer;
			}
			
			//we are in tree mode
			if (parent.isChildless) 
				parent.makeChance();
			
			if (parent.isChildless)
				parent.addMove(player);	
			
			parent.addMove(player);	
			
			
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