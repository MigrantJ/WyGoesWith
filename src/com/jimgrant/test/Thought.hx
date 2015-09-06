package com.jimgrant.test;
import format.swf.MovieClip;
import nme.display.Sprite;
import nme.geom.Rectangle;
import motion.Actuate;
import motion.easing.Elastic;

class Thought extends Sprite
{
	//constants
	static private var BUBBLE_OFFSET_X : Int = -250;
	static private var BUBBLE_OFFSET_Y : Int = -200;
	static private var TWEEN_TIME : Int = 1;
	static private var ICON_OFFSET_MULT_X = .67;
	static private var ICON_OFFSET_MULT_Y = .67;
	static private var HIDE_TIME_MIN = 1; //5
	static private var HIDE_TIME_MAX = 2; //7
	static private var SHOW_TIME_MIN = 4;
	static private var SHOW_TIME_MAX = 10;
	static private var bounds : Rectangle = new Rectangle(260, 0, 120, 960);
	static private var dreams : Array<String> = ["dream1", "dream2", "dream3", "dream4", "dream5", "dream6", "dream7"];
	
	//properties
	private var world : World;
	private var mc : MovieClip;
	private var showTime(get_showTime, null) : Float;
	private var hideTime(get_hideTime, null) : Float;
	private var thoughtState(default, set_thoughtState) : String;
	private var thoughtStateMC : MovieClip;
	
	public function new(thoughtWorld:World) 
	{
		super();
		world = thoughtWorld;
		mc = world.artAssetLibrary.createMovieClip("thought");
		addChild(mc);
		mc.x = BUBBLE_OFFSET_X;
		mc.y = BUBBLE_OFFSET_Y;
		
		initShowTimer();
	}
	
	//getters / setters
	private function get_showTime() : Float {
		return Math.random() * (SHOW_TIME_MAX - SHOW_TIME_MIN) + SHOW_TIME_MIN;
	}
	
	private function get_hideTime() : Float {
		return Math.random() * (HIDE_TIME_MAX - HIDE_TIME_MIN) + HIDE_TIME_MIN;
	}
	
	private function set_thoughtState(string : String) : String {
		thoughtStateMC = world.artAssetLibrary.createMovieClip(string);
		addChild(thoughtStateMC);
		thoughtStateMC.x = mc.x * ICON_OFFSET_MULT_X;
		thoughtStateMC.y = mc.y * ICON_OFFSET_MULT_Y;
		return string;
	}
	
	//methods 
	private function initShowTimer() : Void {
		this.visible = false;
		if (thoughtStateMC != null) {
			removeChild(thoughtStateMC);
		}
		var timer = Actuate.timer(showTime).onComplete(show);
	}
	
	private function initHideTimer() : Void {
		var timer = Actuate.timer(hideTime).onComplete(hide);
	}
	
	private function show() : Void {
		this.visible = true;
		this.scaleX = 0;
		this.scaleY = 0;
		thoughtState = getThoughtState();		
		var tween = Actuate.tween(this, TWEEN_TIME, { scaleX: 1, scaleY: 1 } );
		tween.ease(Elastic.easeOut);
		//tween.onUpdate(print, [this.scaleX]);
		tween.onComplete(initHideTimer);
	}
	
	private function print(s:Dynamic) : Void {
		trace(s);
	}
	
	private function hide() : Void {
		var tween = Actuate.tween(this, TWEEN_TIME, { scaleX: 0, scaleY: 0 } );
		tween.ease(Elastic.easeIn);
		tween.onComplete(initShowTimer);
	}
	
	private function checkToFlip() : Void {
		if (world.grub.x < bounds.left) {
			mc.scaleX = -1;
			mc.x = BUBBLE_OFFSET_X * -1;
		} else if (world.grub.x > bounds.right) {
			mc.scaleX = 1;
			mc.x = BUBBLE_OFFSET_X;
		}
	}
	
	private function getThoughtState() : String {
		if (world.grub.state == "sleep") {
			//send Wy a random dream
			return dreams[Std.random(dreams.length - 1)];
		} else {
			return checkNeeds(); 
		}
	}
	
	private function checkNeeds() : String {
		var possibleThoughts = []; 
		var lowNeedsCount = 0;
		
		if (world.gui.foodMeter.fill.scaleX <= .25) {
			lowNeedsCount ++;
			possibleThoughts.push("thoughtFood");
		}
		if (world.gui.playMeter.fill.scaleX <= .25) {
			lowNeedsCount ++;
			possibleThoughts.push("thoughtPlay");
		}
		if (world.gui.washMeter.fill.scaleX <= .25) {
			lowNeedsCount ++;
			possibleThoughts.push("thoughtWash");
		}
		if (world.gui.sleepMeter.fill.scaleX <= .25) {
			lowNeedsCount ++;
			possibleThoughts.push("thoughtSleep");
		}
		
		//add "emotion" state based on how many needs are low
		var thoughtState = "thoughtBored";
		if (lowNeedsCount <= 1) {
			possibleThoughts.push("thoughtHappy");
		} else if (lowNeedsCount == 2) {
			possibleThoughts.push("thoughtBored");
		} else {
			possibleThoughts.push("thoughtMad");
			possibleThoughts.push("thoughtOMG");
		}
		
		var randomThought = Math.floor(Math.random() * possibleThoughts.length);
		var thoughtState = possibleThoughts[randomThought];
		
		return thoughtState;
	}
}