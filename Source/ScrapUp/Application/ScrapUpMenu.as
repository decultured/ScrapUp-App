package ScrapUp.Application
{
	import flash.system.*;
	import flash.ui.*;
	import flash.geom.*;
	import mx.events.*;
	import mx.controls.Alert;
	import mx.controls.FlexNativeMenu;
	import Utilities.Logger.*;
	import Utilities.WindowManager.*;
	
	public class ScrapUpMenu extends FlexNativeMenu
	{
		public var menuData:XML = <root>
	            <menuitem label="ScrapUp">
	                <menuitem label="About" command="about" enabled="false"/>
					/*<menuitem type="separator"/>*/
					/*<menuitem label="Hide ScrapUp" command="hide-window" key="h" />*/
					<menuitem type="separator"/>
	                <menuitem label="Quit" command="quit" key="q"/>
	            </menuitem>
	            <menuitem label="File">
	                <menuitem label="New" command="new" key="n"/>
	                <menuitem label="Open Scrapbook File..." command="open" />
	                <menuitem type="separator"/>
	                <menuitem label="Save Scrapbook File..." command="save" />
					<menuitem type="separator"/>
					<menuitem label="Export">
		                <menuitem label="PNG Image" command="saveImage"/>
					</menuitem>
	                <menuitem type="separator"/>
	                <menuitem type="separator"/>
	                <menuitem label="Print..." key="p" command="print" enabled="false"/>
	            </menuitem>
	            <menuitem label="Edit">
	                <menuitem label="Undo" key="z" command="undo" enabled="false"/>
	                <menuitem label="Redo" command="redo" enabled="false"/>
	                <menuitem type="separator"/>
					<menuitem label="Cut" command="cut" key="x"/>
					<menuitem label="Copy" command="copy" key="c"/>
					<menuitem label="Paste" command="paste" key="v" />
					<menuitem label="Delete" command="delete" />
	                <menuitem type="separator"/>
					<menuitem label="Select All" command="selectAll" key="a"/>
					<menuitem label="Deselect All" command="deselectAll"/>
	                <menuitem type="separator"/>
					<menuitem label="Move Selected Forward" command="moveForward"/>
					<menuitem label="Move Selected Backward" command="moveBackward"/>
					<menuitem label="Move Selected To Front" command="moveToFront"/>
					<menuitem label="Move Selected To Back" command="moveToBack"/>
	            </menuitem>
	            <menuitem label="Insert">
	                <menuitem label="Label" command="insertLabel" key="1"/>
	                <menuitem label="Text Box" command="insertTextBox" key="2"/>
	                <menuitem label="Image" command="insertImage" key="3"/>
	            </menuitem>
	            <menuitem label="View">
                	<menuitem label="Fullscreen" type="check" command="fullscreen" toggled="false" key="f"/>
                	<menuitem label="Viewer Window" type="check" command="viewer" key="0"/>
	                <menuitem label="Status Bar" type="check" command="statusbar" toggled="false" key="/"/>
	                <menuitem label="Grid" type="check" command="showgrid" toggled="false"/>
	                <menuitem type="separator" />
	                <menuitem label="Zoom In" command="zoomin" key="=" />
	                <menuitem label="Zoom Out" command="zoomout" key="-" />
	                <menuitem label="Fit To Screen" type="check" command="fittoscreen" toggled="false"/>
		            <menuitem label="Zoom">
	            		<menuitem label="25%"  amount="0.25" command="zoom" />
	            		<menuitem label="50%"  amount="0.50" command="zoom" />
	            		<menuitem label="75%"  amount="0.75" command="zoom" />
	            		<menuitem label="100%" amount="1.0" command="zoom" />
	            		<menuitem label="150%" amount="1.5" command="zoom" />
	            		<menuitem label="200%" amount="2.0" command="zoom" />
	            		<menuitem label="400%" amount="4.0" command="zoom" />
		            </menuitem>
	                <menuitem type="separator"/>
	                <menuitem label="Debug Log Viewer" command="logviewer" key="l" />
	                <menuitem label="Save Debug Log File..." command="savelog" />
	            </menuitem>
	        </root>;

//		public var scrapUpMain:WindowedApplication = null;
		public var scrapUpApp:ScrapUpApp = null;
		
		public function ScrapUpMenu():void
		{
			dataProvider = menuData;
			keyEquivalentModifiersFunction = StandardOSModifier;
			addEventListener(FlexNativeMenuEvent.ITEM_CLICK, menuItemClicked);
			addEventListener(FlexNativeMenuEvent.MENU_SHOW, menuShow);
		}
		
		private function menuShow(menuEvent:FlexNativeMenuEvent):void
		{
//			if (!_EditDocumentView.IsObjectSelected()) {
//			}
		}

		private function StandardOSModifier(item:Object):Array{
			var modifiers:Array = new Array();
			if((Capabilities.os.indexOf("Windows") >= 0)){
				modifiers.push(Keyboard.CONTROL);
			} else if (Capabilities.os.indexOf("Mac OS") >= 0){
				modifiers.push(Keyboard.COMMAND);
			}
			return modifiers;
		}


		private function menuItemClicked(menuEvent:FlexNativeMenuEvent):void
		{
			if (!scrapUpApp) {
				return;
			}

			var command:String = menuEvent.item.@command;
			switch(command){
				case "cut":			scrapUpApp.Cut(null); break;
				case "copy": 		scrapUpApp.Copy(null); break;
				case "paste":		scrapUpApp.Paste(null); break;
				case "delete":		scrapUpApp.document.DeleteSelected();	break;
				case "quit":		scrapUpApp.Quit(); break;
				case "about":		break;
				case "open":		scrapUpApp.OpenFile();	break;
				case "save":		scrapUpApp.SaveFile();	break;
				case "savelog":		scrapUpApp.SaveLogFile();	break;
				case "saveImage": 	scrapUpApp.SaveImage(); break;
				case "savePDF":		scrapUpApp.SavePDF(); break;
				case "print":		break;
				case "undo":		break;
				case "redo":		break;
				case "new": 		scrapUpApp.New(); break;
				case "moveForward":		scrapUpApp.editPage.MoveSelectedForward(); break;
				case "moveBackward": 	scrapUpApp.editPage.MoveSelectedBackward(); break;
				case "moveToFront":		scrapUpApp.editPage.MoveSelectedToFront(); break;
				case "moveToBack":		scrapUpApp.editPage.MoveSelectedToBack();	break;
				case "selectAll": 		scrapUpApp.editPage.SelectAll(); break;
				case "deselectAll": 	scrapUpApp.editPage.DeselectAll(); break;
				case "insertImage":			scrapUpApp.editPage.AddScrapByType('image');			break;
				case "insertLabel":			scrapUpApp.editPage.AddScrapByType('label');			break;
				case "insertTextBox": 		scrapUpApp.editPage.AddScrapByType('textbox');		break;
				case "zoomin": 	scrapUpApp.ZoomIn(); break;
				case "zoomout": scrapUpApp.ZoomOut(); break;
				case "viewer": scrapUpApp.OpenViewer(); break;
				case "fittoscreen":
					scrapUpApp.fitToScreen = !scrapUpApp.fitToScreen;
					menuEvent.item.@toggled = scrapUpApp.fitToScreen;
					break;
				case "zoom": scrapUpApp.Zoom(menuEvent.item.@amount); break;
				case "statusbar":
					scrapUpApp.statusBarVisible = !scrapUpApp.statusBarVisible;
					menuEvent.item.@toggled = scrapUpApp.statusBarVisible;
					break;
				case "showgrid":
					scrapUpApp.appGrid.visible = !scrapUpApp.appGrid.visible;
					menuEvent.item.@toggled = scrapUpApp.appGrid.visible;
					break;
				case "fullscreen":
					scrapUpApp.Fullscreen();
					menuEvent.item.@toggled = !menuEvent.item.@toggled;
					break;
				case "hide-window":
					scrapUpApp.HideApplication();
					break;
				case "logviewer":
					WindowManager.Open(new LoggerWindow(), null, "logger", false, new Point(600, 500));
					break;
				default:
					Logger.LogWarning("Unrecognized Menu Command: " + command + "  " + menuEvent.item.@label);
			}
		}		
	}
}