package lse.math.games.builder.viewmodel 
{
	import lse.math.games.builder.model.ExtensiveForm;
	import lse.math.games.builder.model.Node;
	
	/**
	 * @author Mark Egesdal
	 */
	public class TreeGridNode extends Node
	{
		private var _adjustedDepth:int = -1;
		private var _xpos:Number;
		private var _ypos:Number;
		
		
		public function TreeGridNode(extensiveForm:TreeGrid, number:int) { 
			super(extensiveForm, number); 
		}
				
		public function get xpos():Number { return _xpos; }
		public function get ypos():Number { return _ypos; }		
		
		public function set xpos(value:Number):void { _xpos = value; }
		public function set ypos(value:Number):void { _ypos = value; }		
		
		override public function get depth():int {
			return _adjustedDepth < 0 ? super.depth : _adjustedDepth;
		}
		
		
		override public function toString():String
		{
			return super.toString() + (!isNaN(_xpos) && !isNaN(_ypos) ? " (" + int(_xpos) + "," + int(_ypos) + ")" : "");
		}
		
		internal function assignDepth(depth:int):void
		{
			_adjustedDepth = depth;
		}
		
		internal function resetDepth():void
		{
			_adjustedDepth = -1;
		}
	}
}