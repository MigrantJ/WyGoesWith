package com.jimgrant.test;

//needed for any swf asset manipulation
import format.SWF;
import haxe.macro.Format.
import nme.geom.Point;
//needed to use any asset, image, sound, font, etc.
import nme.Assets;
//does the same stuff Spaceport sprites do (i.e. DisplayObjectContainer)
import nme.display.Sprite;
import nme.display.StageAlign;
import nme.display.StageScaleMode; //investigate this further for stage scaling issue
import nme.Lib;
import nme.net.SharedObject;
//for stage height?
import nme.system.Capabilities;
import nme.utils.Timer;
import nme.events.TimerEvent;

class World extends Sprite {
	//Gameplay constants
	public static var METER_REFRESH = 250;
	
	public static var DAYNIGHTCYCLE = 120000; //6 hours: 21600000  1 hour: 3600000  2 minutes: 120000 
	public static var SKY_REFRESH = 150; //15 seconds: 15000
	
	public static var NEED_FOOD_TIME = 7200000;  //decay time, milliseconds, time it takes for bar to reach 0
	static var SNACK_VALUE = 500000; //how many of those seconds a snack fills
	static var MEAL_VALUE = 1500000; //how many of those seconds a meal fills
	static var TREAT_VALUE = 3000000; //how many of those seconds a treat fills
	
	public static var NEED_PLAY_TIME = 7200000; //decay time for Wy's boredom level to reach bottom
	public static var PLAY_VALUE = 600000; //how many of those milliseconds that a play fills

	public static var NEED_SLEEP_TIME = 14400000;  //decay time, in milliseconds, for Wy's tiredness
	public static var SLEEP_VALUE = 100000; //while sleeping, fills this many milliseconds per METER_REFRESH
	
	//for debugging sleep: fast mode 
	//public static var NEED_SLEEP_TIME = 50000;  //decay time, in milliseconds, for Wy's tiredness
	//public static var SLEEP_VALUE = 2000; //while sleeping, fills this many milliseconds per METER_REFRESH

	public static var NEED_WASH_TIME = 21600000; //decay time for Wy's dirtiness to bottom out. 60k = 1 minute
	public static var GARDEN_MAKE_DIRTY = 1800000; //decay time for Wy's dirtiness to bottom out. 60k = 1 minute

	static var TOTAL_LEVEL2_EXP = 100; // to go from baby to child
	static var TOTAL_LEVEL3_EXP = 101; //to go from child to adolescent
	static var TOTAL_LEVEL4_EXP = 102; //to go from adolescent to adult
	public static var GRUB_MAX_LEVEL = 4;
	public static var XP_STAR_VALUE = 2;
	
	static var START_COIN_TOTAL = 10;
	static var START_LEVEL = 1;
	
	//Stage constants
	static var STAGECENTER = 320; //TODO replace with math that determines this by device
	
	//Gameplay variables
	public var grubLevel : Int;
	public var grubMaxLevel : Int;
	public var expTotal : Int;
	public var expForLevel : Int; 
	public var coinTotal : Int;
	 
	public var selectedGarden: Int; 
	
	//Objects
	public var artAssetLibrary : SWF;
	public var saveData : SharedObject;
	public var backgroundLayer : Sprite;
	public var bgSunMoon : Sprite;
	public var objectLayer : Sprite;
	public var overLayer : Sprite;
	public var UILayer : Sprite;
	public var popupLayer : Sprite;
	
	public var stageCenterX : Int; 
	
	public var grub : Grub;
	public var gui : GuiSetup;
	public var object : Object;
	public var effect: AnimatedObject; 
	public var drops : DropSystem;
	public var wash : MovieClip;
	public var rain : MovieClip;
	public var darkness : MovieClip;
	public var poo : MovieClip;
	public var zzz : MovieClip;
	public var bgSky : MovieClip;
	public var bgSkyNight : MovieClip;
	public var bgStars : MovieClip;
	public var bgStarsNight : MovieClip;
	public var bgRainbow : MovieClip;
	public var bgGrass : MovieClip;
	public var bgClouds : MovieClip;
	
	public static var bgArray:Array<String> = ["bg1", "bg2", "bg3", "bg4"];
	public var collectSets:Array<CollectSet>; //an array of collect sets
	
	public var sleepTimer : Timer;
	
	public function new (artSWF:SWF) {
		//Build the world by creating containers and adding graphical objects to them
		//Also initialize timers and some gameplay states
		
		super();
		artAssetLibrary = artSWF;
		
		grubLevel = START_LEVEL;
		grubMaxLevel = GRUB_MAX_LEVEL;
		coinTotal = START_COIN_TOTAL;
		
		stageCenterX = STAGECENTER;
		
		//Layers are containers for sprites
		backgroundLayer = new Sprite(); //behind Wy
		objectLayer = new Sprite(); //Wy
		overLayer = new Sprite(); //Food, toys, and other stage props
		overLayer.mouseEnabled = false;
		UILayer = new Sprite(); //GUI
		popupLayer = new Sprite(); //Menus?
		
		this.addChild(backgroundLayer); 
		this.addChild(objectLayer);
		this.addChild(overLayer);
		this.addChild(UILayer);
		this.addChild(popupLayer);
		
		//SPINE test code
		//var spinetest = new SpineTest();
		//UILayer.addChild(spinetest);
		
		//create movieClips for background elements
		bgSky = artAssetLibrary.createMovieClip("bgSky");
		bgSkyNight = artAssetLibrary.createMovieClip("bgSkyNight");
		bgStarsNight = artAssetLibrary.createMovieClip("bgStarsNight");
		bgStars = artAssetLibrary.createMovieClip("skyStars");
		bgSunMoon = artAssetLibrary.createMovieClip("bgDayNight");
		bgGrass = artAssetLibrary.createMovieClip("bgGrass");
		bgClouds = artAssetLibrary.createMovieClip("bg1");
		bgRainbow = artAssetLibrary.createMovieClip("skyRainbow");
		
		darkness = artAssetLibrary.createMovieClip("darkness");
		
		//add background elements to layers
		backgroundLayer.addChild(bgSky);
		backgroundLayer.addChild(bgSkyNight);
		backgroundLayer.addChild(bgStars);
		backgroundLayer.addChild(bgStarsNight);
		backgroundLayer.addChild(bgSunMoon);
		backgroundLayer.addChild(bgRainbow);
		backgroundLayer.addChild(bgGrass);
		backgroundLayer.addChild(bgClouds);
		
		//overLayer.addChild(darkness);
		
		//position background elements 
		bgSky.x = 0;
		bgSky.y = 0;
		bgSkyNight.x = 0;
		bgSkyNight.y = 0;
		bgStarsNight.x = 0;
		bgStarsNight.y = 0;
		bgGrass.x = -5;
		bgGrass.y = 250;
		bgSunMoon.x = 340; //todo change to stage center
		bgSunMoon.y = 350;
		bgStars.x = 100;
		bgStars.y = 50;
		bgRainbow.x = 500;
		bgRainbow.y = 200;
		bgClouds.x = -5;
		bgClouds.y = -10;
		
		//add Grub
		grub = new Grub(this);
		objectLayer.addChild(grub);
		grub.x = 300;
		grub.y = 400;
		
		getSaveData();
		
		/*
		switch( saveData.data.grubLevel ) {
			case 2: 
				expForLevel = TOTAL_LEVEL3_EXP;
			case 3: 
				expForLevel = TOTAL_LEVEL4_EXP;
			default: 
				expForLevel = TOTAL_LEVEL2_EXP;
		}*/
		
		//add Drops
		drops = new DropSystem(this, overLayer);
		
		//All these things must get called after save data initializes
		
		//add the CollectSets and prizes
		collectSets = new Array<CollectSet>();
		collectSets.push (new CollectSet(this, "Artist Collection", "collectSet1", "collectSet1a", "collectSet1b", "collectSet1c", "stego", 30, -110));
		collectSets.push (new CollectSet(this, "Garden Collection", "collectSet2", "collectSet2a", "collectSet2b", "collectSet2c", "hatSunhat", 0, -110));
		collectSets.push (new CollectSet(this, "Bakery Collection", "collectSet3", "collectSet3a", "collectSet3b", "collectSet3c", "hatChef", 0, -140));
		collectSets.push (new CollectSet(this, "Aquarium Collection", "collectSet4", "collectSet4a", "collectSet4b", "collectSet4c", "hatOcto", 0, -110));
		
		collectSets.push (new CollectSet(this, "Space Collection", "collectSet5", "collectSet5a", "collectSet5b", "collectSet5c", "hatOcto", 20, -110));
		collectSets.push (new CollectSet(this, "Studying Collection", "collectSet6", "collectSet6a", "collectSet6b", "collectSet6c", "hatBaseball", 20, -110));
		collectSets.push (new CollectSet(this, "Gym Class Sucks Collection", "collectSet7", "collectSet7a", "collectSet7b", "collectSet7c", "hatBaseball", 20, -110));
		collectSets.push (new CollectSet(this, "Stormy Collection", "collectSet8", "collectSet8a", "collectSet8b", "collectSet8c", "hatTophat", 10, -110));
		
		
		/*********/
		//STAGE ART
		/*********/
		
		//add darkness and night stars 
		
		
		
		darkness.mouseEnabled = false;
		darkness.x = 0;
		darkness.y = 0; 
		
		bgStarsNight.x = 75;
		bgStarsNight.y = 10; 
		
		
		darkness.blendMode = flash.display.BlendMode.MULTIPLY;
		updateDarkness();
		
		//adjust night sky
		bgSkyNight.alpha = 0;
		bgStarsNight.alpha = 0;
		
		//hide rainbow
		bgRainbow.visible = false; 
		
		//add ZZZs
		zzz = artAssetLibrary.createMovieClip("zzz");
		overLayer.addChild(zzz);
		zzz.x = 0;
		zzz.y = 0;
		zzz.visible = false;
		
		//add wash
		wash = artAssetLibrary.createMovieClip("wash");
		overLayer.addChild(wash);
		wash.x = -150;
		wash.y = 1;
		wash.gotoAndStop(1);
		
		//add rain
		rain = artAssetLibrary.createMovieClip("rain");
		overLayer.addChild(rain);
		rain.x = 100;
		rain.y = 1;
		//rain.gotoAndStop(1);
		rain.visible = false;
		
		//add poo
		poo = artAssetLibrary.createMovieClip("poo");
		overLayer.addChild(poo);
		poo.x = 150;
		poo.y = 450;
		poo.visible = false;
		poo.gotoAndStop(1);
		
		//add GUI
		gui = new GuiSetup(this, artAssetLibrary, UILayer);
		
		sleepTimer = new Timer(METER_REFRESH);
		sleepTimer.addEventListener(TimerEvent.TIMER, sleepTimerAction);
	}
	
	public function debugEraseSave():Void {
		saveData.clear();
	}
	
	private function getSaveData():Void {
		saveData = SharedObject.getLocal("WyGoesWith");
		if (saveData.data.needFood == null) {
			trace ("no save data");
			var now : Date = Date.now();
			//this is where save data is initialized
			saveData.data.needFood = now.getTime() + NEED_FOOD_TIME;
			saveData.data.needSleep = now.getTime() + NEED_SLEEP_TIME;
			saveData.data.needPlay = now.getTime() + NEED_PLAY_TIME;
			saveData.data.needWash = now.getTime() + NEED_WASH_TIME;
			//get current time, add the duration of a day-night cycle to it to get the future time at which it resets and starts over
			saveData.data.dayNightCycle = now.getTime() + DAYNIGHTCYCLE; 
			saveData.data.name = grub.grubName;
			saveData.data.bdayMonth = grub.grubBdayMonth;
			saveData.data.bdayDay = grub.grubBdayDayNumber;
			saveData.data.favoriteFood = grub.grubFavoriteFood;
			saveData.data.grubTrait1 = grub.grubTrait1;
			saveData.data.grubTrait2 = grub.grubTrait2;
			saveData.data.grubTrait3 = grub.grubTrait3;
			saveData.data.grubBirthTime = now.getTime(); 
			saveData.data.expTotal = 0;
			saveData.data.grubLevel = 1;
			saveData.data.expForLevel = TOTAL_LEVEL2_EXP;
			
			saveData.data.garden1Time = 0;
			saveData.data.garden1TimeTotal = 0;
			saveData.data.garden2Time = 0;
			saveData.data.garden2TimeTotal = 0;
			saveData.data.garden3Time = 0;
			saveData.data.garden3TimeTotal = 0;
			
			saveData.flush();
		} else {
			trace ("save data found");
			//saveData.data.needFood = null; //uncomment and run the game twice
		}
	}
	
	
	public function removeObject():Void {
		if (object != null) {
			object.remove();
			objectLayer.removeChild(object);
			object = null;
		}
	}
	
	public function removeObjectBGLayer():Void {
		if (object != null) {
			object.remove();
			backgroundLayer.removeChild(object);
			object = null;
		}
	}
	
	//todo: remove and replace with gradual alpha/unalpha of the darkness layer 
	public function updateDarkness() : Void {
		//darkness
		var sunMoonPosition : Float = Date.now().getTime() % DAYNIGHTCYCLE;
		var sunMoonPercentage : Float = (sunMoonPosition / DAYNIGHTCYCLE);
		//trace ("sunMoonPercentage: " + sunMoonPercentage);
		if (sunMoonPercentage < .20 || sunMoonPercentage > .80) { //.166  and .836
			bgSunMoon.rotation = (sunMoonPosition / DAYNIGHTCYCLE) * 360;
			darkness.alpha = 0;
			bgSkyNight.alpha = 0;
			bgStarsNight.alpha = 0;
		} else if (sunMoonPercentage > .20 && sunMoonPercentage < .30) {
			darkness.alpha = ((sunMoonPercentage - .20) / (.30 - .20));  //.166  .332  .166
			bgSkyNight.alpha = ((sunMoonPercentage - .20) / (.30 - .20));  //.166  .332  .166
			bgStarsNight.alpha = ((sunMoonPercentage - .20) / (.30 - .20));  //.166  .332  .166
		} else if (sunMoonPercentage > .30 && sunMoonPercentage < .70) {  //.666
			darkness.alpha = 100;
			bgSkyNight.alpha = 100;
			bgStarsNight.alpha = 100;
		} else if (sunMoonPercentage > .70 && sunMoonPercentage < .80) { //.666 and .836
			darkness.alpha = (1 - ((sunMoonPercentage - .70) / (.80 - .70))); //.666
			bgSkyNight.alpha = (1 - ((sunMoonPercentage - .70) / (.80 - .70))); //.666
			bgStarsNight.alpha = (1 - ((sunMoonPercentage - .70) / (.80 - .70))); //.666
		} 
		//sky rotation
		bgSunMoon.rotation = sunMoonPercentage * 360;
	}

	public function toggleZZZs() : Void {
		zzz.x = grub.x - 20;
		zzz.y = grub.y - 120;
		if (zzz.visible == true) {
			zzz.visible = false;
		} else {
			zzz.visible = true;
		}
	}
	
	public function addExp(xp:Int):Void {
		//exp and check for level up
		saveData.data.expTotal = saveData.data.expTotal + xp; //increase the saved amount of xp
		if (saveData.data.grubLevel < grubMaxLevel) {  //if the player's level is less than max level
			if (saveData.data.expTotal >= saveData.data.expForLevel) {  //if player has more xp than needed for this level 
				saveData.data.expTotal = 0; //reset Exp total 
				//todo keep "overflow" xp and apply it to the new level's bar
				saveData.data.grubLevel ++;
				saveData.data.expForLevel ++;
				gui.menus.get("LevelUp").visible = true;
				gui.updateAllTexts("LevelUp");
			}
		} else {
			saveData.data.expTotal = saveData.data.expForLevel;
		}
		saveData.flush();
		gui.updateAllTexts("HUD");
	}
	
	public function changeCurrency(currency:Int):Void {
		coinTotal = coinTotal + currency;
		gui.updateAllTexts("HUD"); 
	}

	public function createFood(foodType: String, foodCost: Int ):Void {
		object = new Food(this, foodType); 
		objectLayer.addChild(object);
		changeCurrency(foodCost);
		grub.state = "walkTowardsObject";
	}
	
	public function createToy() : Void {
		var toy = new Toy(this);
		toy.play();
	}
	
	public function createPillow() : Void {
		object = new Pillow(this); 
		backgroundLayer.addChild(object);
		grub.state = "walkTowardsPillow";
	}

	//this function refills the sleep meter while Wy is sleeping
	private function sleepTimerAction(event:TimerEvent) : Void {
		if (saveData.data.needSleep < Date.now().getTime()) {
			saveData.data.needSleep = Date.now().getTime() + World.SLEEP_VALUE;
		} else if (saveData.data.needSleep + World.SLEEP_VALUE >= Date.now().getTime() + World.NEED_SLEEP_TIME) {
			saveData.data.needSleep = Date.now().getTime() + World.NEED_SLEEP_TIME;
			grub.state = "wake";
		} else {
			saveData.data.needSleep = saveData.data.needSleep + World.SLEEP_VALUE;
		}
		saveData.flush();
	}
	
	public function createSmoke(smokeX : Float, smokeY : Float) : Void {
		var effect : AnimatedObject = new AnimatedObject(artAssetLibrary.createMovieClip("effectSpawn"), smokeX, smokeY);
		effect.addAnimation("play", 1, 35, null);
		effect.addState("play", "play", null, function () { removeEffect(effect); } );
		effect.state = "play";
		overLayer.addChild(effect);
		effect.mouseEnabled = false; 
		
	}

	public function removeEffect(effect : AnimatedObject) : Void {
		overLayer.removeChild(effect);
	}
	
}