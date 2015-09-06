package com.jimgrant.test;

import format.SWF;
import format.swf.MovieClip;
import nme.geom.Point;
import nme.geom.Rectangle;
import nme.Assets;
import nme.display.Sprite;
import nme.display.StageAlign;
import nme.display.StageScaleMode;
import nme.Lib;
import flash.events.Event;
import nme.utils.Timer;
import nme.events.TimerEvent;
import nme.events.MouseEvent;
import motion.Actuate;
import motion.easing.Linear;
import motion.easing.Cubic;
import motion.actuators.GenericActuator;

class Grub extends AnimatedObject {
	//constants
	static private var WALK_SPEED = 200; //in pixels per second
	static private var WALK_DIST_MIN = 50;
	static private var WALK_DIST_MAX = 300;
	static private var RUN_SPEED = 300;
	
	static private var FOOD_STOP_DISTANCE_THRESHOLD = 90;
	
	static public var walkBounds : Rectangle = new Rectangle(50, 250, 450, 270); //560 originally 	
		
	static private var STINK_OFFSET_X : Int = 20;
	static private var STINK_OFFSET_Y : Int = -140;
	
	//properties
	private var world : World;
	private var thought : Thought;
	public var stink : MovieClip;
	private var hat : MovieClip;
	private var timer : Timer;
	private var walkDest : Point;
	private var touch: Point;
	private var tween: IGenericActuator;
	private var effect: AnimatedObject;
	private var isTouchable: Bool = true;
	
	//trait properties
	public var grubName: String;
	public var grubBdayMonth: String;
	public var grubBdayMonthNumber: Int;
	public var grubBdayDayNumber: Int;
	public var grubTrait1: String;
	public var grubTrait2: String;
	public var grubTrait3: String;
	public var grubFavoriteFood : String; 
	
	private static var grubNameArray:Array<String> = ["Wy", "Ry", "Wiki", "Kady", "Shy", "Dreamy", "Pippy", "Flake", "Yummy", "Candy", "Catherine", "Lala", "Terry", "Zippy", "Groovy", "Stormy", "Esther", "Tempo", "Pixel", "Twizzle", "Zap", "Sunshine", "Sunny", "Bacon", "I <3 Jim"];
	private static var grubBdayMonthArray:Array<String> = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
	
	private static var grubTalentPool:Array<String> = ["Artistic", "Smart", "Musical", "Mathemagical", "Scientific", "Witty"];
	private static var grubPersonalityPool:Array<String> = ["Messy", "Friendly", "Curious", "Cheery", "Playful", "Shy", "Picky", "Hyper", "Lazy", "Neat", "Outgoing", "Jaded", "Always Late", "Grumpy", "Lucky"];
	
	//constructor
	public function new (grubWorld:World) {
		world = grubWorld;
		super(world.artAssetLibrary.createMovieClip("Wy"), 200, 200);
		mc.scaleX = -.75;
		mc.scaleY = .75;
		
		//stinky wy 
		stink = world.artAssetLibrary.createMovieClip("stink");
		addChild(stink);
		stink.x = STINK_OFFSET_X;
		stink.y = STINK_OFFSET_Y;
		
		//Start up Grub's idle timer
		timer = new Timer(2000);
		timer.addEventListener(TimerEvent.TIMER, idleTimer);

		//Add thoughts, child it to Grub
		thought = new Thought(world);
		addChild(thought);
		
		//Initialize Animations
		addAnimation("idle", 1, 22, "idle");
		addAnimation("walk", 23, 35, "walk");
		addAnimation("run", 36, 42, "run");
		addAnimation("sleep", 43, 52, "sleepLoop");
		addAnimation("sleepLoop", 53, 103, "sleepLoop");
		addAnimation("wake", 104, 116, "idle", "idle");
		addAnimation("swim", 117, 138, "swim");
		addAnimation("eat", 139, 163, "idle", "idle");
		addAnimation("play", 164, 185, "idle");
		addAnimation("garden", 241, 274, "idle", "idle");
		addAnimation("protest", 186, 195, "protestLoop");
		addAnimation("protestLoop", 196, 208, "protestExit");
		addAnimation("protestExit", 209, 218, "idle", "idle");
		addAnimation("grabbed", 219, 222, "grabbedLoop");
		addAnimation("grabbedLoop", 223, 240, "grabbedLoop");
		addAnimation("land", 276, 285, "idle");
		
		//Initialize States
		//add state, state name, animation name, function to call on start, function to call on end 
		addState("idle", "idle", function() {
			turnOnGrabable();
			timer.reset();
			timer.start();
		}, null);
		addState("walk", "walk", function() {
			moveToDest(getNewWalkDest(), WALK_SPEED, "idle");
		}, null);
		addState("walkTowardsObject", "run", function() {
			turnOffGrabable();
			moveToDest(world.object.position, RUN_SPEED, "eat");
		}, null);
		addState("walkTowardsPillow", "run", function() {
			turnOffGrabable();
			moveToDest(world.object.position, RUN_SPEED, "sleep");
		}, null);
		addState("walkTowardsGarden", "run", function() {
			turnOffGrabable();
			moveToDest(world.gui.menus.get("onscreenGardens").buttons.get("garden" + world.selectedGarden).position, RUN_SPEED, "garden");
		}, null);
		addState("garden", "garden", function() {
			setFacing(world.gui.menus.get("onscreenGardens").buttons.get("garden" + world.selectedGarden));
		}, null);
		addState("play", "play", function() {
			setFacing(world.object);
		}, null);
		addState("eat", "eat", function() {
				setFacing(world.object);
			}, function() {
				world.removeObject();
			});
		addState("sleep", "sleep", function() {
			setFacing(world.object);
			world.gui.menus.get("Actions").buttons.get("buttonSleep").enable();
			world.toggleZZZs();
			world.sleepTimer.start();
		}, function() {
			});
		addState("autosleep", "sleep", function() {
			turnOffGrabable();
			timer.stop();
			world.gui.menus.get("Actions").disableAllButtonsInMenu();
			world.gui.menus.get("Actions").buttons.get("buttonSleep").enable();
			world.toggleZZZs();
			world.sleepTimer.start();
		}, null);
		addState("wake", "wake", function() {
			timer.stop();
			world.toggleZZZs();
			world.removeObjectBGLayer();
			world.sleepTimer.stop();
			world.gui.menus.get("Actions").enableAllButtonsInMenu();
		}, function() {
			turnOnGrabable();
		});
		addState("grabbed", "grabbed", function() {
			timer.stop();
		}, null);
		addState("protest", "protest", function() {
			Actuate.stop(tween, [ "x", "y" ], false, false);
			timer.stop();
			world.gui.buttonsDisable();
		}, 	function() { world.gui.buttonsEnable(); 
			timer.reset();
			timer.start();} 
		);
		addState("fall", "grabbed", function() {
			world.gui.buttonsDisable(); 
			tween = Actuate.tween (this, .5, { x: position.x, y: 450 } );
			tween.ease(Cubic.easeIn);
			tween.onComplete(set_state, ["land"]);
		}, 	function() {
			world.createSmoke(position.x, position.y + 50);
		});
		addState("land", "land", function() {
			tween = Actuate.tween (this, .5, { x: position.x, y: 450 } );
			tween.ease(Cubic.easeIn);
			tween.onComplete(set_state, ["idle"]);
		}, 	function() {
			world.gui.buttonsEnable(); 
		});
		
		//Start Listeners
		addEventListener(MouseEvent.MOUSE_DOWN, onTouchBegin);
		
		//Choose grub traits
		grubTraitsAssign();
		
		state = "idle";
	}
	
	//Personality (traits) selection method
	private function grubTraitsAssign():Void {
		//TRAITS SELECTION! 
		//These are traits that do not / can not be changed after they are assigned to a grub.
			var grubTalentNumber : Int = Std.random(grubTalentPool.length); //pick a random number between 0 and however long the talent pool array is
			grubTrait1 = grubTalentPool[grubTalentNumber];
			
			var grubPersonalityNumber : Int = Std.random(grubPersonalityPool.length); //pick a random number between 0 and however long the talent pool array is
			grubTrait2 = grubPersonalityPool[grubPersonalityNumber];
			
			//now we figure out which entry in the personality pool we already used and we "slice" it out
			var traitArrayBegin : Array<String> = grubPersonalityPool.slice(0, grubPersonalityNumber);
			var traitArrayEnd : Array<String> = grubPersonalityPool.slice(grubPersonalityNumber + 1, grubPersonalityPool.length);
			//we stitch the two arrays together
			var traitArrayJoined: Array<String> = traitArrayBegin.concat(traitArrayEnd); 
			
			var grubPersonalityNumber : Int = Std.random(traitArrayJoined.length); //pick a random number between 0 and however long the talent pool array is
			grubTrait3 = traitArrayJoined[grubPersonalityNumber];
			
			
		//Favorite Food selection
			var favoriteSnackNumber : Int = Std.random(Food.snackArray.length);
			grubFavoriteFood = Food.snackArray[favoriteSnackNumber];
			
		//Grub Name
			//TODO: Allow user to edit he grub's name and save it, but for now just picking one and assigning it is fine 
			var grubNameNumber : Int = Std.random(grubNameArray.length); //pick a random number between 0 and however long the grub name array is now 
			grubName = grubNameArray[grubNameNumber]; //use that number to choose a name 
			
		//Grub birth month selection
			grubBdayMonthNumber = Std.random(grubBdayMonthArray.length); //pick a random number out of this array's length
			grubBdayMonth = grubBdayMonthArray[grubBdayMonthNumber]; //choose a month
		
		//Grub birth day selection
			//remember, the array starts at 0 so all month numbers shift one to the left 
			switch( grubBdayMonthNumber ) {
			case 1: //1 february 
				grubBdayDayNumber = Std.random(28) + 1;
			case 3, 5, 8, 10: 
				grubBdayDayNumber = Std.random(29) + 1;
			default: 
				grubBdayDayNumber = Std.random(30) + 1;
			}
			//trace("testing this is visible on ios");
	}
	
	//Movement methods
	private function getNewWalkDest():Point {
		var walkBoundsCenterX : Float = walkBounds.x + walkBounds.width / 2;
		var walkBoundsCenterY : Float = walkBounds.y + walkBounds.height / 2;
		var grubCenterX : Float = position.x + 50;
		var grubCenterY : Float = position.y + 50;
		var walkToX : Float;
		var walkToY : Float;
		if (grubCenterX <= walkBoundsCenterX) {
			walkToX = Std.random(Math.floor(walkBounds.right - grubCenterX + WALK_DIST_MIN)) + walkBounds.x;
		} else {
			walkToX = Std.random(Math.floor(grubCenterX - WALK_DIST_MIN - walkBounds.left)) + walkBounds.x;
		}
		if (grubCenterY <= walkBoundsCenterY) {
			walkToY = Std.random(Math.floor(walkBounds.bottom - grubCenterY + WALK_DIST_MIN)) + walkBounds.y;
		} else {
			walkToY = Std.random(Math.floor(grubCenterY - WALK_DIST_MIN - walkBounds.top)) + walkBounds.y;
		}
		return new Point(walkToX, walkToY);
	}
	
	//move to dest covers both idle walking and purposeful walking (towards objects on stage) 
	private function moveToDest(destination:Point, speed:Int, endState:String):Void {
		timer.stop();
		walkDest = destination; 
		
		//if Wy is walking towards food or a pillow these X and Y offsets must be modified
		if (endState == "eat") {
			if (walkDest.x > position.x) {
				walkDest.x -= 200;
			} else {
				walkDest.x += 200;
			}
			walkDest.y -= 50;
		} 
		
		if (endState == "garden") {
			if (walkDest.x > position.x) {
				walkDest.x -= 10;
			} else {
				walkDest.x += 100;
			}
				walkDest.y -= 50;
		}
		
		var time = Point.distance(position, walkDest) / speed;
		setFacing();
		tween = Actuate.tween (this, time, { x: walkDest.x, y: walkDest.y} ); 
		tween.ease(Linear.easeNone);
		tween.onComplete(set_state, [endState]);
	}
	
	private function setFacing(?sprite:Sprite):Void {
		if (walkDest.x > position.x || (sprite != null && sprite.x > position.x)) {  //make no modifications to offsets here, this is also used by other functions
			mc.scaleX = -.75;
			mc.scaleY = .75;
		}
		else {
			mc.scaleX = .75;
			mc.scaleY = .75;
		}
	}
	
	//"prebound" event listener functions
	private function idleTimer(event:TimerEvent):Void {
		state = "walk";
	}
	
	private function turnOnGrabable():Void {
		if (!isTouchable) {
			addEventListener(MouseEvent.MOUSE_DOWN, onTouchBegin);
			isTouchable = true;
		}
	}
	
	private function turnOffGrabable():Void {
		if (isTouchable) {
			removeEventListener(MouseEvent.MOUSE_DOWN, onTouchBegin);
			isTouchable = false;
		}
	}
	
	private function onTouchBegin(event):Void {
		Actuate.stop(this);
		state = "grabbed";
		removeEventListener(MouseEvent.MOUSE_DOWN, onTouchBegin);
		world.addEventListener(MouseEvent.MOUSE_MOVE, onTouchMove);
		world.addEventListener(MouseEvent.MOUSE_UP, onTouchEnd);
		touch = new Point(event.stageX / world.scaleX, event.stageY / world.scaleY);
		position = touch;
	}
	
	private function onTouchMove(event):Void {
		touch.x = event.stageX / world.scaleX;
		touch.y = event.stageY / world.scaleY;
		position = touch;
	}
	
	private function onTouchEnd(event):Void {
		if (position.y <= walkBounds.top) { //then Wy should fall back onto the ground
			state = "fall";
		} else {
			state = "idle";
		}
		addEventListener(MouseEvent.MOUSE_DOWN, onTouchBegin);
		world.removeEventListener(MouseEvent.MOUSE_MOVE, onTouchMove);
		world.removeEventListener(MouseEvent.MOUSE_UP, onTouchEnd);
	}
	
	public function addHat(mcName:String, hatX:Int, hatY:Int):Void {
		if (hat != null) mc.removeChild(hat);
		hat = world.artAssetLibrary.createMovieClip(mcName);
		hat.x = hatX;
		hat.y = hatY;
		mc.addChild(hat);
	}
}


