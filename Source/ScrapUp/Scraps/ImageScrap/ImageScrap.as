package ScrapUp.Scraps.ImageScrap
{
	import ScrapUp.Scrap.*;
	import mx.events.PropertyChangeEvent;
	import flash.events.KeyboardEvent;
	import flash.display.BitmapData;
	import Utilities.KeyCodes;
	
	public class ImageScrap extends Scrap
	{             
		[Bindable][Savable] public var URL:String = null;
		[Bindable][Savable] public var fileID:String = null;
		[Bindable][Savable] public var fillMode:String = "scale";

		[Bindable] public var bitData:BitmapData = null;
		
		public function ImageScrap()
		{
			super(ImageScrapSkin, ImageScrapEditor, ImageScrapEditorSmall);
			aspectLocked = true;
			type="image";
		}
		
		public override function LoadFromData(data:Object):Boolean
		{
			if (data is BitmapData && view)
			{
				bitData = data as BitmapData;
				return true;
			}
			return false;
		}
	}
}
