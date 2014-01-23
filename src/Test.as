package
{
	import com.greensock.TweenMax;
	
	import flash.display.GradientType;
	import flash.display.SpreadMethod;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
//////////////1111111111111
	[SWF(width="1000",height="600",frameRate="25")]
	public class Test extends Sprite
	{
		private var sprite1:Sprite;
		private var sprite2:Sprite;
		private var timer:Timer;
		public function Test()
		{
			this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			this.timer = new Timer(50);
			
		}
		
		private function clickHandler(evt:MouseEvent):void{
			TweenMax.killAll();	
		}
		
		private function onAddedToStage(evt:Event):void{
			this.stage.addEventListener(MouseEvent.CLICK, clickHandler);
			this.graphics.beginFill(0x00ff00, 0.5);
			this.graphics.drawRect(0,0,1000,600);
			this.graphics.endFill();
			BezierTextController.initialize(this.stage);
			BezierTextController.setRectangle(new Rectangle(0,0,1000,600));
			timer.addEventListener(TimerEvent.TIMER, onTimer);
			timer.start();
		}
		
		private function onTimer(evt:TimerEvent):void{
			var len:int = Math.random()*40;
			var str:String = "";
			for (var i:int =0; i < len; ++i) {
				str += String.fromCharCode(65+Math.random()*57);
			}
			BezierTextController.show(str);
		}
	}
}