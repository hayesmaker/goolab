package liquify
{
	import flash.display.Bitmap;
	import flash.display.DisplayObjectContainer;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.KeyboardEvent;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
	import flash.display.GradientType;
	import flash.display.SpreadMethod;
	import flash.display.Sprite;
	import flash.filters.BitmapFilter;
	import flash.filters.DisplacementMapFilter;
	import flash.filters.DisplacementMapFilterMode;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	
	/**
	 * ...
	 * @author Duc-Tri VU
	 */
	public class TestLiquify extends Sprite
	{
		[Embed(source="../bitmaps/checker.jpg")]
		private var Picture:Class;
		private var picture:Bitmap = new Picture();
		private var gBrush:MyLiquifyBrush = new MyLiquifyBrush();
		
		public function TestLiquify(st:Stage)
		{
			var myLiquifyManager:MyLiquifyManager = new MyLiquifyManager();
			myLiquifyManager.initLiquify(st, picture.bitmapData);
			addChild(myLiquifyManager);
			
			//size = gBrush.cRadius * 2;
			//gBrush.x = 400;
			//gBrush.y = 400;
			//
			//new Goofie();
			//stage.addChild(this);
			//createFilter();
			//addChild(picture);
			//addChild(gBrush);
			//addEventListener(MouseEvent.MOUSE_MOVE, moveFilter);
			//st.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			
		}
		
		public function moveFilter(e:MouseEvent):void
		{
			if (picture.hitTestPoint(e.stageX, e.stageY))
			{
				createFilter(e.stageX - size * 0.5, e.stageY - size * 0.5);
					//trace(e.stageX, e.stageY);
			}
		}
		
		private var size:uint = 100; // size of square brush
		
		/**
		 * Crée le filtre
		 * @return
		 */
		private function createFilter(x:int = 0, y:int = 0):void
		{
			var mapBitmap:BitmapData = new BitmapData(size, size);
			var mat:Matrix = new Matrix();
			mat.translate(size * 0.5, size * 0.5);
			mapBitmap.draw(gBrush, mat);
			//mapBitmap = createBrush();
			
			
			var mapPoint:Point = new Point(x, y);
			
			var componentX:uint = BitmapDataChannel.RED;
			var componentY:uint = BitmapDataChannel.RED;
			// BitmapDataChannel.ALPHA BitmapDataChannel.BLUE BitmapDataChannel.GREEN BitmapDataChannel.RED
			
			var scaleX:Number = 50; // 0.5;
			//var scaleY:Number = 10; // -30;
			
			var mode:String = DisplacementMapFilterMode.IGNORE;
			
			var color:uint = 0xff0000; // uniquement pour DisplacementMapFilterMode.COLOR
			var alpha:Number = 1; // uniquement pour DisplacementMapFilterMode.COLOR
			
			var dmf1:DisplacementMapFilter = new DisplacementMapFilter(mapBitmap, mapPoint, componentX, componentY, scaleX, scaleY, mode, color, alpha);
			
			var dmf2:DisplacementMapFilter = new DisplacementMapFilter(mapBitmap, mapPoint, BitmapDataChannel.GREEN, BitmapDataChannel.BLUE, scaleX, scaleX, "clamp");
			
			picture.filters = [dmf2];
		}
		
		/**
		 *
		 * @return
		 */
		private function createBrush():BitmapData
		{
			var matrix:Matrix = new Matrix();
			var brush:Shape = new Shape();
			var bitmapData:BitmapData = new BitmapData(size, size, false, 0x7F7F7F);
			
			matrix.createGradientBox(size, size);
			brush.graphics.beginGradientFill(GradientType.RADIAL, [0xFF0000, 0x7F7F7F], [1, 1], [55, 200], matrix, SpreadMethod.PAD);
			matrix = null;
			brush.graphics.drawRect(0, 0, size, size);
			bitmapData.draw(brush, new Matrix());
			
			// affiche le brush, pour debug____________________________________
			//var bitmap:Bitmap = new Bitmap(bitmapData);
			//bitmap.x = 500;
			//addChild(bitmap);
			
			return bitmapData;
		}
		
		private function onKeyDown(e:KeyboardEvent):void
		{
			//trace("key down " + e.keyCode);
			
			switch (e.keyCode)
			{
				case Keyboard.NUMPAD_ADD: 
					gBrush.setRadius(gBrush.cRadius + 2);
					size = gBrush.cRadius;
					createFilter(mouseX - size * 0.5, mouseY - size * 0.5);
					
					break;
				case Keyboard.NUMPAD_SUBTRACT: 
					gBrush.setRadius(gBrush.cRadius - 2);
					size = gBrush.cRadius;
					createFilter(mouseX - size * 0.5, mouseY - size * 0.5);
					break;
				case Keyboard.W: 
					gBrush.setBrush("move");
					break;
				case Keyboard.X: 
					gBrush.setBrush("min");
					break;
				case Keyboard.C: 
					gBrush.setBrush("max");
					break;
				case Keyboard.V: 
					gBrush.setBrush("erase");
					break;
				default: 
					trace("No comprendo ! "+e.keyCode);
					break;
			}
		}
	
	} // end class ================================================================================

} // end package ██████████████████████████████████████████████████████████████████████████████████