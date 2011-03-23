package ScrapUp.Application
{
	import flash.events.*;
	import spark.components.SkinnableContainer;
	import Utilities.Logger.*;
	
	public class ScrapUpSideBar extends SkinnableContainer
	{
		[SkinState("hidden")]
		[SkinState("extended")]

		[Bindable]public var appClass:ScrapUpApp = null;

		[Bindable]private var _IsOpen:Boolean = false;
		public function get IsOpen():Boolean {return _IsOpen; }
		
		public function ScrapUpSideBar()
		{
			super();
		}

		public function open():void {
			_IsOpen = true;
			invalidateSkinState();
		}
	
		public function close():void {
			_IsOpen = false;
			invalidateSkinState();
		}

		override protected function getCurrentSkinState():String {
			return (_IsOpen == true ? "extended" : "hidden");
		}
	}
}