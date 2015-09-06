package com.jimgrant.test;

import nme.geom.Point;
import nme.geom.Rectangle;

class Food extends Object
{
	static private var spawnBounds : Rectangle = new Rectangle(60, 250, 500, 200);
		
	private static var SNACK_VALUE = 500000; //how many of those seconds a snack fills
	private static var MEAL_VALUE = 1500000; //how many of those seconds a meal fills
	private static var TREAT_VALUE = 3000000; //how many of those seconds a treat fills
	public static var snackArray:Array<String> = ["foodApple", "foodBanana", "foodOreo", "foodCarrot", "foodDonut", "foodWatermelon"];
	private static var mealArray:Array<String> = ["foodBurger", "foodPizza", "foodEggroll", "foodSteak", "foodPancakes", "foodTacos"];
	private static var treatArray:Array<String> = ["foodBrownie", "foodCake", "foodCinnamon", "foodCupcake", "foodFrenchsilk", "foodIcecream"];
	
	
	public var foodType : String;
	public var value : Int;
	
	public function new(foodWorld:World, foodType:String) 
	{
		//receive the food type from user choice, feed it to Wy
		super(foodWorld);
		
		this.foodType = foodType;
		
		var foodChoice : String = "";
		var random = Std.random(6);
		if (foodType == "snack") {
			foodChoice = snackArray[random];
			value = SNACK_VALUE;
		}
		else if (foodType == "meal") {
			foodChoice = mealArray[random];
			value = MEAL_VALUE;
		}
		else if (foodType == "treat") {
			foodChoice = treatArray[random];
			value = TREAT_VALUE;
		}
		else {
			trace("Unknown foodType");
		}
		mc = world.artAssetLibrary.createMovieClip(foodChoice);
		addChild(mc);
		//trace ("food X: " + this.x + "food Y: " + this.y);
	}
	
	public function eat() : Void {
		//add the food's value to save data and update the gui meters
		if (world.saveData.data.needFood < Date.now().getTime()) {
			world.saveData.data.needFood = Date.now().getTime() + value;
		}
		else if (world.saveData.data.needFood + value >= Date.now().getTime() + World.NEED_FOOD_TIME) {
			world.saveData.data.needFood = Date.now().getTime() + World.NEED_FOOD_TIME;
		}
		else {
			world.saveData.data.needFood += value;
		}
		world.saveData.flush();
		world.gui.updateAllTexts("HUD");
		if (foodType == "snack") {
			world.drops.spawnDropGroup("SnackDrop", this.position);
		} else if (foodType == "meal") {
			world.drops.spawnDropGroup("MealDrop", this.position);
		} else if (foodType == "treat") {
			world.drops.spawnDropGroup("TreatDrop", this.position);
		}
		
	}
	
	public override function remove() : Void {
		eat();
	}
}