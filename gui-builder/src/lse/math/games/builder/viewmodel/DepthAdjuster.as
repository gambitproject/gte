package lse.math.games.builder.viewmodel 
{
	import lse.math.games.builder.model.Iset;
	import lse.math.games.builder.model.Node;
	import lse.math.games.builder.presenter.IAction;
	
	/**
	 * @author Mark Egesdal
	 */
	public class DepthAdjuster implements IAction
	{
		
		public function DepthAdjuster() {}
		
		public function doAction(grid:TreeGrid):void
		{						
			alignDepths(grid);
			sortOutCollisions(grid);
		}
		
		public function get changesData():Boolean {
			return true;
		}
		
		public function get changesSize():Boolean {
			return true;
		}
		
		public function get changesDisplay():Boolean {
			return true;
		}
		
		private function sortOutCollisions(grid:TreeGrid):void
		{
			// We should create the priority queue of the depth groups that were just found
			// Create a priority queue of nodes by (1) depth and (2) leftOf			
			var queue:DynamicNodePriorityQueue = new DynamicNodePriorityQueue(grid.root);
			
			// Take a node off queue:
			// 1. If iset == null, NEXT
			// 2. If nextInIset == null, NEXT
			// 3. Get nextInIset and compare depths
			// 3a. If same depth: PROCESS
			// 3b. Else, NEXT
			
			while (!queue.isEmpty) {
				var toProcess:Node = queue.shift();
				if (toProcess.iset == null) {
					continue;
				}					
				
				// get next in iset as this level
				var nextInIsetAtDepth:Node = null;
				for (var nextInIset:Node = toProcess.nextInIset; nextInIset != null; nextInIset = nextInIset.nextInIset) {
					if (nextInIset.depth == toProcess.depth) {
						nextInIsetAtDepth = nextInIset;
						break;
					}
				}
				if (nextInIsetAtDepth == null) {					
					continue;
				}
				
				// PROCESS:
				// Shift nodes off queue until front of queue is nextInIset
				// Increase the depth of each shifted node by one and add back to queue					
				while (queue.front != nextInIsetAtDepth) 
				{
					var toCheck:TreeGridNode = queue.shift() as TreeGridNode;
					
					// choose iset to increment (only affects nodes in iset with depth greater or equal to current depth)
					// TODO: adjust span to just consider current depth instead of whole iset
					// for all items in the iset to the left with depth equal to current depth, increment and add back to queue
					// for all items in the iset to the left with depth greater than current depth...
					//      or items to the right with depth greater or equal to current depth, REMOVE and then increment and add back							
										
					var toAdjust:Node = toCheck;
					if (toCheck.iset == null) {						
						toAdjust = toProcess;
					} else if (toCheck.iset.span < toProcess.iset.span) {
						
						// We need to make sure that iset that is coming in does not have ancestors in common with the swapping set
						// To keep it simple we only allow the swap if entire iset is at the current depth or less
						toAdjust = toProcess;
						for (var toCheckMate:Node = toCheck.iset.firstNode; toCheckMate != null; toCheckMate = toCheckMate.nextInIset) {
							if (toCheckMate.depth > toProcess.depth) {
								toAdjust = toCheck;
								break;
							}
						}
					}
					
					// TODO: how to prevent same iset from getting processed multiple times
					if (pushDownAllIsetDependents(toAdjust, toAdjust.depth)) {
						queue.dirty();
					}
					
					if (toAdjust == toProcess) {
						break;
					}
				}				
			}
		}
		
		private function pushDownAllIsetDependents(node:Node, depth:int):Boolean
		{		
			var didAdjustments:Boolean = false;

			for (var child:Node = node.firstChild; child != null; child = child.sibling) {
				if (pushDownAllIsetDependents(child, depth + 1)) {
					didAdjustments = true;
				}
			}
			
			if (node.depth == depth) {				
				(node as TreeGridNode).assignDepth(depth + 1);				
				didAdjustments = true;
			}
			
			if (node.iset != null) {
				for (var isetNode:Node = node.iset.firstNode; isetNode != null; isetNode = isetNode.nextInIset) {
					if (isetNode.depth == depth && isetNode != node) {
						if (pushDownAllIsetDependents(isetNode, depth)) {
							didAdjustments = true;
						}											
					}
				}
			}						
			
			return didAdjustments;
		}
		
		private function alignDepths(grid:TreeGrid):void
		{
			// sort nodes with (1) lowest BASE depth first and (2) left Of first 
			// so, we should clear depth delta before insertion into the pqueue
			var queue:NodePriorityQueue = new NodePriorityQueue();
			recAddToQueue(grid.root, queue);
			
			while (!queue.isEmpty) {				
				var node:Node = queue.shift();
				
				// nothing to do for nodes with no isets or singleton isets
				if (node.iset == null || node.iset.numNodes == 1) {
					continue;
				}
				
				// record current depth
				var below:int = node.depth;
				var above:int = -1;
				var potentialPulls:Vector.<Node> = new Vector.<Node>();
				
				// find the next lower (closest to the root) depth in the iset
				// while we are at it remove all items in the iset at the same depth from the queue
				for (var isetNode:Node = node.iset.firstNode; isetNode != null; isetNode = isetNode.nextInIset) {
					if (isetNode != node) {
						if (isetNode.depth < below) {							
							if (isetNode.depth > above) {
								above = isetNode.depth;
							}
						} else if (isetNode.depth == below) {
							var removeIdx:int = queue.remove(isetNode);
							if (removeIdx == -1) throw new Error("Node was not found in queue");
						}
					}
				}				
							
				// if the next lower depth == the current depth, this iset is finished and we move on			
				if (above == -1) {
					continue;
				}
				
				// add all the potential pulls
				for (var potentialPull:Node = node.iset.firstNode; potentialPull != null; potentialPull = potentialPull.nextInIset) {
					if (potentialPull.depth == above) {
						potentialPulls.push(potentialPull);
					}
				}
				
				// ignore nodes in iset with greater depth			
				// otherwise for all nodes <= currentDepth and > lowestDepth 
				// recursively add all nodes in ancestor isets smaller than the currentDepth
				var nodeSet:Vector.<Node> = new Vector.<Node>();
				recAddAncestorIsetNodes(below, above, node.iset, nodeSet);
				
				// once we have that set complete, we can go through the nodes in the starting iset that are less than the current depth
				// on a node-by-node basis, check to see if it has descendants in the set (only need to check descendants up to the current depth)
				// if there are no descendants, move to current depth and remove from queue... otherwise stay put
				while (potentialPulls.length > 0) {
					var toPull:TreeGridNode = potentialPulls.pop() as TreeGridNode;
					if (!recHasDecendantsInNodeSet(toPull, below, nodeSet)) {
						toPull.assignDepth(below);						
						
						// any depth change of a node requires removal from the queue to keep sort order consistent
						queue.remove(toPull);						
						
						// we need to add children back to queue if they were already processed
						for (var pulledChild:Node = toPull.firstChild; pulledChild != null; pulledChild = pulledChild.sibling) {
							if (!queue.contains(pulledChild)) {
								queue.push(pulledChild);
							}
						}
					}
				}				
			}
		}		
		
		private static function recHasDecendantsInNodeSet(node:Node, maxDepth:int, nodeSet:Vector.<Node>):Boolean
		{
			var hasDecendants:Boolean = (nodeSet.indexOf(node) != -1);
			if (!hasDecendants) {
				if (node.depth < maxDepth) {
					for (var child:Node = node.firstChild; child != null; child = child.sibling) {
						hasDecendants = recHasDecendantsInNodeSet(child, maxDepth, nodeSet);
						if (hasDecendants) {
							break;
						}
					}
				}
			}
			return hasDecendants;
		}
				
		private static function recAddAncestorIsetNodes(bottom:int, top:int, iset:Iset, nodeSet:Vector.<Node>):void
		{
			if (bottom == top) {
				return;
			}
			
			for (var node:Node = iset.firstNode; node != null; node = node.nextInIset) {
				if (node.depth == bottom) {
					if (nodeSet.indexOf(node) == -1) {
						nodeSet.push(node);
					}					
					if (node.parent != null) {
						recAddAncestorIsetNodes(bottom - 1, top, node.parent.iset, nodeSet);
					}
				}
			}
		}
		
		// add to the queue depth first with depth deltacleared
		// TODO: add children from right to left to optimize queueing time... need a new pointer to prevSibling
		private function recAddToQueue(node:Node, queue:NodePriorityQueue):void
		{			
			for (var child:Node = node.firstChild; child != null; child = child.sibling) {
				recAddToQueue(child, queue);				
			}
			(node as TreeGridNode).resetDepth();
			queue.push(node);
		}
	}
}
import lse.math.games.builder.model.Node;
class DynamicNodePriorityQueue
{	
	private var _dequeued:Node;
	private var _depth:int;
	private var _root:Node;
	private var _front:Node;
	private var _dirty:Boolean;
	
	function DynamicNodePriorityQueue(root:Node) 
	{
		_root = _front = root;
		_depth = root.depth;
		_dirty = false;
	}
	
	public function get front():Node {
		return getNextInQueue();
	}
	
	public function get isEmpty():Boolean {
		return getNextInQueue() == null;
	}
	
	public function dirty():void 
	{
		_dirty = true;
	}
	
	public function shift():Node 
	{		
		_dequeued = getNextInQueue();
		_dirty = true;
		return _dequeued;
	}
	
	private function getNextInQueue():Node 
	{
		if (_dirty) {			
			if (_dequeued != null) {
				_front = _dequeued.getNextNodeToRightAt(_depth);
				if (_front == null) {
					++_depth;					
					_front = _root.getFirstNodeInSubtreeAt(_depth);
				}
			}
			_dirty = false;
		}
		return _front;
	}
}