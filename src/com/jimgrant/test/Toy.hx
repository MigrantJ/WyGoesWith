package com.jimgrant.test;

import nme.display.Sprite;
import flash.events.Event;
/*
import box2D.collision.shapes.B2CircleShape;
import box2D.collision.shapes.B2PolygonShape;
import box2D.common.math.B2Vec2;
import box2D.dynamics.B2Body;
import box2D.dynamics.B2BodyDef;
import box2D.dynamics.B2DebugDraw;
import box2D.dynamics.B2FixtureDef;
import box2D.dynamics.B2World;
*/

class Toy extends Object
{
	
	public function new(toyWorld: World) {
		super(toyWorld);
	}
	
	public function play() : Void {
		var value : Int = World.PLAY_VALUE;
		//trace (world.saveData.data.needPlay);
		if (world.saveData.data.needPlay < Date.now().getTime()) {
			world.saveData.data.needPlay = Date.now().getTime() + value;
		}
		else if (world.saveData.data.needPlay >= Date.now().getTime() + World.NEED_PLAY_TIME) {
			world.saveData.data.needPlay = Date.now().getTime() + World.NEED_PLAY_TIME;
		}
		else {
			world.saveData.data.needPlay += value;
		}
		world.saveData.flush();
		world.gui.updateAllTexts("HUD");
		world.drops.spawnDropGroup("PlayDrop", this.position);
	}
		
		
	
/*
	private static var PHYSICS_SCALE:Float = 1 / 30;
	
	private var PhysicsDebug:Sprite;
	public var b2world:B2World;
	
	public function new() 
	{
		//super(toyWorld);
		//mc = world.artAssetLibrary.createMovieClip("toyFootball");
		//addChild(mc);
		
		super();
		PhysicsDebug = new Sprite ();		
		b2world = new B2World(new B2Vec2 (0, 10.0), true);
		addChild(PhysicsDebug);
		
		var debugDraw:B2DebugDraw = new B2DebugDraw ();
		debugDraw.setSprite (PhysicsDebug);
		debugDraw.setDrawScale (1 / PHYSICS_SCALE);
		debugDraw.setFlags (B2DebugDraw.e_shapeBit);
		
		b2world.setDebugDraw (debugDraw);
		
		createBox (250, 600, 500, 100, false);
		createBox (250, 100, 100, 100, true);
		createCircle (400, 100, 50, true);
		
		addEventListener (Event.ENTER_FRAME, this_onEnterFrame);
	}
	
	private function createBox (x:Float, y:Float, width:Float, height:Float, dynamicBody:Bool):Void {
		var bodyDefinition = new B2BodyDef ();
		bodyDefinition.position.set (x * PHYSICS_SCALE, y * PHYSICS_SCALE);
		
		if (dynamicBody) {
			
			bodyDefinition.type = B2Body.b2_dynamicBody;
			
		}

		var polygon = new B2PolygonShape ();
		polygon.setAsBox ((width / 2) * PHYSICS_SCALE, (height / 2) * PHYSICS_SCALE);
		
		var fixtureDefinition = new B2FixtureDef ();
		fixtureDefinition.shape = polygon;
		

		var body = b2world.createBody(bodyDefinition);
		body.createFixture (fixtureDefinition);
	}
	
	
	private function createCircle (x:Float, y:Float, radius:Float, dynamicBody:Bool):Void {
		
		var bodyDefinition = new B2BodyDef ();
		bodyDefinition.position.set (x * PHYSICS_SCALE, y * PHYSICS_SCALE);
		
		if (dynamicBody) {
			
			bodyDefinition.type = B2Body.b2_dynamicBody;
			
		}
		
		var circle = new B2CircleShape (radius * PHYSICS_SCALE);
		
		var fixtureDefinition = new B2FixtureDef ();
		fixtureDefinition.shape = circle;
		
		var body = b2world.createBody (bodyDefinition);
		body.createFixture (fixtureDefinition);
		body.setAngularVelocity(10);
		body.setAngularDamping(0);
	}
	
	// Event Handlers
	
	private function this_onEnterFrame (event:Event):Void {
		event.target.b2world.step (1 / 30, 10, 10);
		event.target.b2world.clearForces ();
		event.target.b2world.drawDebugData ();
		
	}
	*/
}