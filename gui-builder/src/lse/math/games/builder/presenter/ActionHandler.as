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
	
	// TODO: Manage the switch between edit modes. Currently i am not sure if the
	// undo queue is resetted, probably yes, else it would potentially cause lots'a problems
	
	/**
	 * Class that handles Action executing, as well as undoing and redoing, and reseting the workspace either 
	 * to the default (just root) game, or to one loaded via an xml container.</p>
	 * 
	 * @author alfongj
	 */
	public class ActionHandler
	{
		private var _xml:XML = null; // XML corresponding to the current tree
		private var _fileManager:FileManager;	
		private var settings:UserSettings = UserSettings.instance;
		private var log:util.Log = Log.instance;
		private var _undone:Vector.<XML> = new Vector.<XML>();
		private var _history:Vector.<XML> = new Vector.<XML>();
		private var _xmlWriter:XMLExporter = new XMLExporter();
		
				
		public function ActionHandler(fileManager:FileManager) {
			_fileManager = fileManager;
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
					_xml = _xmlWriter.writeTree(tree);
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
					//TODO #32
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
				_undone = new Vector.<XML>();
				_history = new Vector.<XML>();
			} else if(game is StrategicForm)
			{
				log.add(Log.ERROR_THROW, "This function has not been implemented yet");
				//TODO: #32
			}		
		}
		
		/** Creates the default game and resets history and undone data */
		public function reset(game:Game):void
		{
			_xml = null;
			if(game is TreeGrid) {
				initGame(game as TreeGrid);
			} else if(game is StrategicForm) {
				initGame(game as StrategicForm);
			}
			
			_undone = new Vector.<XML>();
			_history = new Vector.<XML>();
		}
		
		
				
		/** Executes action, and stores it in 'history' vector, if it changes Data */
		public function processAction(action:IAction, game:Game):void
		{	
			if(game is TreeGrid)
			{
				if (action != null) {
					if (action.changesData) { 
						
						while(_undone.length>0) _undone.pop(); //Empty the 'undone' queue		
						action.doAction(game as TreeGrid);
						_fileManager.unsavedChanges = true;
						
						if(_xml != null) {
							_history.push(_xml);
						}
						
						_xml = _xmlWriter.writeTree(game as TreeGrid);
					} else
						action.doAction(game as TreeGrid);
				}
			} else if(game is StrategicForm) {
				
				//	manageMatrixBuffer(action);
				log.add(Log.ERROR_THROW, "This function has not been implemented yet");
				// TODO: #32	Implement Undo/Redo in strategic form?		
			}
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
					
					_undone.push(_xml);
					_xml = _history.pop();
					initGame(game);
					
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
				if (_undone.length > 0)
				{
					_history.push(_xml);
					_xml = _undone.pop();
					initGame(game);
					
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
	}
}