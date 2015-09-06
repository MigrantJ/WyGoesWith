package com.jimgrant.test;
import format.swf.MovieClip;
import nme.events.MouseEvent;

/**
 * ...
 * @author Mandi
 */

class Garden extends GuiButton
{
		//create buttons out of four separate graphics: dirt, leaves1, leaves2, leaves3  (we don't need to pass those graphics, we're assuming this is a garden) 
		//conditionally change part of the button (which leavesN it currently has attached) based on saved data
		
		//both dirt and leaf graphic must change state together when clicked 
		
		//create text field or leave that in guisetup? 
		//where is timer handled? currently in guisetup
		//where is conditional click handled?  currently in guisetup
		
	private var world : World;
	private var percentDone : Dynamic;
	private var currentUp : String; //for this button, what's the proper up state? 
	private var currentDown : String; //for this button, what's the proper down state? 
	private var currentInactive : String; //for this button, what's the proper inactive state? 
	
	public function new(name : String, gardenX:Float, gardenY:Float, gardenWorld: World, action: Dynamic, gardenPercentDone : Dynamic) 
	{
		world = gardenWorld;
		percentDone = gardenPercentDone;
		
		super(world.artAssetLibrary.createMovieClip("garden"), gardenX, gardenY, action); 
	}

	public function updateState() {	
		var lastState : String = "up";
		if (state == currentUp) lastState = "up";
		else if (state == currentDown) lastState = "down";
		else lastState == "inactive";
		
		
		if (percentDone() < -40000000) { //this is such a lame hack lol
			currentUp = "gardenUp";
			currentDown = "gardenDown";
			currentInactive = "gardenInactive";
		}
		else if (percentDone() <= 0) {
			currentUp = "gardenLeaf3Up";
			currentDown = "gardenLeaf3Down";
			currentInactive = "gardenLeaf3Inactive";	
		}
		else if (percentDone() < .50 ) {
			currentUp = "gardenLeaf2Up";
			currentDown = "gardenLeaf2Down";
			currentInactive = "gardenLeaf2Inactive";
		}
		else if (percentDone() < 1){
			currentUp = "gardenLeaf1Up";
			currentDown = "gardenLeaf1Down";
			currentInactive = "gardenLeaf1Inactive";
		}
		else {
			currentUp = "gardenUp";
			currentDown = "gardenDown";
			currentInactive = "gardenInactive";
		}
		
		if (lastState == "up") state = currentUp;
		else if (lastState == "down") state = currentDown;
		else state = currentInactive;
	}
	
	public override function enable() : Void {
		if (!enabled) {
			enabled = true;
			state = currentUp;
			addEventListener( MouseEvent.MOUSE_DOWN, onButtonDown );
		}
	}
	
	public override function disable() : Void {
		enabled = false;
		state = currentInactive;
		if (hasEventListener(MouseEvent.MOUSE_DOWN)) removeEventListener(MouseEvent.MOUSE_DOWN, onButtonDown);
	}
	
	private override function onButtonUp(event) {
		state = currentUp;
		removeEventListener( MouseEvent.MOUSE_UP, onButtonUp );
		btnCallback();
	}
	
	private override function onButtonDown(event) {
		state = currentDown;
		
		addEventListener( MouseEvent.MOUSE_UP, onButtonUp );
	}
	
	private override function setUpAnimations():Void {
		addAnimation("gardenUp", 1, 2, "gardenUp");
		addAnimation("gardenDown", 3, 4, "gardenDown");
		addAnimation("gardenInactive", 5, 6, "gardenInactive");
		
		addAnimation("gardenLeaf1Up", 7, 8, "gardenLeaf1Up");
		addAnimation("gardenLeaf1Down", 9, 10, "gardenLeaf1Down");
		addAnimation("gardenLeaf1Inactive", 11, 12, "gardenLeaf1Inactive");
		
		addAnimation("gardenLeaf2Up", 13, 14, "gardenLeaf2Up");
		addAnimation("gardenLeaf2Down", 15, 16, "gardenLeaf2Down");
		addAnimation("gardenLeaf2Inactive", 17, 18, "gardenLeaf2Inactive");
		
		addAnimation("gardenLeaf3Up", 19, 20, "gardenLeaf3Up");
		addAnimation("gardenLeaf3Down", 21, 22, "gardenLeaf3Down");
		addAnimation("gardenLeaf3Inactive", 23, 24, "gardenLeaf3Inactive");
		
		//needs to know what state to put this button into when starting the game 
		//check save data in constructor, choose its state based on that 
		
		addState("gardenUp", "gardenUp", null, null);
		addState("gardenDown", "gardenDown", null, null);
		addState("gardenInactive", "gardenInactive", null, null);
		
		addState("gardenLeaf1Up", "gardenLeaf1Up", null, null);
		addState("gardenLeaf1Down", "gardenLeaf1Down", null, null);
		addState("gardenLeaf1Inactive", "gardenLeaf1Inactive", null, null);
		
		addState("gardenLeaf2Up", "gardenLeaf2Up", null, null);
		addState("gardenLeaf2Down", "gardenLeaf2Down", null, null);
		addState("gardenLeaf2Inactive", "gardenLeaf2Inactive", null, null);
		
		addState("gardenLeaf3Up", "gardenLeaf3Up", null, null);
		addState("gardenLeaf3Down", "gardenLeaf3Down", null, null);
		addState("gardenLeaf3Inactive", "gardenLeaf3Inactive", null, null);
		
		currentUp = "gardenUp";
		currentDown = "gardenDown";
		currentInactive = "gardenInactive";
	}
}