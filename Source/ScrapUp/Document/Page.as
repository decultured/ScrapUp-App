package ScrapUp.Document
{
	import spark.components.Group;
	import mx.events.PropertyChangeEvent;
	import mx.utils.*;
	import mx.core.*;  
	import flash.utils.*;
	import ScrapUp.Scrap.*;
	import Utilities.Logger.*;
	
	public class Page extends Group
	{
		[Savable]public var UID:String;

		public static var DEFAULT_WIDTH:Number = 1280;
		public static var DEFAULT_HEIGHT:Number = 800;
		
		[Bindable][Savable]public var displayName:String = "UNNAMED";
		[Bindable][Savable]public var backgroundURL:String = null;
		[Bindable][Savable]public var backgroundColor:Number = 0xFFFFFF;
		[Bindable][Savable]public var pageHeight:Number = 1280;
		[Bindable][Savable]public var pageWidth:Number = 800;
		
		private var _Loading:Boolean = false;
		
		private var _Scraps:Object = new Object();
		
		public function Page():void
		{
			New();
		}

		public function NewUID():void
		{
			UID = UIDUtil.createUID();
		}

		public function New():void
		{
			NewUID();
			pageWidth = DEFAULT_WIDTH;
			pageHeight = DEFAULT_HEIGHT;
			backgroundURL = null;
			backgroundColor = 0xffffff;
			DeleteAllScraps();
			_Scraps = new Object();
		}

		public function ViewResized():void
		{
			// TODO : Reposition all objects to fit in new size
		}

		public function AddScrap(scrap:Scrap):Scrap
		{
			if (scrap && !_Scraps[scrap.UID]) {
				_Scraps[scrap.UID] = scrap;
				addElement(scrap.view);
				return scrap;
			}
			Logger.LogWarning("Problem Adding Scrap", scrap);
			return null;
		}

		public function AddScrapByType(type:String, isUserInitiated:Boolean = false):Scrap
		{
			var scrap:Scrap = AddScrap(ScrapFactory.CreateByType(type));
			return scrap;
		}
		
		public function DeleteScrap(scrap:Scrap):void
		{
			if (scrap) {
				_Scraps[scrap.UID] = null;
				removeElement(scrap.view);
			}
		}
		
		public function DeleteAllScraps():void
		{
			for (var i:int = numElements - 1; i > -1; i--) {
				if (getElementAt(i) is ScrapView) {
					var scrapView:ScrapView = getElementAt(i) as ScrapView;
					DeleteScrap(scrapView.model as Scrap);
				}
			}
		}
		
		public function SaveToObject():Object
		{
			// Logger.LogDebug("PageSaving : " + UID, this);
			
			var typeDef:XML = describeType(this);
			var newObject:Object = new Object();
			for each (var metadata:XML in typeDef..metadata) {
				if (metadata["@name"] != "Savable") continue;
				if (this.hasOwnProperty(metadata.parent()["@name"]))
					newObject[metadata.parent()["@name"]] = this[metadata.parent()["@name"]];
			}

			newObject["scraps"] = new Array();

			for (var i:int = 0; i < numElements; i++) {
				if (getElementAt(i) is ScrapView) {
					var scrapView:ScrapView = getElementAt(i) as ScrapView;
					scrapView.model.zindex = i;
					newObject["scraps"].push(scrapView.model.SaveToObject());
				}
			}

			return newObject;
		}

		public function LoadFromObject(dataObject:Object):Boolean
		{
			New();
		
			if (!dataObject) {
				Logger.LogError("PageLoading - dataObject was NULL", this);
				return false;
			}

			for (var key:String in dataObject)
			{
				if (key == "scraps") {
					if (!dataObject[key] is Array)
						continue;
					var scrapArray:Array = dataObject[key] as Array;
					for (var i:uint = 0; i < scrapArray.length; i++) {
						var scrapDataObject:Object = scrapArray[i] as Object;
						if (!scrapDataObject["type"])
							continue;
						var newScrap:Scrap = AddScrapByType(scrapDataObject["type"]);
						if (newScrap)
							newScrap.LoadFromObject(scrapDataObject);
					}
				} else {
					try {
						if(this.hasOwnProperty(key)) {
							this[key] = dataObject[key];
							dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, key, null, this[key]));
						}
					} catch(e:Error) {
						Logger.LogWarning("Key: " + key + " Not found for object: " + this, this); 
					}
				}
			}
			
			// Logger.LogDebug("Page Loaded: " + displayName + " Width: " + pageWidth + " Height: " + pageHeight, this);
			return true;
		}
	} 
}