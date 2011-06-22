package util
{
	import mx.controls.Alert;
	import mx.collections.ArrayList;
	
	/**
	 * Class in substitution of trace, which keeps a log of the traced messages and does different actions 
	 * depending on the type of the traced statement i.e., error, debug, etc. Its methods should be accessed statically
	 * @author alfongj
	 */
	public class Log
	{
		private static var _instance : Log = null; //Instance of the class for making it a singleton (needed for binding lastMessage)
		
		public static function get instance():Log
		{
			if(_instance == null)
			{
				_instance = new Log();
			}
			
			return _instance;
		}
		
		public function Log() {}
		
		private static var lines : ArrayList = new ArrayList();
		private static const LOG_MAX_LENGTH : int = 100;
		
		private static var _lastMessage : String = "";
		
		public function get lastMessage():String
		{
			if(lines.length==0)
				return "";
			
			var entry : Object = lines.source[lines.length-1];
			
			var type:String = getStringFromType(entry.type as int);
			
			return (entry.time as Date).toUTCString() + " " + type + ": " + entry.line + (entry.origin==null ? "" : " - " + entry.origin);
		}
		
		public static const ERROR : int = 1;
		public static const ERROR_THROW : int = 2;
		public static const DEBUG : int = 3;
		
		/**
		 * Traces one line, storing it in the log. Depending on the type of statement you select, it does the following:
		 * - ERROR: Shows an alert to the user apart from storing internally the error and calling trace() for sending it to the console
		 * - ERROR_THROW: Same as previous but also throws an error interrupting execution
		 * - DEBUG: Just stores the content of the trace, and calls trace()
		 * 
		 * @param type: type of the statement traced. Options: Log.ERROR and Log.DEBUG
		 * @param line: Content of the trace
		 * @param origin: (Optional) Name of the class which is the origin of the error
		 */
		public static function add(type : int, line : String, origin : String = null) : void
		{
			logLine(type, line, origin);
			
			switch(type)
			{
				case ERROR:
					Alert.show(line, "Error" + (origin==null ? "" : " - "+origin));
					trace("Error: "+line+(origin==null ? "" : " - "+origin));
					break;
				case ERROR_THROW:
					throw new Error(line);
					break;
				case DEBUG:
					trace("Debug: "+line+(origin==null ? "" : " - "+origin));
					break;
				default:
					add(ERROR, "Wrong param 'type' when calling trace()", "Log");
					break;
			}			
		}	
		
		//Stores one line in the log, and deletes the oldest one if the max is exceeded
		private static function logLine(type : int, line : String, origin : String) : void
		{
			while (lines.length > LOG_MAX_LENGTH)
				lines.removeItemAt(0);
			lines.addItem({"type" : type, "line" : line, "origin" : origin, "time" : new Date()});
			//_lastMessage = getStringFromType(type) + ": " + line + (origin==null ? "" : " - "+origin);
		}
		
		/** Returns a String with the content of the arraylist of lines (last 100 lines as a default, or 'numLines' if specified)*/
		public static function logDump(numLines : int = -1) : String
		{
			var ret : String = "";
			
			var counter : int = 0;
			
			for each (var entry : Object in lines.source)
			{
				var type:String = getStringFromType(entry.type as int);
				
				ret = (entry.time as Date).toUTCString() + " " + type + ": " + entry.line + (entry.origin==null ? "" : " - " + entry.origin) + "\n" + ret;
				
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
		private static function getStringFromType( type : int):String
		{
			switch (type)
			{
				case ERROR:
				case ERROR_THROW:
					return "Error";
				
				case DEBUG:
					return "Debug";
				
				default:
					return "???";
			}
		}
	}	
}