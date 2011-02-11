package lse.math.games.builder.viewmodel 
{
	import flashx.textLayout.operations.ModifyInlineGraphicOperation;
	import lse.math.games.builder.model.Iset;
	import lse.math.games.builder.model.Node;	
	import lse.math.games.builder.presenter.ActionChain;
	import lse.math.games.builder.presenter.IAction;
	import lse.math.games.builder.viewmodel.action.*;
	
	/**	
	 * @author Mark Egesdal
	 */
	public class TreeGridActionFactory
	{		
		private static const _depthAdjuster:DepthAdjuster = new DepthAdjuster();
		
		public function TreeGridActionFactory() {}
		
		public function mergeIsets(grid:TreeGrid, x:Number, y:Number):IAction
		{
			var iset:Iset = grid.findIset(x, y);
			var action:MergeAction = null;
			if (iset != null) {
				action = new MergeAction(grid, iset);			
				action.onMerge = _depthAdjuster;
			}
			return action;
		}
		
		public function outcomeDataUpdate(grid:TreeGrid, nodeId:int, pathIn:String, pay1:Number, pay2:Number):IAction
		{
			var chain:ActionChain = null;
			var n:Node = grid.getNodeById(nodeId);
			if (n != null) {
				chain = new ActionChain();				
				
				if (grid.isZeroSum) {
					pay2 = -pay1;				
				}
				if (!isNaN(pay1) || !isNaN(pay2)) { //if neither is a number don't bother...
					var action:IAction = new PayChangeAction(nodeId, pay1, pay2);
					chain.push(action);
				}
				
				// parse and assign moves at same time, so that undo is atomic
				// use pop to get off the bottom work from selected leaf back up
				var moveLabels:Array = pathIn.split(" ");
				var numLevels:int = n.numAncestors;
				while (numLevels > moveLabels.length) {
					n = n.parent;
					--numLevels;
				}
				// now moveLabels is >= number of nodes to label
				while (n != null) {
					var moveLabel:String = moveLabels.pop();
					action = new LabelChangeAction(n.number, moveLabel);
					chain.push(action);
					n = n.parent;
				}
				chain.push(_depthAdjuster);
			}
			return chain;
		}
		
		public function randomPayoffs(grid:TreeGrid):IAction
		{
			var chain:ActionChain = new ActionChain();			
			for (var leaf:Node = grid.root.firstLeaf; leaf != null; leaf = leaf.nextLeaf) 
			{
				var pay1:Number = randomInt(grid.maxPayoff);
				var pay2:Number = grid.isZeroSum ? -pay1 : randomInt(grid.maxPayoff);								
				var action:IAction = new PayChangeAction(leaf.number, pay1, pay2);
				chain.push(action);
			}
			chain.push(_depthAdjuster);
			return chain;
		}
		
		public function label(grid:TreeGrid):IAction
		{			
			return new AutoLabelAction();
		}
		
		public function rotateRight(grid:TreeGrid):IAction
		{			
			return new RotateAction(RotateAction.CLOCKWISE);
		}
		
		public function rotateLeft(grid:TreeGrid):IAction
		{			
			return new RotateAction(RotateAction.COUNTERCLOCKWISE);
		}
		
		public function perfectRecall(grid:TreeGrid):IAction
		{			
			var chain:ActionChain = new ActionChain();			
			chain.push(new PerfectRecallAction());
			chain.push(_depthAdjuster);
			return chain;
		}
		
		public function makeZeroSumPayoffs(grid:TreeGrid):IAction
		{
			var chain:ActionChain = new ActionChain();			
			for (var leaf:Node = grid.root.firstLeaf; leaf != null; leaf = leaf.nextLeaf) 
			{
				if (leaf.outcome != null) {	
					var pay:Number = leaf.outcome.pay(grid.firstPlayer)
					var action:IAction = new PayChangeAction(leaf.number, pay, -pay);
					chain.push(action);
				}
			}
			chain.push(new DepthAdjuster());
			return chain;
		}
		
		public function cutIset(grid:TreeGrid, x:Number, y:Number):IAction
		{
			var beforeCut:Node = null;
			for (var h:Iset = grid.root.iset; h != null; h = h.nextIset) {
				beforeCut = grid.getNodeInIsetBeforeCoords(h, x, y, TreeGrid.ISET_DIAM/2);	
				if (beforeCut != null) {					
					break;
				}
			}
			
			// TODO: if after the cut != after the cut at the node's depth, then we have to do a cut and some merges
			// we need to figure out where the draw lines are compared to the click and partition the nodes into two groups
			// it will then create two new isets, one for the left and one for the right of the cut			
					
			var action:ActionChain = null;
			if (beforeCut != null) {
				action = new ActionChain();
				action.push(new CutAction(beforeCut));
				action.push(_depthAdjuster);
			}
			return action;			
		}		
		
		public function addChild(grid:TreeGrid, x:Number, y:Number):IAction 
		{
			var h:Iset = grid.findIset(x, y);
			var n:Node = grid.findNode(x, y);
			var action:IAction = null;
			if (h != null || n != null) {
				action = new AddChildAction(h, n);
			}
			return action;
		}
		
		public function dissolveIset(grid:TreeGrid, x:Number, y:Number):IAction
		{
			var h:Iset = grid.findIset(x, y);
			var chain:ActionChain = null;
			
			if (h != null && h.numNodes > 1) {				
				chain = new ActionChain();
				chain.push(new DissolveAction(h));
				chain.push(_depthAdjuster);
			}
			return chain;				
		}
		
		public function deleteNode(grid:TreeGrid, x:Number, y:Number):IAction
		{
			var n:Node = grid.findNode(x, y);			
			
			var chain:ActionChain = null;
			if (n != null) {				
				chain = new ActionChain();
				chain.push(new DeleteAction(n));
				chain.push(_depthAdjuster);
			}
			return chain;
		}
		
		public function changePlayer(grid:TreeGrid, x:Number, y:Number):IAction
		{
			var h:Iset = grid.findIset(x, y);
			var n:Node = grid.findNode(x, y);			
			
			if (h == null && n == null) return null;
			else return new ChangePlayerAction(h, n);
		}
		
		public function makeChance(grid:TreeGrid, x:Number, y:Number):IAction
		{
			var h:Iset = grid.findIset(x, y);
			var n:Node = grid.findNode(x, y);			
						
			if (h == null && n == null) return null;
			
			var action:MakeChanceAction = new MakeChanceAction(h, n);
			action.onDissolve = _depthAdjuster;
			return action;
		}		
		
		// protected so it can be overridden for endo testing
		protected function randomInt(max:Number):int
		{
			return int(Math.random() * max);
		}
	}
}