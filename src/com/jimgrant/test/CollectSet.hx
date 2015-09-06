package com.jimgrant.test;
import format.swf.MovieClip;

 
class CollectSet 
{
	private var world: World;
	public var name: String;
	public var userName: String;
	
	public var setItems:Array<DropSystem.DropType>;
	public var setItemsCount:Array<Int>;
	public var setPrize:String;
	public var setPrizeX:Int;
	public var setPrizeY:Int;

	public function new(setWorld:World, collectSetUserName:String, collectSetName:String, item1Name:String, item2Name:String, item3Name:String, setPrizeName:String, collectSetPrizeX:Int, collectSetPrizeY:Int) 
	{
		world = setWorld;
		name = collectSetName;
		userName = collectSetUserName;
		var item1: DropSystem.DropType = world.drops.getDropType(item1Name); 
		var item2: DropSystem.DropType = world.drops.getDropType(item2Name); 
		var item3: DropSystem.DropType = world.drops.getDropType(item3Name); 
		setItems = [item1 , item2, item3];
		setItemsCount = [0, 0, 0];
		setPrize = setPrizeName;
		setPrizeX = collectSetPrizeX;
		setPrizeY = collectSetPrizeY;
		
		//contains the sets, which includes:
		//three unique collectible items in each set
		//set name
		//prize for finishing set
		//current quantity of collectibles as an int
		
	}
	
	
	
}