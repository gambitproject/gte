package lse.math.games.builder.viewmodel.action 
{
	import lse.math.games.builder.presenter.IAction;
	import lse.math.games.builder.viewmodel.TreeGrid;
	
	/**	
	 * Rotates the tree clock or counterclockwise
	 * <li>NOT <strike>Changes Data</strike></li>
	 * <li>Changes Size</li>
	 * <li>Changes Display</li>
	 * @author Mark Egesdal
	 */
	public class RotateAction implements IAction
	{
		public static const CLOCKWISE:String = "clockwise";
		public static const COUNTERCLOCKWISE:String = "counterclockwise";
		
		private var _direction:String = null;
		public function RotateAction(direction:String) 
		{
			if (direction == CLOCKWISE) {
				_direction = CLOCKWISE;
			} else if (direction == COUNTERCLOCKWISE) {
				_direction = COUNTERCLOCKWISE;
			} else {
				throw new Error("Rotate direction must be one of 'clockwise' or 'counterclockwise'");
			}
		}
		
		public function doAction(grid:TreeGrid):void {
			if (_direction == CLOCKWISE) {
				grid.rotateRight();
			} else {
				grid.rotateLeft();
			}
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