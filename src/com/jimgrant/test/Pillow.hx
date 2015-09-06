package com.jimgrant.test;

import nme.utils.Timer;
import nme.events.TimerEvent;

/**
 * ...
 * @author Mandi
 */

class Pillow extends Object 
{
	static private var SLEEP_TIMER_TICKS = 1000; //in milliseconds
	private var timer : Timer;
	
	public function new(pillowWorld: World) {
		super(pillowWorld);
		mc = world.artAssetLibrary.createMovieClip("pillow");
		//this.x = 300;
		//this.y = 300;
		addChild(mc);
		
		timer = new Timer(2000);
		timer.addEventListener(TimerEvent.TIMER, sleepTimer);
	}
	
	public function sleep() : Void { 
		//perchance to dream 
		var value : Int = World.SLEEP_VALUE;
		//trace ("world.saveData.data.needSleep = " + world.saveData.data.needSleep);
		
		/*
		if (world.saveData.data.needSleep < Date.now().getTime()) {
			world.saveData.data.needSleep = Date.now().getTime() + value;
		}
		else if (world.saveData.data.needSleep >= Date.now().getTime() + World.NEED_SLEEP_TIME) {
			world.saveData.data.needSleep = Date.now().getTime() + World.NEED_SLEEP_TIME;
		}
		else {
			world.saveData.data.needSleep += value;
		}
		world.saveData.flush();
		*/
		timer.start();
		world.gui.updateAllTexts("HUD");
	}
	
	private function sleepTimer(event:TimerEvent) : Void {
		trace(world.saveData.data.needSleep);
		world.saveData.data.needSleep = world.saveData.data.needSleep + World.SLEEP_VALUE;
		world.saveData.flush();
	}
	
}