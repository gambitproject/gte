package lse.math.games.builder.viewmodel.action 
{
	import flash.utils.getTimer;
	
	import lse.math.games.builder.presenter.IAction;
	import lse.math.games.builder.viewmodel.TreeGrid;
	
	import util.Log;
	
	/**	
	 * Rotates the tree to a certain orientation. <p/>
	 * <li>NOT <strike>Changes Data</strike></li>
	 * <li>Changes Size</li>
	 * <li>Changes Display</li>
	 * @author Mark Egesdal & alfongj
	 */
	public class RotateAction implements IAction
	{
		//public static const CLOCKWISE:String = "clockwise";
		//public static const COUNTERCLOCKWISE:String = "counterclockwise";
		
		//Root positions
		public static const UP:String = "up";
		public static const LEFT:String = "left";
		public static const DOWN:String = "down";
		public static const RIGHT:String = "right";
		
		private var _direction:String = null;
		
		private var _timeElapsed:int = 0;
		
		
		
		public function get timeElapsed():int {return _timeElapsed; }
		
		public function RotateAction(direction:String) 
		{
			switch(direction)
			{
//				case CLOCKWISE:
//				case COUNTERCLOCKWISE:
//					trace("Rotation direction " + direction + " is deprecated. Please check the Documentation");
				case UP:
				case DOWN:
				case RIGHT:
				case LEFT:
					_direction = direction;
					break;
				default:
					Log.instance.add(Log.ERROR_HIDDEN, "Rotate direction must be UP, DOWN, RIGHT or LEFT");
			}
		}
		
		public function doAction(grid:TreeGrid):void {
			var prevTime:int = getTimer();
			
			switch(_direction)
			{
//				case CLOCKWISE:
//					grid.rotateRight();
//					break;
//				case COUNTERCLOCKWISE:
//					grid.rotateLeft();
//					break;
				case UP:
					grid.rotate = 0;
					break;
				case DOWN:
					grid.rotate = 2;
					break;
				case RIGHT:
					grid.rotate = 3;
					break;
				case LEFT:
					grid.rotate = 1;
					break;
			}
			
			_timeElapsed = getTimer() - prevTime;
		}		
		
		public function get changesData():Boolean {
			return false;
		}
		
		public function get changesSize():Boolean {
			return true;
		}
		
		public function get changesDisplay():Boolean {
			return true;
		}	
	}
}