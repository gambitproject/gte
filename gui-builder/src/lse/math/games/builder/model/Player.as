package lse.math.games.builder.model 
{	
	/**
	 * @author Mark
	 */
	public class Player
	{
		public static const CHANCE:Player = new Player(CHANCE_NAME, null);
		public static const CHANCE_NAME:String = "chance";
		
		private var _firstMove:Move;
		private var _lastMove:Move;
		
		private var _name:String;
		
		private var _nextPlayer:Player = null;
		//private var _prevPlayer:Player = null;
		
		public function Player(name:String, tree:ExtensiveForm)
		{
			_name = name;
			if (tree != null) {
				if (name == Player.CHANCE_NAME) {
					throw new Error("Name " + name + " reserved for chance node");
				}

				if (tree.firstPlayer == null) {
					tree.setFirstPlayer(this);
					//_prevPlayer = this;
					//_nextPlayer = this;
				} else {				
					//_nextPlayer = tree.firstPlayer;
					//_prevPlayer = tree.firstPlayer.prevPlayer;
					var prev:Player = tree.firstPlayer;
					while (prev.nextPlayer != null) {
						prev = prev.nextPlayer;
					}
					prev._nextPlayer = this;
					//tree.firstPlayer._prevPlayer._nextPlayer = this;
					//tree.firstPlayer._prevPlayer = this;
				}
				
			} else {
				if (name != CHANCE_NAME) {
					throw new Error("Only chance node can have pass a null ExtensiveForm reference");
				}
				//_nextPlayer = this;
				//_prevPlayer = this;
			}
		}
		
		public function get name():String {
			return _name;
		}
		
		public function get nextPlayer():Player {
			return _nextPlayer;
		}
		
		public function toString():String {
			return _name;
		}
	}
}