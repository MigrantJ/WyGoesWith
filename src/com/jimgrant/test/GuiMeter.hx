package com.jimgrant.test;
import nme.display.Sprite;
import format.swf.MovieClip;

/**
 * ...
 * @author Jim
 */

 //This is a factory class that makes new meters, layering their graphics appropriately so they can be filled and emptied
 //TODO: it'd be nice if this class stored the var or function that makes them fill or empty, sorta like GuiButton does for callbacks
class GuiMeter extends Sprite
{
	public var container:MovieClip;
	public var fill:MovieClip;
	private var fillXOffset:Int;
	private var fillYOffset:Int;
		
	public function new(containerMC:MovieClip, fillMC:MovieClip) {
		super();
		container = containerMC;
		fill = fillMC;
		fillXOffset = 1;
		fillYOffset = 0;
		
		fill.x = fillXOffset;
		fill.y = fillYOffset;
		this.addChild(fill);
		this.addChild(container);
	}
}