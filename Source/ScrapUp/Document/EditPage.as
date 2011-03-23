package ScrapUp.Document
{
	import mx.controls.Alert;
	import ScrapUp.Scrap.*;
	import ScrapUp.Scraps.*;
	import flash.geom.*;
	import spark.components.Group;
	import spark.components.SkinnableContainer;
	import ScrapUp.Document.Skins.*;
	import ScrapUp.Application.*;
	import com.roguedevelopment.objecthandles.*;
	import com.roguedevelopment.objecthandles.constraints.*;
	import com.roguedevelopment.objecthandles.decorators.AlignmentDecorator;
	import com.roguedevelopment.objecthandles.decorators.DecoratorManager;
	import mx.managers.PopUpManager;
	import Utilities.Logger.*;

	public class EditPage extends Page
	{
		public var objectHandles:ObjectHandles;
		protected var decoratorManager:DecoratorManager;
		[Bindable]public var appClass:ScrapUpApp;
		
		public var toolbar:Group;
		public var smallToolbar:Group;
		
		[Bindable]public var selectedRefreshable:Boolean = false;
		[Bindable]public var selectedEditable:Boolean = false;
		[Bindable]public var singleScrapSelected:Boolean = false;
		
		[Bindable]public var scrapOptionsEnabled:Boolean = false;
		
		public function EditPage():void
		{
			super();
		}
		
		public function InitializeForEdit():void
		{
			InitObjectHandles();
		}

		public override function New():void
		{
			if (objectHandles && objectHandles.selectionManager)
				objectHandles.selectionManager.clearSelection();
			super.New();
		}

		public function OpenPageWizard():void {
			var pageWizard:EditPageWizard = new EditPageWizard();
			pageWizard.appClass = appClass;
			pageWizard.setStyle("top", "0");
			pageWizard.setStyle("bottom", "0");
			pageWizard.setStyle("left", "0");
			pageWizard.setStyle("right", "0");

			ScrapUpApp.instance.OpenPopup(pageWizard, "pagewizard", false, new Point(300, 200));
		}

		public function InitObjectHandles():void
		{
			objectHandles = new ObjectHandles(this, null, new Flex4HandleFactory(), new Flex4ChildManager());
			objectHandles.selectionManager.addEventListener(SelectionEvent.ADDED_TO_SELECTION, ObjectSelected);
			objectHandles.selectionManager.addEventListener(SelectionEvent.REMOVED_FROM_SELECTION, ObjectDeselected);
			objectHandles.selectionManager.addEventListener(SelectionEvent.SELECTION_CLEARED, ObjectDeselected);

			objectHandles.addEventListener(ObjectChangedEvent.OBJECT_MOVED, ObjectChanged);
//			objectHandles.addEventListener(ObjectChangedEvent.OBJECT_MOVING, ObjectChanged);
			objectHandles.addEventListener(ObjectChangedEvent.OBJECT_RESIZED, ObjectChanged);
//			objectHandles.addEventListener(ObjectChangedEvent.OBJECT_RESIZING, ObjectChanged);
			objectHandles.addEventListener(ObjectChangedEvent.OBJECT_ROTATED, ObjectChanged);
//			objectHandles.addEventListener(ObjectChangedEvent.OBJECT_ROTATING, ObjectChanged);

			var sizeConstraint:SizeConstraint = new SizeConstraint();
			sizeConstraint.minWidth = 20;
			sizeConstraint.minHeight = 20;
			
			objectHandles.addDefaultConstraint(sizeConstraint);							

			SetToolbar();

			// Logger.LogDebug("ObjectHandles Initialized", this);

//			decoratorManager = new DecoratorManager( objectHandles, this );
//			decoratorManager.addDecorator( new AlignmentDecorator() );
		}

		public function AddObjectHandles(newScrap:Scrap):void
		{
			if (newScrap) {
				var handles:Array = [];
				var constraints:Array = null;

				if (newScrap.verticalSizable && newScrap.horizontalSizable) {
					handles.push( new HandleDescription( HandleRoles.RESIZE_UP + HandleRoles.RESIZE_LEFT, new Point(0,0), new Point(0,0)));
					handles.push( new HandleDescription( HandleRoles.RESIZE_UP + HandleRoles.RESIZE_RIGHT, new Point(100,0), new Point(0,0))); 
					handles.push( new HandleDescription( HandleRoles.RESIZE_DOWN + HandleRoles.RESIZE_RIGHT, new Point(100,100), new Point(0,0))); 
					handles.push( new HandleDescription( HandleRoles.RESIZE_DOWN + HandleRoles.RESIZE_LEFT, new Point(0,100), new Point(0,0))); 
				}
				if (newScrap.verticalSizable) {
					handles.push( new HandleDescription( HandleRoles.RESIZE_UP, new Point(50,0), new Point(0,0))); 
					handles.push( new HandleDescription( HandleRoles.RESIZE_DOWN, new Point(50,100), new Point(0,0))); 
				}
				if (newScrap.horizontalSizable) {
					handles.push( new HandleDescription( HandleRoles.RESIZE_LEFT, new Point(0,50), new Point(0,0))); 
					handles.push( new HandleDescription( HandleRoles.RESIZE_RIGHT, new Point(100,50), new Point(0,0))); 
				}
				if (newScrap.rotatable)
					handles.push( new HandleDescription( HandleRoles.ROTATE, new Point(100,50), new Point(20,0))); 
				if (newScrap.aspectLocked) {
					constraints = [];
					constraints.push(new MaintainProportionConstraint());
				}
				
				objectHandles.registerComponent(newScrap, newScrap.view, handles, true, constraints);
				DeselectAll();
				objectHandles.selectionManager.addToSelected(newScrap);
			}
		}
		
		public override function ViewResized():void
		{
			super.ViewResized();
		}
		
		public function GetSelectedScrap():Scrap
		{
			if (objectHandles.selectionManager.currentlySelected.length == 1 &&
				objectHandles.selectionManager.currentlySelected[0] != null &&
				objectHandles.selectionManager.currentlySelected[0] is Scrap) {
					return objectHandles.selectionManager.currentlySelected[0] as Scrap;
			}
			return null;
		}
		
		public function SetToolbar():void
		{
			if (!toolbar || !smallToolbar)
				return;
				
			toolbar.removeAllElements();
			smallToolbar.removeAllElements();

		 	if (objectHandles.selectionManager.currentlySelected.length == 1) {
				var selectedScrap:Scrap = objectHandles.selectionManager.currentlySelected[0] as Scrap;
				toolbar.addElement(selectedScrap.CreateEditor());
				var newSmallEditor:ScrapEditor = selectedScrap.CreateSmallEditor();
				if (newSmallEditor) {
					smallToolbar.addElement(newSmallEditor);
				} else {
					// Logger.LogDebug("No Small Scrap Editor available for this scrap: " + selectedScrap.type);
				}
				scrapOptionsEnabled = true;
				selectedRefreshable = false;
				selectedEditable = selectedScrap.editable;
				singleScrapSelected = true;
			} else if (objectHandles.selectionManager.currentlySelected.length > 1) {
				scrapOptionsEnabled = true;
				selectedRefreshable = false;
				selectedEditable = false;
				singleScrapSelected = false;
			} else {
				toolbar.addElement(new EditPageToolbar(this, EditPageToolbarSkin));
				smallToolbar.addElement(new EditPageToolbar(this, EditPageSmallToolbarSkin));
				scrapOptionsEnabled = false;
				selectedRefreshable = false;
				selectedEditable = false;
				singleScrapSelected = false;
			}
		}
		
		private function SnapPosition(scrap:Scrap):void {
			if (scrap && appClass.appGrid.snap && appClass.appGrid.xDensity) {
				var num:Number = 0;
				var gridSize:Number = appClass.appGrid.xDensity;
			
				// X Positioning
				num = (scrap.x % gridSize) - (gridSize * 0.5);
				if (num)
					scrap.x = scrap.x - (scrap.x % gridSize);
				else
					scrap.x = scrap.x - (scrap.x % gridSize) + gridSize;
			
				// Y Positioning
				num = (scrap.y % gridSize) - (gridSize * 0.5);
				if (num)
					scrap.y = scrap.y - (scrap.y % gridSize);
				else
					scrap.y = scrap.y - (scrap.y % gridSize) + gridSize;
			}
		}

		private function SnapSize(scrap:Scrap):void {
			if (scrap && appClass.appGrid.snap && appClass.appGrid.xDensity) {
				var num:Number = 0;
				var gridSize:Number = appClass.appGrid.xDensity;
			
				// Width adjustment
				num = (scrap.width % gridSize) - (gridSize * 0.5);
				if (num)
					scrap.width = scrap.width - (scrap.width % gridSize);
				else
					scrap.width = scrap.width - (scrap.width % gridSize) + gridSize;
			
				// Height adjustment
				num = (scrap.height % gridSize) - (gridSize * 0.5);
				if (num)
					scrap.height = scrap.height - (scrap.height % gridSize);
				else
					scrap.height = scrap.height - (scrap.height % gridSize) + gridSize;
			}
		}

		private function ObjectChanged(event:ObjectChangedEvent):void{
			for each (var scrap:Scrap in event.relatedObjects) {
				if (event.type == ObjectChangedEvent.OBJECT_MOVED) {
					SnapPosition(scrap);
					scrap.Moved();
				}
				else if (event.type == ObjectChangedEvent.OBJECT_RESIZED) {
					//SnapSize(scrap);
					scrap.Resized();
				}
				else if (event.type == ObjectChangedEvent.OBJECT_ROTATED) {
					scrap.Rotated();
				}
			}
		}

		public override function AddScrap(_scrap:Scrap):Scrap
		{
			var newScrap:Scrap = super.AddScrap(_scrap);
			if (!newScrap) {
				return null;
			}
			
			// TODO WHAT IS THIS?
			// newScrap.isInEditor = true;
			
			AddObjectHandles(newScrap);
			return newScrap;
		}
		
		public override function DeleteScrap(_scrap:Scrap):void
		{
			if (_scrap == null)
				return;
				
			objectHandles.unregisterComponent(_scrap.view);
			SetToolbar();
			super.DeleteScrap(_scrap);
		}

		public function SelectAll():void
		{
			if (!objectHandles)
				return;
				
			objectHandles.selectionManager.clearSelection();
			for (var i:int = numElements - 1; i > -1; i--) {
				if (getElementAt(i) is ScrapView) {
					var scrapView:ScrapView = getElementAt(i) as ScrapView;
					objectHandles.selectionManager.addToSelected(scrapView.model);
				}
			}
		}
		
		public function SelectScrap(_scrap:Scrap):void
		{
			if (!objectHandles || !_scrap)
				return;
				
			objectHandles.selectionManager.clearSelection();
			objectHandles.selectionManager.addToSelected(_scrap);
		}
		
		public function DeselectAll():void
		{
			if (!objectHandles)
				return;
				
			objectHandles.selectionManager.clearSelection();
		}
		
		protected function ObjectSelected(event:SelectionEvent):void {
			for each (var scrap:Scrap in event.targets) {
				scrap.selected = true;
			}
			SetToolbar();
		}

		protected function ObjectDeselected(event:SelectionEvent):void {
			if (toolbar)
				toolbar.removeAllElements();

			for each (var scrap:Scrap in event.targets) {
				scrap.selected = false;
			}
			SetToolbar();
		}

		public function DeleteSelected():void
		{
			var selectedArray:Array = new Array();

			for (var i:int = 0; i < objectHandles.selectionManager.currentlySelected.length; i++) {
				if (objectHandles.selectionManager.currentlySelected[i] != null && objectHandles.selectionManager.currentlySelected[i] is Scrap)
					selectedArray.push(objectHandles.selectionManager.currentlySelected[i] as Scrap);
			}

			for (i = 0; i < selectedArray.length; i++) {
				DeleteScrap(selectedArray[i]);
			}

			objectHandles.selectionManager.clearSelection();
		}
		
		public function IsSelectedDeletable():Boolean
		{
			if(objectHandles.selectionManager.currentlySelected.length == 0) {
				return false;
			}
			
			for (var i:int = 0; i < objectHandles.selectionManager.currentlySelected.length; i++) {
				if (objectHandles.selectionManager.currentlySelected[i] != null && objectHandles.selectionManager.currentlySelected[i] is Scrap) {
					var scrap:Scrap = objectHandles.selectionManager.currentlySelected[i] as Scrap;
					if(scrap.isLocked == true) {
						return false;
					}
				}
			}
			
			return true;
		}

		public function ToggleEditSelected():void
		{
			if (objectHandles.selectionManager.currentlySelected.length == 1) {
				(objectHandles.selectionManager.currentlySelected[0] as Scrap).ToggleEditMode();
			}
		}

		public function RefreshSelected():void
		{
			if (objectHandles.selectionManager.currentlySelected.length == 1) {
				(objectHandles.selectionManager.currentlySelected[0] as Scrap).Refresh();
			}
		}

		public function ToggleLockSelected():void
		{
			if (objectHandles.selectionManager.currentlySelected.length == 1) {
				(objectHandles.selectionManager.currentlySelected[0] as Scrap).ToggleLocked();
			}
		}

		public function MoveSelectedForward():void
		{
			if (objectHandles.selectionManager.currentlySelected.length == 1) {
				var scrapView:ScrapView = (objectHandles.selectionManager.currentlySelected[0] as Scrap).view;
				var idx:Number = getElementIndex(scrapView);
				
				if (idx < numElements - 1) {
					for (var i:int = idx + 1; i < numElements; i++) {
						if (getElementAt(i) is ScrapView) {
							setElementIndex(scrapView, i);
							break;
						}
					}
				}
			}
		}
		
		public function MoveSelectedBackward():void
		{
			if (objectHandles.selectionManager.currentlySelected.length == 1) {
				var scrapView:ScrapView = (objectHandles.selectionManager.currentlySelected[0] as Scrap).view;
				var idx:Number = getElementIndex(scrapView);
				
				if (idx > 0) {
					for (var i:int = idx - 1; i >= 0; i--) {
						if (getElementAt(i) is ScrapView) {
							setElementIndex(scrapView, i);
							break;
						}
					}
				}
			}
		}
		
		public function MoveSelectedToFront():void
		{
			if (objectHandles.selectionManager.currentlySelected.length == 1) {
				var scrapView:ScrapView = (objectHandles.selectionManager.currentlySelected[0] as Scrap).view;
				var idx:Number = getElementIndex(scrapView);
				
				if (idx < numElements - 1) {
					for (var i:int = numElements - 1; i >= 0; i--) {
						if (getElementAt(i) is ScrapView) {
							setElementIndex(scrapView, i);
							break;
						}
					}
				}
			}
		}
		
		public function MoveSelectedToBack():void
		{
			if (objectHandles.selectionManager.currentlySelected.length == 1) {
				var scrapView:ScrapView = (objectHandles.selectionManager.currentlySelected[0] as Scrap).view;
				var idx:Number = getElementIndex(scrapView);
				
				if (idx > 0)
					setElementIndex(scrapView, 0);
			}
		}
	} 
}