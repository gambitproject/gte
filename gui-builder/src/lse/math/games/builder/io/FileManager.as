package lse.math.games.builder.io
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.net.SharedObject;
	import flash.utils.ByteArray;
	import flash.utils.setTimeout;
	
	import lse.math.games.builder.presenter.TreeGridPresenter;
	import lse.math.games.builder.settings.UserSettings;
	
	import mx.core.FlexGlobals;
	
	import util.Log;
	import util.PromptTwoButtons;

	/** 
	 * The FileManager class handles operations related with file saving and loading. <br>
	 * Specifically, it includes:
	 * <ul><li>A string with the filename.</li>
	 * <li>A backup xml of the tree, which can be up-to-date, if _unsavedChanges is false, 
	 * or not if it is true.</li>
	 * <li>Functions related to making possible an autosave system</li>
	 * <li>Functions for loading and saving files (in different formats)</li></p>
	 *
	 * @author alfongj
	 */
	public class FileManager
	{
		private static const FILE_OPEN_TYPES:Array = [new FileFilter("*.xml", "*.xml")];
		private static const FILE_SAVE_TYPES:Array = [".xml", ".fig", ".png"];
		//TODO: SETTING
		private static const AUTOSAVE_INTERVAL:int = 300000; //Time in ms between each two autosaves
		
		private var fr:FileReference = null;
		private var _filename:String;
		private var _unsavedChanges:Boolean = false;
		private var _backupXML:XML = null;
		
		private var controller:TreeGridPresenter;
		private var settings:UserSettings = UserSettings.instance;
		private var treeStorage:SharedObject;
		
		private var log:Log = Log.instance;
		
		
		
		public function FileManager(_controller:TreeGridPresenter){
			controller = _controller;
			filename = "Untitled";
			setTimeout(autosave, AUTOSAVE_INTERVAL);
			
			//Look if there is an autosave, and load it if so
			treeStorage = SharedObject.getLocal( "autosave", "/" );
			if(treeStorage != null && treeStorage.data["treeXML"] !=null)
			{
				setTimeout(askLoadTree, 3000); //Leave 3 seconds for the creation of canvas
			} 
		}
		
		/** Name of the file */
		[Bindable]
		public function get filename():String { return _filename; }
		public function set filename(value:String):void {			
			_filename = value;
			setBrowserWindowTitle();
		}
		
		/** If there are actions pending to be saved in the latest autosave */
		public function set unsavedChanges(value:Boolean):void { 
			if(value!=_unsavedChanges)
			{
				_unsavedChanges = value;
				setBrowserWindowTitle();
			}
		}
		
		/* XML containing the last saved tree */
		private function set backupXML(value:XML):void {
			_backupXML = value;
			
			if(settings.cookiesStorable /*&& autosave_on */)
			{
				//Have to get a new instance of the shared object because it might have not existed previously
				SharedObject.getLocal( "autosave", "/" ).setProperty("treeXML", value);
				unsavedChanges = false;
			}
		}
		
		
		
		//Change the browser window's title to 'GTE - filename'
		private function setBrowserWindowTitle():void {
			ExternalInterface.call("changeDocTitle('" + _filename + (_unsavedChanges ? "*":"") + "')");
			/* javascript inside the web container should be:
			function changeDocTitle(value)
			{
				document.title = 'GTE - '+value;
			} */	
		}
		
		/* < --- --- File Managing: clearing, saving, loading --- ---> */
		
		/** Creates a new copy of the current tree and stores it as a SharedObject if possible */
		public function autosave():void {
			//TODO: Check if autosave setting is on
			if(_unsavedChanges)
				backupXML = controller.saveCurrentTreeToXML();
			setTimeout(autosave, AUTOSAVE_INTERVAL);
		}
		
		//Asks if to load a saved tree
		private function askLoadTree():void {
			PromptTwoButtons.show(loadAutoSavedTree, "There is " +
				"an auto-saved tree from last execution. Would you like to load it?")
		}
		
		/* Loads a tree saved via autosave */
		private function loadAutoSavedTree():void {
			if(PromptTwoButtons.buttonPressed == PromptTwoButtons.OK)
			{
				backupXML = treeStorage.data["treeXML"] as XML;
				controller.loadTreeFromXML(_backupXML);
			} else {
				clear();
			}
		}
		
		/** Resets the filename */
		public function clear():void {
			filename = "Untitled";
			backupXML = null;
			treeStorage = SharedObject.getLocal( "autosave", "/" );			
			if(treeStorage!=null)
				treeStorage.clear();
		}
		
		/*
		 * Returns the filename associated to a file, removing from it
		 * the extension, if it is one of the ones listed in FILE_SAVE_TYPES.<br>
		 * Returns null if the file doesn't have name.
		 */
		private function getNameFromFile(fr:FileReference):String { 
			if(fr!=null && fr.name!=null)
			{
				var newFileName:String = fr.name;
				
				//Removes file extension (There might be a better way)
				for(var i:int = 0; i<FILE_SAVE_TYPES.length; i++)
				{
					var ext:String = FILE_SAVE_TYPES[i];
					if(newFileName.substr(newFileName.length-ext.length, ext.length).toLowerCase() == ext)
					{
						newFileName = newFileName.substr(0, newFileName.length-ext.length);
						break;
					}
				}
				
				return newFileName;			
			}
			
			return null;
		}
		
		//TODO: On some point, remove listeners, or does fr = null call garbage collector correctly?
		
		/**
		 * Opens a dialog for saving the tree in .fig format using TreeGridFigWriter
		 */
		public function saveFig(figStr:String):void
		{			
			fr = new FileReference();
			
			fr.addEventListener(Event.COMPLETE, onSaveComplete);
			fr.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			
			fr.save(figStr, filename+".fig"); 
		}
		
		/**
		 * Opens a dialog for saving an image of the tree in .png format
		 */
		public function saveImage(ba:ByteArray):void
		{			
			fr = new FileReference();
			
			fr.addEventListener(Event.COMPLETE, onSaveComplete);
			fr.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			
			fr.save(ba, filename+".png");
		}
		
		/**
		 * Opens a dialog for saving the tree in xml format
		 */
		public function saveXML(treeXML:XML):void 
		{			
			backupXML = treeXML;
			
			fr = new FileReference();
			
			fr.addEventListener(Event.COMPLETE, onSaveComplete);
			fr.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			
			fr.save(treeXML.toXMLString(), filename+".xml");
		}
		
		/**
		 * Opens a dialog for selecting and opening a tree in xml format
		 */
		public function openFile():void
		{
			//create the FileReference instance
			fr = new FileReference();
			
			//listen for when they select a file
			fr.addEventListener(Event.SELECT, onFileSelect);
			
			//listen for when then cancel out of the browse dialog
			fr.addEventListener(Event.CANCEL, onCancel);
			
			//open a native browse dialog that filters for text files
			fr.browse(FILE_OPEN_TYPES);
		}
		
		/* <--- --- Browse Event Handlers --- ---> */
		
		//called when the user selects a file from the browse dialog
		private function onFileSelect(e:Event):void
		{						
			//listen for when the file has loaded
			fr.addEventListener(Event.COMPLETE, onLoadComplete);
			
			//listen for any errors reading the file
			fr.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
			
			fr.addEventListener(Event.OPEN, onFileOpen);
			
			//load the content of the file
			fr.load();
		}
		
		//called when the user cancels out of the browser dialog
		private function onCancel(e:Event):void
		{
			//trace("File Browse Canceled");
			fr = null;
		}
		
		private function onFileOpen(e:Event):void
		{
			//trace("File Opened for loading");
		}
		
		/* <--- --- Select Event Handlers --- ---> */
		
		//called when the file has completed loading
		//TODO: error handling of XML parsing?
		private function onLoadComplete(e:Event):void
		{			
			//read the bytes of the file as a string
			var text:String = fr.data.readUTFBytes(fr.data.bytesAvailable);		
			
			var xml:XML = new XML(text);						
			controller.loadTreeFromXML(xml);
			
			backupXML = xml;
			filename = getNameFromFile(fr);
			
			fr = null;
		}
		
		//called if an error occurs while loading the file contents
		private function onLoadError(e:IOErrorEvent):void
		{
			log.add(Log.ERROR, "Error loading file : " + e.text);
		}
		
		//called when the file has completed saving, independently of the file saving command chosen
		private function onSaveComplete(evt:Event):void{
			log.add(Log.HINT, "File saved correctly");
			filename = getNameFromFile(fr);
			unsavedChanges = false;
			
			fr = null;
		}
		
		//called if an error occurs while saving the file contents
		private function onSaveError(e:IOErrorEvent):void
		{
			log.add(Log.ERROR, "Error saving file : " + e.text);
		}	
	}
}