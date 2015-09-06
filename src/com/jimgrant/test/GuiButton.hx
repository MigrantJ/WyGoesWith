package com.jimgrant.test;
import format.swf.MovieClip;
import nme.events.MouseEvent;

/**
 * ...
 * @author Jim
 */

//This is a factory class that makes new buttons and keeps track of their state
class GuiButton extends AnimatedObject
{
	private var btnCallback : Void->Void; //the function the button performs when clicked
	private var enabled : Bool; //keeps track of whether the button is available or not
	
	//constructor
	public function new(movieClip:MovieClip, buttonX:Float, buttonY:Float, buttonCallback:Void->Void) {
		super(movieClip, buttonX, buttonY);
		btnCallback = buttonCallback;
		setUpAnimations();
		enable();
	}
	
	//public methods
	//allows the button to be pressed and puts the mc on its up frame. Clicking the button will call onButtonDown
	public function enable() : Void {
		if (!enabled) {
			enabled = true;
			state = "up";
			addEventListener( MouseEvent.MOUSE_DOWN, onButtonDown );
		}
	}
	
	//turns the button off and allows no further interaction til it's enabled again
	public function disable() : Void {
		enabled = false;
		state = "inactive";
		if (hasEventListener(MouseEvent.MOUSE_DOWN)) removeEventListener(MouseEvent.MOUSE_DOWN, onButtonDown);
	}
	
	//private methods
	//called when the player releases the button. Note that this also starts the callback function
	private function onButtonUp(event) {
		state = "up";
		removeEventListener( MouseEvent.MOUSE_UP, onButtonUp );
		btnCallback();
	}
	
	//called when the player clicks the button and listens for button release
	private function onButtonDown(event) {
		state = "down";
		
		addEventListener( MouseEvent.MOUSE_UP, onButtonUp );
	}
	
	//sets up which animation frames to use for the different button states.
	//Eventually I'd like to make these customizable so we can have animated buttons.
	private function setUpAnimations():Void {
		addAnimation("up", 1, 2, "up");
		addAnimation("down", 3, 4, "down");
		addAnimation("inactive", 5, 6, "inactive");
		
		addState("up", "up", null, null);
		addState("down", "down", null, null);
		addState("inactive", "inactive", null, null);
	}
}