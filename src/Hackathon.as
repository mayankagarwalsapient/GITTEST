package
{
	import com.as3nui.nativeExtensions.air.kinect.examples.cameras.RGBCameraDemo;
	import com.as3nui.nativeExtensions.air.kinect.examples.skeleton.SkeletonJointsDemo;
	import com.trackbody.BodyTracking;
	
	import flash.display.MovieClip;
	import flash.display.Screen;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	[SWF(frameRate="60", backgroundColor="#FFFFFF")]
	public class Hackathon extends Sprite
	{
		private var rgbPreview:RGBCameraDemo;
		private var sketon:SkeletonJointsDemo;
		private var bodytracking:BodyTracking;
		
		
		
		public function Hackathon()
		{
			
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			stage.nativeWindow.bounds = new Rectangle((Screen.mainScreen.bounds.width - 1024) * .5, (Screen.mainScreen.bounds.height - 600) * .5, 1024, 600);
			stage.nativeWindow.visible = true;
			//rgbPreview = new RGBCameraDemo();
			//sketon = new SkeletonJointsDemo();
		//	addChild(sketon);
			//addChild(rgbPreview);
			//stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
		
			bodytracking = new BodyTracking();
			addChild(bodytracking);
			
			
		}
	}
}