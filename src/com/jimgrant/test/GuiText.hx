package com.jimgrant.test;
import nme.text.TextField;

/**
 * ...
 * @author Jim
 */

class GuiText extends TextField
{
	public var valueFunc: Void->String;
	
	public function new() 
	{
		
		super();
		this.selectable = false; //this stops the annoying cursor hover problem with text
		this.mouseEnabled = false; //this stops text blocking mouse clicks
		this.embedFonts = true; //this lets our fonts work and it's not on by default for some dumb reason
		valueFunc = function() { return text; };
	}
	
	//executes the function, if any, that updates the text value of this textfield
	public function update() {
		this.text = valueFunc();
		
	}
	
}