package com.jimgrant.test;
import format.swf.MovieClip;
import nme.display.Sprite;
import nme.geom.Point;
import nme.geom.Rectangle;
import motion.Actuate;
import motion.easing.Elastic;

class Object extends Sprite
{
	//static private var spawnBounds : Rectangle = new Rectangle(60, 150, 520, 500);
	static private var spawnBounds : Rectangle = new Rectangle(60, 300, 500, 300);
	
	private var world : World;
	public var mc : MovieClip;
	public var position(get_position, set_position) : Point;
	private var effect : AnimatedObject;
	
	public function new(objectWorld:World) 
	{
		super();
		world = objectWorld;
		setOppositeQuadrantPos();
		
		this.scaleX = 0;
		this.scaleY = 0;
		var tween = Actuate.tween (this, 1, { scaleX: 1, scaleY: 1 });
		tween.ease(Elastic.easeOut);
		
		world.createSmoke(position.x, position.y);
	}
	
	public function get_position():Point {
		return new Point(this.x, this.y);
	}
	
	public function set_position(p:Point):Point {
		this.x = p.x;
		this.y = p.y;
		return new Point(this.x, this.y);
	}

	
	public function remove():Void {
		//this gets overridden by inheritors
	}
	
	private function setRandomPos():Void {
		position = new Point((Math.random() * spawnBounds.width) + spawnBounds.x, (Math.random() * spawnBounds.height) + spawnBounds.y);
	}
	
	private function setOppositeQuadrantPos() : Void { 
		var xPos : Float = 0;
		var yPos : Float = 0;
		
		if (world.grub.x < (spawnBounds.width/2 + spawnBounds.x)) { 
			xPos = ((Math.random() * spawnBounds.width/2) + spawnBounds.x + 250);
		} else {
			xPos = ((Math.random() * spawnBounds.width/2) + spawnBounds.x);
		}
		if (world.grub.y < (spawnBounds.height/2) + spawnBounds.y) { 
			yPos = ((Math.random() * spawnBounds.height/2) + spawnBounds.y + 100); //300
		} else {
			yPos = ((Math.random() * spawnBounds.height/2) + spawnBounds.y);
		}
		
		position = new Point (xPos, yPos);
		
	}
}