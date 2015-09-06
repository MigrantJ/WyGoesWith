package com.jimgrant.test;

import nme.geom.Rectangle;
import nme.geom.Point;
import nme.events.MouseEvent;
import motion.Actuate;
import motion.easing.Quad;
import motion.actuators.GenericActuator;

class GuiScrollMenu extends GuiMenu
{
	static inline public var CONSTRAIN_NONE : Int = 0; //this menu moves in all directions (useful for a world map or something like that)
	static inline public var CONSTRAIN_HORZ : Int = 1; //this menu moves left-right
	static inline public var CONSTRAIN_VERT : Int = 2; //this menu moves up-down
	
	static inline private var COAST_TIME : Float = 1; //in seconds
	static inline private var COAST_X_MULT : Int = 40; //the higher, the further coasting will travel
	static inline private var COAST_Y_MULT : Int = 40; //ditto
	static inline private var SNAPBACK_TIME : Float = .5; //in seconds
	
	private var scrollConstraint : Int; //uses the constants defined above
	private var view : Rectangle; //the viewable area of the scroll menu. Defines the snap coords as well.

	//these are the coords the menu will snap to when its location exceeds them
	private var minSnapX : Float;
	private var maxSnapX : Float;
	private var minSnapY : Float;
	private var maxSnapY : Float;
	
	private var origPosition : Point; //where the menu used to be before the user began moving it
	private var position(get_position, set_position) : Point; //where the menu currently is
	private var touch : Point; //where user was touching / dragging the mouse last time
	
	private var xDistanceMouseTraveled : Float = 0; //used to set how far the menu should move, both for dragging and for coasting after letting go
	private var yDistanceMouseTraveled : Float = 0; //used to set how far the menu should move, both for dragging and for coasting after letting go
	
	private var tween : IGenericActuator;
	
	public function new(gui: Gui, constraint: Int, scrollView: Rectangle)
	{
		super(gui);
		scrollConstraint = constraint;
		view = scrollView;
		
		position = new Point(view.x, view.y); //start it out at the top left corner of the viewing area
		addEventListener(MouseEvent.MOUSE_DOWN, onTouchBegin);
	}
	
	//getter / setter methods for properties
	public function get_position():Point {
		return new Point(this.x, this.y);
	}
	
	public function set_position(p:Point):Point {
		this.x = p.x;
		this.y = p.y;
		return new Point(this.x, this.y);
	}
	
	public function resetExtents():Void { //call this whenever you add elements to the scroll menu, this controls how far up and down the menu can scroll
		minSnapX = view.x + view.width - this.width;
		maxSnapX = view.x;
		minSnapY = view.top + view.height - this.height;
		maxSnapY = view.top;
		trace (this.height);
	}
	
	private function onTouchBegin(event):Void {
		//reset the distance traveled vars so coast() doesn't keep going
		xDistanceMouseTraveled = 0;
		yDistanceMouseTraveled = 0;
		
		removeEventListener(MouseEvent.MOUSE_DOWN, onTouchBegin);
		parentGui.world.addEventListener(MouseEvent.MOUSE_MOVE, onTouchMove);
		parentGui.world.addEventListener(MouseEvent.MOUSE_UP, onTouchEnd);
		origPosition = position;
		touch = new Point(event.stageX / parentGui.world.scaleX, event.stageY / parentGui.world.scaleY); //we multiply by two because the world is at half size, see Main.hx
		Actuate.stop(tween, null, false, false);
	}
	
	private function onTouchMove(event):Void {
		if (isEnabled) disableAllButtonsInMenu(); //turn off all the buttons while the menu is moving
		
		var newX : Float = position.x;
		var newY : Float = position.y;
		var curTouch : Point = new Point(event.stageX / parentGui.world.scaleX, event.stageY / parentGui.world.scaleY);
		
		if (scrollConstraint != CONSTRAIN_VERT) { //then we want the screen to be able to move horizontally
			xDistanceMouseTraveled = curTouch.x - touch.x;
			var newLocation = newX + xDistanceMouseTraveled;
			
			if (newLocation < minSnapX || newLocation > maxSnapX) {
				xDistanceMouseTraveled /= 2; //if we're traveling beyond the bounds of the view, slow the drag down
			}
			
			newX += xDistanceMouseTraveled;
		} else if (scrollConstraint != CONSTRAIN_HORZ) { //then we want the screen to be able to move vertically			
			yDistanceMouseTraveled = curTouch.y - touch.y;
			var newLocation = newY + yDistanceMouseTraveled;
			
			if (newLocation < minSnapY || newLocation > maxSnapY) {
				yDistanceMouseTraveled /= 2; //if we're traveling beyond the bounds of the view, slow the drag down
			}
			
			newY += yDistanceMouseTraveled;
		}
		
		touch = curTouch; //save the touch so we can measure the dist the next time the mouse moves
		position = new Point(newX, newY);
	}
	
	private function onTouchEnd(event):Void {
		enableAllButtonsInMenu();
		addEventListener(MouseEvent.MOUSE_DOWN, onTouchBegin);
		parentGui.world.removeEventListener(MouseEvent.MOUSE_MOVE, onTouchMove);
		parentGui.world.removeEventListener(MouseEvent.MOUSE_UP, onTouchEnd);
		
		coast();
	}
	
	//when the user lets go, the menu coasts to a stop.
	private function coast() {
		var xDest = position.x + (xDistanceMouseTraveled * COAST_X_MULT);
		var yDest = position.y + (yDistanceMouseTraveled * COAST_Y_MULT);
		tween = Actuate.tween (this, COAST_TIME, { x: xDest, y: yDest } );
		tween.ease(Quad.easeOut);
		tween.onUpdate(snapBack); //coasting ends when we hit the scroll limit
	}
	
	//put the menu back within the scroll limits (determined by the view rectangle)
	private function snapBack() {
		if (position.y < minSnapY) { //too high, snap back downwards to the minimum Y location
			Actuate.stop(tween, null, false, false);
			tween = Actuate.tween (this, .5, { y: minSnapY } ); 
			tween.ease(Quad.easeOut);
		}
		else if (position.y > maxSnapY) { //too low, snap back upwards to the maximum Y location
			Actuate.stop(tween, null, false, false);
			tween = Actuate.tween (this, .5, { y: maxSnapY } ); 
			tween.ease(Quad.easeOut);
		}
	}
}