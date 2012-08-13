package lse.math.games.builder.view 
{		
	import flash.display.DisplayObject;
	import flash.text.engine.TextLine;
	import spark.components.TextInput;
	import lse.math.games.builder.model.Rational;
	import lse.math.games.builder.presenter.IAction;
	import lse.math.games.builder.presenter.Presenter;
	import lse.math.games.builder.viewmodel.TreeGrid;
	import lse.math.games.builder.viewmodel.action.LabelChangeAction;
	import lse.math.games.builder.viewmodel.action.PayChangeAction;
	import lse.math.games.builder.viewmodel.action.ParameterChangeAction;
	
	import mx.controls.Alert;
	
	import util.Log;
	//import util.PromptTextInput;
	import util.PromptTextInputCanvas;
	
	/**
	 * Linked list of Painters, usable as Painter itself, applying each operation to the whole list
	 * It also contains functionality for selecting and editing labels
	 * @author Mark
	 */
	public class PainterChain implements IPainter
	{
		private var _start:PainterChainLink;
		private var _end:PainterChainLink;
		
		private var log:Log = Log.instance;
		private var ti:TextInput =null;
		
		
		public function PainterChain() {}
		
		public function set links(value:Vector.<IPainter>):void {
			for each (var painter:IPainter in value) 
			{
				var link:PainterChainLink = new PainterChainLink(painter);			
				if (_start == null) {
					_start = link;
				}
				if (_end != null) {
					_end.next = link;
				}
				_end = link;
			}
		}
		
		/** Runs all the painters' paint function, therefore painting everything under its control */
		public function paint(g:IGraphics, width:Number, height:Number):void 
		{			
			for (var link:PainterChainLink = _start; link != null; link = link.next) {
				link.painter.paint(g, width, height);
			}			
		}
		
		/** Assigns all labels corresponding to all the painters. They get registered under each painter's own labels array */
		public function assignLabels():void 
		{
			for (var link:PainterChainLink = _start; link != null; link = link.next) {
				link.painter.assignLabels();
			}				
		}
		
		/** Performs all the necessary measurements to perform correctly the painting operations */
		public function measureCanvas():void 
		{
			for (var link:PainterChainLink = _start; link != null; link = link.next) {
				link.painter.measureCanvas();
			}				
		}
		
		/** Collects and returns an object containing all the labels inside the painters */
		public function get labels():Object {
			var labels:Object = new Object();
			for (var link:PainterChainLink = _start; link != null; link = link.next) {				
				for (var labelKey:String in link.painter.labels) {
					labels[labelKey] = link.painter.labels[labelKey];
				}
			}
			return labels;
		}
		
		/** Returns the maximum of the drawWidths of the painters*/
		public function get drawWidth():Number {
			var maxWidth:Number = 0;
			for (var link:PainterChainLink = _start; link != null; link = link.next) {
				if (link.painter.drawWidth > maxWidth) {
					maxWidth = link.painter.drawWidth;
				}
			}
			return maxWidth;
		}
		
		/** Returns the maximum of the drawHeights of the painters*/
		public function get drawHeight():Number {
			var maxHeight:Number = 0;
			for (var link:PainterChainLink = _start; link != null; link = link.next) {
				if (link.painter.drawHeight > maxHeight) {
					maxHeight = link.painter.drawHeight;
				}
			}
			return maxHeight;			
		}
		
		[Bindable]
		public function get scale():Number {
			return _start != null ? _start.painter.scale : 1.0;			
		}
		
		public function set scale(value:Number):void {			
			for (var link:PainterChainLink = _start; link != null; link = link.next) {				
				link.painter.scale = value;
			}		
		}
		
		private var _selectedLabelKey:String;
		private var _controller:Presenter;
		
		/** Launches a prompt to edit a selected label. In future versions its functionality might be widened to nodes and other things */
		public function selectAndEdit(controller:Presenter, x:Number, y:Number):void
		{
			if(controller.treeMode)
			{
				_controller = controller;
				
				_selectedLabelKey = null;
				for (var labelKey:String in labels)
				{
					var label:TextLine = labels[labelKey];
					if(label.x<=x && label.x+label.width>=x &&
						label.y>=y && label.y-label.height<=y)
					{
						if(labelKey.indexOf("iset_")==0)
						{
							log.add(Log.HINT, "Player name editing is not supported yet");
						} else if(labelKey.indexOf("move_")==0)
						{						
							PromptTextInputCanvas.show(onReturnFromPrompt, label.textBlock.content.rawText,x,y,1,0);
							_selectedLabelKey = labelKey;
							break;
						}
						else if(labelKey.indexOf("outcome_")==0)
						{
							PromptTextInputCanvas.show(onReturnFromPrompt, label.textBlock.content.rawText,x,y,1,0);
							_selectedLabelKey = labelKey;
							break;
						}
					}
				}
			} else
			{
				log.add(Log.ERROR_THROW, "This function has not been implemented yet");
				//TODO #32
			}
		}
		
		//Executes the edit action
		private function onReturnFromPrompt():void
		{
			if(PromptTextInputCanvas.lastEnteredText!=null && PromptTextInputCanvas.lastEnteredText!="")
			{
				_controller.doAction(getEditAction);
			}
		}
		
		//Builds a 'edit action' which can be a LabelChangeAction or a PayChangeAction, depending on what was edited
		private function getEditAction(grid:TreeGrid):IAction
		{
			var action:IAction = null;
			
			if(_selectedLabelKey.indexOf("move_")==0)
			{
				var id:int = parseInt(_selectedLabelKey.split("_")[1]);
				action = new LabelChangeAction(id, PromptTextInputCanvas.lastEnteredText);
			} else if(_selectedLabelKey.indexOf("outcome_")==0) {
				var payCode:String = (_selectedLabelKey.split("_")[1]);
				id = parseInt(payCode.split(":")[0]);
				var playerName:String = payCode.split(":")[1];
					
				var pay:Rational = Rational.parse(PromptTextInputCanvas.lastEnteredText);
				var s:String=PromptTextInputCanvas.lastEnteredText;
				
					
					var pattern:RegExp = /\d*\...\d*/;
					if (pattern.test(s)) {
		
						
						if (grid.parameters==0) { 
							
							grid.parameters++;
							if (playerName == grid.firstPlayer.name) {
								action = new ParameterChangeAction(id, PromptTextInputCanvas.lastEnteredText, null);
							} else if(playerName == grid.firstPlayer.nextPlayer.name) {
								action = new ParameterChangeAction(id, null, PromptTextInputCanvas.lastEnteredText);
							}
							return	action;					
							
						} else {
							
							log.add(Log.ERROR, "Only one parameter is allowed until now.");
							return null;
						}
						
					
					} else {
						if(pay==Rational.NaN) {
							log.add(Log.ERROR, "Bad number format, please use just numbers and '/' '.' characters for decimals");
							return null;
						}	
					}
				
				if(grid.isZeroSum)
				{
					if(playerName == grid.firstPlayer.name) {
						action = new PayChangeAction(id, pay, pay.negate());
						if (grid.parameters==1)
							grid.parameters--;
					} else if(playerName == grid.firstPlayer.nextPlayer.name) {
						action = new PayChangeAction(id, pay.negate(), pay);
						if (grid.parameters==1)
							grid.parameters--;
					}
				}else
				{
					if(playerName == grid.firstPlayer.name) {
						action = new PayChangeAction(id, pay, null);
						if (grid.parameters==1)
							grid.parameters--;
					} else if(playerName == grid.firstPlayer.nextPlayer.name) {
						action = new PayChangeAction(id, null, pay);
						if (grid.parameters==1)
							grid.parameters--;
					}
				}
			}else
				log.add(Log.ERROR_THROW, "ERROR: Unknown type of Label being modified");
			
			return action;
		}
	}
}

import lse.math.games.builder.view.IPainter;
class PainterChainLink
{
	private var _painter:IPainter;
	public var next:PainterChainLink;	
	
	public function PainterChainLink(painter:IPainter)
	{
		_painter = painter;
	}
	
	public function get painter():IPainter {
		return _painter;
	}
}