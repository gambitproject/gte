package lse.math.games.tree;

public class Player {	
	public static final String CHANCE_NAME = "!";
	public static final Player CHANCE = new Player(CHANCE_NAME);
	
	public Player next;
	
	private String _playerId;
	
	public Player(String playerId) {
		_playerId = playerId;
	}
	
	@Override
	public String toString()
	{
		return _playerId;
	}
}
