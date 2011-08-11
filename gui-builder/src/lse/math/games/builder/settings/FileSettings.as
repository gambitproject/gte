package lse.math.games.builder.settings
{		
	import flash.errors.IllegalOperationError;
	
	import mx.controls.Alert;
	
	/**
	 * This class stores the file in use's settings.<p/>
	 * 
	 * It is a singleton, and instead of calling the constructor directly, you 
	 * should use FileSettings.instance. <p/>
	 * 
	 * Instructions:
	 * <ul>
	 * <li>Check that a setting is stored using hasValue.</li>
	 * <li>Store and access run-time values of the settings using getValue and setValue functions.</li> 
	 * <li>Delete all settings with clear() everytime you close a file (or open a new one)</li>
	 * <li>Set these settings as the default ones with setAsDefault()</li>
	 * </ul><br/>
	 * 
	 * @see SCodes SCodes - For reference on the actual Settings that there exist
	 * <br>@see Settings Settings - for the graphic settings editor, and how to add new settings<br/>
	 * 
	 * @author alfongj 
	 */
	public class FileSettings
	{		
		private static var _instance:FileSettings = null;
		
		private var data:Object;		
		
		/**
		 * DO NOT CALL THE CONSTRUCTOR DIRECTLY, INSTEAD USE FileSettings.instance
		 * <br>This acts like a private constructor
		 */
		public function FileSettings( lock:Class ){
			if( lock != FileSettingsSingletonLock ){
				throw new IllegalOperationError( "Settings is a Singleton, please use the static instance method instead." );
			} else {
				clear();
			}
		}
		
		/**
		 * The Singleton instance of the Settings to use when accessing properties and methods of the Settings.
		 */		
		public static function get instance():FileSettings
		{
			if(_instance == null)
			{
				_instance = new FileSettings(FileSettingsSingletonLock);
			}
			
			return _instance;
		}
		
		
		/** Returns true if it contains value for a specified key */
		public function hasValue( key:Object ):Boolean {
			return data.hasOwnProperty(key);
		}
		
		/**
		 * Retrieves a value in the settings by the specified key. <p/>
		 * 
		 * @param key	(Object) the key that the desired setting data was saved under
		 * @return 		(Object) returns the data saved by key
		 */
		public function getValue( key:Object ):Object {
			return data[key];
		}
		
		/**
		 * Saves a value into the settings under the specified key. <p/>
		 * 
		 * @param key	(String) the key under which to save the value
		 * @param value (Object) the value to be saved
		 */
		public function setValue( key:String, value:Object ):void {
			data[key] = value;
		}
		
			
		
		/** Clears the settings. Should be called when a new file is opened */
		public function clear():void
		{
			data = new Object();
			loadDefaults();
		}
		
		/* Loads all stored values from user's local 'flash cookies' */
		private function loadDefaults():void
		{
			var defSettings:UserSettings = UserSettings.instance;
			
			defSettings.getValue("dummy"); //Run this in case defSettings are not loaded
			
			for(var key:String in defSettings.data)
			{
				if(key.indexOf("DEFAULT")==0)
				{
					var newKey:String = "FILE"+key.substr(7);
					data[newKey] = defSettings.data[key];
				}
			}
		}
		
		/** Sets the current file settings as the default ones */
		public function setAsDefault():void
		{
			var defSettings:UserSettings = UserSettings.instance;
			for(var key:String in data)
			{
				var defKey:String = "DEFAULT"+key.substr(4);
				defSettings.setValue( defKey, data[key] );
			}
		}
	}
}

//Dummy private class for making the constructor artificially private
class FileSettingsSingletonLock {}