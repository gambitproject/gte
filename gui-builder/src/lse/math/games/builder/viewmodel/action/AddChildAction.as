package lse.math.games.builder.viewmodel.action 
{
	import lse.math.games.builder.model.Iset;
	import lse.math.games.builder.model.Move;
	import lse.math.games.builder.model.Node;
	import lse.math.games.builder.model.Player;
	import lse.math.games.builder.presenter.IAction;
	import lse.math.games.builder.viewmodel.DepthAdjuster;
	import lse.math.games.builder.viewmodel.TreeGrid;
	
	/**	
	 * @author Mark Egesdal
	 */
	public class AddChildAction implements IAction
	{
		private var _isetId:int = -1;
		private var _nodeId:int = -1;
		private static var _depthAdjuster:IAction = new DepthAdjuster(); //TODO: remove and use ActionChain or onAdd decorator
		
		
		public function AddChildAction(iset:Iset, node:Node) 
		{
			if (iset != null) _isetId = iset.idx;
			if (node != null) _nodeId = node.number;
		}
		
		
		public function doAction(grid:TreeGrid):void
		{			
			var iset:Iset = null;
			if (_isetId >= 0) {
				iset = grid.getIsetById(_isetId);			
			}
			
			if (iset != null) {
				addChildrenTo(iset, grid);
				_depthAdjuster.doAction(grid);
			} else if (_nodeId >= 0) {				
				var node:Node = grid.getNodeById(_nodeId);
				if (node != null) {
					node.makeNonTerminal();
					addChildrenTo(node.iset, grid);
					_depthAdjuster.doAction(grid);
				}
			}
		}
		
		private function addChildrenTo(parent:Iset, grid:TreeGrid):void
		{			
			var player:Player = null;
			var lastPlayableNode:Node = parent.firstNode;
			while (true) {
				if (lastPlayableNode.iset.player != Player.CHANCE) {
					player = lastPlayableNode.iset.player.nextPlayer;
					break;
				} else if (lastPlayableNode.parent == null) {
					break;
				}
				lastPlayableNode = lastPlayableNode.parent;
			}
			if (player == null) {
				player = grid.firstPlayer;
			}			
			if (parent.isChildless)
			{				
				var h:Iset = parent.newIset(player);
				parent.addMoveTo(h);
				parent.addMoveTo(h);
			} else if (childrenInOneIsetAndChildless(parent)) {
				
				// if all children in one Iset and without children
				// add new child to each node in Iset and place these
				// children in same Iset as existing children
				parent.addMoveTo(parent.firstNode.firstchild.iset);
				
				// make nextInIset of new Node the nextInIset
				// of previous lastchild and
				// make the new node the nextInIset of lastchild				
			} else {				
				parent.addMove(player);
				
				// TODO: this behavior below needs work and has some bugs...
				
				/*var moveNodes:Vector.<Node> = new Vector.<Node>();
				for (var mate:Node = parent.firstNode; mate != null; mate = mate.nextInIset) {
					moveNodes.push(mate.firstchild);
				}				
				var dest:Iset = null;
				while (moveNodes[0] != null && dest == null) 
				{					
					var baseline:Move = null;
					for (var i:int = 0; i < moveNodes.length; ++i) {
						if (moveNodes[i].isLeaf) {
							if (baseline == null) {
								baseline = moveNodes[i].reachedby;
								dest = moveNodes[i].iset;								
							} else if (baseline != moveNodes[i].reachedby) {								
								dest = null;								
							}
						} else {							
							dest = null;
						}
						moveNodes[i] = moveNodes[i].sibling;
					}
				}
				if (dest == null) {
					dest = parent.newIset(player);
				}
				parent.addMoveTo(dest);*/			
			}			
		}	
		
		private function childrenInOneIsetAndChildless(iset:Iset):Boolean
		{
			// true if all children of nodes in this 
			// Iset are in one iset and childless
			var ok:Boolean = true;
			var y:Node = iset.firstNode;
			if (y.isLeaf) {
				ok = false;
			} else {
				var h:Iset = y.firstchild.iset;
				if (h == null) {
					ok = false;
				}

				while (ok && y != null) { //go through nodes in Iset
					var z:Node = y.firstchild;
					
					while (ok && z != null) {
						ok = ((z.iset == h)&&(z.firstchild == null));
						z = z.sibling;
					}
					y = y.nextInIset;
				}
			}
			return ok;
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
	}
}