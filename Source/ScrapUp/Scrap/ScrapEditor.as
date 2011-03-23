package ScrapUp.Scrap
{
	import spark.components.SkinnableContainer;
	
	public class ScrapEditor extends SkinnableContainer
	{
		[Bindable]public var model:Object;
		
		public function ScrapEditor(_model:Scrap, _scrapEditorSkin:Class)
		{
			super();
			model = _model;
			setStyle("skinClass", _scrapEditorSkin);
		}
	}
}