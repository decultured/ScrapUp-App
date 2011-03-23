package ScrapUp.Scraps.TextBoxScrap
{
	import ScrapUp.Scrap.*;
	import spark.components.TextArea;
	
	public class TextBoxScrapView extends ScrapView
	{
		[SkinPart(required="true")]
		[Bindable]public var editorLabel:TextArea;
		
		public function TextBoxScrapView(_model:Scrap, _scrapViewSkin:Class)
		{
			super(_model, _scrapViewSkin);
		}
	}
}