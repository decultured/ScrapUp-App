package ScrapUp.Application
{
	import mx.events.PropertyChangeEvent;
	import mx.graphics.ImageSnapshot;
	import mx.events.ResizeEvent;
	import mx.events.FlexEvent;
	import mx.events.AIREvent;
	import mx.controls.Alert;
	import mx.graphics.*;
	import mx.core.*;
	import flash.display.StageDisplayState;
	import flash.events.KeyboardEvent;
	import flash.filesystem.*;
	import flash.desktop.*;
	import flash.display.*;
	import flash.events.*;
	import flash.utils.*;
	import flash.geom.*;
	import flash.net.*;
	import spark.components.SkinnableContainer;
	import spark.components.RichEditableText;
	import spark.components.BorderContainer;
	import spark.components.TitleWindow;
	import spark.components.TextInput;
	import spark.components.TextArea;
	import spark.components.Group;
	import ScrapUp.Scraps.TextBoxScrap.*;
	import ScrapUp.Scraps.ImageScrap.*;
	import ScrapUp.Application.Skins.*;
	import ScrapUp.Application.*;
	import ScrapUp.Document.*;
	import ScrapUp.Scrap.*;
	import Utilities.WindowManager.*;
	import Utilities.Logger.*;
	import Utilities.json.*;

	public class ScrapUpApp extends ScrapUpBaseApp
	{
		[Savable]public var FileFormatVersion:String="1.0";

		[Bindable]public static var instance:ScrapUpBaseApp = null;

		[SkinPart(required="true")]
		public var toolbar:Group;

		[SkinPart(required="true")]
		[Bindable]public var appGrid:Grid;

		[SkinPart(required="true")]
		public var appStatusBar:ScrapUpStatusBar;

		[SkinPart(required="true")]
		public var popupOverlay:SkinnableContainer;

		[SkinPart(required="true")]
		public var welcomeScreen:SkinnableContainer;

		[SkinPart(required="true")]
		[Bindable]public var docContainer:BorderContainer;

		[SkinPart(required="true")]
		[Bindable]public var editPage:EditPage;

		[SkinPart(required="true")]
		[Bindable]public var editPageContainer:BorderContainer;

		[Bindable]public var zoom:Number = 1.0;
		[Bindable]public var fitToScreen:Boolean = false;

		[Bindable]public var pageManager:PageManager = new PageManager();

		[Bindable]public var statusBarVisible:Boolean = false;

		protected var _PopupWindows:Object = new Object();
		protected var _PopupWindowContents:Object = new Object();

		public var supClipboard:ScrapUpClipboard;

		public var window:DisplayObject;
 		private var _ViewerWindow:ScrapUpViewerWindow;

		public var nativeWindow:NativeWindow;

		public function ScrapUpApp():void
		{
			instance = this;

			Logger.LogDebug("App Created", this);
			supClipboard = new ScrapUpClipboard(this);
			addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, PropertyChangeHandler);
			pageManager.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, PageManagerChanged);

			WindowManager.instance = new AirWindowManager();
			NativeApplication.nativeApplication.addEventListener(InvokeEvent.INVOKE, ShowApplication) // listening for the invoke event if the user clicks on the dock icon
		}

		protected function PropertyChangeHandler(event:PropertyChangeEvent):void
		{
			switch( event.property )
			{
				case "editPage":
					Logger.Log("Edit Page Added");
					editPage.LoadFromObject(pageManager.currentPage);
					return;
				case "docContainer":
					docContainer.removeEventListener(ResizeEvent.RESIZE, DocContainerResized);
					docContainer.addEventListener(ResizeEvent.RESIZE, DocContainerResized);
					return;
				case "fitToScreen":
					if (fitToScreen && docContainer)
						ZoomToSize(docContainer.width, docContainer.height);
					return;
			}
		}

		protected function PageManagerChanged(event:PropertyChangeEvent):void
		{
			switch( event.property )
			{
				case "currentPageIndex":
					Logger.Log("Page Index Changed");
					SaveCurrentPage();
					editPage.LoadFromObject(pageManager.currentPage);
					return;
			}
		}

		protected function DocContainerResized(event:ResizeEvent):void
		{
			if (!fitToScreen)
				return;

			ZoomToSize(docContainer.width, docContainer.height);
		}

		public override function SaveCurrentPage():void
		{
			pageManager.SetPageByUID(editPage.SaveToObject(), editPage.UID);
		}

		public override function New():void
		{
			pageManager.New(true);
			editPage.LoadFromObject(pageManager.currentPage);
		}

		public override function ZoomOut():void
		{
			if (zoom > 0.1)
				zoom = zoom / 2.0;
			fitToScreen = false;
		}

		public override function ZoomIn():void
		{
			if (zoom < 4.0)
				zoom = zoom * 2.0;
			fitToScreen = false;
		}

		public override function ZoomToSize(newWidth:Number, newHeight:Number):void
		{
			if (!editPage || !editPage.height || !newHeight)
				return;

			var docAspectRatio:Number = editPage.width/editPage.height;
			var containerAspectRatio:Number = newWidth/newHeight;

			if (containerAspectRatio >= docAspectRatio) {
				// zoom by height
				zoom = newHeight / editPage.height;
			} else {
				// zoom by width
				zoom = newWidth / editPage.width;
			}
		}

		public override function Zoom(amount:Number):void
		{
			zoom = amount;
			fitToScreen = false;
		}

		public function OpenViewer():void {
			if (_ViewerWindow) {
				_ViewerWindow.close();
				return;
			}

			_ViewerWindow = new ScrapUpViewerWindow();
			_ViewerWindow.width = 800;
            _ViewerWindow.height = 600;
			_ViewerWindow.addEventListener(AIREvent.WINDOW_COMPLETE, HandleViewerComplete);
			_ViewerWindow.addEventListener(Event.CLOSE, HandleViewerClose);

            try {
                _ViewerWindow.open(true);
				window.visible = false;
            } catch (err:Error) {
                Logger.LogError("Problem Opening Viewer Window: " + err, this);
            }
		}

		public function HandleViewerClose(event:Event):void
		{
			_ViewerWindow.removeEventListener(Event.CLOSE, HandleViewerClose);
			_ViewerWindow = null;
			window.visible = true;
		}

		public function HandleViewerComplete(event:AIREvent):void
		{
			_ViewerWindow.removeEventListener(AIREvent.WINDOW_COMPLETE, HandleViewerComplete);
			_ViewerWindow.supViewer.LoadFromObject(SaveToObject());
		}

        public override function OpenPopup(contents:UIComponent, name:String, modal:Boolean = true, size:Point = null):void {
 			var newWindow:ScrapUpPopupWindow = null;

			if (!size)
				size = new Point(500, 350);

			if (_PopupWindows[name] && _PopupWindows[name] is ScrapUpPopupWindow) {
				newWindow = _PopupWindows[name] as ScrapUpPopupWindow;
				newWindow.removeAllElements();
				newWindow.addElement(contents);
			} 
			else if (_PopupWindows[name] && _PopupWindows[name] is TitleWindow) {
				super.OpenPopup(contents, name, modal);
				return;
			} else {
				newWindow = new ScrapUpPopupWindow();
				newWindow.systemChrome = "none";
				newWindow.type = NativeWindowType.NORMAL;
				newWindow.resizable = false;
				newWindow.width = size.x;
	            newWindow.height = size.y;
				newWindow.transparent = true;
				newWindow.removeAllElements();
				newWindow.setStyle("skinClass", ScrapUpPopupWindowSkin);
				newWindow.addElement(contents);
				newWindow.addEventListener(Event.CLOSE, HandlePopUpClose);
				_PopupWindows[name] = newWindow;
			}

            try {
                newWindow.open(true);
            } catch (err:Error) {
                Logger.LogError("Problem Opening Popup Window: " + err, this);
            }
        }

		public function HandlePopUpClose(event:Event):void
		{
			for (var key:String in _PopupWindows) {
				if (_PopupWindows[key] == event.target)
					_PopupWindows[key] = null;
			}
		}

        public override function ClosePopup(name:String):void {
 			var newWindow:ScrapUpPopupWindow = null;
			if (_PopupWindows[name] && _PopupWindows[name] is ScrapUpPopupWindow) {
				newWindow = _PopupWindows[name] as ScrapUpPopupWindow;
				newWindow.close();
			} 
			else if (_PopupWindows[name] && _PopupWindows[name] is TitleWindow) {
				super.ClosePopup(name);
				return;
			}
        }

		public override function Quit():void
		{
			NativeApplication.nativeApplication.exit();	
		}

		public override function Fullscreen():void
		{
			if (stage.displayState == StageDisplayState.FULL_SCREEN_INTERACTIVE)
				stage.displayState = StageDisplayState.NORMAL;
			else
				stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
		}

		/* This is to emulate the OSX behavior for apple+H */
		public function HideApplication():void {
			if(_ViewerWindow) {
				_ViewerWindow.visible = false;
				_ViewerWindow.orderToBack();
			} else if(nativeWindow) {
				/*nativeWindow.visible = false;*/
				nativeWindow.orderToBack();
			}
		}

		public function ShowApplication(event:Event):void {
			if(!nativeWindow && NativeApplication.nativeApplication.activeWindow) {
				nativeWindow = NativeApplication.nativeApplication.activeWindow;
			}

			if(_ViewerWindow) {
				_ViewerWindow.visible = true;
				_ViewerWindow.activate();
			} else if(nativeWindow) {
				/*window.visible = true;*/
				nativeWindow.activate();
			}
		}

		public override function SaveFile():void
		{
			var file:File = File.desktopDirectory.resolvePath("MyScrapBook.sup");
			file.addEventListener(Event.SELECT, SaveFileEvent);
			file.browseForSave("Save As");
		}

		protected function SaveFileEvent(event:Event):void
		{
			var jsonFile:String = JSON.encode(SaveToObject());
			var newFile:File = event.target as File;
			var fs:FileStream = new FileStream();
			try{
				fs.open(newFile,FileMode.WRITE);
				jsonFile = jsonFile.replace(/\n/g, File.lineEnding);
				fs.writeUTFBytes(jsonFile);
				fs.close();
				Logger.Log("File Saved: " + newFile.url, this);
			} catch(e:Error){
				Logger.Log(e.message, this);
			}
		}

		public function SaveLogFile():void
		{
			var file:File = File.desktopDirectory.resolvePath("ScrapUp Error Log.txt");
			file.addEventListener(Event.SELECT, SaveLogFileEvent);
			file.browseForSave("Save Log As");
		}

		protected function SaveLogFileEvent(event:Event):void
		{
			var newFile:File = event.target as File;
			var fs:FileStream = new FileStream();
			try{
				fs.open(newFile,FileMode.WRITE);
				fs.writeUTFBytes(Logger.toString());
				fs.close();
				Logger.Log("File Saved: " + newFile.url, this);
			} catch(e:Error){
				Logger.Log(e.message, this);
			}
		}

		public override function OpenFile():void
		{
			var file:File = File.desktopDirectory;
			file.addEventListener(Event.SELECT, OpenFileEvent);

			var filters:Array = new Array();
			filters.push( new FileFilter( "ScrapUp Files", "MyScrapBook.sup" ) );
			file.browseForOpen("Open", filters);
		}

		protected function OpenFileEvent(event:Event):void
		{
			OpenFileObject(event.target as File);
		}

		public function OpenFileObject(file:File):void
		{
			if (!file)
				return;

			var stream:FileStream = new FileStream();
			try{
			    stream.open(file, FileMode.READ);
				Logger.Log("File Opened: " + file.url, this);
			    var fileData:Object = JSON.decode(stream.readUTFBytes(stream.bytesAvailable));
			    LoadFromObject(fileData);
			} catch(e:Error){
				Logger.LogError("File Open Error: " + file.url, this);
			}
		}

		public function Copy(event:Event):void
		{
			var focusObj:Object = NativeApplication.nativeApplication.activeWindow.stage.focus;

			if(focusObj != null && (focusObj is RichEditableText || focusObj is TextArea)) {
				NativeApplication.nativeApplication.copy();
			} else {
				var copyScrap:Scrap = editPage.GetSelectedScrap();
				if (!copyScrap)
					return;

				var copyObject:Object = copyScrap.SaveToObject();
				Clipboard.generalClipboard.clear();
				Clipboard.generalClipboard.setData("scrapup:scrapObject", JSON.encode(copyObject));
/*
				if (copyScrap is LabelScrap)
					Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, (copyScrap as LabelScrap).text);
				else if (copyScrap is TextBoxScrap)
					Clipboard.generalClipboard.setData(ClipboardFormats.HTML_FORMAT, (copyScrap as TextBoxScrap).text);
*/
				editPage.DeselectAll();
				var scaleMat:Matrix = new Matrix();
				scaleMat.scale(3,3);
				Clipboard.generalClipboard.setData(ClipboardFormats.BITMAP_FORMAT, ImageSnapshot.captureBitmapData(copyScrap.view, scaleMat, null, null, null, true));
				editPage.SelectScrap(copyScrap);
			}
		}

		public function Cut(event:Event):void
		{
			var focusObj:Object = NativeApplication.nativeApplication.activeWindow.stage.focus;

			if(focusObj != null && (focusObj is RichEditableText || focusObj is TextArea)) {
				NativeApplication.nativeApplication.cut();
			} else {
				var copyScrap:Scrap = editPage.GetSelectedScrap();
				if (!copyScrap)
					return;

				Copy(null);
				editPage.DeleteScrap(copyScrap);
			}
		}

		public function Paste(event:Event):void
		{
			var focusObj:Object = NativeApplication.nativeApplication.activeWindow.stage.focus;

			if(focusObj != null && (focusObj is RichEditableText || focusObj is TextArea)) {
				NativeApplication.nativeApplication.paste();
			} else {
				var formatsString:String = "Formats: ";
				for each (var format:String in Clipboard.generalClipboard.formats) {
					formatsString += format + ", ";
				}
				Logger.LogDebug("Formats Pasted: " + formatsString, this);


				if (Clipboard.generalClipboard.hasFormat("scrapup:scrapObject")) {
					var scrapDataObject:Object = JSON.decode(Clipboard.generalClipboard.getData("epaths:scrapObject") as String);
					if (!scrapDataObject || !scrapDataObject["type"])
						return;

					var newScrap:Scrap = editPage.AddScrapByType(scrapDataObject["type"]);
					if (newScrap) {
						newScrap.LoadFromObject(scrapDataObject);
						newScrap.x = 17;
						newScrap.y = 17;
					}
				} else if (Clipboard.generalClipboard.hasFormat(ClipboardFormats.BITMAP_FORMAT)) {
					newScrap = editPage.AddScrapByType("image");
					newScrap.LoadFromData(Clipboard.generalClipboard.getData(ClipboardFormats.BITMAP_FORMAT) as BitmapData);
					Logger.LogDebug("Bitmap Pasted", this);
				} else if (Clipboard.generalClipboard.hasFormat(ClipboardFormats.HTML_FORMAT)) {
					var newTextBoxScrap:TextBoxScrap = editPage.AddScrapByType("textbox") as TextBoxScrap;
					newTextBoxScrap.text = Clipboard.generalClipboard.getData(ClipboardFormats.HTML_FORMAT) as String;
					Logger.LogDebug("HTML Pasted " + newTextBoxScrap.text, this);
				} else if (Clipboard.generalClipboard.hasFormat(ClipboardFormats.TEXT_FORMAT)) {
					newTextBoxScrap = editPage.AddScrapByType("textbox") as TextBoxScrap;
					newTextBoxScrap.text = Clipboard.generalClipboard.getData(ClipboardFormats.TEXT_FORMAT) as String;
					Logger.LogDebug("Text Pasted " + newTextBoxScrap.text, this);
				}
			}
		}

		public override function SaveImage():void
		{
			var file:File = File.desktopDirectory.resolvePath("snapshot.png");
			file.addEventListener(Event.SELECT, SaveImageEvent);
			editPage.DeselectAll();
			file.browseForSave("Save As");
		}

		protected function SaveImageEvent(event:Event):void
		{
			var gridOn:Boolean = appGrid.visible;
			appGrid.visible = false;
			appGrid.validateNow();
			var snapshot:ImageSnapshot = ImageSnapshot.captureImage(editPageContainer, 300);
			if (gridOn)
				appGrid.visible = true;
			var newFile:File = event.target as File;
			var fs:FileStream = new FileStream();
			try{
				fs.open(newFile,FileMode.WRITE);
				fs.writeBytes(snapshot.data, 0, snapshot.data.length);
				fs.close();
				Logger.Log("Image Saved: " + newFile.url, this);
			} catch(e:Error){
				trace(e.message);
			}
		}

		public override function SaveToObject():Object
		{
			// Load App Stuff
			var typeDef:XML = describeType(this);
			var newObject:Object = new Object();
			for each (var metadata:XML in typeDef..metadata) {
				if (metadata["@name"] != "Savable") continue;
				if (this.hasOwnProperty(metadata.parent()["@name"]))
					newObject[metadata.parent()["@name"]] = this[metadata.parent()["@name"]];
			}

			pageManager.currentPage = editPage.SaveToObject();

			// Load Pages
			newObject["pages"] = pageManager.pages.toArray();

			return newObject;
		}


		public override function LoadFromObject(dataObject:Object):Boolean
		{
			if (!dataObject) return false;

			New();

			Logger.Log("Document Loading", this);

			for (var key:String in dataObject)
			{
				if (key == "document") {
					for(var obj_k:String in dataObject[key]) {
						try {
							if(this.hasOwnProperty(obj_k))
								this[obj_k] = dataObject[obj_k];
						} catch(e:Error) { }
					}
				} else if (key == "pages") {
					if (!dataObject[key] is Array)
						continue;

					pageManager.LoadFromArray(dataObject[key]);
				}
			}

			editPage.LoadFromObject(pageManager.currentPage);
			dispatchEvent(new Event(PAGE_LOAD_COMPLETE));

			return true;
		}

		public function onDragIn(event:NativeDragEvent):void{
			if (event.clipboard.hasFormat(ClipboardFormats.FILE_LIST_FORMAT) || 
				event.clipboard.hasFormat(ClipboardFormats.BITMAP_FORMAT) || 
				event.clipboard.hasFormat(ClipboardFormats.HTML_FORMAT) ||
				event.clipboard.hasFormat(ClipboardFormats.TEXT_FORMAT)) {
				NativeDragManager.acceptDragDrop(this);
			}
		}

		public function onDrop(event:NativeDragEvent):void{
			var newScrap:Scrap = null;
			var formatsString:String = "Formats: ";

			for each (var format:String in event.clipboard.formats) {
				formatsString += format + ", ";
			}
			if (event.clipboard.hasFormat(ClipboardFormats.FILE_LIST_FORMAT)) {
				var dropfiles:Array = event.clipboard.getData(ClipboardFormats.FILE_LIST_FORMAT) as Array;
				for each (var file:File in dropfiles){
					var ext:String = file.extension.toLowerCase();
					if (ext == "png" || ext == "jpg" || ext == "jpeg" || ext == "gif") {
						newScrap = editPage.AddScrapByType("image");
						if (newScrap is ImageScrap)
							(newScrap as ImageScrap).URL = file.url;
						Logger.Log("Image Dropped: " + file.url, this);
					} else if (ext == "sup") {
						OpenFileObject(file);
					}
					else {
						Logger.LogError("File Dropped with Unmapped Extention: " + file.url, this);
					}
				}
				Logger.Log("Filelist Dropped", this);
			} else if (event.clipboard.hasFormat(ClipboardFormats.BITMAP_FORMAT)) {
				newScrap = editPage.AddScrapByType("image");
				newScrap.LoadFromData(event.clipboard.getData(ClipboardFormats.BITMAP_FORMAT) as BitmapData);
				Logger.Log("Bitmap Dropped", this);
			} else if (event.clipboard.hasFormat(ClipboardFormats.HTML_FORMAT)) {
				var newTextBoxScrap:TextBoxScrap = editPage.AddScrapByType("textbox") as TextBoxScrap;
				newTextBoxScrap.text = event.clipboard.getData(ClipboardFormats.HTML_FORMAT) as String;
				Logger.Log("HTML Dropped " + newTextBoxScrap.text, this);
			} else if (event.clipboard.hasFormat(ClipboardFormats.TEXT_FORMAT)) {
				newTextBoxScrap = editPage.AddScrapByType("textbox") as TextBoxScrap;
				newTextBoxScrap.text = event.clipboard.getData(ClipboardFormats.TEXT_FORMAT) as String;
				Logger.Log("Text Dropped " + newTextBoxScrap.text, this);
			} else if (event.clipboard.hasFormat(ClipboardFormats.URL_FORMAT)) {
				Logger.Log("URL Dropped : " + event.clipboard.getData(ClipboardFormats.URL_FORMAT) as String, this);
			} else {
				Logger.LogWarning("Unknown Format Dropped", this);
			}
			Logger.Log("Formats Dropped: " + formatsString, this);
		}
/*
		public override function SavePDF():void
		{
			var file:File = File.desktopDirectory.resolvePath("report.pdf");
			file.addEventListener(Event.SELECT, SavePDFEvent);
			_EditDocumentView.ClearSelection();
			file.browseForSave("Save As");
		}

		protected function SavePDFEvent(event:Event):void
		{
			var snapshot:ImageSnapshot = ImageSnapshot.captureImage(_EditDocumentView, 0, new JPEGEncoder());
			var snapshotBitmap:BitmapData = ImageSnapshot.captureBitmapData(_EditDocumentView);

			var newPDF:PDF = new PDF(Orientation.LANDSCAPE, Unit.MM, Size.LETTER);
			newPDF.setDisplayMode(Display.FULL_WIDTH);

			newPDF.addPage();
//			newPDF.addImageStream(snapshot.data, ColorSpace.DEVICE_RGB, new Resize ( Mode.FIT_TO_PAGE, Position.CENTERED ));
			newPDF.addImage(new Bitmap(snapshotBitmap), new Resize ( Mode.FIT_TO_PAGE, Position.CENTERED ));
/*
			newPDF.setFont(FontFamily.ARIAL , Style.NORMAL, 12);
			newPDF.addText("Claimant Name: " + this.firstName.text + " " + lastName.text,10,40);
			newPDF.addText("Date: " + this.date.text,10,50);
			newPDF.addTextNote(48,45,100,2,"Claim Filed on: " + this.date.text + " today's date: " + new Date());
			newPDF.addText("Policy #: " + this.policyNum.text,10,60);
			newPDF.addText("Contact #: " + this.contact.text,10,70);
			newPDF.addText(this.claimNum.text,10,80);
			newPDF.addText("Claim Description:",10,90);
			newPDF.setXY(10,95);
			newPDF.addMultiCell(200,5,desc.text);
*/
/*
			var newFile:File = event.target as File;
			var fs:FileStream = new FileStream();
			try{
				fs.open(newFile,FileMode.WRITE);
				var pdfBytes:ByteArray = newPDF.save(Method.LOCAL);
				fs.writeBytes(pdfBytes);
				fs.close();
				Logger.Log("PDF Saved: " + newFile.url, LogEntry.INFO, this);
			} catch(e:Error){
				trace(e.message);
			}
		}
*/		
	}	
}
