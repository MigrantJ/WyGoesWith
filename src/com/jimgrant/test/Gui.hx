package com.jimgrant.test;
import format.SWF;
import format.swf.MovieClip;
import format.swf.symbol.Font;
import nme.display.Sprite;
import nme.geom.Rectangle;
import nme.text.TextFormat;
import nme.text.TextField;
import nme.Assets;

/**
 * ...
 * @author Jim
 * NO WY-SPECIFIC CODE HERE
 * This is a library for creating GUIs. Its primary goals are simplicity and portability.
 * Please do not edit unless you are adding functionality to the gui system.
 * Any buttons, meters etc. for Wy should be put in GuiSetup.hx
 */

//a data type that holds the names of the movie clip instances used for the different parts of a meter
typedef MeterType = { name:String, container:String, fill:String }
 
class Gui {
	public var world:World;
	public var artAssetLibrary:SWF;
	public var layer:Sprite;
	
	public var graphics:Map<String, MovieClip>;
	public var menus:Map<String, GuiMenu>;
	public var buttonTypes:Map<String, MovieClip>;
	public var meterTypes:Map<String, MeterType>;
	public var fonts:Map<String, TextFormat>;
	
	public function new(guiWorld:World, guiLibrary:SWF, guiLayer:Sprite) {
		world = guiWorld;
		artAssetLibrary = guiLibrary;
		layer = guiLayer;
		
		graphics = new Map();
		menus = new Map();
		buttonTypes = new Map();
		meterTypes = new Map();
		fonts = new Map(); //TODO Fix font, it doesnt load in game
	}
	
	//creates a new GuiMenu and stores a reference to it in the menus hash
	public function addMenu(name:String, ?scroll:Bool = false, ?scrollConstraint:Int = GuiScrollMenu.CONSTRAIN_VERT, ?scrollView:Rectangle): GuiMenu {
		var menu : GuiMenu = new GuiMenu(this);
		menus.set(name, menu);
		layer.addChild(menu);
		return menu;
	}
	
	//just like GuiMenu except it scrolls!
	public function addScrollMenu(name:String, scrollConstraint:Int = GuiScrollMenu.CONSTRAIN_VERT, scrollView:Rectangle): GuiScrollMenu {
		var menu : GuiScrollMenu = new GuiScrollMenu(this, scrollConstraint, scrollView);
		menus.set(name, menu);
		layer.addChild(menu);
		return menu;
	}
	
	//creates a new graphic. Graphics are non-interactive objects like icons or backgrounds
	public function addGraphic(name:String, mcName: String, x:Float, y:Float): Void {
		var mc = artAssetLibrary.createMovieClip(mcName);
		mc.x = x;
		mc.y = y;
		graphics.set(name, mc);
		layer.addChild(mc);
	}
	
	public function addButtonType(name:String, mcName:String) {
		var mc = artAssetLibrary.createMovieClip(mcName);
		buttonTypes.set(name, mc);
	}

	public function addMeterType(meterType:MeterType) {
		meterTypes.set(meterType.name, meterType);
	}
	
	public function addFont (name:String, size:Int, color:Int, font:String) {
		var fontAsset = Assets.getFont("assets/" + font);
		var textFormat = new TextFormat(fontAsset.fontName);
		
		textFormat.size = size;
		textFormat.color = color;
		
		fonts.set(name, textFormat); //add to Hash
	}
	
	//disables every button in every menu in the game. Use with caution!
	public function disableAllButtons() : Void {
		for (menu in menus) menu.disableAllButtonsInMenu();
	}
	
	//enables every button in every menu in the game. Use with caution!
	public function enableAllButtons() : Void {
		for (menu in menus) menu.enableAllButtonsInMenu();
	}
}