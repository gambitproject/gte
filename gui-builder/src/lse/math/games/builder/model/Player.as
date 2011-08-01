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
		public function Player(name:String, tree:ExtensiveForm)
		{
			_name = name;
			if (tree != null) {
				if (name == Player.CHANCE_NAME) {
					log.add(Log.ERROR_THROW, "Name " + name + " reserved for chance node");
				}

				if (tree.firstPlayer == null) {
					tree.firstPlayer = this;
					//_prevPlayer = this;
					//_nextPlayer = this;
				} else {				
					var prev:Player = tree.firstPlayer;
					while (prev.nextPlayer != null) {
						prev = prev.nextPlayer;
					}
					prev._nextPlayer = this;
					//_prevPlayer = prev;
					//_nextPlayer = tree.firstPlayer;
					//tree.firstPlayer._prevPlayer._nextPlayer = this;
					//tree.firstPlayer._prevPlayer = this;
				}
				
			} else {
				if (name != CHANCE_NAME) {
					log.add(Log.ERROR_THROW, "Only chance node can have pass a null ExtensiveForm reference");
				}
				//_nextPlayer = tree.firstPlayer;
				//_prevPlayer = tree.firstPlayer;
			}
		}
		
		/** Name of the player */
		public function get name():String {
			return _name;
		}
		
		/** Next player */
		public function get nextPlayer():Player {
			return _nextPlayer;
		}
		
		public function toString():String {
			return _name;
		}
	}
}