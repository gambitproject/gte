package lse.math.games.builder.model 
{	
	import org.flexunit.Assert;

	/**
	 * @author alfongj
	 */
	public class PlayerTest
	{
		[Test]
		public function testNewPlayer():void
		{
			var tree:ExtensiveForm = new ExtensiveForm();
			var play1:Player = new Player("1", tree);
			var play2:Player = new Player("2", tree);
			var play3:Player = new Player("3", tree);
			
			Assert.assertEquals(play1.name, "1");
			Assert.assertEquals(play1.nextPlayer.name, "2");
			Assert.assertEquals(play1.nextPlayer.nextPlayer.name, "3");
		}
	}
}