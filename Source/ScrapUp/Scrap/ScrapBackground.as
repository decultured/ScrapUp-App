package ScrapUp.Scrap
{
	import spark.components.BorderContainer;
	import spark.components.SkinnableContainer;
	
	public class ScrapBackground extends SkinnableContainer
	{
		[Bindable]public var model:Object;
		[Bindable]public var editing:Boolean = false;

		public function ScrapBackground()
		{
			super();
		}
	}
}