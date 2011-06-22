package lse.math.games.builder.presenter 
{
	import lse.math.games.builder.viewmodel.TreeGrid;
	
	/**
	 * Linked list of Actions, usable as an action itself, applying each operation to the whole list
	 * @author Mark
	 */
	public class ActionChain implements IAction
	{
		private var _start:ActionChainLink;
		private var _end:ActionChainLink;
		
		/** Adds new action to the end of the linked list */
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
		
		/** Executes all actions in the list */
		public function doAction(grid:TreeGrid):void
		{
			var link:ActionChainLink = _start;
			while (link != null) {
				link.action.doAction(grid);
				link = link.next;
			}
		}
		
		/** Checks if any of the actions changes data */
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
		
		/** Checks if any of the actions changes data */
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
		
		/** Checks if any of the actions changes the display */
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
//Internal class used as 'nodes' of Actions inside the Linked List
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