package lse.math.games.builder.view
{
	import flash.events.MouseEvent;
	
	import mx.managers.PopUpManager;
	
	import spark.components.TextArea;
	import spark.components.TitleWindow;
	
	[SkinState("disabledSuccessful")]
	[SkinState("disabledWithControlBarSuccessful")]
	[SkinState("inactiveSuccessful")]
	[SkinState("inactiveWithControlBarSuccessful")]
	[SkinState("normalSuccessful")]
	[SkinState("normalWithControlBarSuccessful")]
	public class OutputWindow extends TitleWindow
	{
		public function OutputWindow()
		{
			title = "Output: ";
		}
		
		[SkinPart(required = "false")]
		public var textContainer:TextArea;
		
		private var success:Boolean;
		private var textChanged:Boolean;
		private var textValue:String;
		
		/**
		 * @inheritDoc
		 */
		override protected function commitProperties():void
		{
			super.commitProperties();
			
			if (textChanged && textContainer)
			{
				textContainer.text = textValue;
				textChanged = false;
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function getCurrentSkinState():String
		{
			var skinState:String = super.getCurrentSkinState();
			return success ? skinState + "Successful" : skinState;
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);
			if (instance == textContainer)
			{
				textChanged = true;
				invalidateProperties();
			}
		}
		
		public function setText(text:String):void
		{
			if (text == textValue)
				return;
			success = text && text.indexOf("SUCCESS") != -1;
			invalidateSkinState();
			textValue = text;
			textChanged = true;
			invalidateProperties();
			
			//Changes its width and height according to the text
			var maxLength:int = 0;
			var textInLines:Array = text.split("\n");
			for each(var line:String in textInLines)
			{
				if(line.length>maxLength) maxLength = line.length;
			}
			
			this.width = Math.max(200, maxLength*7+100);
			this.height = Math.min(parent.height - 150, 14*textInLines.length + 70);			
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function closeButton_clickHandler(event:MouseEvent):void
		{
			super.closeButton_clickHandler(event);
			
			PopUpManager.removePopUp(this);
		}
	}
}