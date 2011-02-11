package lse.math.games.builder.presenter 
{
	import lse.math.games.builder.viewmodel.TreeGrid;
	
	/**
	 * @author Mark
	 */
	public class ActionChain implements IAction
	{
		private var _start:ActionChainLink;
		private var _end:ActionChainLink;
		
		public function push(action:IAction):void
		{
			var link:ActionChainLink = new ActionChainLink(action);			
			if (_start == null) {
				_start = link;
			}
			if (_end != null) {
				_end.next = link;
			}
			_end = link;
		}
		
		public function doAction(grid:TreeGrid):void
		{
			var link:ActionChainLink = _start;
			while (link != null) {
				link.action.doAction(grid);
				link = link.next;
			}
		}
		
		public function get changesData():Boolean {
			var link:ActionChainLink = _start;
			while (link != null) {
				if (link.action.changesData) {
					return true;
				}
				link = link.next;
			}
			return false;
		}
		
		public function get changesSize():Boolean {
			var link:ActionChainLink = _start;
			while (link != null) {
				if (link.action.changesSize) {
					return true;
				}
				link = link.next;
			}
			return false;
		}
		
		public function get changesDisplay():Boolean {
			var link:ActionChainLink = _start;
			while (link != null) {
				if (link.action.changesDisplay) {
					return true;
				}
				link = link.next;
			}
			return false;
		}
	}

}

import lse.math.games.builder.presenter.IAction;
class ActionChainLink
{
	private var _action:IAction;
	public var next:ActionChainLink;	
	
	public function ActionChainLink(action:IAction)
	{
		_action = action;
	}
	
	public function get action():IAction {
		return _action;
	}
}