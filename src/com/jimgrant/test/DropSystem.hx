package com.jimgrant.test;
import format.swf.MovieClip;
import nme.display.Sprite;
import nme.geom.Point;
import nme.geom.Rectangle;
import nme.events.MouseEvent;
import motion.Actuate;
import motion.easing.Quad;
import motion.easing.Bounce;
import motion.easing.Quart;
import motion.actuators.GenericActuator;

class DropSystem
{
	private var dropTypes : Map<String, DropType>;
	private var dropGroups : Map< String, Array<DropRarity>>;
	private var world : World;
	private var layer : Sprite;
	
	public function new(dropSystemWorld:World, dropSystemLayer:Sprite) {
		dropTypes = new Map();
		dropGroups = new Map();
		world = dropSystemWorld;
		layer = dropSystemLayer;
		setup();
	}
	
	//methods
	public function addDropType(dropName:String, dropMC:String, dropPickUpFunc:Void->Void, dropFlyTo:Point) : Void {
		dropTypes.set(dropName, new DropType(dropMC, dropPickUpFunc, dropFlyTo));
	}
	
	public function getDropType(dropTypeName:String) : DropType {  // : DropType means "return DropType"
		return dropTypes.get(dropTypeName); //find dropTypeName in the hashtable known as dropTypes, and return it as an instance of the DropType class 
	}
	
	public function spawnDropGroup(name:String, point:Point) : Void {
		//let's create a rectangle within which to randomly send our drops!
		var left = Math.max(Grub.walkBounds.left, point.x - 200); //truncate the rectangle to the left side of the grub's walkbounds
		var right = Math.min(Grub.walkBounds.right, point.x + 200); //likewise, don't let it go too far right
		var top = point.y - 20;
		var bottom = point.y + 20;
		
		var dropZone = new Rectangle(left, top, right - left, bottom - top);
		
		var spawn : Drop;
		var dropGroup = dropGroups.get(name);
		for (drop in dropGroup) {
			var chance = Math.random() * 100;
			if (chance <= drop.rarity) {
				var className = Type.getClassName(Type.getClass(drop.dropType)); //get the name of the class of this drop
				if (className == "String") { //then it's not a DropType class... must be the name of a drop group!
					var subGroup = dropGroups.get(drop.dropType); //use the name to get the drop group
					var rarityTotal : Int = 0; //stores the total of all the drops' rarities, so we can calculate drop chance
					for (subDrop in subGroup) {
						rarityTotal += subDrop.rarity;
					}
					chance = Math.random() * rarityTotal;
					var chanceMem : Int = 0;
					for (subDrop in subGroup) {
						chanceMem += subDrop.rarity; //as we cycle through the group, it gets more likely one will be selected
						if (chanceMem >= chance) {
							spawn = new Drop(world, layer, subDrop.dropType.mc, point.x, point.y, dropZone, subDrop.dropType.pickUpFunc, subDrop.dropType.flyTo);
							break; //only one should spawn
						}
					}
				}
				else {
					spawn = new Drop(world, layer, drop.dropType.mc, point.x, point.y, dropZone, drop.dropType.pickUpFunc, drop.dropType.flyTo);
				}
			}
		}
	}
	
	public function setup() : Void {
		addDropType("XP", "expIcon", function() { world.addExp(World.XP_STAR_VALUE); }, new Point(232,38));
		addDropType("Coin", "currencyIcon", function() { world.changeCurrency(1); }, new Point(40, 38));
		
		addDropType("foodCinnamon", "foodCinnamon", function() { }, new Point(50, 850));
		//gift box
		//addDropType("collectObject", "collectObject", function() { spawnDropGroup("CollectSet", new Point(100,100)); }, new Point(550, 9));
		
		//add all of the possible collectibles 
		addDropType("collectSet1a", "collectSet1a", function() { }, new Point(550, 9));
		addDropType("collectSet1b", "collectSet1b", function() { }, new Point(550, 9));
		addDropType("collectSet1c", "collectSet1c", function() { }, new Point(550, 9));
		
		addDropType("collectSet2a", "collectSet2a", function() { }, new Point(550, 9));
		addDropType("collectSet2b", "collectSet2b", function() { }, new Point(550, 9));
		addDropType("collectSet2c", "collectSet2c", function() { }, new Point(550, 9));
		
		addDropType("collectSet3a", "collectSet3a", function() { }, new Point(550, 9));
		addDropType("collectSet3b", "collectSet3b", function() { }, new Point(550, 9));
		addDropType("collectSet3c", "collectSet3c", function() { }, new Point(550, 9));
		
		addDropType("collectSet4a", "collectSet4a", function() { }, new Point(550, 9));
		addDropType("collectSet4b", "collectSet4b", function() { }, new Point(550, 9));
		addDropType("collectSet4c", "collectSet4c", function() { }, new Point(550, 9));
		
		addDropType("collectSet5a", "collectSet5a", function() { }, new Point(550, 9));
		addDropType("collectSet5b", "collectSet5b", function() { }, new Point(550, 9));
		addDropType("collectSet5c", "collectSet5c", function() { }, new Point(550, 9));
		
		addDropType("collectSet6a", "collectSet6a", function() { }, new Point(550, 9));
		addDropType("collectSet6b", "collectSet6b", function() { }, new Point(550, 9));
		addDropType("collectSet6c", "collectSet6c", function() { }, new Point(550, 9));
		
		addDropType("collectSet7a", "collectSet7a", function() { }, new Point(550, 9));
		addDropType("collectSet7b", "collectSet7b", function() { }, new Point(550, 9));
		addDropType("collectSet7c", "collectSet7c", function() { }, new Point(550, 9));
		
		addDropType("collectSet8a", "collectSet8a", function() { }, new Point(550, 9));
		addDropType("collectSet8b", "collectSet8b", function() { }, new Point(550, 9));
		addDropType("collectSet8c", "collectSet8c", function() { }, new Point(550, 9));

		//dropGroups = hash tables
		dropGroups.set("SnackDrop", [
			{ dropType : dropTypes.get("XP"), rarity : 100 },
			{ dropType : "collectObject", rarity: 5 },
		]);
		
		
		dropGroups.set("MealDrop", [
			{ dropType : dropTypes.get("XP"), rarity : 100 },
			{ dropType : dropTypes.get("XP"), rarity : 75 },
			{ dropType : dropTypes.get("XP"), rarity : 50 },
			{ dropType : dropTypes.get("Coin"), rarity : 15 },
			{ dropType : "collectObject", rarity: 25 },
		]);
		
		dropGroups.set("TreatDrop", [
			{ dropType : dropTypes.get("XP"), rarity : 100 },
			{ dropType : dropTypes.get("XP"), rarity : 100 },
			{ dropType : dropTypes.get("XP"), rarity : 75 },
			{ dropType : dropTypes.get("XP"), rarity : 50 },
			{ dropType : dropTypes.get("Coin"), rarity : 25 },
			{ dropType : "collectObject", rarity: 25 },
		]); 
		
		dropGroups.set("PlayDrop", [
			{ dropType : dropTypes.get("XP"), rarity : 85 },
			{ dropType : dropTypes.get("Coin"), rarity : 100 },
			{ dropType : dropTypes.get("Coin"), rarity : 50 },
			{ dropType : dropTypes.get("Coin"), rarity : 25 },
			{ dropType : "collectObject", rarity: 100 },
		]);
		
		dropGroups.set("Collectibles", [
			{ dropType : dropTypes.get("collectSet1a"), rarity : 100 },
			{ dropType : dropTypes.get("collectSet1b"), rarity : 50 },
			{ dropType : dropTypes.get("collectSet1c"), rarity : 1 },
			{ dropType : dropTypes.get("collectSet2a"), rarity : 100 },
			{ dropType : dropTypes.get("collectSet2b"), rarity : 50 },
			{ dropType : dropTypes.get("collectSet2c"), rarity : 1 },
			{ dropType : dropTypes.get("collectSet3a"), rarity : 100 },
			{ dropType : dropTypes.get("collectSet3b"), rarity : 50 },
			{ dropType : dropTypes.get("collectSet3c"), rarity : 1 },
			{ dropType : dropTypes.get("collectSet4a"), rarity : 100 },
			{ dropType : dropTypes.get("collectSet4b"), rarity : 50 },
			{ dropType : dropTypes.get("collectSet4c"), rarity : 1 },
			{ dropType : dropTypes.get("collectSet5a"), rarity : 100 },
			{ dropType : dropTypes.get("collectSet5b"), rarity : 50 },
			{ dropType : dropTypes.get("collectSet5c"), rarity : 1 },
			{ dropType : dropTypes.get("collectSet6a"), rarity : 100 },
			{ dropType : dropTypes.get("collectSet6b"), rarity : 50 },
			{ dropType : dropTypes.get("collectSet6c"), rarity : 1 },
			{ dropType : dropTypes.get("collectSet7a"), rarity : 100 },
			{ dropType : dropTypes.get("collectSet7b"), rarity : 50 },
			{ dropType : dropTypes.get("collectSet7c"), rarity : 1 },
			{ dropType : dropTypes.get("collectSet8a"), rarity : 100 },
			{ dropType : dropTypes.get("collectSet8b"), rarity : 50 },
			{ dropType : dropTypes.get("collectSet8c"), rarity : 1 },
		]);
		
		dropGroups.set("collectObject", [
			{ dropType : dropTypes.get("collectSet1a"), rarity : 1 },
			{ dropType : dropTypes.get("collectSet1b"), rarity : 1 },
			{ dropType : dropTypes.get("collectSet1c"), rarity : 1 },
			{ dropType : dropTypes.get("collectSet2a"), rarity : 1 },
			{ dropType : dropTypes.get("collectSet2b"), rarity : 1 },
			{ dropType : dropTypes.get("collectSet2c"), rarity : 1 },
			{ dropType : dropTypes.get("collectSet3a"), rarity : 1 },
			{ dropType : dropTypes.get("collectSet3b"), rarity : 1 },
			{ dropType : dropTypes.get("collectSet3c"), rarity : 1 },
			{ dropType : dropTypes.get("collectSet4a"), rarity : 1 },
			{ dropType : dropTypes.get("collectSet4b"), rarity : 1 },
			{ dropType : dropTypes.get("collectSet4c"), rarity : 1 },
			{ dropType : dropTypes.get("collectSet5a"), rarity : 1 },
			{ dropType : dropTypes.get("collectSet5b"), rarity : 1 },
			{ dropType : dropTypes.get("collectSet5c"), rarity : 1 },
			{ dropType : dropTypes.get("collectSet6a"), rarity : 1 },
			{ dropType : dropTypes.get("collectSet6b"), rarity : 1 },
			{ dropType : dropTypes.get("collectSet6c"), rarity : 1 },
			{ dropType : dropTypes.get("collectSet7a"), rarity : 1 },
			{ dropType : dropTypes.get("collectSet7b"), rarity : 1 },
			{ dropType : dropTypes.get("collectSet7c"), rarity : 1 },
			{ dropType : dropTypes.get("collectSet8a"), rarity : 1 },
			{ dropType : dropTypes.get("collectSet8b"), rarity : 1 },
			{ dropType : dropTypes.get("collectSet8c"), rarity : 1 },
		]);
		
		dropGroups.set("gardenDrop", [
			{ dropType : dropTypes.get("foodCinnamon"), rarity : 100 },
			{ dropType : dropTypes.get("foodCinnamon"), rarity : 100 },
			{ dropType : dropTypes.get("foodCinnamon"), rarity : 100 },
			{ dropType : dropTypes.get("foodCinnamon"), rarity : 100 },
			{ dropType : dropTypes.get("XP"), rarity : 100 },
			{ dropType : dropTypes.get("XP"), rarity : 100 },
			{ dropType : dropTypes.get("XP"), rarity : 75 },
			{ dropType : dropTypes.get("Coin"), rarity : 100 },
			{ dropType : dropTypes.get("Coin"), rarity : 100 },
			{ dropType : dropTypes.get("Coin"), rarity : 100 },
			{ dropType : "collectObject", rarity: 25 },
			{ dropType : "collectObject", rarity: 5 },
		]);
	}
}

typedef DropRarity = {
	var dropType : Dynamic;
	var rarity : Int;
}

class Drop extends Sprite
{
	static private var DROP_DIST_MIN : Int = 70; //70
	static private var DROP_DIST_MAX : Int = 120; //120
	static private var DROP_IDLE_TIME : Int = 5; //in seconds
	static private var DROP_FLY_TIME : Float = .5; //in seconds
	static private var bounds : Rectangle = new Rectangle(30, 30, 550, 500);
	
	public var mc : MovieClip;
	public var position(get_position, set_position) : Point;
	
	private var world : World;
	private var pickUpFunc : Void->Void;
	private var flyTo : Point;
	private var timer : IGenericActuator;
	private var destX : Float;
	private var destY : Float;
	private var bounceY : Float;
	
	//constructor
	public function new(dropWorld:World, dropLayer:Sprite, dropMC:String, dropX:Float, dropY:Float, dropRect:Rectangle, dropFunc:Void->Void, dropFlyTo:Point) 
	{
		super();
		world = dropWorld;
		mc = dropWorld.artAssetLibrary.createMovieClip(dropMC);
		addChild(mc);
		position = new Point(dropX, dropY);
		pickUpFunc = dropFunc;
		flyTo = dropFlyTo;
		dropLayer.addChild(this);
		bounceY = 0;
		
		bounce(dropRect);
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
	
	//methods
	private function bounce(dropZone: Rectangle):Void {
		/* preserving this cuz the math might come in handy someday
		var angle = Math.PI * Math.random();
		var distance = Math.random() * (DROP_DIST_MAX - DROP_DIST_MIN) + DROP_DIST_MIN;
		var destination = position.add(Point.polar(distance, angle));
		var bounceHeight = destination.y + 50; //50
		var tweenMove = Actuate.tween(this, 1, { x: destination.x } ).ease(Quad.easeOut);
		var tweenHeight = Actuate.tween(this, 1, { y: bounceHeight } ).ease(Bounce.easeOut);
		tweenMove.onComplete(makeTappable);
		*/
		
		destX = Std.random(Math.floor(dropZone.right - dropZone.left)) + dropZone.left;
		destY = Std.random(Math.floor(dropZone.bottom - dropZone.top)) + dropZone.top;
		var tweenHeight = Actuate.tween(this, .25, { bounceY: 100 } ).ease(Quart.easeOut).onComplete(function() { //this tween guides the climb of the drop
			var tweenHeight = Actuate.tween(this, .75, { bounceY: 0 } ).ease(Bounce.easeOut); //while this one handles the fall + bounce, which is why it's longer
		});
		var tweenMove = Actuate.tween(this, 1, { x: destX } ).ease(Quad.easeOut).onUpdate(function() { //this tween handles the horizontal motion
			y = destY - bounceY; //this handles the vertical, reading the var we're tweening on the previous few lines
		});
		tweenMove.onComplete(makeTappable);
	}
	
	private function makeTappable():Void {
		this.addEventListener( MouseEvent.MOUSE_DOWN, onTap );
		timer = Actuate.timer(DROP_IDLE_TIME).onComplete(flyToUI);
	}
	
	private function flyToUI():Void {
		//execute the saved function that gives the player whatever the drop signifies (xp, currency, etc.)
		pickUpFunc();
		world.UILayer.addChild(this);
		var tween = Actuate.tween(this, DROP_FLY_TIME, { x: flyTo.x, y: flyTo.y } );
		tween.ease(Quad.easeOut);
		tween.onComplete(destroy);
	}
	
	private function destroy():Void {
		this.removeChild(mc);
	}
	
	//event listener functions
	private function onTap(event):Void {
		this.removeEventListener( MouseEvent.MOUSE_DOWN, onTap );
		timer.onComplete(null); // we don't need the timer anymore since the user picked it up manually
		flyToUI();
	}
}

class DropType
{
	public var mc:String;
	public var pickUpFunc:Void->Void;
	public var flyTo:Point;
	
	public function new(dropTypeMC:String, dropTypePickUpFunc: Void->Void, dropTypeFlyTo: Point)
	{
		mc = dropTypeMC;
		pickUpFunc = dropTypePickUpFunc;
		flyTo = dropTypeFlyTo;
	}
}