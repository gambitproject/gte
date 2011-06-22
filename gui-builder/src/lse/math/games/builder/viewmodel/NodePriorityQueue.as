package lse.math.games.builder.viewmodel 
{	
	import lse.math.games.builder.model.Node;
	
	/**
	 * NodePriorityQueue
	 * 	 
	 * Sorts the nodes from front to back in a priority queue
	 * Deeper nodes and nodes to the right are toward the end
	 * 
	 * In keeping consistent with the Array class:
	 * 
	 * push(value:Node)		adds an item to the queue
	 * remove(value:Node)	removes an item from the queue
	 * shift():Node			remove/return the front of the queue
	 * pop():Node			remove/return the back of the queue 
	 * 
	 * front and back properties can be used to peak
	 * length property will iterate the queue to find a count
	 * 
	 * push() and remove() return position Node was inserted/removed, 
	 * which allows for a measure of algorithm efficieny (in remove(), if it returns -1
	 * the actual number of iterations is equal to length-1)
	 * 
	 * @author Mark Egesdal
	 */
	public class NodePriorityQueue
	{
		private var _front:NodeWrapper = null;
		private var _back:NodeWrapper = null;
		
		public function NodePriorityQueue() {}
		
		public function get front():Node {
			return _front.node;
		}
		
		public function get back():Node {
			return _back.node;
		}
		
		public function get isEmpty():Boolean {
			return _front == null;
		}
		
		public function get length():int {
			var count:int = 0;
			for (var i:NodeWrapper = _front; i != null; i = i.next) {
				++count;
			}
			return count;
		}
		
		/** Inserts a node in its corresponding position, determined by belongsBefore() function 
		 * @return The position in which it is inserted
		 */
		public function push(node:Node):int
		{		
			var idx:int = 0;
			var toAdd:NodeWrapper = new NodeWrapper(node);
			if (isEmpty) {				
				_front = _back = toAdd;				
			} else if (belongsBefore(_front, toAdd)) {
				insertBefore(_front, toAdd);
			} else {			
				for (var enqueued:NodeWrapper = _front; enqueued != null; enqueued = enqueued.next) {
					++idx;					
					if (belongsBefore(enqueued.next, toAdd)) {
						insertAfter(enqueued, toAdd);
						break;
					}					
				}
			}
			return idx;
		}
		
		/** Removes a certain node
		 * @return -1 if node wasn't found, or its pos if it was found and removed
		 */
		public function remove(toRemove:Node):int
		{
			var idx:int = -1;
			if (!isEmpty) {			
				for (var enqueued:NodeWrapper = _front; enqueued != null; enqueued = enqueued.next) {
					++idx;
					if (enqueued.node == toRemove) {
						if (enqueued.next != null) enqueued.next.prev = enqueued.prev;
						if (enqueued.prev != null) enqueued.prev.next = enqueued.next;
						if (_front == enqueued) _front = enqueued.next;
						if (_back == enqueued) _back = enqueued.prev;
						break;
					}
					else if(enqueued.next ==null) //Haven't found the node
						return -1;								
				}
			}
			return idx;	
		}
		
		/** Returns and removes front node */
		public function shift():Node
		{
			var rv:Node = null;
			if (_front != null) {
				rv = _front.node;
				_front = _front.next;
				if (_front == null) {
					_back = null;
				}
			}
			return rv;
		}
		
		/** Returns and removes back node */
		public function pop():Node
		{
			var rv:Node = null;
			if (_back != null) {
				rv = _back.node;
				_back = _back.prev;
				if (_back == null) {
					_front = null;
				}
			}
			return rv;
		}
		
		/** Checks if the list contains certain node */
		public function contains(toCheck:Node):Boolean
		{
			var found:Boolean = false;
			if (!isEmpty) {
				for (var enqueued:NodeWrapper = _front; enqueued != null; enqueued = enqueued.next) {					
					if (enqueued.node == toCheck) {
						found = true;
						break;
					}
				}
			}
			return found;
		}
			
		//Inserts 'toAdd' before 'enqueued'
		private function insertBefore(enqueued:NodeWrapper, toAdd:NodeWrapper):void
		{			
			toAdd.next = enqueued;
			
			toAdd.prev = enqueued.prev;			
			if (toAdd.prev != null) toAdd.prev.next = toAdd;
			enqueued.prev = toAdd;
						
			if (enqueued == _front) {
				_front = toAdd;
			}
		}
				
		//Inserts 'toAdd' after 'enqueued'
		private function insertAfter(enqueued:NodeWrapper, toAdd:NodeWrapper):void
		{			
			toAdd.prev = enqueued;
			
			toAdd.next = enqueued.next;
			if (toAdd.next != null) toAdd.next.prev = toAdd;
			enqueued.next = toAdd;			
			
			if (enqueued == _back) {
				_back = toAdd;
			}
		}
		
		//Returns true if either the enqueued node doesn't exist, if the node toAdd has less depth than it,
		//or if they have the same length but toAdd is to the left of the enqueued one
		private function belongsBefore(enqueued:NodeWrapper, toAdd:NodeWrapper):Boolean
		{
			return (enqueued == null) || 
				(enqueued.node.depth > toAdd.node.depth) ||
				(enqueued.node.depth == toAdd.node.depth && enqueued.node.isRightOf(toAdd.node));
		}
	}
}
import lse.math.games.builder.model.Node;
class NodeWrapper
{
	public var node:Node;
	public var next:NodeWrapper = null;
	public var prev:NodeWrapper = null;
	function NodeWrapper(node:Node) { this.node = node; }
}