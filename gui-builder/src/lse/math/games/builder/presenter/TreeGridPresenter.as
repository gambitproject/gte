package lse.math.games.builder.presenter 
{
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.external.ExternalInterface;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	
	import lse.math.games.builder.fig.FigFontManager;
	import lse.math.games.builder.fig.TreeGridFigWriter;
	import lse.math.games.builder.io.XMLExporter;
	import lse.math.games.builder.io.FileManager;
	import lse.math.games.builder.model.Iset;
	import lse.math.games.builder.model.Node;
	import lse.math.games.builder.model.NormalForm;
	import lse.math.games.builder.model.Player;
	import lse.math.games.builder.model.Rational;
	import lse.math.games.builder.model.Strategy;
	import lse.math.games.builder.settings.FileSettings;
	import lse.math.games.builder.view.Canvas;
	import lse.math.games.builder.view.MouseScroller;
	import lse.math.games.builder.viewmodel.TreeGrid;
	
	import mx.collections.*;
	import mx.controls.Alert;
	import mx.events.*;
	import mx.graphics.codec.PNGEncoder;
	import mx.olap.aggregators.MinAggregator;
	import mx.rpc.http.HTTPService;
	
	import util.Log;
	
	/**	
	 * @author Mark Egesdal
	 */
	
	//TODO: #33 Presenter & MatrixGridPresenter
	public class TreeGridPresenter
	{
		private var _canvas:Canvas;
		private var _fileManager:FileManager;  
		private var _treeActionHandler:TreeActionHandler;		
		private var _grid:TreeGrid;
		
		private var _gridData:ArrayCollection = new ArrayCollection();		
		private var _getClickAction:Function = null;
		private var _getDataUpdateAction:Function = null;
				
		private var log:Log = Log.instance;
		

		
		//private var _modelDirty:Boolean = true;		
				
		public function TreeGridPresenter() 
		{									
			_gridData.addEventListener("collectionChange", onOutcomeEdit);
			_fileManager = new FileManager(this);
			_treeActionHandler  = new TreeActionHandler(_fileManager);
		}
		
		public function set grid(value:TreeGrid):void {
			_grid = value;
		}
		
		/** Current canvas the application is running */
		public function get canvas():Canvas { return _canvas; }
		public function set canvas(canvas:Canvas):void {
			if (canvas == null) {
				throw new Error("Cannot assign a null canvas")
			}
			_canvas = canvas;
			_canvas.addEventListener(MouseEvent.MOUSE_WHEEL, mouseZoomHandle);
			invalidate(true, true, true);
		}
		
		/** 
		 * Object that manages all file managin operations: 
		 * saving, loading, filename changing, etc.
		 */
		public function get fileManager():FileManager { return _fileManager; }
		
		[Bindable]
		public function get isZeroSum():Boolean {			
			return _grid.isZeroSum;
		}
		
		public function set isZeroSum(value:Boolean):void {			
			_grid.isZeroSum = value;
			//TODO: reset the leaves			
		}
		
		[Bindable]
		public function get isNormalReduced():Boolean {			
			return _grid.isNormalReduced;
		}
		
		public function set isNormalReduced(value:Boolean):void {			
			_grid.isNormalReduced = value;
			invalidate(false, true, true);
		}
		
		[Bindable]
		public function get outcomeData():ArrayCollection {			
			return _gridData;
		}
		
		public function set outcomeData(value:ArrayCollection):void {
			_gridData = value;
			invalidate(true, false, false);
		}
		
		[Bindable]
		public function get getClickAction():Function {			
			return _getClickAction;
		}
		
		public function set getClickAction(value:Function):void {
			_getClickAction = value;
			removeSelected(false);
		}
		
		[Bindable]
		public function get getDataUpdateAction():Function {			
			return _getDataUpdateAction;
		}
		
		public function set getDataUpdateAction(value:Function):void {
			_getDataUpdateAction = value;
		}
		
		public function get availableFontFamilies():Array {			
			return FigFontManager.getAvailableFontFamilies();
		}		
				
		[Bindable]
		public function get selectedNode():int {
			return _grid.selectedNodeId;
		}
		
		public function set selectedNode(nodeId:int):void {
			_grid.selectedNodeId = nodeId;			
			invalidate(false, false, true);
		}
		
		public function get player1Name():String {
			return _grid.firstPlayer.name;
		}
				
		public function get player2Name():String {
			return _grid.firstPlayer.nextPlayer.name;
		}
		
		// TODO: how to make these update in a binding?
		public function get numIsets():int {
			return _grid.numIsets;
		}
		
		public function get numNodes():int {
			return _grid.numNodes;
		}	
		
		private function areLeafChanges(viewObj:Object, modelObj:Node):Boolean
		{
			var changes:Boolean = false;
			if (viewObj.leaf != pathInString(modelObj)) {				
				changes = true;
			}
			if (modelObj.outcome != null) {
				var pay1:Rational = modelObj.outcome.pay(_grid.firstPlayer);
				var pay2:Rational = modelObj.outcome.pay(_grid.firstPlayer.nextPlayer);					
				if ((pay1.isNaN && viewObj.pay1 != "?") || 
					(!pay1.isNaN && viewObj.pay1 != pay1.toString()))
				{
					changes = true;
				}
				if ((pay2.isNaN && viewObj.pay2 != "?") || 
					(!pay2.isNaN && viewObj.pay2 != pay2.toString()))
				{
					changes = true;
				}
			} else if (viewObj.pay1 != "?" || viewObj.pay2 != "?") {
				changes = true;			
			}
			return changes;
		}
		
		private var lastSelectedNode:int = -1;
		private var lastMergeBase:Iset = null;
		
		/* Removes the node and or iset currently selected. If keepCopy is true, values are kept before removing them, for later restoration using restoreSelected() */
		private function removeSelected(keepCopy : Boolean):void
		{
			var invalidateDisplay:Boolean = false;
			if (selectedNode >= 0) {
				if(keepCopy)
					lastSelectedNode = selectedNode;
				
				selectedNode = -1;
				invalidateDisplay = true;
			}
			if (_grid.mergeBase != null) {	
				if(keepCopy)
					lastMergeBase = _grid.mergeBase;
				
				_grid.mergeBase = null;
				invalidateDisplay = true;				
			}
			invalidate(false, false, invalidateDisplay);
		}
		
		/* Restores last selected node and or Iset, removed using removeSelected() function */
		private function restoreSelected():void
		{
			var invalidateDisplay:Boolean = false;
			if(lastSelectedNode != -1)
			{
				selectedNode = lastSelectedNode;
				lastSelectedNode = -1;
				invalidateDisplay = true;
			}
			if(lastMergeBase != null)
			{
				_grid.mergeBase = lastMergeBase;
				lastMergeBase = null;
				invalidateDisplay = true;
			}
			invalidate(false, false, invalidateDisplay);
		}
		
		private var _modelDirty:Boolean = true;
		private function updateViewModel():void
		{			
			var dataIdx:int = 0;
							
			if (_modelDirty) {
				_modelDirty = false;
				for (var leaf:Node = _grid.root.firstLeaf; leaf != null; leaf = leaf.nextLeaf) 
				{									
					var leafObj:Object = null;
					var update:Boolean = false;
					// while the current object isn't equal to and is left of the new leaf
					while (true) {
						leafObj = _gridData.length > dataIdx ? _gridData.getItemAt(dataIdx) : null;
						if (leafObj == null) {						
							break;
						} else if (leafObj.uid == leaf.number) {							
							if (areLeafChanges(leafObj, leaf)) {
								update = true;
							}	
							break;						
						} else if (_grid.getNodeById(leafObj.uid) != null && _grid.getNodeById(leafObj.uid).isRightOf(leaf)) {					
							leafObj = null;
							break;
						} else {					
							_gridData.removeItemAt(dataIdx);							
						}
					} 
					if (leafObj == null) 
					{
						leafObj = {
							uid: leaf.number		
						};
						if (_gridData.length <= dataIdx) {
							_gridData.addItem(leafObj);
						} else {
							_gridData.setItemAt(leafObj, dataIdx);
						}
					}
					
					leafObj.leaf = pathInString(leaf);				
					if (leaf.outcome != null) {
						var pay1:Rational = leaf.outcome.pay(_grid.firstPlayer);
						var pay2:Rational = leaf.outcome.pay(_grid.firstPlayer.nextPlayer);					
						leafObj.pay1 = pay1.isNaN ? "?" : pay1.toString();
						leafObj.pay2 = pay2.isNaN ? "?" : pay2.toString();
					} else {
						leafObj.pay1 = "?";
						leafObj.pay2 = "?";
					}
					if (update) {
						_gridData.itemUpdated(leafObj);
					}					
					++dataIdx;
				}
				invalidate(false, true, true);
				_modelDirty = true;				
			}
		}
		
		//Zooms in or out when a MOUSE_WHEEL event is detected
		private function mouseZoomHandle(e:MouseEvent):void
		{
			if(e.type==MouseEvent.MOUSE_WHEEL)
			{
				if(e.delta>0)
					zoomIn();
				else if(e.delta<0)
					zoomOut();
			}
		}
		
		/** Sets zoom to 100% */
		private function resetZoom():void
		{
			_canvas.painter.scale = 1.0;
			_grid.scale = 1.0;
			invalidate(false, true, true);
		}
		
		/** Zooms in by increasing the scale in 1.1 */
		public function zoomIn():void
		{
			var oldScale:Number = _canvas.painter.scale;
			var newScale:Number = oldScale * 1.1;
			if (oldScale < 1 && newScale > 1) {
				newScale = 1.0;
			}
			
			_canvas.painter.scale = newScale;
			_grid.scale = newScale;
			invalidate(false, true, true);
		}
		
		/** Zooms out by dividing the scale in 1.1 */
		public function zoomOut():void
		{
			var oldScale:Number = _canvas.painter.scale;
			var newScale:Number = oldScale / 1.1;
			if (oldScale > 1 && newScale < 1) {
				newScale = 1.0;
			}
			
			_canvas.painter.scale = newScale;
			_grid.scale = newScale;
			invalidate(false, true, true);
		}
		
		/** Adjusts zoom to show the tree optimally */
		public function zoomAdjust():void
		{
			var scroller:DisplayObjectContainer = _canvas.parent;
						
			var width:Number = _canvas.painter.drawWidth;
			var height:Number = _canvas.painter.drawHeight;
			
			var oldScale:Number = _canvas.painter.scale;
			var newScale:Number = oldScale;
			
			if(scroller.width > width && scroller.height > height)
			{
				//Zoom in
				newScale = oldScale * Math.min(scroller.width/width, scroller.height/height);
				if(newScale > 5)
				{
					log.add(Log.HINT, "The tree is still very small, try adding some nodes on it before auto fitting it :)");
					newScale = oldScale;
				}
			}
			else if(scroller.width < width || scroller.height < height)
			{
				//Zoom out
				newScale = oldScale * Math.min(scroller.width/width, scroller.height/height);
			}

			_canvas.painter.scale = newScale;
			_grid.scale = newScale;
			invalidate(false, true, true);
		}
		
		/** 
		 * Creates an action from the 'getAction' function passed as parameter
		 *  Then it executes the action and invalidates whatever is necessary.
		 */
		public function doAction(getAction:Function):void
		{                   
			var action:IAction = getAction(_grid);
			if (action != null) {
				_treeActionHandler.processAction(action, _grid);						
				invalidate(action.changesData, action.changesSize, action.changesDisplay);		
			}
		}
		
		/**
		 * Creates an action from the 'getClickAction' function property, and the x and y coords passed as arguments
		 * <br>Then it executes the action and invalidates whatever is necessary.
		 * <br>It also deselects a node if it was selected
		 */
		public function doActionAt(x:Number, y:Number):void
		{
			if(getClickAction!= null)
			{
				selectedNode = -1;
				var action:IAction = getClickAction(_grid, x, y);
				if (action != null) {
					_treeActionHandler.processAction(action, _grid);									
					invalidate(action.changesData, action.changesSize, action.changesDisplay);
				}
			}
		}		
		
		public function undo():void
		{             
			if (_treeActionHandler.undo(_grid)) {
				invalidate(true, true, true);
			} else {
				log.add(Log.HINT, "No more operations to undo");
			}
		}
		
		public function redo():void
		{             
			if (_treeActionHandler.redo(_grid)) {
				invalidate(true, true, true);
			} else {
				log.add(Log.HINT, "No more operations to redo");
			}
		}	
		
		//When the values in the table at the right hand side get changed, this method is executed, 
		//which creates and processes a series of actions depending on the things modified
		private function onOutcomeEdit(event:CollectionEvent):void
		{
			if (event.kind == CollectionEventKind.UPDATE && _modelDirty) {
				var chain:ActionChain = null;
				for each (var pevent:PropertyChangeEvent in event.items) {																	
					var action:IAction = getDataUpdateAction(_grid, pevent.source.uid, pevent.source.leaf, pevent.source.pay1, pevent.source.pay2);
					if (action != null) {
						if (chain == null) {
							chain = new ActionChain();
						}
						chain.push(action);
					}
				}
				if (chain != null) {
					_treeActionHandler.processAction(chain, _grid);						
					invalidate(chain.changesData, chain.changesSize, chain.changesDisplay);		
				}
			}
		}
		
		/** Invalidates display characteristics that need to be redrawn */
		public function invalidate(model:Boolean, canvasSize:Boolean, display:Boolean):void 
		{
			if (model) {
				updateViewModel();				
			}
			if (display) {
				// TODO: I'm updating labels twice when I switch forms
				_canvas.updateLabels(); // will trigger invalidateProperties();
			}
			if (canvasSize) {
				_canvas.invalidateSize();
			}
			if (display) {				
				_canvas.invalidateDisplayList();
			}	
		}
		
		private function pathInString(node:Node):String
		{
			var rv:Vector.<String> = new Vector.<String>();
			var n:Node = node;
			while (n.reachedby != null)
			{
				rv.push(n.reachedby);
				n = n.parent;
			}
			rv.reverse();
			return rv.join(" ");
		}
		
		
		
		/* ---- File Managing ---- */
		
		/** 
		 * Resets everything
		 */
		public function clear():void
		{
			resetZoom();
			_treeActionHandler.reset(_grid);
			fileManager.clear();
			invalidate(true, true, true);
		}
		
		/**
		 * Opens a dialog for saving the tree in .fig format using TreeGridFigWriter
		 */
		public function fig():void
		{
			var out:TreeGridFigWriter = new TreeGridFigWriter();
			
			removeSelected(true);
			var figStr:String = out.paintFig(_canvas.painter, _canvas.width, _canvas.height, _grid);
			restoreSelected();

			fileManager.saveFig(figStr);
		}
		
		/**
		 * Opens a dialog for saving an image of the tree in .png format
		 */
		public function image():void
		{
		  var bd:BitmapData = new BitmapData(_canvas.width, _canvas.height);
		  
		  removeSelected(true);
		  _canvas.validateNow();
		  bd.draw(_canvas);
		  restoreSelected();
		  
		  var ba:ByteArray = (new PNGEncoder()).encode(bd);
		  
		  fileManager.saveImage(ba);
		}
		
		/**
		 * Opens a dialog for saving the tree in xml format
		 */
		public function save():void 
		{			
			fileManager.saveXML(saveCurrentTreeToXML());
		}
		
		/**
		 * Returns a XML file with the current tree packaged in it
		 */
		public function saveCurrentTreeToXML():XML {
			var xmlWriter:XMLExporter = new XMLExporter();
			return xmlWriter.writeTree(_grid);		
		}
		
		/**
		 * Loads a tree/matrix from xml, deleting any previous states
		 */
		public function loadFromXML(xml:XML):void
		{			
			//TODO #33 check what type of data is inside the xml
			loadTreeFromXML(xml);
		
			invalidate(true, true, true);
		}
		
		private function loadTreeFromXML(xml:XML):void
		{
			_treeActionHandler.load(xml, _grid);
			isZeroSum = false;	
		}
		
		//TODO #33 loadMatrixFromXML
		
		/**
		 * Opens a dialog for selecting and opening a file in xml format
		 */
		public function open():void
		{
			fileManager.openFile();
		}

		// URL Request Handler below here...
		public function runAlgorithm(algo:Object, seed:String):void
			//TODO #33: Although the functionality should be the same, depending on the nf or ef mode,
			//the data for running the algo might need to be generated
		{			
			if (algo == null || algo.service == null || algo.service == undefined 
				|| algo.url == null || algo.url == undefined) {
				log.add(Log.ERROR, "Algorithm not configured");
				return;
			}
			
			var srv:HTTPService = HTTPService(algo.service);
			srv.url = algo.url;
			var params:Object = {
				algo: algo.uid				
			};
			if (seed != null) {
				params.s = seed;				
			}
			if (algo.type == "nf") {
				var nf:NormalForm = new NormalForm(_grid, true);				
				var rows:Vector.<Strategy> = nf.strategies(nf.firstPlayer);
				var cols:Vector.<Strategy> = nf.strategies(nf.firstPlayer.nextPlayer);
				params.a = getMatrixParam(nf.payMatrixMap[nf.firstPlayer], rows, cols);				
				params.b = getMatrixParam(nf.payMatrixMap[nf.firstPlayer.nextPlayer], rows, cols);
				params.r = getStrategyNamesParam(rows);
				params.c = getStrategyNamesParam(cols);
			} else if (algo.type == "xf") {				
				params.g = getTreeParam();
			} else {
				log.add(Log.ERROR, "type was not recognized: " + algo.type);
			}
			
			srv.send(params);
        }
		
		private function getTreeParam():String
		{
			var xmlWriter:XMLExporter = new XMLExporter();
			var treeXML:XML = xmlWriter.writeTree(_grid);
			XML.prettyPrinting = false;
			var value:String = treeXML.toXMLString();
			XML.prettyPrinting = true;
			return value;
		}
		
		private function getMatrixParam(matrix:Object, rows:Vector.<Strategy>, cols:Vector.<Strategy>):String
		{
			var lines:Vector.<String> = new Vector.<String>();
			for each (var row:Strategy in rows) 
			{				
				var line:Vector.<String> = new Vector.<String>();	
				for each (var col:Strategy in cols) 
				{					
					var pairKey:String = Strategy.key([row, col]);							
					line.push(matrix[pairKey]);
				}
				lines.push(line.join(" "));
			}			
			return lines.join("\r\n");
		}
		
		private function getStrategyNamesParam(strats:Vector.<Strategy>):String
		{
			var line:Vector.<String> = new Vector.<String>();
			for each (var strat:Strategy in strats) {				
				line.push(strat.seqStr(true, ""));
			}			
						
			return line.join(" ");
		}
	}
}