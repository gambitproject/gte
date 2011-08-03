package util
{
	import flash.errors.IllegalOperationError;
	import flash.events.EventDispatcher;

	/**
	 * EventManager is a singleton class that can act as Event Dispatcher
	 * and listener for any class, without them having to be related. </p>
	 * 
	 * Use this class by calling EventManager.instance, and not by calling 
	 * the constructor. </p>
	 * 
	 * Call this.dispatchEvent() to dispatch a new event, addEventListener()
	 * to add a listener, and removeEventListener for removing it. </p>
	 * 
	 * @author alfongj
	 */
	public class EventManager extends EventDispatcher
	{
		private static var _instance:EventManager = null;
		
		
		
		/**
		 * DO NOT CALL THE CONSTRUCTOR DIRECTLY, INSTEAD USE EventManager.instance
		 * <br>This acts like a private constructor
		 */
		public function EventManager( lock:Class ){
			if( lock != EventManagerSingletonLock ){
				throw new IllegalOperationError( "Settings is a Singleton, please use the static instance method instead." );
			}
		}
		
		/**
		 * The Singleton instance of the Settings to use when accessing properties and methods of the Settings.
		 */		
		public static function get instance():EventManager
		{
			if(_instance == null)
			{
				_instance = new EventManager(EventManagerSingletonLock);
			}
			
			return _instance;
		}
	}
	
}

//Dummy private class for making the constructor artificially private
class EventManagerSingletonLock {}