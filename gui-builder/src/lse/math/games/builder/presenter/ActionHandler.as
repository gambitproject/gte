package lse.math.games.builder.presenter 
{	
	import flash.utils.getTimer;
	
	import lse.math.games.builder.io.ExtensiveFormXMLReader;
	import lse.math.games.builder.io.ExtensiveFormXMLWriter;
	import lse.math.games.builder.io.FileManager;
	import lse.math.games.builder.viewmodel.DepthAdjuster;
	import lse.math.games.builder.viewmodel.TreeGrid;
	
	import util.Log;
	
	/**
	 * Class that handles Action executing, as well as undoing and redoing, and reseting the workspace either 
	 * to the default (just root) tree, or to one loaded via an xml container.</p>
	 * 
	 * @author Mark
	 */
	public class ActionHandler
	{
		//TODO: SETTING
		private const MINIMUM_BUFFER_SIZE:int = 10; //Number of actions that will be undoable, as a minimum
		private const MAXIMUM_TIME_UNDO:int = 1000; //Maximum milliseconds that the 'undo' command should take 

		private var _undone:Vector.<IAction> = new Vector.<IAction>();
		private var _history:Vector.<IAction> = new Vector.<IAction>();
		private var _xml:XML = null; //TODO: store as an actual TreeGrid obj? It would imply making it and its properties clonable
		//however, the time lost in creating and accesing the _xml is small, lower than 20ms, so I think it is not worth changing
		private var _fileManager:FileManager;		
		
		private var log:util.Log = Log.instance;
		
		
				
		public function ActionHandler(fileManager:FileManager) {
			_fileManager = fileManager;
		}
				
		/** Executes action, and stores it in 'history' vector, if it changes Data */
		public function processAction(action:IAction, grid:TreeGrid):void
		{			
			if (action != null) {
				if (action.changesData) { // TODO: else add it to a pending list of actions todo					
					action.doAction(grid);
					_fileManager.unsavedChanges = true;
					manageBuffer(action, grid);
				} else
					action.doAction(grid);
			}
		}		
		
		/* 
		 * Pushes the action into the buffer of done actions. 
		 * If the list of actions exceeds in processing time MAXIMUM_TIME_UNDO 
		 * and in length MINIMUM_BUFFER_SIDE, it deletes the last stored action,
		 * and updates with it the recovery _xml.
		 */
		private function manageBuffer(action:IAction, grid:TreeGrid):void
		{			
			_history.push(action);
			
			var totalTimeInBuffer:int = 0;
			var i:int = _history.length;
			while(--i) totalTimeInBuffer += _history[i].timeElapsed;
			
			if(totalTimeInBuffer > MAXIMUM_TIME_UNDO && _history.length > MINIMUM_BUFFER_SIZE)
			{	
				var recGrid:TreeGrid = new TreeGrid();
				initTree(recGrid); //Create a treegrid from the recovery xml
				
				_history.shift().doAction(recGrid); //Update the recovery grid while
													//erasing the last action
				
				var xmlWriter:ExtensiveFormXMLWriter = new ExtensiveFormXMLWriter();
				_xml = xmlWriter.write(recGrid); //Store the grid into xml again
			}
		}

		/** 
		 * Undoes last action by resetting the tree and reapplying all actions that had been done.
		 * @return True if there was operation to undo, False if not
		 */
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
				
				_fileManager.unsavedChanges = true;
				
				return true;
			} else {
				return false;
			}
		}

		/** 
		 * Repeats last undone Action.
		 * @return True if there was operation to redo, False if not
		 */
		public function redo(grid:TreeGrid):Boolean
		{
			if (_undone.length != 0)
			{
				var todo:IAction = _undone.pop();
				todo.doAction(grid);
				_history.push(todo);
				
				_fileManager.unsavedChanges = true;
				
				return true;
			} else {
				return false;				
			}		
		}		
		
		//Restores tree from a xml file or creates a default one (just the root)
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
		
		/** Loads a tree from a xml file, and resets history and undone data */
		public function load(xml:XML, grid:TreeGrid):void
		{			
			_xml = xml;
			initTree(grid);	
			_undone = new Vector.<IAction>();
			_history = new Vector.<IAction>();
		}
		
		/** Creates the default tree (just the root) and resets history and undone data */
		public function reset(grid:TreeGrid):void
		{
			_xml = null;
			initTree(grid);
			_undone = new Vector.<IAction>();
			_history = new Vector.<IAction>();
		}
	}
}