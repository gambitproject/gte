package lse.math.games.builder.presenter 
{	
	import lse.math.games.builder.viewmodel.DepthAdjuster;
	import lse.math.games.builder.viewmodel.TreeGrid;
	import lse.math.games.builder.io.ExtensiveFormXMLReader;
	
	/**
	 * @author Mark
	 */
	public class ActionHandler
	{
		//TODO: store check point restore states to prevent undo and redo from being unusable after long periods of use
		private var _undone:Vector.<IAction> = new Vector.<IAction>();
		private var _history:Vector.<IAction> = new Vector.<IAction>();		
		private var _xml:XML = null; //TODO: store as an actual TreeGrid obj?
				
		public function ActionHandler() {}
				
		public function processAction(action:IAction, grid:TreeGrid):void
		{			
			if (action != null) {
				if (action.changesData) { // TODO: else add it to a pending list of actions todo
					_history.push(action);
				}
				action.doAction(grid);
			}
		}		

		public function undo(grid:TreeGrid):Boolean
		{
			if (_history.length > 0) {				
				initTree(grid);
				_undone.push(_history.pop());

				var redoStack:Vector.<IAction> = new Vector.<IAction>();
				while (_history.length > 0) {
					redoStack.push(_history.pop());
				}

				while (redoStack.length > 0)
				{
					var todo:IAction = redoStack.pop();
					todo.doAction(grid);			
					_history.push(todo);				
				}
				return true;
			} else {
				return false;
			}
		}

		public function redo(grid:TreeGrid):Boolean
		{
			if (_undone.length != 0)
			{
				var todo:IAction = _undone.pop();
				todo.doAction(grid);
				_history.push(todo);
				return true;
			} else {
				return false;				
			}		
		}		
		
		private function initTree(grid:TreeGrid):void
		{			
			if (_xml != null) {
				var reader:ExtensiveFormXMLReader = new ExtensiveFormXMLReader(_xml);
				reader.load(grid);
				
				var depthAdjuster:IAction = new DepthAdjuster();
				depthAdjuster.doAction(grid);
			} else {
				grid.clearTree();
				grid.defaultTree();
			}
		}
		
		public function load(xml:XML, grid:TreeGrid):void
		{			
			_xml = xml;
			initTree(grid);		
			_undone = new Vector.<IAction>();
			_history = new Vector.<IAction>();
		}
		
		public function reset(grid:TreeGrid):void
		{
			_xml = null;
			initTree(grid);
			_undone = new Vector.<IAction>();
			_history = new Vector.<IAction>();
		}
	}
}