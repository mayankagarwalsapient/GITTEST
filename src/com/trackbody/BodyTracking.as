package com.trackbody
{
	import com.as3nui.nativeExtensions.air.kinect.Kinect;
	import com.as3nui.nativeExtensions.air.kinect.KinectSettings;
	import com.as3nui.nativeExtensions.air.kinect.constants.CameraResolution;
	import com.as3nui.nativeExtensions.air.kinect.data.User;
	import com.as3nui.nativeExtensions.air.kinect.events.CameraImageEvent;
	import com.as3nui.nativeExtensions.air.kinect.events.DeviceErrorEvent;
	import com.as3nui.nativeExtensions.air.kinect.events.DeviceEvent;
	import com.as3nui.nativeExtensions.air.kinect.events.DeviceInfoEvent;
	import com.as3nui.nativeExtensions.air.kinect.events.UserEvent;
	import com.as3nui.nativeExtensions.air.kinect.examples.DemoBase;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	public class BodyTracking extends DemoBase
	{
		public static const KinectMaxDepthInFlash:uint = 200;
		private static const TOP_LEFT:Point = new Point(0, 0);
		private var rgbBitmap:Bitmap;
		private var userBitmap:Bitmap;
		private var device:Kinect;
		private var skeletonRenderers:Vector.<SkeletonRenderer>;
		private var skeletonContainer:Sprite;
		private var heightInput:TextField;
		private var heightNum:Number;
		private var widthNum:Number;
		private var depthNum:Number;
		private var mc:MovieClip;
		public function BodyTracking()
		{
			//TODO: implement function
			super();
			mc.graphics.beginFill(0xff0000);
			mc.graphics.drawCircle(0,0,100);
			mc.graphics.endFill();
			mc.x = 800;
			mc.y = 200;
				 

		}
		override protected function startDemoImplementation():void{
			if (Kinect.isSupported()) {
				device = Kinect.getDevice();
				rgbBitmap = new Bitmap();
				rgbBitmap.alpha = .6;
			addChild(rgbBitmap);
			
				
				device.addEventListener(CameraImageEvent.RGB_IMAGE_UPDATE, rgbImageUpdateHandler, false, 0, true);
				device.addEventListener(DeviceInfoEvent.INFO, deviceInfoHandler, false, 0, true);
				device.addEventListener(DeviceErrorEvent.ERROR, deviceErrorHandler, false, 0, true);
				device.addEventListener(DeviceEvent.STARTED, kinectStartedHandler, false, 0, true);
				device.addEventListener(DeviceEvent.STOPPED, kinectStoppedHandler, false, 0, true);
				
				var settings:KinectSettings = new KinectSettings();
				settings.skeletonEnabled = true;
				settings.rgbEnabled = true;
				settings.userMaskEnabled = true;
				settings.rgbResolution = CameraResolution.RESOLUTION_1280_960;
				settings.userMaskResolution = CameraResolution.RESOLUTION_640_480;
				userBitmap = new Bitmap(new BitmapData(settings.userMaskResolution.x, settings.userMaskResolution.y, true, 0));
				device.addEventListener(UserEvent.USERS_WITH_SKELETON_ADDED, skeletonsAddedHandler, false, 0, true);
				device.addEventListener(UserEvent.USERS_WITH_SKELETON_REMOVED, skeletonsRemovedHandler, false, 0, true);
				skeletonRenderers = new Vector.<SkeletonRenderer>();
				skeletonContainer = new Sprite();
				addChild(skeletonContainer);
				addChild(userBitmap);
				userBitmap.width = 1280;
				userBitmap.height = 960
				addEventListener(Event.ENTER_FRAME, enterFrameHandler, false, 0, true);
				device.start(settings);
				heightInput = new TextField();
				var myFormat:TextFormat = new TextFormat();
				
				myFormat.size = 25;
				myFormat.align = TextFormatAlign.CENTER;
				heightInput.defaultTextFormat = myFormat;
				heightInput.width = 1200;
				
				addChild(heightInput);
			}
		}
		protected function skeletonsRemovedHandler(event:UserEvent):void {
			for each(var removedUser:User in event.users) {
				var index:int = -1;
				for (var i:int = 0; i < skeletonRenderers.length; i++) {
					if (skeletonRenderers[i].user == removedUser) {
						index = i;
						break;
					}
				}
				if (index > -1) {
					skeletonContainer.removeChild(skeletonRenderers[index]);
					skeletonRenderers.splice(index, 1);
				}
			}
		}
		protected function skeletonsAddedHandler(event:UserEvent):void {
			for each(var addedUser:User in event.users) {
			
				var skeletonRenderer:SkeletonRenderer = new SkeletonRenderer(addedUser);
				skeletonContainer.addChild(skeletonRenderer);
				skeletonRenderers.push(skeletonRenderer);
			}
		}
		
		protected function enterFrameHandler(event:Event):void {
			for each(var skeletonRenderer:SkeletonRenderer in skeletonRenderers) {
				skeletonRenderer.explicitWidth = explicitWidth;
				skeletonRenderer.explicitHeight = explicitHeight;
				heightNum = skeletonRenderer.calculateHeight();
				widthNum = skeletonRenderer.calculateWidth();
				userBitmap.bitmapData.lock();
				userBitmap.bitmapData.fillRect(userBitmap.bitmapData.rect, 0);
				for each(var user:User in device.users) {
					
					if (user.userMaskData != null) {
						
						
						//removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
						userBitmap.bitmapData.copyPixels(user.userMaskData, user.userMaskData.rect, TOP_LEFT);
						//trace(String(Math.round(getVisibleBounds(userBitmap).width * 2.54 / 96 *12) /100));
						//	trace(getVisibleBounds(bmp))
					}
				}
				var ht:Number = heightNum/100;
				var wt:Number = (widthNum/100)
			//	trace(ht + "   Width " + wt );
				heightInput.text = String(ht *wt);
				trace(getVisibleBounds(userBitmap).width * 2.54 / 96 *12 /100 *  760 );
				userBitmap.bitmapData.unlock();
				// userBitmap.bitmapData = skeletonRenderer.userBitMapData();
				skeletonRenderer.render();
			}
		}
		private function getVisibleBounds(source:DisplayObject):Rectangle
		{
			// Updated 11-18-2010;
			// Thanks to Mark in the comments for this addition;
			var matrix:Matrix = new Matrix()
			matrix.tx = -source.getBounds(null).x;
			matrix.ty = -source.getBounds(null).y;
			
			var data:BitmapData = new BitmapData(source.width, source.height, true, 0x00000000);
			data.draw(source, matrix);
			var bounds : Rectangle = data.getColorBoundsRect(0xFFFFFFFF, 0x000000, false);
			data.dispose();
			return bounds;
		}
		protected function deviceErrorHandler(event:DeviceErrorEvent):void
		{
			trace("ERROR: " + event.message);
		}
		
		protected function deviceInfoHandler(event:DeviceInfoEvent):void
		{
			trace("INFO: " + event.message);
		}
		
		protected function kinectStartedHandler(event:DeviceEvent):void {
			trace("[RGBCameraDemo] device started");
		}
		
		protected function kinectStoppedHandler(event:DeviceEvent):void {
			trace("[RGBCameraDemo] device stopped");
		}
		
		override protected function stopDemoImplementation():void {
			if (device != null) {
				device.stop();
				device.removeEventListener(CameraImageEvent.RGB_IMAGE_UPDATE, rgbImageUpdateHandler);
				device.removeEventListener(DeviceEvent.STARTED, kinectStartedHandler);
				device.removeEventListener(DeviceEvent.STOPPED, kinectStoppedHandler);
				device.removeEventListener(DeviceInfoEvent.INFO, deviceInfoHandler);
				device.removeEventListener(DeviceErrorEvent.ERROR, deviceErrorHandler);
				removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
				device.removeEventListener(UserEvent.USERS_WITH_SKELETON_ADDED, skeletonsAddedHandler);
				device.removeEventListener(UserEvent.USERS_WITH_SKELETON_REMOVED, skeletonsRemovedHandler);
			}
		}
		
		protected function rgbImageUpdateHandler(event:CameraImageEvent):void {
			
			rgbBitmap.bitmapData = event.imageData;
			layout();
		}
		
		override protected function layout():void {
			rgbBitmap.x = (explicitWidth - rgbBitmap.width) * .5;
			rgbBitmap.y = (explicitHeight - rgbBitmap.height) * .5;
			
			if (skeletonContainer != null) {
			userBitmap.x=	 skeletonContainer.x = rgbBitmap.x;
			userBitmap.y=	skeletonContainer.y = rgbBitmap.y;
				
			}
			if (root != null) {
				root.transform.perspectiveProjection.projectionCenter = new Point(explicitWidth * .5, explicitHeight * .5);
			}
		}
	}
}
import com.as3nui.nativeExtensions.air.kinect.data.SkeletonJoint;
import com.as3nui.nativeExtensions.air.kinect.data.User;
import com.bit101.components.Label;

import flash.display.BitmapData;
import flash.display.Sprite;
import flash.text.TextField;


internal class SkeletonRenderer extends Sprite {
	
	public var user:User;
	private var labels:Vector.<Label>;
	private var circles:Vector.<Sprite>;
	private var textFld:TextField;
	
	public var explicitWidth:uint;
	public var explicitHeight:uint;
	
	public function SkeletonRenderer(user:User) {
		this.user = user;
		
		labels = new Vector.<Label>();
		circles = new Vector.<Sprite>();
	}
	
	private function createLabelsIfNeeded():void {
		while (labels.length < user.skeletonJoints.length) {
			labels.push(new Label(this));
		}
	}
	
	private function createCirclesIfNeeded():void {
		while (circles.length < user.skeletonJoints.length) {
			var circle:Sprite = new Sprite();
			circle.graphics.beginFill(0xff0000);
			circle.graphics.drawCircle(0, 0, 10);
			circle.graphics.endFill();
			addChild(circle);
			circles.push(circle);
		}
	}
	
	public function calculateWidth():Number{
		var formula:Number = user.rightElbow.position.rgb.x - user.leftElbow.position.rgb.x;
		var centi:Number = formula * 2.54 / 96;
		return centi * 10;
	}
	public function calculateHeight():Number{
		var formula:Number = (Math.max(user.rightFoot.position.depthRelative.y* explicitHeight,user.leftFoot.position.depthRelative.y* explicitHeight)) - (user.head.position.depthRelative.y* explicitHeight);
	//;
//	trace(user.rightElbow.position.rgb.x );
		
		
		
		var centi:Number = formula * 2.54 / 96;
		
		return centi*21;
	}
	public function render():void {
		graphics.clear();
		var numJoints:uint = user.skeletonJoints.length;
		
		
				
	//	trace(user.position.world.z)
		//create labels
		createLabelsIfNeeded();
		createCirclesIfNeeded();
		
		for (var i:int = 0; i < numJoints; i++) {
			var joint:SkeletonJoint = user.skeletonJoints[i];
			var label:Label = labels[i];
			var circle:Sprite = circles[i];
			
			//circle
		//	trace(joint.name + "   -------------------------------- " + joint.position.world.z);
			circle.x = joint.position.rgb.x;
			circle.y = joint.position.rgb.y;
			//label
			label.text = joint.name ;
			label.x = circle.x;
			label.y = circle.y;
		}
	}
}