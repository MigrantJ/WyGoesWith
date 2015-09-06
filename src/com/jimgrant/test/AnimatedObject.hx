package com.jimgrant.test;
import format.swf.MovieClip;
import nme.display.Sprite;
import flash.events.Event;
import nme.geom.Point;

/**
 * ...
 * @author Jim
 */
typedef State = { label: String, animation : String, actionBegin : Dynamic, actionEnd : Dynamic };

class AnimatedObject extends Sprite
{
	private var mc:MovieClip;
	
	public var state(get_state, set_state) : String; //the public string that allows other parts of the code to change this object's state
	private var currentState : State; //the actual state the object is currently in. This is private! Use "state" to change the object's state!
	private var states : Map<String, State>; //list of all the states the object can be in. Populate this before using the object
	public var animation(get_animation, set_animation) : String;
	private var currentAnimation : Animation;
	private var animations : Map<String, Animation>;
	
	public var position(get_position, set_position) : Point;

	public function new(objectMC: MovieClip, objectX: Float, objectY: Float) 
	{
		super();
		mc = objectMC;
		this.addChild(objectMC);
		this.x = objectX;
		this.y = objectY;
		states = new Map<String, State>();
		animations = new Map<String, Animation>();
		mc.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		
		addAnimation("DEFAULT", 1, 2, "DEFAULT");
		addState("DEFAULT", "DEFAULT", null, null);
		currentState = states.get("DEFAULT");
	}
	
	//getters / setters
	private function get_position():Point {
		return new Point(this.x, this.y);
	}
	
	private function set_position(p:Point):Point {
		this.x = p.x;
		this.y = p.y;
		return new Point(this.x, this.y);
	}
	
	private function get_state() : String {
		return currentState.label;
	}
	
	//setter for currentAnimation. Automatically turns on the state when this var is set
	private function set_state(stateString:String):String {
		if (states.exists(stateString)) {
			currentState.actionEnd();
			currentState = states.get(stateString);
			animation = currentState.animation;
			currentState.actionBegin();
		} else {
			throw "The state '" + stateString + "' is being called, but doesn't exist.";
		}
		return stateString;
	}
	
	private function get_animation() : String {
		return currentAnimation.label;
	}
	
	//setter for currentAnimation. Automatically starts playing the animation when this var is set.
	private function set_animation(animString:String):String {
		if (animations.exists(animString)) {
			var anim:Animation = animations.get(animString);
			mc.gotoAndPlay(anim.frameBegin);
			currentAnimation = anim;
		} else {
			throw "The animation '" + animString + "' is being called, but doesn't exist.";
		}
		return animString;
	}
	
	public function addState(stateLabel: String, stateAnimation: String, stateStartAction: Dynamic, stateEndAction: Dynamic) {
		//if we pass in null, this state doesn't have actions associated with it. Fill it in with a blank function so the game doesn't crash when trying to access the action
		if (stateStartAction == null) {
			stateStartAction = function() { };
		}
		if (stateEndAction == null) {
			stateEndAction = function() { };
		}
		var s : State = { label : stateLabel, animation : stateAnimation, actionBegin : stateStartAction, actionEnd : stateEndAction };
		states.set(stateLabel, s);
	}
	
	//adds an animation to this object's animation list, so it can be retrieved later
	public function addAnimation(animLabel: String, startFrame: Int, endFrame: Int, animAction: Dynamic, animState: String = null) {
		animations.set(animLabel, new Animation(animLabel, this, startFrame, endFrame, animAction, animState));
	}
	
	//checks on each frame to see if the animation should end and then does its onEndFrame action
	private function onEnterFrame(event:Event):Void {
		if (currentAnimation != null && mc.currentFrame == currentAnimation.frameEnd) {
			currentAnimation.onEndFrame();
		}
	}
}