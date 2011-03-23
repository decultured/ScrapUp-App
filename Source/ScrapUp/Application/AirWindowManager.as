package ScrapUp.Application
{
	import spark.components.TitleWindow;
	import mx.core.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.desktop.*;
	import flash.display.*;
	import ScrapUp.Application.Skins.*;
	import Utilities.WindowManager.*;
	import Utilities.Logger.*;
	
	public class AirWindowManager extends WindowManager
	{
		public static var instance:WindowManager;

		public function AirWindowManager():void
		{
			super();
		}

        override protected function _OpenPopup(contents:UIComponent, title:String, name:String, modal:Boolean = true, size:Point = null):void {
			if (!contents)
				return;

 			var newWindow:ScrapUpPopupWindow = null;
			if (!size)
				size = new Point(500, 350);
				
			contents.setStyle("top", "0");
			contents.setStyle("bottom", "0");
			contents.setStyle("left", "0");
			contents.setStyle("right", "0");
				
			if (_PopupWindows[name] && _PopupWindows[name] is ScrapUpPopupWindow) {
				newWindow = _PopupWindows[name] as ScrapUpPopupWindow;
				newWindow.removeAllElements();
				newWindow.addElement(contents);
			} 
			else if (_PopupWindows[name] && _PopupWindows[name] is TitleWindow) {
				super._OpenPopup(contents, title, name, modal, size);
				return;
			} else {
				newWindow = new ScrapUpPopupWindow();
				newWindow.systemChrome = "none";
				newWindow.type = NativeWindowType.NORMAL;
				newWindow.resizable = false;
				newWindow.width = size.x;
	            newWindow.height = size.y;
				newWindow.transparent = true;
				newWindow.removeAllElements();
				newWindow.setStyle("skinClass", ScrapUpPopupWindowSkin);
				newWindow.addElement(contents);
				newWindow.addEventListener(Event.CLOSE, _HandlePopUpClose);
				_PopupWindows[name] = newWindow;
			}

            try {
                newWindow.open(true);
            } catch (err:Error) {
                Logger.LogError("Problem Opening Popup Window: " + err, this);
            }
        }
		
		protected function _HandlePopUpClose(event:Event):void
		{
			for (var key:String in _PopupWindows) {
				if (_PopupWindows[key] == event.target)
					_PopupWindows[key] = null;
			}
		}
		
        override protected function _ClosePopup(name:String):void {
 			var newWindow:ScrapUpPopupWindow = null;
			if (_PopupWindows[name] && _PopupWindows[name] is ScrapUpPopupWindow) {
				newWindow = _PopupWindows[name] as ScrapUpPopupWindow;
				newWindow.close();
			} 
			else if (_PopupWindows[name] && _PopupWindows[name] is TitleWindow) {
				super._ClosePopup(name);
				return;
			}
        }
	}
}
