package com.jimgrant.test;

import nme.display.Sprite;
import format.swf.MovieClip;
import nme.text.TextField;
import nme.Lib;
/**
 * ...
 * @author Jim
 */

 //This is a factory class that makes new menus
 //A "menu", in this case, is anything that holds GUI elements, such as buttons, meters, graphics, or text.
 //So a HUD is a menu in this case. Think of a menu as a collection of GUI stuff
class GuiMenu extends Sprite
{
	public var parentGui:Gui;
	public var buttons:Map<String, GuiButton>;
	public var meters:Map<String, GuiMeter>;
	public var textFields:Map<String, GuiText>;
	
	private var isEnabled:Bool = true;
	
	public function new(gui: Gui) 
	{
		super();
		parentGui = gui;
		buttons = new Map();
		meters = new Map();
		textFields = new Map(); //create the hash that will hold all the text fields
	}
	
	public function addGraphic(mcName: String, x:Float, y:Float, ?xScale:Float = 1, ?yScale:Float = 1 ): Void {
		var mc = parentGui.artAssetLibrary.createMovieClip(mcName);
		mc.x = x;
		mc.y = y;
		mc.scaleX = xScale;
		mc.scaleY = yScale;
		this.addChild(mc);
	}
	
	public function addButton(name: String, type:String, x: Float, y:Float, btnCallback:Void->Void, ?icon: String, ?iconXScale:Float = 1, ?iconYScale:Float = 1):Void {
		var mc: MovieClip;
		var iconMC: MovieClip;
		
		mc = parentGui.artAssetLibrary.createMovieClip(type);
		
		var button = new GuiButton(mc, x, y, btnCallback);
		buttons.set(name, button);
		this.addChild(button);
		
		if (icon != null) {
			iconMC = parentGui.artAssetLibrary.createMovieClip(icon);
			button.addChild(iconMC);
			iconMC.x += 55;
			iconMC.y += 55;
			iconMC.scaleX = iconXScale;
			iconMC.scaleY = iconYScale;
		}
	}
	
	public function addButtonReady(name: String, button: GuiButton) {
		buttons.set(name, button);
		this.addChild(button);
	}
	
	public function addMeter(name:String, type:String, x:Int, y:Int):GuiMeter {
		var containerName:String = parentGui.meterTypes.get(type).container;
		var fillName:String = parentGui.meterTypes.get(type).fill;
		var fillXOffset:Int = 0;
		var fillYOffset:Int = 1;
		
		var containerMC = parentGui.artAssetLibrary.createMovieClip(containerName);
		var fillMC = parentGui.artAssetLibrary.createMovieClip(fillName);
		
		var meter = new GuiMeter(containerMC, fillMC);
		meter.x = x;
		meter.y = y;
		meters.set(name, meter);
		this.addChild(meter);
		return meter;
	}
	
	public function addText (name:String, text:String, font:String, x:Int, y:Int, width:Int, height:Int, ?centered:Bool, ?valueFunc: Void->String, ?button:String) {
		var textField = new GuiText();
		var textFormat = parentGui.fonts.get(font);
		textField.defaultTextFormat = textFormat;
		textField.text = text;
		if (centered == true) {
			//textField.x = stage.stageWidth - textField.length;
			//textField.x = Lib.current.stage.stageWidth - textField.textWidth / 2;
			textField.x = Lib.stage.stageWidth - textField.textWidth / 2;
		} else {
			textField.x = x;
		}
		
		textField.y = y;
		textField.width = width;
		textField.height = height;
		
		if (valueFunc != null) {
			textField.valueFunc = valueFunc;
		}
		
		textFields.set(name, textField);
		this.addChild(textField);
		
		//experimental button text code
		/*
		if (button) {
			this._buttons[button]._cont.addChild(textField);
			this._buttons[button]._label = textField;
		} else {
			this._texts[name] = textField;
			this._cont.addChild(textField);
		}
		*/
	}
	
	public function disableAllButtonsInMenu() : Void {
		isEnabled = false;
		for (button in buttons) {
			button.disable();
		}
	}
	
	public function enableAllButtonsInMenu() : Void {
		isEnabled = true;
		for (button in buttons) button.enable();
	}
}