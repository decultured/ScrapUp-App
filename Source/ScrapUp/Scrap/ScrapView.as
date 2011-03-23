package ScrapUp.Scrap
{
	import spark.components.BorderContainer;
	import spark.components.SkinnableContainer;
	
	public class ScrapView extends SkinnableContainer
	{
		[Bindable]public var model:Object;
		
		public function ScrapView(_model:Scrap, _scrapViewSkin:Class)
		{
			super();
			model = _model;
			doubleClickEnabled = true;
			if (_scrapViewSkin)
				setStyle("skinClass", _scrapViewSkin);
			setStyle("minWidth", 5);
			setStyle("minHeight", 5);
		}
	}
}