package lse.math.games.builder.view
{
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	
	import spark.components.Scroller;
	
	/**
	 * Scroller that can scroll its contents by following mouse movement
	 * 
	 * To use it, you can either force a certain scroll amount using scroll()
	 * or you can enableMouseScrolling(), that will automatically drag the contents of the 
	 * window when the mouse is pressed, and disableMouseScrolling() after it has been used
	 * @author alfongj
	 */
	public class MouseScroller extends Scroller
	{
		private var _mouseScrollingEnabled:Boolean = false; 
		private var _nowScrolling:Boolean = false;
		
		private var lastX:Number;
		private var lastY:Number;
		
		/** True if the Scroller is either scrolling, or waiting for mouse press for starting scrolling */
		public function get mouseScrollingEnabled():Boolean
		{
			return _mouseScrollingEnabled;
		}
		
		/** True if the Scroller is scrolling right now */
		public function get nowScrolling():Boolean
		{
			return _nowScrolling;
		}

		/** Scrolls the contents of the scroller horizontally in 'x' pixels and vertically in 'y' pixels */
		public function scroll(x:Number, y:Number):void
		{
			viewport.horizontalScrollPosition += x;
			viewport.verticalScrollPosition += y;
		}
		
		/** 
		 * Adds a new listener that when detects a mouse press starts scrolling
		 * Should be deactivated with 'disableMouseScrolling()' afterwards
		 */
		public function enableMouseScrolling():void
		{
			if(_mouseScrollingEnabled)
				return;
			
			addEventListener(MouseEvent.MOUSE_DOWN, startMouseScrolling);
			
			_mouseScrollingEnabled = true;
		}
		
		/** Disables mouse scrolling, and it won't work again until 'enableMouseScrolling()' is run */
		public function disableMouseScrolling():void
		{
			if(!_mouseScrollingEnabled)
				return;
			
			if(_nowScrolling)
				stopMouseScrolling();
			
			removeEventListener(MouseEvent.MOUSE_DOWN, startMouseScrolling);
			
			_mouseScrollingEnabled = false;
		}
		
		//Starts tracking mouse movement and moving the Scroller contents following it 
		private function startMouseScrolling(event:MouseEvent):void
		{
			lastX = event.stageX;
			lastY = event.stageY;
			addEventListener(MouseEvent.MOUSE_UP, stopMouseScrolling);
			addEventListener(MouseEvent.MOUSE_MOVE, dragContents);
			_nowScrolling = true;
		}
		
		//Updates content position with mouse cursor movement 
		private function dragContents(event:MouseEvent):void
		{
			scroll(lastX-event.stageX, lastY-event.stageY);
			lastX = event.stageX;
			lastY = event.stageY;
		}
		
		//Starts tracking mouse movement and moving the Scroller contents following it 
		private function stopMouseScrolling(event:MouseEvent = null):void
		{
			removeEventListener(MouseEvent.MOUSE_UP, stopMouseScrolling);
			removeEventListener(MouseEvent.MOUSE_MOVE, dragContents);
			_nowScrolling = false;
		}
	}
}