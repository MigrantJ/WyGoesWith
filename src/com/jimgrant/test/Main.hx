package com.jimgrant.test;

import format.SWF;
import nme.display.StageAlign;
import nme.display.StageScaleMode;
import nme.Lib;
import nme.Assets;

class Main 
{
	static public function main() 
	{
		var stage = Lib.current.stage;
		
		//for PC use
		//stage.scaleMode = StageScaleMode.NO_SCALE;
		//stage.align = StageAlign.TOP_LEFT;
		
		//for iOS playtesting		
		stage.scaleMode = StageScaleMode.EXACT_FIT;
		stage.align = StageAlign.TOP_LEFT;
		
		var artAssetLibrary = new SWF(Assets.getBytes("assets/WyGoesWith_art_HAXE.swf"));
		
		var world = new World(artAssetLibrary);
		world.scaleX = .5;
		world.scaleY = .5;
		stage.addChild(world);
	}
	
}