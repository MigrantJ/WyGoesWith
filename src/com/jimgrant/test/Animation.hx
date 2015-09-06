package com.jimgrant.test;

class Animation {
	public var label : String;
	public var frameBegin : Int; //first frame of the animation in the movieclip
	public var frameEnd : Int; //last frame of the animation in the movieclip
	public var endAction : String; //the animation to start when this animation is done
	public var endState : String; //ONLY USED WHEN ANIMATION PLAYS ONCE. Go to this state after the animation is finished playing.
	public var length(get_length, null) : Float;
	
	private var object : AnimatedObject;
	
	//constructor
	public function new (animLabel : String, animObject : AnimatedObject, animBegin: Int, animEnd: Int, animEndAction: String, animEndState: String = null) {
		label = animLabel;
		object = animObject;
		frameBegin = animBegin;
		frameEnd = animEnd;
		endAction = animEndAction;
		endState = null;
		if (animEndState != null) {
			endState = animEndState;
		}
	}
	
	//getters and setters
	private function get_length() : Float {
		//convert to seconds, framerate of 30
		return (frameEnd - frameBegin) / 30;
	}
	
	public function onEndFrame() : Void {
		if (endState != null) {
			object.state = endState;
		} else if (endAction == null) { //then this object is done! hopefully we set up some code to get rid of it!
			object.state = "DEFAULT";
		} else {
			object.animation = endAction;
		}
		
		//old code from when animations could execute functions when they were done playing
		/*
		var objectType = Type.getClassName(Type.getClass(object));
		if (Type.getClassName(Type.getClass(endAction)) == "String") {
			object.setAnimation(endAction);
		} else if (Reflect.isFunction(endAction)) {
			endAction();
		} else {
			trace ("ERROR: endAction is of unknown type");
		}
		*/
	}

	public function toString() : String {
		return "Animation|frameBegin: " + frameBegin + " |frameEnd: " + frameEnd + " |endAction: " + endAction;
	}
	
}