package ScrapUp.Application
{
	import spark.components.SkinnableContainer;
	import spark.components.BorderContainer;
	import mx.events.PropertyChangeEvent;
	import spark.components.Group;
	import mx.events.FlexEvent;
	import mx.controls.Alert;
	import flash.geom.*;
	import mx.core.*;
	import mx.graphics.*;
	import flash.events.*;
	import flash.desktop.*;
	import flash.display.*;
	import flash.utils.*;
	import mx.events.ResizeEvent;
	
	public class ScrapUpBaseApp extends SkinnableContainer
	{
		public static var PAGE_LOAD_COMPLETE:String = "page_load_complete";
		
		public function ScrapUpBaseApp():void {}
		public function SaveCurrentPage():void {}
		public function New():void {}
		public function Quit():void	{}
		public function Fullscreen():void {}
		public function OpenPopup(contents:UIComponent, name:String, modal:Boolean = true, size:Point = null):void {}
        public function ClosePopup(name:String):void {}
		public function ZoomOut():void {}
		public function ZoomIn():void {}
		public function ZoomToSize(newWidth:Number, newHeight:Number):void {}
		public function Zoom(amount:Number):void {}
		public function ResetZoom():void {}
		public function SaveImage():void {}
		public function SavePDF():void {}
		public function SaveToObject():Object {return null;}
		public function LoadFromObject(dataObject:Object):Boolean {return false;}
		public function OpenFile():void {}
		public function SaveFile():void {}
	}	
}
