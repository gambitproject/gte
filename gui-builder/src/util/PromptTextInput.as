package util
{
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	
	import mx.containers.ControlBar;
	import mx.containers.Panel;
	import mx.containers.VBox;
	import mx.controls.Button;
	import mx.controls.Label;
	import mx.controls.Spacer;
	import mx.controls.TextInput;
	import mx.core.FlexGlobals;
	import mx.managers.PopUpManager;
	
	/**
	 * PopUp 'prompt' with text input creator, which contains a title, text and textbox. Only one pop up prompt can be shown at each time
	 * <br/>USAGE: <ol>
	 * <li>First, create inside the class from which you'll be calling Prompt.show(), a function you want it to call after closing the prompt</li>
	 * <li>Secondly, call Prompt.show() not forgetting to pass it a valid 'parent' DisplayObject from which to throw the popup</li>
	 * <li>Thirdly, in the function you created in step 1, pick up the result of the prompt via Prompt.lastEnteredText. 
	 * Don't forget to check if its null: that will mean that the user pressed the 'Cancel' button</li> 
	 * </ol>
	 * @author alfongj
	 */
	public class PromptTextInput
	{		
		private static var panel:Panel;
		private static var _onReturn:Function;
		private static var textInput:TextInput;
		private static var promptShowing:Boolean = false;
		private static var _parent:DisplayObject = FlexGlobals.topLevelApplication as DisplayObject;
		
		public static var lastEnteredText:String; //String containing the result text of the prompt
		
		/**
		 * Throws a prompt in a pop up window
		 * @param parent: DisplayObject from which to throw the pop up
		 * @param onReturn: Function to execute after the user has pressed one of the buttons and closed the popup
		 * @param text: Text to show the user 
		 */
		public static function show(onReturn:Function, text:String, title:String = "Prompt", 
			OKText:String = "OK", cancelText:String = "Cancel" ):void {
			
			if(!promptShowing)
			{			
				_onReturn = onReturn;
				
				var vb:VBox = new VBox();
				var label:Label = new Label();
				textInput = new TextInput();
				
				var cb:ControlBar = new ControlBar();
				var s:Spacer = new Spacer();
				var b1:Button = new Button();
				var b2:Button = new Button();
				
				s.percentWidth = 100;
				
				b1.label = OKText;
				b1.addEventListener(MouseEvent.CLICK, closePopUpOK);
				b2.label = cancelText;
				b2.addEventListener(MouseEvent.CLICK, closePopUpCancel);
				
				cb.addChild(s);
				cb.addChild(b1);
				cb.addChild(b2);
				
				label.text = text;
				
				vb.setStyle("paddingBottom", 5);
				vb.setStyle("paddingLeft", 5);
				vb.setStyle("paddingRight", 5);
				vb.setStyle("paddingTop", 5);
				vb.addChild(label);
				vb.addChild(textInput);
				
				panel = new Panel();
				panel.title = title;
				panel.addChild(vb);
				panel.addChild(cb);
				
				createPopUp();
			}
		}
		
		//Creates, throws and centers the popup using the panel filled previoulsy
		private static function createPopUp():void {
			PopUpManager.addPopUp(panel, _parent, true);
			PopUpManager.centerPopUp(panel);
			promptShowing = true;
		}
		
		//Should be called after pressing the OK button
		//Closes the pop up, stores the edited text, and calls onreturn
		private static function closePopUpOK(evt:MouseEvent):void {
			PopUpManager.removePopUp(panel);
			lastEnteredText = textInput.text;
			panel = new Panel();
			promptShowing = false;
			_onReturn();
		}
		
		//Should be called after pressing the Cancel
		//Closes the pop up, dismisses the edited text, and calls onreturn
		private static function closePopUpCancel(evt:MouseEvent):void {
			PopUpManager.removePopUp(panel);
			
			lastEnteredText = null;

			panel = new Panel();
			promptShowing = false;
			_onReturn();
		}
	}
}