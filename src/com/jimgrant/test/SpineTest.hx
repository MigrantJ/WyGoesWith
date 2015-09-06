package com.jimgrant.test;

import nme.display.Sprite;
import spinehx.SkeletonRenderer;
import spinehx.SkeletonRendererDebug;
import spinehx.atlas.TextureAtlas;
import spinehx.Skeleton;
import spinehx.Bone;
import spinehx.Animation;
import spinehx.AnimationState;
import spinehx.SkeletonJson;
import spinehx.SkeletonData;
import spinehx.AnimationStateData;
import flash.events.Event;
import flash.events.MouseEvent;

class SpineTest extends Sprite {
	var time:Float = 0.0;
	var renderer:SkeletonRenderer;
	var debugRenderer:SkeletonRendererDebug;
	var atlas:TextureAtlas;
	var skeleton:Skeleton;
	var animation:Animation;
    var root_:Bone;
    var state:AnimationState;
    var lastTime:Float = 0.0;
	var currentWeapon:String = "spear";
	
	var mode:Int = 1; //this controls the rendering mode
	
	public function new() {
		super();
		atlas = TextureAtlas.create("assets/spinehx/goblins.atlas", "assets/spinehx/");
		var json = SkeletonJson.create(atlas);
		var skeletonData:SkeletonData = json.readSkeletonData("goblins", nme.Assets.getText("assets/spinehx/goblins.json"));
		animation = skeletonData.findAnimation("walk");
		
		skeleton = Skeleton.create(skeletonData);
		skeleton.setSkinByName("goblingirl"); //necessary for a skeleton with multiple skins, it's not on by default
		skeleton.setToBindPose(); //not sure what this does
		skeleton = Skeleton.copy(skeleton); //not sure what this does
		
		root_ = skeleton.getRootBone();
        root_.x = 50;
		root_.y = 20;
		root_.scaleX = 1.0;
		root_.scaleY = 1.0;
        skeleton.setFlipY(true);
		
		skeleton.updateWorldTransform();
		
		lastTime = haxe.Timer.stamp();
		
		renderer = new SkeletonRenderer(skeleton);
        debugRenderer = new SkeletonRendererDebug(skeleton);
		renderer.x = 0;
        renderer.y = 350;
        addChild(renderer);
        addChild(debugRenderer);
		
		addEventListener(Event.ENTER_FRAME, render);
        addEventListener(Event.ADDED_TO_STAGE, added);
		
		/*
		super();
		atlas = TextureAtlas.create("assets/spinehx/spineboy.atlas", "assets/spinehx/");
		var json = SkeletonJson.create(atlas);
		var skeletonData:SkeletonData = json.readSkeletonData("spineboy", nme.Assets.getText("assets/spinehx/spineboy.json"));
		
		// Define mixing between animations.
        var stateData = new AnimationStateData(skeletonData);
        stateData.setMixByName("walk", "jump", 0.4);
        stateData.setMixByName("jump", "walk", 0.4);
		
		state = new AnimationState(stateData);
        state.setAnimationByName("walk", true);
		
		skeleton = Skeleton.create(skeletonData);
		
		root_ = skeleton.getRootBone();
        root_.setX(150);
        root_.setY(360);
        skeleton.setFlipY(true);
		
		skeleton.updateWorldTransform();
		
		lastTime = haxe.Timer.stamp();
		
		renderer = new SkeletonRenderer(skeleton);
        debugRenderer = new SkeletonRendererDebug(skeleton);
        addChild(renderer);
        addChild(debugRenderer);
        addChild(new nme.display.FPS());
		
		addEventListener(Event.ENTER_FRAME, render);
        addEventListener(Event.ADDED_TO_STAGE, added);
		
		//renderer.thing();
		*/
	}
	
	public function added(e:Event):Void {
        this.mouseChildren = false;
        stage.addEventListener(MouseEvent.CLICK, onClick);
    }
	
	public function onClick(e:Event):Void {
//        mode++;
//        mode%=3;
        
		trace("clicked");
		if (name == "goblins") {
            skeleton.setSkinByName(skeleton.getSkin().getName() == "goblin" ? "goblingirl" : "goblin");
            skeleton.setSlotsToBindPose();
        }
		
		if (currentWeapon == "dagger") {
			currentWeapon = "spear";
		} else {
			currentWeapon = "dagger";
		}
		skeleton.setAttachment("left hand item", currentWeapon);
    }

    public function render(e:Event):Void {
		var deltaTime:Float = haxe.Timer.stamp() - lastTime;
        lastTime = haxe.Timer.stamp();
		time += deltaTime;

		var root_:Bone = skeleton.getRootBone();
		var x:Float = root_.getX() + 160 * deltaTime * (skeleton.getFlipX() ? -1 : 1);
		if (x > nme.Lib.stage.stageWidth) skeleton.setFlipX(true);
		if (x < 0) skeleton.setFlipX(false);
		root_.setX(x);

		animation.apply(skeleton, time, true);
		skeleton.updateWorldTransform();
		skeleton.update(deltaTime);


        if(mode == 0 || mode == 1){
            renderer.visible = true;
            renderer.clearBuffers();
            renderer.draw();
        } else renderer.visible = false;
        if(mode == 0 || mode == 2){
            debugRenderer.visible = true;
            debugRenderer.draw();
        } else debugRenderer.visible = false;
		
		/*
        var delta = (haxe.Timer.stamp() - lastTime) / 3;
        lastTime = haxe.Timer.stamp();
        state.update(delta);
        state.apply(skeleton);

        if (state.getAnimation().getName() == "walk") {
            // After one second, change the current animation. Mixing is done by AnimationState for you.
            if (state.getTime() > 2) state.setAnimationByName("jump", false);
        } else {
            if (state.getTime() > 1) state.setAnimationByName("walk", true);
        }

        skeleton.updateWorldTransform();
		
        if(mode == 0 || mode == 1){
            renderer.visible = true;
            renderer.draw();
        } else renderer.visible = false;
        if(mode == 0 || mode == 2){
            debugRenderer.visible = true;
            debugRenderer.draw();
        } else debugRenderer.visible = false;
		*/
    }
	
}