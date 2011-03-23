package ScrapUp.Scraps.LabelScrap
{
	import ScrapUp.Scrap.*;
	import mx.events.PropertyChangeEvent;
	
	public class SkeletonScrap extends Scrap
	{
		public function SkeletonScrap()
		{
			super(SkeletonScrapSkin, SkeletonScrapEditor);
			type = "Skeletonscrap";
		}
		
		protected override function ModelChanged(event:PropertyChangeEvent):void
		{
			switch( event.property )
			{
				case "text":
					return;
			}

			super.ModelChanged(event);
		}
	}
}
