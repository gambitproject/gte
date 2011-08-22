package lse.math.games.builder.presenter 
{	
	import flash.utils.getTimer;
	
	import lse.math.games.builder.io.FileManager;
	import lse.math.games.builder.io.XMLExporter;
	import lse.math.games.builder.io.XMLImporter;
	import lse.math.games.builder.model.Game;
	import lse.math.games.builder.model.StrategicForm;
	import lse.math.games.builder.settings.SCodes;
	import lse.math.games.builder.settings.Settings;
	import lse.math.games.builder.settings.UserSettings;
	import lse.math.games.builder.viewmodel.DepthAdjuster;
	import lse.math.games.builder.viewmodel.TreeGrid;
	
	import util.Log;
	

	
	/**
	 * Class that handles Action executing, as well as undoing and redoing, and reseting the workspace either 
	 * to the default (just root) game, or to one loaded via an xml container.</p>
	 * 
	 * @author Mark & alfongj
	 */
	public class ActionHandler
	{
		private const MAXIMUM_TIME_UNDO:int = 1000; //When the undo buffer actions sum up more than these ms, 
													//it starts trimming, always keeping at least the 
													//MINIMUM_BUFFER_SIZE in settings.
		
		private var _undone:Vector.<IAction> = new Vector.<IAction>();
		private var _history:Vector.<IAction> = new Vector.<IAction>();
		private var _xml:XML = null; 
		private var _fileManager:FileManager;	
		private var settings:UserSettings = UserSettings.instance;
		private var log:util.Log = Log.instance;
		
		
				
		public function ActionHandler(fileManager:FileManager) {
			_fileManager = fileManager;
		}
				
		/** Executes action, and stores it in 'history' vector, if it changes Data */
		public function processAction(action:IAction, game:Game):void
		{	
			if(game is TreeGrid)
			{
				if (action != null) {
					if (action.changesData) { // TODO: else add it to a pending list of actions todo	
						
						while(_undone.length>0) _undone.pop(); //Empty the 'undone' queue		
						action.doAction(game as TreeGrid);
						_fileManager.unsavedChanges = true;
						manageTreeBuffer(action);
					} else
						action.doAction(game as TreeGrid);
				}
			} else if(game is StrategicForm) {
				
				//	manageMatrixBuffer(action);
				log.add(Log.ERROR_THROW, "This function has not been implemented yet");
				//TODO: #32			
			}
		}		
		
		/* 
		 * Pushes the action into the buffer of done actions. 
		 * If the list of actions exceeds in processing time MAXIMUM_TIME_UNDO 
		 * and in length MINIMUM_BUFFER_SIDE, it deletes the last stored action,
		 * and updates with it the recovery _xml.
		 */
		private function manageTreeBuffer(action:IAction):void
		{			
			_history.push(action);
			
			var totalTimeInBuffer:int = 0;
			var i:int = _history.length;
			while(--i) totalTimeInBuffer += _history[i].timeElapsed;
			
			if(totalTimeInBuffer > MAXIMUM_TIME_UNDO
				&& _history.length > (settings.getValue(SCodes.MINIMUM_BUFFER_SIZE) as int))
			{	
				var recGrid:TreeGrid = new TreeGrid();
				initGame(recGrid); //Create a treegrid from the recovery xml
				
				_history.shift().doAction(recGrid); //Update the recovery grid while
													//erasing the last action
				
				var xmlWriter:XMLExporter = new XMLExporter();
				_xml = xmlWriter.writeTree(recGrid); //Store the grid into xml again
			}
		}

		
		private function manageMatrixBuffer(action:IAction):void
		{
			log.add(Log.ERROR_THROW, "This function has not been implemented yet");
			//TODO: #32
		}
		
		/** 
		 * Undoes last action by resetting the tree and reapplying all actions that had been done.
		 * @return True if there was operation to undo, False if not
		 */
		public function undo(game:Game):Boolean
		{
			if(game is TreeGrid)
			{
				if (_history.length > 0) {				
					initGame(game);
					_undone.push(_history.pop());
	
					var redoStack:Vector.<IAction> = new Vector.<IAction>();
					while (_history.length > 0) {
						redoStack.push(_history.pop());
					}
	
					while (redoStack.length > 0)
					{
						var todo:IAction = redoStack.pop();
						todo.doAction(game as TreeGrid);			
						_history.push(todo);				
					}
					
					_fileManager.unsavedChanges = true;
					
					return true;
				} else {
					return false;
				}
			} else if(game is StrategicForm)
			{				
				log.add(Log.ERROR_THROW, "This function has not been implemented yet");
				//TODO: #32				
				return false;
			} else
			{
				log.add(Log.ERROR_THROW, "Fatal error: unknown type of game", "ActionHandler.undo()");
				return false;
			}
		}

		/** 
		 * Repeats last undone Action.
		 * @return True if there was operation to redo, False if not
		 */
		public function redo(game:Game):Boolean
		{
			if(game is TreeGrid)
			{
				if (_undone.length != 0)
				{
					var todo:IAction = _undone.pop();
					todo.doAction(game as TreeGrid);
					_history.push(todo);
					
					_fileManager.unsavedChanges = true;
					
					return true;
				} else {
					return false;				
				} 
			} else if(game is StrategicForm)
			{				
				log.add(Log.ERROR_THROW, "This function has not been implemented yet");
				//TODO: #32				
				return false;
			} else
			{
				log.add(Log.ERROR_THROW, "Fatal error: unknown type of game", "ActionHandler.redo()");
				return false;
			}	
		}		
				
		//Restores tree from a xml file or creates a default one (just the root)
		private function initGame(game:Game):void
		{			
			if(game is TreeGrid)
			{
				var tree:TreeGrid = game as TreeGrid;
				if (_xml != null) {
					var reader:XMLImporter = new XMLImporter(_xml);
					reader.loadTree(tree);
					
					var depthAdjuster:IAction = new DepthAdjuster();
					depthAdjuster.doAction(tree);
				} else {
					tree.clearTree();
					tree.defaultTree();
				}
			} else if(game is StrategicForm)
			{
				var matrix:StrategicForm = game as StrategicForm;
				if(_xml != null) {
					log.add(Log.ERROR_THROW, "This function has not been implemented yet");
					//TODO #32
				} else {
					matrix.clearMatrix();
					matrix.defaultMatrix();
				}
			}
		}
		
		/** Loads a game from a xml file, and resets history and undone data */
		public function load(xml:XML, game:Game):void
		{			
			if(game is TreeGrid)
			{
				_xml = xml;
				initGame(game as TreeGrid);	
				_undone = new Vector.<IAction>();
				_history = new Vector.<IAction>();
			} else if(game is StrategicForm)
			{
				log.add(Log.ERROR_THROW, "This function has not been implemented yet");
				//TODO: #32
			}		
		}
		
		/** Creates the default game and resets history and undone data */
		public function reset(game:Game):void
		{
			if(game is TreeGrid)
			{
				_xml = null;
				initGame(game as TreeGrid);
				_undone = new Vector.<IAction>();
				_history = new Vector.<IAction>();
			} else if(game is StrategicForm)
			{
				_xml = null;
				initGame(game as StrategicForm);
				_undone = new Vector.<IAction>();
				_history = new Vector.<IAction>();
			}
		}
	}
}