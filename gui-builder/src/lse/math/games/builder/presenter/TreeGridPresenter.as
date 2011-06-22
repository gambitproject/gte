package lse.math.games.builder.presenter 
{
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
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
	import flash.utils.ByteArray;
	
	import lse.math.games.builder.fig.FigFontManager;
	import lse.math.games.builder.fig.TreeGridFigWriter;
	import lse.math.games.builder.io.ExtensiveFormXMLWriter;
	import lse.math.games.builder.model.Node;
	import lse.math.games.builder.model.NormalForm;
	import lse.math.games.builder.model.Player;
	import lse.math.games.builder.model.Rational;
	import lse.math.games.builder.model.Strategy;
	import lse.math.games.builder.view.Canvas;
	import lse.math.games.builder.viewmodel.TreeGrid;
	
	import mx.collections.*;
	import mx.controls.Alert;
	import mx.events.*;
	import mx.graphics.codec.PNGEncoder;
	import mx.rpc.http.HTTPService;
	
	import util.Log;
	
	/**	
	 * @author Mark Egesdal
	 */
	public class TreeGridPresenter
	{
		private var _canvas:Canvas;
		
		private var _actionHandler:ActionHandler = new ActionHandler();		
		private var _grid:TreeGrid;
		
		private var _gridData:ArrayCollection = new ArrayCollection();		
		private var _getClickAction:Function = null;
		private var _getDataUpdateAction:Function = null;
		
		private var _fileName:String = "Untitled";
		
		private var _log:Log = Log.instance;
		private var _lastLogMessage:String = _log.lastMessage;
		
		//private var _modelDirty:Boolean = true;		
		
		public function TreeGridPresenter() 
		{									
			_gridData.addEventListener("collectionChange", onOutcomeEdit);	
		}
		
		//TODO: This doesn't update the gui
		public function get lastLogMessage():String
		{
			_lastLogMessage = _log.lastMessage;
			return _lastLogMessage;
		}
		
		[Bindable]
		public function get fileName():String {
			return _fileName;
		}
		
		public function set fileName(value:String):void {
			_fileName = value;
		}
		
		public function set grid(value:TreeGrid):void {
			_grid = value;
		}
		
		public function set canvas(canvas:Canvas):void {
			if (canvas == null) {
				throw new Error("Cannot assign a null canvas")
			}
			_canvas = canvas;
			_canvas.addEventListener(MouseEvent.MOUSE_WHEEL, mouseZoomHandle);
			invalidate(true, true, true);
		}

		
		[Bindable]
		public function get player1Color():uint {
			return _grid.player1Color;
		}
		
		public function set player1Color(value:uint):void {
			_grid.player1Color = value;
			invalidate(false, false, true);
		}
		
		[Bindable]
		public function get player2Color():uint {
			return _grid.player2Color;
		}
		
		public function set player2Color(value:uint):void {
			_grid.player2Color = value;
			invalidate(false, false, true);
		}
		
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
		public function get fontFamily():String {			
			return _grid.fontFamily;
		}
		
		public function set fontFamily(value:String):void {
			_grid.fontFamily = value;
			invalidate(false, false, true); //TODO: measure needs invalidation if we do any measurement based on label sizes
		}
		
		[Bindable]
		public function get getClickAction():Function {			
			return _getClickAction;
		}
		
		public function set getClickAction(value:Function):void {
			_getClickAction = value;
			var invalidateDisplay:Boolean = false;
			if (selectedNode >= 0) {
				selectedNode = -1;
				invalidateDisplay = true;
			}
			if (_grid.mergeBase != null) {			
				_grid.mergeBase = null;
				invalidateDisplay = true;				
			}
			invalidate(false, false, invalidateDisplay);
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
		
		public function zoomIn():void
		{
			var oldScale:Number = _canvas.painter.scale;
			var newScale:Number = oldScale * 1.1;
			if (oldScale < 1 && newScale > 1) {
				newScale = 1.0;
			}
			
			_canvas.painter.scale = newScale;
			invalidate(false, true, true);
		}
		
		public function zoomOut():void
		{
			var oldScale:Number = _canvas.painter.scale;
			var newScale:Number = oldScale / 1.1;
			if (oldScale > 1 && newScale < 1) {
				newScale = 1.0;
			}
			
			_canvas.painter.scale = newScale;
			invalidate(false, true, true);
		}
		
		public function doAction(getAction:Function):void
		{                   
			var action:IAction = getAction(_grid);
			if (action != null) {
				_actionHandler.processAction(action, _grid);						
				invalidate(action.changesData, action.changesSize, action.changesDisplay);		
			}
		}
		
		public function doActionAt(x:Number, y:Number):void
		{
			if(getClickAction!= null)
			{
				selectedNode = -1;
				var action:IAction = getClickAction(_grid, x, y);
				if (action != null) {
					_actionHandler.processAction(action, _grid);									
					invalidate(action.changesData, action.changesSize, action.changesDisplay);
				}
			}
		}
		
		public function undo():void
		{             
			if (_actionHandler.undo(_grid)) {
				invalidate(true, true, true);
			}
		}
		
		public function redo():void
		{             
			if (_actionHandler.redo(_grid)) {
				invalidate(true, true, true);
			}
		}	
				
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
					_actionHandler.processAction(chain, _grid);						
					invalidate(chain.changesData, chain.changesSize, chain.changesDisplay);		
				}
			}
		}
		
		private function invalidate(model:Boolean, canvasSize:Boolean, display:Boolean):void 
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
		
		public function clear():void
		{
			_actionHandler.reset(_grid);
			fileName = "Untitled";
			invalidate(true, true, true);
		}
		
		//TODO: IOHandler from here down...
		private static const FILE_OPEN_TYPES:Array = [new FileFilter("*.xml", "*.xml")];
		private static const FILE_SAVE_TYPES:Array = [".xml", ".fig", ".png"];
		private var fr:FileReference = null;
		
		/**
		 * Updates the name of the current tree taking it from the file associated to it
		 * Should be called after saving or loading a file
		 */
		public function updateName():void { //?
			if(fr!=null && fr.name!=null)
			{
				var newFileName:String = fr.name;
				
				//Removes file extension (There might be a better way)
				for(var i:int = 0; i<FILE_SAVE_TYPES.length; i++)
				{
					var ext:String = FILE_SAVE_TYPES[i];
					if(newFileName.substr(newFileName.length-ext.length, ext.length).toLowerCase() == ext)
					{
						newFileName = newFileName.substr(0, newFileName.length-ext.length);
						break;
					}
				}
				
				fileName = newFileName;			
			}
		}
		
		/**
		 * Opens a dialog for saving the tree in .fig format using TreeGridFigWriter
		 */
		public function fig():void
		{
			var out:TreeGridFigWriter = new TreeGridFigWriter();
			var figStr:String = out.paintFig(_canvas.painter, _canvas.width, _canvas.height, _grid);

			fr = new FileReference();
			
			fr.addEventListener(Event.COMPLETE, onSaveComplete);
			fr.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);

			fr.save(figStr, fileName+".fig"); 
		}
		
		/**
		 * Opens a dialog for saving an image of the tree in .png format
		 */
		public function image():void
		{
		  var bd:BitmapData = new BitmapData(_canvas.width, _canvas.height);
		  bd.draw(_canvas);
		  
		  var ba:ByteArray = (new PNGEncoder()).encode(bd);
		  
		  fr = new FileReference();
		  
		  fr.addEventListener(Event.COMPLETE, onSaveComplete);
		  fr.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);

		  fr.save(ba, fileName+".png");
		}
		
		/**
		 * Opens a dialog for saving the tree in xml format
		 */
		public function save():void 
		{
			var xmlWriter:ExtensiveFormXMLWriter = new ExtensiveFormXMLWriter();
			var treeXML:XML = xmlWriter.write(_grid);		
			
			fr = new FileReference();
			
			fr.addEventListener(Event.COMPLETE, onSaveComplete);
			fr.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);

			fr.save(treeXML.toXMLString(), fileName+".xml");
		}
		
		public function loadXML(xml:XML):void
		{			
			_actionHandler.load(xml, _grid);
			isZeroSum = false;			
			invalidate(true, true, true);
		}
		
		/**
		 * Opens a dialog for selecting and opening a tree in xml format
		 */
		public function open():void
		{
			//create the FileReference instance
			fr = new FileReference();

			//listen for when they select a file
			fr.addEventListener(Event.SELECT, onFileSelect);

			//listen for when then cancel out of the browse dialog
			fr.addEventListener(Event.CANCEL, onCancel);
						
			//open a native browse dialog that filters for text files
			fr.browse(FILE_OPEN_TYPES);
		}

		/************ Browse Event Handlers **************/

		//called when the user selects a file from the browse dialog
		private function onFileSelect(e:Event):void
		{						
			//listen for when the file has loaded
			fr.addEventListener(Event.COMPLETE, onLoadComplete);

			//listen for any errors reading the file
			fr.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
			
			fr.addEventListener(Event.OPEN, onFileOpen);

			//load the content of the file
			fr.load();
		}

		//called when the user cancels out of the browser dialog
		private function onCancel(e:Event):void
		{
			//trace("File Browse Canceled");
			fr = null;
		}
		
		private function onFileOpen(e:Event):void
		{
			//trace("File Opened for loading");
		}

		/************ Select Event Handlers **************/

		//called when the file has completed loading
		//TODO: error handling of XML parsing?
		private function onLoadComplete(e:Event):void
		{			
			//read the bytes of the file as a string
			var text:String = fr.data.readUTFBytes(fr.data.bytesAvailable);		
			
			var xml:XML = new XML(text);						
			loadXML(xml);
			
			updateName();
			
			fr = null;
		}
		
		//called if an error occurs while loading the file contents
		private function onLoadError(e:IOErrorEvent):void
		{
			trace("Error loading file : " + e.text);
		}
		
		//called when the file has completed saving, independently of the file saving command chosen
		private function onSaveComplete(evt:Event):void{
			//trace("File saved correctly");
			updateName();
			
			fr = null;
		}
		
		//called if an error occurs while saving the file contents
		private function onSaveError(e:IOErrorEvent):void
		{
			trace("Error saving file : " + e.text);
		}
		
		
		
		// URL Request Handler below here...
		public function runAlgorithm(algo:Object, seed:String):void
		{
			if (algo != null && algo.service == undefined || algo.url == undefined) {
				Alert.show("Algorithm not configured");
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
				Alert.show("type was not recognized: " + algo.type);
			}
			srv.send(params);
        }
		
		private function getTreeParam():String
		{
			var xmlWriter:ExtensiveFormXMLWriter = new ExtensiveFormXMLWriter();
			var treeXML:XML = xmlWriter.write(_grid);
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