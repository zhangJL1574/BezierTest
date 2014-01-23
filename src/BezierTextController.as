package
{
	import com.greensock.TimelineLite;
	import com.greensock.TweenLite;
	import com.greensock.TweenMax;
	import com.greensock.plugins.BezierPlugin;
	import com.greensock.plugins.BezierThroughPlugin;
	import com.greensock.plugins.TweenPlugin;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObjectContainer;
	import flash.display.Stage;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;

	public class BezierTextController
	{
		private static var _rectArray:Array = [];
		private static var _stage:Stage;
		private static var _rect:Rectangle;
		private static var _index:int = 0;
		private static var _queue:Array = [];
		public function BezierTextController()
		{
			super();
		}
		
		public static function initialize(obj:Stage):void{
			_stage = obj;
		}
		
		public static function setRectangle(obj:Rectangle):void{
			_rect = obj;
		}
		
		private static function randomPoint(width:Number, height:Number,content:String, _point:Point=null,  isBold:Boolean=false, color:uint=0xff3300, size:int=20):Point{
			var arr:Array = [];
			var objA:Rectangle;
			var objB:Rectangle;
			var obj:Object;
			var point:Point;
			arr.push(_rect);
			for each(obj in _rectArray) {
				var temp:Array = arr;
				arr = [];
				objB = obj.rect;
				for each(objA in temp) {
					if (isAContainB(objA, objB) == true) {
						pushRectangle(arr, objA.x,objA.y,objA.width,objB.y-objA.y);
						pushRectangle(arr, objA.x,objB.y,objB.x-objA.x,objB.height);
						pushRectangle(arr,objB.x+objB.width,objB.y,objA.width-objB.width-(objB.x-objA.x),objB.height);
						pushRectangle(arr, objA.x,objB.y+objB.height,objA.width,objA.height-objB.height-(objB.y-objA.y));
					}else {
						arr.push(objA);
					}
				}
			}
			
			var maxArea:Number = 0;
			var objC:Rectangle;
			for each(objA in arr) {
				if (objA.width >= width && objA.height >= height) {
					point = new Point(objA.x+Math.random()*(objA.width-width), objA.y+Math.random()*(objA.height-height));
					obj = {};
					obj.index = _index;
					obj.rect = new Rectangle(point.x, point.y, width, height);
					_rectArray.push(obj);
					return point;
				}
//				if (maxArea < objA.height*objA.width) {
//					maxArea = objA.height*objA.width;
//					objC = objA;
//				}
			}
//			if (objC) {
//				point = new Point(objC.x, objC.y+Math.random()*(objC.height-height));
//				obj = {};
//				obj.index = _index;
//				obj.rect = new Rectangle(point.x, point.y, width, height);
//				_rectArray.push(obj);
//			}else {
//				trace(width,height);
//				point = new Point(_rect.x+Math.random()*(_rect.width-width), _rect.y+Math.random()*(_rect.height-height));
//			}
//			point = new Point(_rect.x+Math.random()*(_rect.width-width), _rect.y+Math.random()*(_rect.height-height)); //没有位置放入队列
			_queue.push({"content":content,"point":_point,"isBold":isBold,"color":color,"size":size});
			trace("push:"+content);
			return point;
		}
		
		private static function pushRectangle(arr:Array, x:Number,y:Number,width:Number,height:Number):void{
			if (width > 0 && height > 0) {
				arr.push(new Rectangle(x,y,width,height));
			}
		}
		
		private static function isAContainB(a:Rectangle, b:Rectangle):Boolean{
			if (a.x <= b.x && a.y <= b.y && a.x+a.width >= b.x+b.width && a.y+a.height >= b.y+b.height) {
				return true;
			}
			return false;
		}
		
		private static function refreshQueue():void{
			if (_queue.length > 0) {
				var obj:Object = _queue.pop();
				trace("pop:"+obj.content);
				show(obj.content,obj.point,obj.isBold,obj.color,obj.size);
			}
		}
		
		private static function deleteRectByIndex(ind:int):void{
			var len:int = _rectArray.length;
			for (var i:int =len-1;i>=0;--i){
				if (_rectArray[i].index == ind) {
					_rectArray.splice(i,1);
					refreshQueue();
//					trace("delete "+ind);
					break;
				}
			}
		}
		
		public static function show(content:String, point:Point=null,  isBold:Boolean=false, color:uint=0xff3300, size:int=20):void{
			var _textField:TextField = new TextField();
			var _textFormat:TextFormat;
			var bitmapList:Array = [];
			var bitmapData:BitmapData;
			var bitmap:Bitmap;
			var recWidth:Number = 0;
			var i:int;
			_textFormat = new TextFormat();
			//_textFormat.font = FBEmbedFont.FONT_EMBED_BOLD_NAME;
			_textFormat.bold = isBold;
			_textFormat.size = size;
			_textFormat.color = color;
			_textField.defaultTextFormat = _textFormat;
			if (point == null) {
				_textField.text = content;
				point = randomPoint(_textField.textWidth,_textField.textHeight, content,point,isBold,color,size);
			}
			if (point == null) {
				return;
			}
			for (i = 0; i < content.length; ++i) {
				_textField.text = content.charAt(i);
				_textField.width = _textField.textWidth+5;
				_textField.height = _textField.textHeight+5;
				bitmapData = new BitmapData(_textField.width,_textField.height,true,0x0);
				bitmapData.draw(_textField);
				bitmap = new Bitmap(bitmapData);
				bitmap.y = point.y;
				bitmap.x = point.x + recWidth;
				bitmapList.push(bitmap);
				recWidth += _textField.textWidth;
			}
			var timeDelay:Number = 0;
			var timeline:TimelineLite = new TimelineLite;
			var tween:TweenMax;
//			timeline.canBeKilled = false;
			for (i = 0; i < bitmapList.length; ++i) {
				bitmap = bitmapList[i] as Bitmap;
				bitmap.alpha = 0;
				var fy:Number = bitmap.y;
				_stage.addChild(bitmap);
				var func:Function = function (flag:Boolean,ind:int):void{
					if (flag == true) {
						deleteRectByIndex(ind);
					}
				}
				timeline.insert(tween=TweenMax.to(bitmap, 0.5, {alpha:1,bezierThrough:[{x:bitmap.x, y:fy},{x:bitmap.x, y:fy-10},{x:bitmap.x, y:fy}],onComplete:func,onCompleteParams:[i==bitmapList.length-1,_index]}),timeDelay);
				tween.canBeKilled = false;
				timeDelay += 0.5/3;
			}
			timeDelay += 1;
			for (i = 0; i < bitmapList.length; ++i) {
				bitmap = bitmapList[i] as Bitmap;
				var compFunc:Function = function(_bitmap:Bitmap):void{
					_bitmap.bitmapData.dispose();
					_bitmap.bitmapData = null;
					_bitmap.parent.removeChild(_bitmap);
				};
				timeline.insert(tween=TweenMax.to(bitmap, 0.5, {alpha:0,x:Math.random()*100-50+bitmap.x,y:Math.random()*100-50+bitmap.y,onComplete:compFunc,onCompleteParams:[bitmap]}),timeDelay);
				tween.canBeKilled = false;
			}
			_index++;
		}
	}
}