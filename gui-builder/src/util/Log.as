package util
{
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TextEvent;
	import flash.net.FileReference;
	
	import mx.collections.ArrayList;
	import mx.controls.Alert;
	
	/**
	 * Class in substitution of trace, which keeps a log of the traced messages and does different actions 
	 * depending on the type of the traced statement i.e., error, debug, etc. Its methods should be accessed statically
	 * 
	 * @author alfongj
	 */
	public class Log
	{
		private static var _instance : Log = null; //Instance of the class for making it a singleton (needed for binding lastMessage)
		
		private var dispatcher:EventManager = EventManager.instance; 
		
		
		
		public static function get instance():Log
		{
			if(_instance == null)
			{
				_instance = new Log(LogSingletonLock);
			}
			
			return _instance;
		}
		
		public function Log(lock:Class) {
			if( lock != LogSingletonLock ){
				throw new IllegalOperationError( "Settings is a Singleton, please use the static instance method instead." );
			} else {
			}
		}
		
		private var lines : ArrayList = new ArrayList();
		private const LOG_MAX_LENGTH : int = 100;
		
		[Bindable]
		private var _lastMessage : String = ""; //TODO: Possibly remove, better throw events
		
		public function get lastMessage():String
		{
			if(lines.length==0)
				return "";
			
			var entry : Object = lines.source[lines.length-1];
			
			var type:String = getStringFromType(entry.type as int);
			
			return (entry.time as Date).toLocaleTimeString() + " " + type 
				+ ": " + entry.line + (entry.origin==null ? "" : " - " + entry.origin);
		}
		
		/** 
		 * An ERROR occurred possibly by user interaction, which displays an 
		 * alert to the user 
		 */
		public static const ERROR : int = 1;
		
		/** 
		 * An ERROR so important that it must interrupt the workflow, so 
		 * therefore it is thrown, apart from logged 
		 */
		public static const ERROR_THROW : int = 2; 
		
		/** 
		 * A minor ERROR from which the user doesn't need to know anything 
		 * and therefore isn't shown to him. It is treated the same as DEBUG,
		 * the only difference being that this one is marked as an ERROR (something
		 * bad), and DEBUG can just be anything that the debugger would want to track,
		 * not necessarily somethign bad.
		 */
		public static const ERROR_HIDDEN : int = 3; 
		
		/** A substitution of trace(), just debugging info for dev use */
		public static const DEBUG : int = 4;
		
		/** 
		 * A message sent to the user as to recommmend him doing something. Not 
		 * as invasive as ERROR, because it doesn't show in a PopUp,it shows in the 
		 * logLine instead (the space below the canvas).
		 */
		public static const HINT : int = 5;

		
		
		/**
		 * Traces one line, storing it in the log. Depending on the type of statement you select, it does the following:
		 * 
		 * <ul><li> ERROR: Shows an alert to the user apart from storing internally the error and calling trace() for sending it to the console </li>
		 * <li> ERROR_THROW: Same as previous but also throws an error interrupting execution </li>
		 * <li> DEBUG: Just stores the content of the trace, and calls trace() </li></ul>
		 * 
		 * @param type: type of the statement traced. Options: Log.ERROR, Log.ERROR_THROW and Log.DEBUG
		 * @param line: Content of the trace
		 * @param origin: (Optional) Name of the class which is the origin of the error
		 */
		public function add(type : int, line : String, origin : String = null) : void
		{
			logLine(type, line, origin);
			
			switch(type)
			{
				case ERROR:
					Alert.show(line, "Error" + (origin==null ? "" : " - "+origin));
					trace("Error: "+line+(origin==null ? "" : " - "+origin));
					break;
				case ERROR_THROW:
					//TODO: Say in a title or something that an unexpected error occurred, and that the log will be saved
					//TODO: Possibly save also the tree
					saveLogDump();
					throw new Error(line);
					break;
				case ERROR_HIDDEN:
					trace("Error: "+line+(origin==null ? "" : " - "+origin));
					break;
				case DEBUG:
					trace("Debug: "+line+(origin==null ? "" : " - "+origin));
					break;
				case HINT:
					dispatcher.dispatchEvent(new TextEvent(EvCodes.HINT_ADDED, false, false, line));
					break;
				
				default:
					add(ERROR_HIDDEN, "Unknown param 'type' when calling trace()", "Log");
					break;
			}			
		}	
		
		//Stores one line in the log, and deletes the oldest one if the max is exceeded
		private function logLine(type : int, line : String, origin : String) : void
		{
			while (lines.length > LOG_MAX_LENGTH)
				lines.removeItemAt(0);
			lines.addItem({"type" : type, "line" : line, "origin" : origin, "time" : new Date()});
			
			_lastMessage = getStringFromType(type) + ": " + line + (origin==null ? "" : " - "+origin);
		}
		
		/** Prompts the user to save a txt file with a dump of the message log*/
		public function saveLogDump() : void
		{
			//TODO: I don't know the reason why, but the save method is ignoring the new line characters. In NotePad++ it is displayed correctly, not so in Notepad
//			var fr:FileReference = new FileReference;
//			fr.save(logDump(), "log.txt");
			//TODO: Better post to the dev in charge, should be a setting that enables it
		}
		
		/** Returns a String with the content of the arraylist of lines (last LOG_MAX_LENGTH lines as a default, or 'numLines' if specified)*/
		public function logDump(numLines : int = -1) : String
		{
			var ret : String = "";
			
			var counter : int = 0;
			
			for each (var entry : Object in lines.source)
			{
				var type:String = getStringFromType(entry.type as int);
				
				ret = (entry.time as Date).toLocaleTimeString() + " " + type + ": " + entry.line + (entry.origin==null ? "" : " - " + entry.origin) + "\n" + ret;
				
				if(numLines>0 && numLines<lines.length)
				{
					counter++;
					if(counter>=numLines)
						break;
				}
			}
			return ret;
		}
		
		//Returns a string corresponding to the name of the type passed
		private function getStringFromType( type : int):String
		{
			switch (type)
			{
				case ERROR:
				case ERROR_THROW:
				case ERROR_HIDDEN:
					return "Error";
				
				case DEBUG:
					return "Debug";
					
				case HINT:
					return "Hint";
				
				default:
					return "???";
			}
		}
	}	
}

//Dummy private class for making the constructor artificially private
class LogSingletonLock {}