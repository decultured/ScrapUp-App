package ScrapUp.Scrap
{
	import ScrapUp.Scraps.ImageScrap.*;
	import ScrapUp.Scraps.LabelScrap.*;
	import ScrapUp.Scraps.TextBoxScrap.*;
	import Utilities.Logger.*;
	
	public class ScrapFactory
	{
		public static function CreateByType(scrapType:String):Scrap
		{
			if (scrapType == "image")
				return new ImageScrap();
			else if (scrapType == "label")
				return new LabelScrap();
			else if (scrapType == "textbox")
				return new TextBoxScrap();
			else
				Logger.LogError("Scrap type not found: " + scrapType); 
			return null;
		}
	}
}