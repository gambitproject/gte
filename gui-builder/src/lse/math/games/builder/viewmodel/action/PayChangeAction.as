package lse.math.games.builder.viewmodel.action 
{
	import lse.math.games.builder.model.Node;
	import lse.math.games.builder.model.Outcome;
	import lse.math.games.builder.model.Rational;
	import lse.math.games.builder.viewmodel.TreeGrid;
	import lse.math.games.builder.presenter.IAction;
	
	/**	
	 * Changes the payoffs of a terminal node
	 * <li>Changes Data</li>
	 * <li>Changes Size</li>
	 * <li>Changes Display</li>
	 * @author Mark Egesdal
	 */
	public class PayChangeAction implements IAction
	{
		private var _nodeId:int;
		private var _pay1:Rational;
		private var _pay2:Rational;
		
		public function PayChangeAction(nodeId:int, pay1:Rational, pay2:Rational)
		{
			_nodeId = nodeId;
			_pay1 = pay1;
			_pay2 = pay2;
		}
		
		public function doAction(grid:TreeGrid):void 		
		{
			var node:Node = grid.getNodeById(_nodeId);
			if (node != null && node.isLeaf) 
			{	
				var outcome:Outcome = (node.outcome == null ? node.makeTerminal() : node.outcome);					
				outcome.setPay(grid.firstPlayer, _pay1);
				outcome.setPay(grid.firstPlayer.nextPlayer, _pay2);					
			}	
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