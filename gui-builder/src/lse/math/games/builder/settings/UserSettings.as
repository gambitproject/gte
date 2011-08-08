package lse.math.games.builder.settings
{		
	import flash.errors.IllegalOperationError;
	import flash.net.SharedObject;
	import flash.system.Security;
	
	import util.Log;
	
	/**
	 * This class stores user settings, and can dump them to a local 'cookie-like' 
	 * shared object, if the user allows local flash storage. <p/>
	 * 
	 * It is a singleton, and instead of calling the constructor directly, you 
	 * should use UserSettings.instance. <p/>
	 * 
	 * Instructions:
	 * <ul>
	 * <li>Store and access run-time values of the settings using getValue and setValue functions.</li> 
	 * <li>Dump stored settings from and to the local 'cookie-like' storage with loadCookies() and saveCookies()</li>
	 * <li>Check cookies can be stored and ask the user to change the setting if necessary with checkCookiesStorable() and askForCookiesStorable() </li>
	 * <li>Delete all saved cookies with clearCookies()</li>
	 * </ul><br/>
	 * 
	 * @see SCodes SCodes - For reference on the actual Settings that there exist
	 * <br>@see Settings Settings - for the graphic settings editor, and how to add new settings<br/>
	 * 
	 * @author <b>alfongj</b> based on <a href="http://ianserlin.com">Ian Serlin</a>'s work 
	 */
	public class UserSettings
	{		
		private static var _instance:UserSettings = null;
		
		private const FILENAME:String = "settings";
		
		private var data:Object;
		private var _settings_RSO:SharedObject	= null;
		private var _loaded:Boolean = false;
		
		private var log:Log = Log.instance; 
		
		
		
		/**
		 * DO NOT CALL THE CONSTRUCTOR DIRECTLY, INSTEAD USE UserSettings.instance
		 * <br>This acts like a private constructor
		 */
		public function UserSettings( lock:Class ){
			if( lock != SettingsSingletonLock ){
				throw new IllegalOperationError( "Settings is a Singleton, please use the static instance method instead." );
			} else {
				_settings_RSO = SharedObject.getLocal( FILENAME, "/" );
				data = new Object();
			}
		}
		
		/**
		 * The Singleton instance of the Settings to use when accessing properties and methods of the Settings.
		 */		
		public static function get instance():UserSettings
		{
			if(_instance == null)
			{
				_instance = new UserSettings(SettingsSingletonLock);
			}
			
			return _instance;
		}
		
		/** If the settings have been loaded from local storage */
		public function get loaded():Boolean
		{
			return _loaded;
		}
		
		/**
		 * Retrieves a value in the settings by the specified key. <p/>
		 * 
		 * @param key	(Object) the key that the desired setting data was saved under
		 * @return 		(Object) returns the data saved by key
		 */
		public function getValue( key:Object ):Object {
			if(!_loaded)
				firstLoad();
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
		
		/** 
		 * Checks if user allows 'cookies' storage, and if there is space available.
		 * 
		 * @author Jesse Stratford
		 */
		public function get cookiesStorable():Boolean
		{
			//TODO: Not working in IE when the user has the setting set to NEVER allow ShraedObj?
			// Create a dummy SO and try to store it
			var mySO:SharedObject = SharedObject.getLocal("test");
			if (mySO==null || !mySO.flush(1)) {
				// SOs not allowed!
				return false;
			} else {
				return true;
			}
		}
		
		
		
		/* 
		* Firstly loads all default values for the settings, then it overwrites the ones stored in user's local cookies
		* <p/> It should be called at the start of the program just once, or if you want to reset settings to the default ones+loaded ones
		*/
		private function firstLoad():void
		{
			if(_loaded)
				log.add(Log.ERROR_HIDDEN, "Warning: Non-saved settings are potentially being overwriting ");
			SCodes.defaultSettings();
			loadCookies();
		}
		
		/** 
		 * Checks if user allows 'cookies' storage, and if there is space available. <br>
		 * If there isn't, it prompts the user to accept them 
		 * 
		 * @author Jesse Stratford
		 */
		public function askForCookiesStorable():void
		{
			if(!cookiesStorable)
				Security.showSettings();
		}
		
		/** Loads all stored values from user's local 'flash cookies' */
		public function loadCookies():void
		{
			for(var key:String in _settings_RSO.data)
			{
				data[key] = _settings_RSO.data[key];
			}
			
			_loaded = true;
		}
		
		/**
		 * Saves all stored values onto user's local 'flash cookies'.
		 * 
		 * @return		(Boolean) true if the values were successfully saved
		 */
		public function saveCookies():Boolean
		{
			for(var key:String in data)
			{
				_settings_RSO.setProperty( key, data[key] );
				if(_settings_RSO.data[key] != data[key])
					return false;
			}
			
			return cookiesStorable;
		}
		
		/** Erases all of the user's cookies */
		public function clearCookies():void
		{
			_settings_RSO.clear();
		}
	}
}

//Dummy private class for making the constructor artificially private
class SettingsSingletonLock {}