package ScrapUp.Scraps.TextBoxScrap
{
	import ScrapUp.Scrap.*;
	import mx.events.PropertyChangeEvent;
	import flash.events.KeyboardEvent;
	import Utilities.KeyCodes;
	
	public class TextBoxScrap extends Scrap
	{            
		[Bindable][Savable]public var text:String = "";

		[Bindable][Savable(theme="true")]public var color:Number = 0x222299;
		[Bindable][Savable(theme="true")]public var textWidth:Number = 200;
		[Bindable][Savable(theme="true")]public var textHeight:Number = 24;
		[Bindable][Savable(theme="true")]public var fontSize:Number = 18;
		
		public static var DEFAULT_LABEL_TEXT:String = "Double Click to Edit";

		public function TextBoxScrap()
		{
			view = new TextBoxScrapView(this, TextBoxScrapSkin);
			super(null, TextBoxScrapEditor, TextBoxScrapEditorSmall);
			type = "textbox";
			editable = true;
			height=50;
		}

		protected override function OnKeyDown(event:KeyboardEvent):void
		{
			if (event.keyCode == KeyCodes.ESCAPE && view.skin && view.skin.currentState == "editing")
				SetEditMode(false);
		}
	}
}
