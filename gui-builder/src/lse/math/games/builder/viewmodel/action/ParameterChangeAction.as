package lse.math.games.builder.viewmodel.action 
{
	import flash.utils.getTimer;
	
	import lse.math.games.builder.model.Node;
	import lse.math.games.builder.model.Outcome;
	import lse.math.games.builder.model.Rational;
	import lse.math.games.builder.presenter.IAction;
	import lse.math.games.builder.viewmodel.TreeGrid;
	
	import util.Log;
	import lse.math.games.builder.viewmodel.AutoLabeller;
	
	/**	
	 * Changes the payoffs of a terminal node
	 * <li>Changes Data</li>
	 * <li>Changes Size</li>
	 * <li>Changes Display</li>
	 * @author Mark Egesdal
	 */
	public class ParameterChangeAction implements IAction
	{
		private var _nodeId:int;
		private var _param1:String;
		private var _param2:String;
		private var log:Log = Log.instance;
		
		private var _timeElapsed:int = 0;
		
		
		
		public function get timeElapsed():int {return _timeElapsed; }
		
		public function ParameterChangeAction(nodeId:int, player1:String, player2:String)
		{
			_nodeId = nodeId;
			_param1 = player1;
			_param2 = player2;
		}
		
		public function doAction(grid:TreeGrid):void 		
		{
			var prevTime:int = getTimer();
			
			var node:Node = grid.getNodeById(_nodeId);
		
			if (node != null && node.isLeaf) 
			{	
				var outcome:Outcome = (node.outcome == null ? node.makeTerminal() : node.outcome);
				if(_param1!=null) {
					node.parameterPlayer1=_param1;
					outcome.setPay(grid.firstPlayer, Rational.ZERO);
				} 
				if(_param2!=null) {
					node.parameterPlayer2=_param2;
					outcome.setPay(grid.firstPlayer.nextPlayer, Rational.ZERO);
				}
			} else
				log.add(Log.ERROR, "Couldn't find any suitable node with idx "+_nodeId, "PayChangeAction");
			
			_timeElapsed = getTimer() - prevTime;
	
			//Fix the bug, that the correct drawing of player numbers is not performed after random payoffs
			grid.orderIds();
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