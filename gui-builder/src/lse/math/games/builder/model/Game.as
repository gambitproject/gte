package lse.math.games.builder.model
{
	/**
	 * Primitive class that contains info and functions to work with players.
	 * 
	 * @author alfongj
	 */
	public class Game
	{
		protected var _firstPlayer:Player = null;

		/** Player who normally moves first in the game */
		public function set firstPlayer(player:Player):void { _firstPlayer = player; }
		public function get firstPlayer():Player { return _firstPlayer; }

		/** Number of players in the game */
		public function get numPlayers():int {
			var count:int = 0;
			var player:Player = _firstPlayer;
			while (player!=null){
				count++;
				if(player.isLast)
					break;
				else
					player = player.nextPlayer;
			} 
			
			return count;
		}
		
	}
}