package com.jimgrant.test;
import format.SWF;
import nme.utils.Timer;
import nme.events.TimerEvent;
import nme.display.Sprite;
import nme.geom.Rectangle;
import motion.Actuate;
import motion.easing.Linear;

/**
 * ...
 * @author Jim
 * This class extends Gui so it can use the functions of that library without putting Wy Goes With-specific code into the library itself.
 */

class GuiSetup extends Gui
{
	public var foodMeter:GuiMeter;
	public var playMeter:GuiMeter;
	public var washMeter:GuiMeter;
	public var sleepMeter:GuiMeter;
	public var expMeter:GuiMeter;
	public var meterTimer:Timer;
	public var gardenTimer:Timer;
	private var collectSetMenu:GuiScrollMenu;
	private var grubPreview : AnimatedObject;
	
	public var garden1 : Garden;
	public var garden2 : Garden;
	public var garden3 : Garden;
	
	public function new(guiWorld:World, guiLibrary:SWF, guiLayer:Sprite) 
	{
		super(guiWorld, guiLibrary, guiLayer);
		
		setupObjects();
		setupMenus();
		
		//all meters refresh every METER_REFRESH milliseconds
		var meterTimer = new Timer(World.METER_REFRESH);
		meterTimer.addEventListener(TimerEvent.TIMER, updateMeters);
		meterTimer.start();
		
		var gardenTimer = new Timer(World.METER_REFRESH);
		gardenTimer.addEventListener(TimerEvent.TIMER, updateGardens);
		gardenTimer.start();
		
		var skyTimer = new Timer(World.SKY_REFRESH);
		skyTimer.addEventListener(TimerEvent.TIMER, updateSky);
		skyTimer.start();
	}
	
	//set up all the types of buttons, fonts, and meters this gui will use
	private function setupObjects():Void {
		addButtonType("choiceButton", "choiceButton");
		addButtonType("buttonBlueSquare", "buttonBlueSquare");
		addButtonType("buttonCurrency", "buttonCurrency");
		addButtonType("buttonCollectSets", "buttonCollectSets");
		//must have same name here, here
		addButtonType("garden", "garden");
		
		addFont("WhiteFont", 36, 0xFFFFFF, "VALENTIN.TTF");
		addFont("WhiteFontSmall", 24, 0xFFFFFF, "VALENTIN.TTF");
		addFont("BlueFont", 36, 0x006a9d, "VALENTIN.TTF");
		addFont("YellowFont", 36, 0xf2c552, "VALENTIN.TTF");
		addFont("BlueFontSmall", 24, 0x006a9d, "VALENTIN.TTF");
		addFont("BlueFontHuge", 64, 0x006a9d, "VALENTIN.TTF");
		
		addMeterType( { name:"meterSmall", container:"meterSmall", fill:"fillSmall" } );
		addMeterType( {name:"meterLarge", container:"meterLarge", fill:"fillLarge" } );
	}
	
	//creates all the menus and gui elements used in Wy, including the hud and pop-ups
	private function setupMenus():Void {
		
		
		
		/**** DEBUG BUTTONS ON RIGHT OF SCREEN *****/
		var debugMenu = addMenu("debugMenu");
		debugMenu.addButton("buttonTreat", "choiceButton", 800, 100, function () { buttonDebug(); } );
		
		/****GARDEN PILES along bottom of screen *****/
		var onscreenGardens = addMenu("onscreenGardens");
		//gardenObject = new Garden(world);  //pass an instance of world, not World which is like a factory 

		garden1 = new Garden("garden1", 60, 614, world, function() { buttonOpenGardenMenu(1); }, function() { return (world.saveData.data.garden1Time - Date.now().getTime()) / world.saveData.data.garden1TimeTotal ; } );
		garden2 = new Garden("garden2", 260, 630, world, function() { buttonOpenGardenMenu(2); }, function() { return (world.saveData.data.garden2Time - Date.now().getTime()) / world.saveData.data.garden2TimeTotal ; } );
		garden3 = new Garden("garden3", 460, 614, world, function() { buttonOpenGardenMenu(3); }, function() { return (world.saveData.data.garden3Time - Date.now().getTime()) / world.saveData.data.garden3TimeTotal ; } );
		
		onscreenGardens.addButtonReady("garden1", garden1);
		onscreenGardens.addButtonReady("garden2", garden2);
		onscreenGardens.addButtonReady("garden3", garden3);
		
		onscreenGardens.addText("gardenTime1", "Ready", "WhiteFontSmall", 70, 670, 500, 200);
		onscreenGardens.addText("gardenTime2", "Ready", "WhiteFontSmall", 280, 688, 500, 200);
		onscreenGardens.addText("gardenTime3", "Ready", "WhiteFontSmall", 470, 670, 500, 200);
		
		var menuGarden = addMenu("menuGarden");
		menuGarden.addGraphic("gardenMenuBG", 50, 150);
		
		menuGarden.addText("gardentitle", "Today's Seeds", "BlueFont", 180, 165, 500, 50);
		menuGarden.addText("gardenNewSeeds", "New seeds in: ", "BlueFontSmall", 130, 450, 500, 50);
		menuGarden.addText("gardenNewSeedsTime", makeDayTimerString(), "BlueFontSmall", 300, 450, 500, 50);
		
		menuGarden.addText("gardenSnack", "Snack", "BlueFontSmall", 90, 210, 500, 50);
		menuGarden.addButton("buttonFood", "buttonBlueSquare", 75, 240, function() { buttonGrowGarden(30000); }, "foodBanana", .5, .5); //900000
		menuGarden.addText("garden15min", "15 mins", "BlueFontSmall", 85, 370, 500, 50);
		menuGarden.addText("garden15min", "Cost: 1", "BlueFontSmall", 75, 400, 500, 50);
		menuGarden.addGraphic("currencyIcon", 175, 412, .75, .75);
		
		menuGarden.addText("gardenMeal", "Meal", "BlueFontSmall", 270, 210, 500, 50);
		menuGarden.addButton("buttonFood", "buttonBlueSquare", 250, 240, function() { buttonGrowGarden(7200000); }, "foodPancakes", .5, .5 );
		menuGarden.addText("garden2hr", "2 hrs", "BlueFontSmall", 270, 370, 500, 50);
		menuGarden.addText("garden15min", "Cost: 2", "BlueFontSmall", 260, 400, 500, 50);
		menuGarden.addGraphic("currencyIcon", 365, 412, .75, .75);
		
		menuGarden.addText("gardenTreat", "Treat", "BlueFontSmall", 440, 210, 500, 50);
		menuGarden.addButton("buttonFood", "buttonBlueSquare", 425, 240, function() { buttonGrowGarden(21600000); }, "foodCinnamon", .5, .5 );
		menuGarden.addText("garden6hr", "6 hrs", "BlueFontSmall", 445, 370, 500, 50);
		menuGarden.addText("garden15min", "Cost: 3", "BlueFontSmall", 430, 400, 500, 50);
		menuGarden.addGraphic("currencyIcon", 532, 412, .75, .75);
		
		
		menuGarden.visible = false;
		
		
		
		/***** GARDEN CANCEL MENU *****/
		var menuGardenCancel = addMenu("GardenCancel");
		menuGardenCancel.addGraphic("gardenMenuSmall", 120, 200);
		menuGardenCancel.addText("gardenCancelText", "Cancel this garden?", "BlueFont", 150, 210, 500, 50);
		
		menuGardenCancel.addButton("buttonFood", "buttonBlueSquare", 180, 290, function() { buttonGardenCancel("yes"); } );
		menuGardenCancel.addButton("buttonFood", "buttonBlueSquare", 320, 290, function() { buttonGardenCancel("no"); } );
		menuGardenCancel.addText("gardenCancelYes", "Yes", "BlueFont", 200, 330, 500, 50);
		menuGardenCancel.addText("gardenCancelCancel", "NO!", "BlueFont", 340, 330, 500, 50);
		
		menuGardenCancel.visible = false;
		
		
		/****MAIN MENU also called INFO MENU *****/ 
		var menuMain = addMenu("Main");
		
		menuMain.addGraphic("subMenuBG", 0, 0);
		//menuMain.addGraphic("mainButtonBar", 0, 555);
		
		//grub name and image
		menuMain.addText("grubNameText", world.saveData.data.name, "BlueFont", 15, 94, 500, 50);
		menuMain.addGraphic("mainGrubWindow", 15, 145);
		
		grubPreview = new AnimatedObject(world.artAssetLibrary.createMovieClip("Wy"), 165, 225); 
		grubPreview.addAnimation("idle", 1, 22, "idle");  //1 to 22 is idle loop 
		grubPreview.addState("idle", "idle", null, null );
		grubPreview.state = "idle";
		grubPreview.scaleX = .55;
		grubPreview.scaleY = .55;
		menuMain.addChild(grubPreview);

		//b-day 
		menuMain.addText("grubBdayText", "Grub B-day:", "BlueFont", 15, 340, 500, 50);
		menuMain.addText("grubBdayVarText", world.saveData.data.bdayMonth + " " + world.saveData.data.bdayDay, "YellowFont", 45, 390, 500, 50);
	
		//time on earth
		menuMain.addText("grubTimeOnEarthText", "Time on Earth:", "BlueFont", 15, 450, 500, 50);
		menuMain.addText("grubTimeOnEarthVarText", makeAgeString(), "YellowFont", 45, 500, 500, 50);
		
		//grub favorite food
		menuMain.addText("grubFavoriteText", "Favorite:", "BlueFont", 400, 340, 500, 50);
		//show picture of favorite food here
		menuMain.addGraphic(world.saveData.data.favoriteFood, 470, 450, .85, .85);
		
		//traits 
		menuMain.addText("grubTraitsText", "Traits:", "BlueFont", 400, 94, 500, 50);
		menuMain.addText("grubTrait1Text", world.saveData.data.grubTrait1, "YellowFont", 360, 150, 500, 50);
		menuMain.addText("grubTrait2Text", world.saveData.data.grubTrait2, "YellowFont", 360, 200, 500, 50);
		menuMain.addText("grubTrait3Text", world.saveData.data.grubTrait3, "YellowFont", 360, 260, 500, 50);
		
		//BUTTONS for sub menus
		//menuMain.addButton("buttonInfoMain", "buttonBlueSquare", 18, 580, function() { }, "btnArtInfo", 1, 1);
		//menuMain.addButton("buttonGC", "buttonBlueSquare", 141, 580, function() { },  "btnArtGC", 1, 1 );
		//menuMain.addButton("buttonBG", "buttonBlueSquare", 266, 580, function() { }, "btnArtBG", 1, 1 );
		//menuMain.addButton("buttonSettings", "buttonBlueSquare", 389, 580, function() { }, "btnArtSettings", 1, 1 );
		//menuMain.addButton("buttonHelp", "buttonBlueSquare", 515, 580, function() { }, "btnArtHelp", 1, 1 );
			
		menuMain.visible = false;
		
		//set up the collectibles menu and then hide it 
		this.addGraphic("collectSetMenuBG", "subMenuBG", 0, 0); 
		collectSetMenu = addScrollMenu("collectSetMenu", GuiScrollMenu.CONSTRAIN_VERT, new Rectangle(0, 0, 640, 850));
		collectSetMenu.addText("grubNameText", "Collections", "BlueFont", 15, 100, 500, 50);
		addCollectSetGraphics();
		graphics.get("collectSetMenuBG").visible = false;
		collectSetMenu.visible = false;
		
		
		//add yellow bar for buttons
		var bgButtonBar = artAssetLibrary.createMovieClip("bgButtonBar");
		world.UILayer.addChild(bgButtonBar);
		bgButtonBar.y = 720;
		//bgButtonBar.y = Capabilities.screenResolutionY - 240;  //This may appear proper on target, but appears misaligned on PC
		
		
		
		/*** FOOD CHOICE popup. We have to make it first because the actions menu references it. ****/
		var menuFood = addMenu("Food");
		menuFood.addGraphic("choiceMenu", 15, 455);
		var treatCost : Int = -2;
		var mealCost : Int = -1;
		var snackCost : Int = 0;
		
		/**** FOOD MENU ****/
		menuFood.addButton("buttonTreat", "choiceButton", 24, 470, function() { buttonFoodChoice("treat", treatCost); } );
		menuFood.addButton("buttonMeal", "choiceButton", 24, 560, function() { buttonFoodChoice("meal", mealCost); } );
		menuFood.addButton("buttonSnack", "choiceButton", 24, 650, function() { buttonFoodChoice("snack", snackCost); } );
		menuFood.addGraphic("currencyIcon", 250, 510);
		menuFood.addGraphic("currencyIcon", 250, 610);
	
		
		//menuFood.addGraphic("currencyIcon", 200, 690);
		
		//button name, string, font to use, x pos, y pos, x draw size, y draw size
		menuFood.addText("buttonTreatText", "Treat", "WhiteFont", 40, 490, 130, 50);
		menuFood.addText("buttonMealText", "Meal", "WhiteFont", 40, 580, 130, 50);
		menuFood.addText("buttonSnackText", "Snack", "WhiteFont", 40, 670, 130, 50);
		menuFood.addText("buttonTreatText", "2", "WhiteFont", 180, 490, 100, 50);
		menuFood.addText("buttonMealText", "1", "WhiteFont", 180, 590, 100, 50);  //Std.string(mealCost)
		//menuFood.addText("buttonSnackText", Std.string(snackCost), "WhiteFont", 230, 670, 100, 50);
		menuFood.visible = false;
		
		
		
		
		/****ACTION MENU along bottom of screen *****/
		var menuActions = addMenu("Actions");
		//name (as a string), buttonType, x, y, ?icon, function to call
		menuActions.addButton("buttonFood", "buttonBlueSquare", 18, 790, function() { buttonFood(); }, "btnArtFood",  1, 1);
		menuActions.addButton("buttonPlay", "buttonBlueSquare", 141, 790, function() { buttonPlay(); }, "btnArtPlay", 1, 1 );
		menuActions.addButton("buttonWash", "buttonBlueSquare", 266, 790, function() { buttonWash(); }, "btnArtWash", 1, 1 );
		menuActions.addButton("buttonSleep", "buttonBlueSquare", 389, 790, function() { buttonSleep(); }, "btnArtSleep", 1, 1 );
		menuActions.addButton("buttonInfo", "buttonBlueSquare", 515, 790, function() { buttonMainMenu(); }, "btnArtInfo", 1, 1 );

		foodMeter = menuActions.addMeter("foodMeter", "meterSmall", 25, 919);
		playMeter = menuActions.addMeter("playMeter", "meterSmall", 148, 919);
		washMeter = menuActions.addMeter("washMeter", "meterSmall", 272, 919);
		sleepMeter = menuActions.addMeter("sleepMeter", "meterSmall", 396, 919);
		menuActions.addText("grubNameText", world.saveData.data.name, "BlueFont", world.stageCenterX - 50, 745, 300, 300);
		
		

		
		/***** LEVEL UP POP UP ******/
		var menuLevelUp = addMenu("LevelUp");
		
		menuLevelUp.addGraphic("menuLevelUp", 60, 140);
		menuLevelUp.addText("LevelUpText", "Level Up!", "BlueFontHuge", 10, 100, 300, 300, true);
		menuLevelUp.addText("LevelUpExplain1Text", "Congratulations!", "BlueFont", 10, 170, 300, 300, true);
		menuLevelUp.addText("LevelUpExplain2Text", "Your grub is now level", "BlueFont", 10, 220, 500, 300, true);
		menuLevelUp.addText("LevelUpLevelText", "", "BlueFontHuge", 10, 265, 500, 300, true, function() { return Std.string(world.saveData.data.grubLevel); } );
		menuLevelUp.addText("LevelUpUnlockText", "You unlocked:", "BlueFont", 10, 325, 500, 300, true);
		
		menuLevelUp.addButton("buttonHideLevelUp", "choiceButton", world.stageCenterX - 110, 440, function() { buttonCloseLevelUp(); } );
		menuLevelUp.addText("LevelUpOKText", "OK", "WhiteFont", 10, 465, 500, 300, true);
		
		menuLevelUp.visible = false;
		
		// HUD at top of screen
		var menuHUD = addMenu("HUD");
		
		menuHUD.addButton("buttonCurrency", "buttonCurrency", 30, 36, function() { buttonFood(); } );
		menuHUD.addButton("buttonCollectSets", "buttonCollectSets", 550, 12, function() { buttonCollectSets(); } );
		
		menuHUD.addGraphic("levelIcon", 220, 36);
		
		menuHUD.addGraphic("xpMeterFill", 264, 24);
		expMeter = menuHUD.addMeter("expMeter", "meterLarge", 264, 24);
		

		menuActions.addText("coinsText", "coins", "BlueFontSmall", 108, 35, 65, 30); //72 on y
		//menuActions.addText("xpText", "xp", "BlueFontSmall", 390, 34, 60, 30);
		menuActions.addText("lvlText", "lvl", "BlueFontSmall", 464, 35, 60, 30);
		
		menuHUD.addText("coinTotalText", "", "BlueFont", 60, 24, 60, 50, function() { return Std.string(world.coinTotal); } );
		menuHUD.addText("levelText", "", "BlueFont", 500, 24, 60, 30, function() { return Std.string(world.saveData.data.grubLevel); } );
		
		//todo - this doesnt work at all, possibly because it's not pulling from save data properly
		if (world.saveData.data.grubLevel < world.grubMaxLevel) {
			menuHUD.addText("expText", "", "BlueFontSmall", 320, 28, 150, 30, function() { return world.saveData.data.expTotal + "/" + world.saveData.data.expForLevel; } );
		} else { //player is level 4, dont draw xp totals
			menuHUD.addText("AdultText", "Adult", "BlueFontSmall", 320, 28, 60, 30);
		}
		updateAllTexts("HUD");
	}
	
	//updates every textfield in a particular menu
	public function updateAllTexts(menu: String) : Void {
		for (textField in menus.get(menu).textFields.keys()) {
			updateText(menu, textField);
		}
	}
	
	//returns the TextField instance from the hash, allowing it to be edited how you see fit
	//the second parameter is optional. It doesn't need to be provided if the GuiText has its valueFunction set to something
	public function updateText(menu: String, textName : String, ?value : String) : Void {
		if (menus.get(menu) == null) {
			trace ("ERROR!! " + menu + " not found!");
		}
		
		//get the memory address of the textfield to update
		var textFieldInstance:GuiText = menus.get(menu).textFields.get(textName);
		
		if (value != null) //then we passed what we want to change the text to in "value". Use that!
			textFieldInstance.text = value;
		else if (textFieldInstance.valueFunc != null) //then this textfield has a function that determines what it says
			textFieldInstance.update();
		else
			throw "The textfield " + textName + " is being updated, but has no value specified and no update function.";
	}
	
	/* COLLECT SETS BUTTON in upper right */ 
	public function buttonCollectSets() {
		var collectSetMenu: GuiMenu = menus.get("collectSetMenu");
		
		if (!collectSetMenu.visible) { //then turn the collect set menu on
			buttonsDisable();
			menus.get("HUD").buttons.get("buttonCollectSets").enable(); //except for the collection button, we can use that to make the popup go away
			graphics.get("collectSetMenuBG").visible = true;
		} else {
			buttonsEnable();
			graphics.get("collectSetMenuBG").visible = false;
		}
		
		collectSetMenu.visible = !collectSetMenu.visible;
	}
	
	
	/******************/
	//GARDEN MENU BUTTONS
	/******************/
	
	public function buttonOpenGardenMenu(gardenID: Int) {
		//save the ID of the clicked garden to world save data
		world.selectedGarden = gardenID;
		var test = Reflect.field(world.saveData.data, "garden1Time");
		gardenMenuConditional();
	}
	
	public function gardenMenuConditional() {
		var saveDataGarden : Float = Reflect.field(world.saveData.data, "garden" + world.selectedGarden + "Time");
		
		//if saveDataGarden is less than nowtime, harvest
		if (saveDataGarden == 0) {
			//idle: garden is idle 
			var gardenMenu: GuiMenu = menus.get("menuGarden");
			gardenMenu.visible = !gardenMenu.visible; 
		} else if (saveDataGarden > Date.now().getTime()) { 
			//cancel: if more than 0, it must be actively growing 
			var menuGardenCancel : GuiMenu = menus.get("GardenCancel");
			menuGardenCancel.visible = !menuGardenCancel.visible; 
			//trace ("cancel: savedatagarden is more than now time");
		} else if (saveDataGarden <= Date.now().getTime()) { 
			//harvest! 
			Reflect.setField(world.saveData.data, "garden" + world.selectedGarden + "Time", 0);
			world.drops.spawnDropGroup("gardenDrop", world.gui.menus.get("onscreenGardens").buttons.get("garden" + world.selectedGarden).position);
			world.saveData.flush();
		}
	}
	
	public function buttonGrowGarden(time: Int) {
		/*** 
		get the time from the button
		record the player's selected garden option into the proper save data slot
		update proper string field
		close garden menu 
		walk wy over and have him pat it 
		***/
		
		var gardenMenu: GuiMenu = menus.get("menuGarden"); 
		gardenMenu.visible = !gardenMenu.visible; //hide the garden menu
		
		
		var now : Date = Date.now();
		var nowTime : Float = now.getTime(); //makes it milliseconds 
		
		if (world.selectedGarden == 1) {
			world.saveData.data.garden1Time = nowTime + time;
			world.saveData.data.garden1TimeTotal = time;
		} else if (world.selectedGarden == 2) {
			world.saveData.data.garden2Time = nowTime + time;
			world.saveData.data.garden2TimeTotal = time;
		} else if (world.selectedGarden == 3) {
			world.saveData.data.garden3Time = nowTime + time;
			world.saveData.data.garden3TimeTotal = time;
		}
		gardenUpdateText();
		world.grub.state = "walkTowardsGarden";
		world.saveData.data.needWash -= World.GARDEN_MAKE_DIRTY;
	}
	
	private function gardenUpdateText() {
		//find garden player selected, make it into a string, so we know which field to put the save data into
		var selectedGardenTimeField:String = "gardenTime" + world.selectedGarden;  
		updateText ("onscreenGardens", selectedGardenTimeField, makeGardenTimerString(world.selectedGarden)); 
	}
	
	private function buttonGardenCancel(choice : String) {
		if (choice == "yes") {
			if (world.selectedGarden == 1) {
				world.saveData.data.garden1Time = 0;
			} else if (world.selectedGarden == 2) {
				world.saveData.data.garden2Time = 0;
			} else if (world.selectedGarden == 3) {
				world.saveData.data.garden3Time = 0;
			}
		} 
		var menuGardenCancel : GuiMenu = menus.get("GardenCancel");
		menuGardenCancel.visible = !menuGardenCancel.visible; 
	}

	
	private function buttonDebug() {
		trace ("debug settings not implemented!");
	}
	
	/******************/
	//ACTION BAR BUTTONS
	/******************/
	
	/* BUTTON FOOD and its friend BUTTON FOOD CHOICE for the food menu and sub food menu */ 
	
	public function buttonFood() {
		var foodMenu: GuiMenu = menus.get("Food");
		if (!foodMenu.visible) {
			buttonsDisable();
			menus.get("Actions").buttons.get("buttonFood").enable(); //except for the food button, we can use that to make the popup go away
		} else { //we're turning the food choice popup off, bring back all the buttons!
			buttonsEnable();
		}
		
		foodMenu.visible = !foodMenu.visible; //toggles the food choice popup on and off
	}
	
	public function buttonFoodChoice(foodType: String, foodCost: Int ):Void {
		world.createFood(foodType, foodCost);
		menus.get("Food").visible = false;
		buttonsEnable();
	}
	
	
	/* PLAY BUTTON in Action bar */
	public function buttonPlay():Void {
				//var toy = new Toy();
				//objectLayer.addChild(toy);
				//Commented out by Mandi to disable physics test 
		world.createToy();
	}
	
	
	/* WASH BUTTON in Action bar */
	public function buttonWash():Void {
		
		if (washMeter.fill.scaleX > .90) {
			//wy refuses a wash when too clean
			world.grub.state = "protest";
		} else { // wy is dirty enough for a wash 
			world.saveData.data.needWash = Date.now().getTime() + World.NEED_WASH_TIME; //prevents overfilling. fills to the extent that it can fill
			buttonsDisable();
			var tween = Actuate.tween (world.wash, 1, { x: 900, y: 1} ); 
			tween.ease(Linear.easeNone);
			tween.onComplete(washComplete);
			world.saveData.flush();
		}
	}
	
	private function washComplete():Void {
		buttonsEnable();
		world.wash.x = -150;
	}
	
	
	/* SLEEP BUTTON in Action bar */
	public function buttonSleep(): Void {
		if (world.grub.state != "sleep" && world.grub.state != "autosleep") {
			if (sleepMeter.fill.scaleX > .90) {
				world.grub.state = "protest";
			} else {
				buttonsDisable();
				world.createPillow();
			}
		} else {
			buttonsEnable();
			world.grub.state = "wake";
		}
	}
		
	/* MAIN MENU in Action bar */
	public function buttonMainMenu():Void {
		var menuMain: GuiMenu = menus.get("Main");
		
		if (!menuMain.visible) {
			buttonsDisable();
			menus.get("Actions").buttons.get("buttonInfo").enable(); //except for the collection button, we can use that to make the popup go away
		} else { 
			buttonsEnable();
		}
		
		menuMain.visible = !menuMain.visible;
	}
	
	
		/* MAIN MENU in Action bar */
	public function buttonCloseLevelUp():Void {
		var menuLevelUp: GuiMenu = menus.get("LevelUp");
		menuLevelUp.visible = false;
	}
	
	/******************/
	//MISC BUTTON FUNCTIONS
	/******************/

	//tests to make sure a button is working at all
	public function TestCallback():Void {
		trace("button clicked");
	}
	
	public function buttonsDisable() {
		menus.get("Actions").disableAllButtonsInMenu(); //turn all the action bar buttons off
		menus.get("HUD").disableAllButtonsInMenu(); //turn all the HUD buttons off
		menus.get("onscreenGardens").disableAllButtonsInMenu();
	}
	
	public function buttonsEnable() {
		menus.get("Actions").enableAllButtonsInMenu();
		menus.get("HUD").enableAllButtonsInMenu(); //turn all the HUD buttons on
		menus.get("onscreenGardens").enableAllButtonsInMenu();
	}
	
	//updates all the meters in the game
	//TODO: this should probably be handled in GuiMeter some day
	public function updateMeters(?event:TimerEvent):Void {
		//current amount of x (taken from save data) divided by constant for total to make a percentage
		foodMeter.fill.scaleX = getNeedMeterPercentage(world.saveData.data.needFood, World.NEED_FOOD_TIME);
		playMeter.fill.scaleX = getNeedMeterPercentage(world.saveData.data.needPlay, World.NEED_PLAY_TIME);
		washMeter.fill.scaleX = getNeedMeterPercentage(world.saveData.data.needWash, World.NEED_WASH_TIME);
		sleepMeter.fill.scaleX = getNeedMeterPercentage(world.saveData.data.needSleep, World.NEED_SLEEP_TIME);
		expMeter.fill.scaleX = (world.saveData.data.expTotal / world.saveData.data.expForLevel);
		
		//Wy reactions to various states 
		//Dirty
		if (washMeter.fill.scaleX < .5) {
			world.grub.stink.visible = true;
		} else {
			world.grub.stink.visible = false;
		}
		
		//Tired 
		//if (sleepMeter.fill.scaleX < .10 && (world.grub.state != "sleep" || world.grub.state != "autosleep")) {
		if (sleepMeter.fill.scaleX < .10 && world.grub.state == "idle") {
			world.grub.state = "autosleep";
		} else if (sleepMeter.fill.scaleX > .80 && world.grub.state == "autosleep") {
			world.grub.state = "wake";
		}
		
		//Gardens
		garden1.updateState();
		garden2.updateState();
		garden3.updateState();
	}
	
	public function updateGardens(?event:TimerEvent):Void {
		updateText ("onscreenGardens", "gardenTime1", makeGardenTimerString(1));
		updateText ("onscreenGardens", "gardenTime2", makeGardenTimerString(2));
		updateText ("onscreenGardens", "gardenTime3", makeGardenTimerString(3));
		if (menus.get("menuGarden").visible == true) {
			updateText ("menuGarden", "gardenNewSeedsTime", makeDayTimerString());
		}
	}
	
	public function updateSky(?event:TimerEvent):Void {
		//world.bgSunMoon.rotation += .25;
		world.updateDarkness();
		
	}
	
	//returns the percent filled the need meter should be
	//All need meters are emptied based on a saved time that they should be empty (expireTime)
	private function getNeedMeterPercentage(expireTime:Float, totalTime:Int):Float {
		var now : Date = Date.now();
		var nowTime : Float = now.getTime();
		var percent : Float = Math.max(0, (expireTime - nowTime) / totalTime);
		return percent;
	}
	
	private function addCollectSetGraphics() {
		var y : Int = 200;
		var i : Int = 1;
		for (collectSet in world.collectSets) {  //for every collectSet in the collectSets array 
			var x : Int = 50;
			
			var COLLECTIONNAME_X_OFFSET : Int = 180;
			var FRAME_Y_OFFSET : Int = -50;
			var ITEM_X_OFFSET : Int = 70;
			var ITEM_Y_OFFSET : Int = 10;
			//build the yellow frame, add the collection set's name to the top
			collectSetMenu.addGraphic("collectSetFrame", x, y + FRAME_Y_OFFSET);
			collectSetMenu.addText("collectSetName" + i, collectSet.userName, "BlueFontSmall", x + COLLECTIONNAME_X_OFFSET, y - 80, 300, 50); 
			
			//for every setItem in the collectSets's setItems array 
			for (setItem in collectSet.setItems) { 
				collectSetMenu.addGraphic(setItem.mc, x + ITEM_X_OFFSET, y + ITEM_Y_OFFSET);
				collectSetMenu.addText("collectSetAmount" + i, "x" + "0", "BlueFont", x + 90, y + 50, 300, 50); 
				x += 140;
			}
			//add the prize separately since there's just one prize per set
			collectSetMenu.addButton("buttonCollectSetPrize" + i, "buttonBlueSquare", x + 10, y - 40, function() { 
				world.grub.addHat(collectSet.setPrize, collectSet.setPrizeX, collectSet.setPrizeY); 
				graphics.get("collectSetMenuBG").visible = false;
				collectSetMenu.visible = false;
				}, collectSet.setPrize, .5, .5 );
			
			//prepare to draw the next row, go back to start of loop
			y += 200;
			i++;
		}
		collectSetMenu.resetExtents();
	}
	
	private function makeDayTimerString() {
		var timeOfGrubDay : Float =  World.DAYNIGHTCYCLE - (Date.now().getTime() % World.DAYNIGHTCYCLE);
		var x = cast(Math.floor(timeOfGrubDay / 1000 + 1), Float); //turn it into seconds
		return processHMSString(x);
	}
	
	private function makeGardenTimerString(gardenID: Int) {
		//this function pulls garden time from save data, all it needs to know is the garden's ID
		//grab time remaining in milliseconds
		//convert it into hours, minutes, seconds
		//if hours, display hours and minutes
		//if minutes, display minutes and seconds 
				
		//this needs to be a float because it's larger than a 32 bit integer
		var gardenTime : Float = Reflect.field(world.saveData.data, "garden" + gardenID + "Time");
		var gardenTimeUntilHarvest : Float = gardenTime - Date.now().getTime();
		
		if (gardenTime == 0) {
			return "Empty!";
		} else if (gardenTimeUntilHarvest <= 0) {
			return "Harvest";
		} else {
			var x = cast(Math.floor(gardenTimeUntilHarvest / 1000 + 1), Float); //turn it into seconds
			return processHMSString(x);
		}
	}
	
	private function processHMSString(x : Float) {
		//process it into seconds, minutes, hours, days
			var seconds = Math.floor(x % 60); 
			x /= 60;
			//trace ("seconds: " + seconds);
			var minutes = Math.floor(x % 60);
			x /= 60;
			var hours = Math.floor(x % 24);
			x /= 24;
			var days = Math.floor(x);
			//trace ("days is " + days);
			
			var timeString = "";
			//not going to need days but leave it here for now 
			if (days != 0) {
				timeString += days + "d ";
			}
			
			//hours is 1 or more, show hours and minutes
			if (hours != 0) {
				timeString += hours + "h ";
			
				if (minutes != 0) {
				timeString += minutes + "m ";
				}
				
			//hours is 0, just show minutes and seconds 
			} else {  
				if (minutes != 0) {
				timeString += minutes + "m ";
				}
				
				if (seconds != 0) {
				timeString += seconds + "s ";
				}
			}
			return timeString + " ";
	
	}
	
	
	
	private function makeAgeString() {
		var now : Date = Date.now();
		var grubAge : Float = now.getTime() - world.saveData.data.grubBirthTime; 
		
		var x = grubAge / 1000;  //turn it into seconds
		var seconds = Math.floor(x % 60); 
		x /= 60;
		var minutes = Math.floor(x % 60);
		x /= 60;
		var hours = Math.floor(x % 24);
		x /= 24;
		var days = Math.floor(x);
		
		var timeString = "";
		if (days != 0) {
			timeString += days + " days, ";
		}
		if (hours != 0) {
			timeString += hours + " hours, ";
		}
		if (minutes != 0) {
			timeString += minutes + " minutes";
		}
		if (timeString == "") {
			timeString = "NEW GRUB!!!";
		}
		return timeString + " ";
	}
}