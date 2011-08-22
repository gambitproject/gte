package lse.math.games.builder.model 
{	
	import util.Log;

	/**
	 * This class represents one player of the game, which just contains a 
	 * name, and belongs to a linked list of players.</p>
	 * 
	 * @author Mark
	 */
	public class Player
	{
		/* TODO: Consider making the list of players circular. Apart from 
		  correcting other classes, the only thing to do is uncomment the commented
		  code below (I presume, but make sure of it) */
		
		public static const CHANCE:Player = new Player(CHANCE_NAME, null);
		public static const CHANCE_NAME:String = "chance";
		
		private var _name:String;
		
		private var _nextPlayer:Player = null;
		//private var _prevPlayer:Player = null;
		
		private var log:Log = Log.instance;
		
		
		
		/** Creates the player and inserts it in the linked list of players */
		public function Player(name:String, game:Game)
		{
			_name = name;
			if (game != null) {
				if (name == Player.CHANCE_NAME) {
					log.add(Log.ERROR_THROW, "Name " + name + " reserved for chance node");
				}

				if (game.firstPlayer == null) {
					game.firstPlayer = this;
					//_prevPlayer = this;
					//_nextPlayer = this;
				} else {				
					var prev:Player = game.firstPlayer;
					while (prev.nextPlayer != null) {
						prev = prev.nextPlayer;
					}
					prev._nextPlayer = this;
					//_prevPlayer = prev;
					//_nextPlayer = game.firstPlayer;
					//game.firstPlayer._prevPlayer._nextPlayer = this;
					//game.firstPlayer._prevPlayer = this;
				}
				
			} else {
				if (name != CHANCE_NAME) {
					log.add(Log.ERROR_THROW, "Only chance node can have pass a null Game reference");
				}
				//_nextPlayer = game.firstPlayer;
				//_prevPlayer = game.firstPlayer;
			}
		}
		
		/** Name of the player */
		public function get name():String {	return _name; }
		
		/** Next player */
		public function get nextPlayer():Player { return _nextPlayer; }
		
		/** If the player is last */
		public function get isLast():Boolean { return _nextPlayer==null; }
		//Note: isLast should be modified internally if the list is made circular,
		//and also, most loops through players in other classes that use 'player!=null' as 
		//stopping criteria when cycling through players. To find those loop, just look 
		//for every reference to the 'get nextPlayer()' function 
		//(Ctrl+Shift+G in Windows FlashBuilder 4.5)
		
		public function toString():String {
			return _name;
		}
	}
}