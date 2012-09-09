// http://anymaking.com/fun-liquify-photo-maker-effects

package liquify
{
	//import fl.controls.*;
	//import fl.events.*;
	import flash.display.*;
	import flash.events.*;
	import flash.filters.*;
	import flash.geom.*;
	import flash.net.*;
	import flash.text.*;
	import flash.ui.*;
	
	public class MyLiquifyManager extends MovieClip
	{
		private var rect:Rectangle;
		private var bmpMap:Bitmap;
		private var origMap:Bitmap;
		private var displacementMap:BitmapData;
		
		private var blurredDisplaceMap:BitmapData;
		private var blDisMapBm:Bitmap;
		private var blurFilter:BlurFilter;
		
		private var dispMapF:DisplacementMapFilter;
		
		private var tmp:Object;
		private var mapHolder:MovieClip;
		private var goofie_go:Boolean = false;
		private var mousePos:Point;
		private var goofie_mode:String = "move";
		private var is_map:Boolean = false;
		//private var cursor:gCursor;
		private var myLiquifyBrush:MyLiquifyBrush;
		private var currentImg:Sprite;
		private var mouse_pressed:Boolean = false;
		//private var gui:gGui;
		private var workingArea:Array;
		private var slCursor:Object;
		private var file_loaded:Boolean = false;
		private var ctrlPressed:Boolean = false;
		private var shiftPressed:Boolean = false;
		private var flashVars:Object;
		private var flashVarsLoaded:Boolean = false;
		private var image:Bitmap;
		private var stageLink:Stage;
		private var yOffset:Number = 54;
		private var originalImage:BitmapData;
		private var firstTime:Boolean = true;
		
		/**
		 * constructor
		 * ========================================================================================
		 */
		public function MyLiquifyManager()
		{
			trace("=== MyLiquifyManager");
			this.mousePos = new Point();
			//this.cursor = new gCursor();
			this.myLiquifyBrush = new MyLiquifyBrush();
			this.currentImg = new Sprite();
			this.slCursor = new Object();
			this.flashVars = new Object();
			this.currentImg.name = "curImage";
		} // end function
		
		/**
		 * Init variables, launch liquify engine
		 * ========================================================================================
		 * @param	st
		 * @param	image
		 * @param	yoff
		 */
		public function initLiquify(st:Stage, image:BitmapData, yoff:Number = 0):void // 54
		{
			trace("=== initLiquify");
			this.stageLink = st;
			if (!this.firstTime)
			{
				this.resetAll();
			}
			this.originalImage = image;
			this.yOffset = yoff;
			this.tmp = {oldx: 0, oldy: 0};
			this.workingArea = [0, 0, image.width, image.height];
			addChild(this.currentImg);
			this.stageLink.addEventListener(MouseEvent.MOUSE_DOWN, this.mouseDownListener);
			this.stageLink.addEventListener(MouseEvent.MOUSE_UP, this.mouseUpListener);
			this.stageLink.addEventListener(MouseEvent.MOUSE_MOVE, this.mouseMoveListener);
			this.stageLink.addEventListener(KeyboardEvent.KEY_DOWN, this.onKeyDown);
			this.stageLink.addEventListener(KeyboardEvent.KEY_UP, this.onKeyUp);
			this.stageLink.addEventListener(Event.ENTER_FRAME, this.applyMapListener);
			this.stageLink.addEventListener(Event.MOUSE_LEAVE, this.mouseLeaveListener);
			this.LoadFinalImg();
			this.firstTime = false;
		} // end function
		
		/**
		 * Everything is done by keyboard !!!
		 * ========================================================================================
		 * @param	event
		 */
		private function onKeyDown(event:KeyboardEvent):void
		{
			trace("=== onKeyDown");
			
			switch (event.keyCode)
			{
				case Keyboard.ESCAPE: 
				{
					this.clearLiquify();
					break;
				}
				case Keyboard.BACKSPACE: 
				{
					break;
				}
				case Keyboard.CONTROL: 
				{
					this.ctrlPressed = true;
					break;
				}
				case Keyboard.SHIFT: 
				{
					this.shiftPressed = true;
					break;
				}
				case Keyboard.W: 
				{
					this.goofie_mode = "move";
					break;
				}
				case Keyboard.X: 
				{
					this.goofie_mode = "max";
					break;
				}
				case Keyboard.C: 
				{
					this.goofie_mode = "min";
					break;
				}
				case Keyboard.V: 
				{
					this.goofie_mode = "erase";
					break;
				}
				case Keyboard.NUMPAD_ADD: 
				{
					//this.chngeGrushSize(this.cursor.cRadius + 15);
					break;
				}
				case Keyboard.NUMPAD_SUBTRACT: 
				{
					//this.chngeGrushSize(this.cursor.cRadius - 15);
					break;
				}
				default: 
				{
					trace("No comprendo ! " + event.keyCode);
					break;
				}
			}
			this.myLiquifyBrush.setBrush(this.goofie_mode);
		} // end function
		
		/**
		 * Reset listeners
		 * ========================================================================================
		 */
		public function resetAll():void
		{
			trace("=== resetAll");
			
			this.stageLink.removeEventListener(MouseEvent.MOUSE_DOWN, this.mouseDownListener);
			this.stageLink.removeEventListener(MouseEvent.MOUSE_UP, this.mouseUpListener);
			this.stageLink.removeEventListener(MouseEvent.MOUSE_MOVE, this.mouseMoveListener);
			this.stageLink.removeEventListener(KeyboardEvent.KEY_DOWN, this.onKeyDown);
			this.stageLink.removeEventListener(KeyboardEvent.KEY_UP, this.onKeyUp);
			this.stageLink.removeEventListener(Event.ENTER_FRAME, this.applyMapListener);
			this.stageLink.removeEventListener(Event.MOUSE_LEAVE, this.mouseLeaveListener);
			this.currentImg.parent.removeChild(this.currentImg);
			this.goofie_mode = "move";
		} // end function
		
		/**
		 * ========================================================================================
		 */
		private function initBrush():void
		{
			trace("=== initBrush");
			
			this.myLiquifyBrush.visible = false;
			this.myLiquifyBrush.mouseEnabled = false;
			this.myLiquifyBrush.setRadius(120);
			//this.cursor.setRadius(120);
			//this.cursor.hide();
			//addChild(this.cursor);
			addChild(this.myLiquifyBrush);
		} // end function
		
		/**
		 *
		 * ========================================================================================
		 * @param	param1
		 * @param	param2
		 * @param	param3
		 * @return
		 */
		public function resize(bmdOrig:BitmapData, targetSize:Number, param3:Number = 0):BitmapData
		{
			trace("=== resize");
			
			if (bmdOrig.width == targetSize)
			{
				return bmdOrig.clone();
			}
			var _loc_4:Number = targetSize / bmdOrig.width;
			var _loc_5:Number = targetSize / bmdOrig.width;
			if (param3 == 0)
			{
				param3 = Math.round(bmdOrig.height * _loc_4);
			}
			else
			{
				_loc_5 = param3 / bmdOrig.height;
			}
			var bmdResized:BitmapData = new BitmapData(targetSize, param3, true, 0);
			var mat:Matrix = new Matrix();
			mat.scale(_loc_4, _loc_5);
			bmdResized.draw(bmdOrig, mat, null, null, null, true);
			
			return bmdResized;
		} // end function
		
		/**
		 *
		 * ========================================================================================
		 * @param	event
		 */
		private function mouseDownListener(event:MouseEvent):void
		{
			trace("=== mouseDownListener");
			
			this.mouse_pressed = true;
			if (event.target == this.currentImg)
			{
				this.goofie_go = true;
				this.tmp = {oldx: event.localX, oldy: event.localY};
			}
			else
			{
				this.tmp = {oldx: 0, oldy: 0};
			}
			//this.cursor.setAlpha(0.4);
		} // end function
		
		/**
		 *
		 * ========================================================================================
		 * @param	event
		 */
		private function mouseUpListener(event:MouseEvent):void
		{
			trace("=== mouseUpListener");
			
			this.mouse_pressed = false;
			this.goofie_go = false;
			//this.cursor.setAlpha(1);
		} // end function
		
		/**
		 *
		 * ========================================================================================
		 * @param	event
		 */
		private function mouseLeaveListener(event:Event):void
		{
			trace("=== mouseLeaveListener");
			
			Mouse.show();
			//this.cursor.hide();
		} // end function
		
		/**
		 *
		 * ========================================================================================
		 * @param	event
		 */
		private function mouseMoveListener(event:MouseEvent):void
		{
			//trace("=== mouseMoveListener");
			
			if (event.target.name != "curImage" && event.target.name != "bgLiq") // bgLiq ???
			{
				Mouse.show();
				//this.cursor.hide();
				return;
			}
			if (!this.file_loaded)
			{
				return;
			}
			if (event.stageX >= this.workingArea[0] && event.stageX <= this.workingArea[0] + this.workingArea[2] && (event.stageY >= this.workingArea[1] + this.yOffset && event.stageY <= this.workingArea[1] + this.workingArea[3]))
			{
				//Mouse.hide();
				//this.cursor.show();	
			}
			else
			{
				Mouse.show();
					//this.cursor.hide();
			}
			if (event.target != this.currentImg && this.mouse_pressed)
			{
				this.goofie_go = false;
			}
			if (event.target == this.currentImg && this.mouse_pressed)
			{
				this.goofie_go = true;
			}
			this.mousePos.x = event.localX;
			this.mousePos.y = event.localY;
			if (this.goofie_go)
			{
				this.applyBrush(this.mousePos);
			}
			this.myLiquifyBrush.x = event.stageX;
			this.myLiquifyBrush.y = event.stageY;
			//this.cursor.x = event.stageX;
			//this.cursor.y = event.stageY - this.yOffset;
			event.updateAfterEvent();
		} // end function
		
		/**
		 * ========================================================================================
		 * @param	size
		 */
		private function changeBrushSize(size:Number):void
		{
			trace("=== changeBrushSize");
			
			size = size < 20 ? (20) : (size);
			size = size > 300 ? (300) : (size);
			//this.cursor.setRadius(param1);
			this.myLiquifyBrush.setRadius(size);
		} // end function
		
		/**
		 * ========================================================================================
		 * @param	event
		 */
		private function applyMapListener(event:Event):void
		{
			//trace("=== applyMapListener");
			
			if (this.goofie_go)
			{
				this.applyBrush(this.mousePos);
			}
			if (this.file_loaded)
			{
				this.origMap.visible = (this.ctrlPressed);
				this.blDisMapBm.visible = (this.shiftPressed);
			}
		
		} // end function
		
		/**
		 * ========================================================================================
		 * @param	pos
		 */
		public function applyBrush(pos:Point):void
		{
			trace("=== applyBrush");
			
			switch (this.goofie_mode)
			{
				case "move": 
				{
					this.goofyMoveBrush(pos);
					break;
				}
				case "erase": 
				case "max": 
				case "min": 
				{
					this.goofyBrush(pos);
					break;
				}
				default: 
				{
					break;
				}
			}
		} // end function
		
		/**
		 * ========================================================================================
		 * @param	pos
		 */
		private function goofyMoveBrush(pos:Point):void
		{
			trace("=== goofyMoveBrush");
			
			this.tmp.oldx = this.tmp.oldx == 0 ? (pos.x) : (this.tmp.oldx);
			this.tmp.oldy = this.tmp.oldy == 0 ? (pos.y) : (this.tmp.oldy);
			var _loc_2:* = pos.x - this.tmp.oldx;
			var _loc_3:* = pos.y - this.tmp.oldy;
			this.tmp = {oldx: pos.x, oldy: pos.y};
			this.myLiquifyBrush.setPoint(pos);
			var _loc_4:* = 128 + Math.min(121, Math.max(-128, (-_loc_2) * 2));
			var _loc_5:* = 128 + Math.min(121, Math.max(-128, (-_loc_3) * 2));
			var _loc_6:* = new ColorTransform(0, 0, 0, 1, 128, _loc_4, _loc_5, 0);
			this.displacementMap.draw(this.myLiquifyBrush, this.myLiquifyBrush.transform.matrix, _loc_6, "hardlight");
			this.applyMap();
		} // end function
		
		/**
		 * ========================================================================================
		 * @param	pos
		 */
		private function goofyBrush(pos:Point):void
		{
			trace("=== goofyBrush");
			
			this.tmp = {oldx: pos.x, oldy: pos.y};
			this.myLiquifyBrush.setPoint(pos);
			this.displacementMap.draw(this.myLiquifyBrush, this.myLiquifyBrush.transform.matrix);
			this.applyMap();
		} // end function
		
		/**
		 * ========================================================================================
		 */
		private function clearLiquify():void
		{
			trace("=== clearLiquify");
			this.displacementMap.fillRect(this.rect, 0x808080); // gris moyen => aucun displacement
			this.blurredDisplaceMap.fillRect(this.rect, 0x808080); // gris moyen => aucun displacement
			this.applyMap();
		} // end function
		
		/**
		 * ========================================================================================
		 */
		private function applyMap():void
		{
			trace("=== applyMap");
			
			this.blurredDisplaceMap.applyFilter(this.displacementMap, this.rect, new Point(0, 0), this.blurFilter);
			this.currentImg.filters = [this.dispMapF];
		} // end function
		
		/**
		 * ========================================================================================
		 */
		private function clearListener(event:MouseEvent):void
		{
			trace("=== clearListener");
			
			this.clearLiquify();
		} // end function
		
		/**
		 * ========================================================================================
		 */
		private function showMapListener(event:MouseEvent):void
		{
			trace("=== showMapListener");
			
			this.showMap();
		} // end function
		
		/**
		 * ========================================================================================
		 */
		private function showMap():void
		{
			trace("=== showMap");
			
			if (this.is_map)
			{
				removeChild(this.bmpMap);
				this.is_map = false;
			}
			else
			{
				this.bmpMap = new Bitmap(this.displacementMap);
				this.bmpMap.x = this.currentImg.x;
				this.bmpMap.name = "mMap";
				this.bmpMap.y = this.currentImg.y;
				this.bmpMap.width = this.bmpMap.width;
				this.bmpMap.height = this.bmpMap.height;
				addChild(this.bmpMap);
				this.is_map = true;
			}
		} // end function
		
		/**
		 * ========================================================================================
		 * @param	event
		 */
		private function onKeyUp(event:KeyboardEvent):void
		{
			trace("=== onKeyUp");
			
			if (event.keyCode == Keyboard.CONTROL)
			{
				this.ctrlPressed = false;
			}
			if (event.keyCode == Keyboard.SHIFT)
			{
				this.shiftPressed = false;
			}
		} // end function
		
		/**
		 * ========================================================================================
		 * @param	param1
		 */
		private function LoadFinalImg(param1:Object = null):void
		{
			trace("=== LoadFinalImg");
			
			var _width:Number = NaN;
			var _height:Number = NaN;
			this.image = new Bitmap(this.originalImage);
			var _loc_4:Number = 8;
			var _loc_5:Rectangle = asUtilsGetSize(new Rectangle(this.workingArea[0], this.workingArea[1], this.workingArea[2] - 20, this.workingArea[3] - 20), new Rectangle(0, 0, this.image.width, this.image.height));
			_width = Math.floor(_loc_5.width);
			_height = Math.floor(_loc_5.height);
			this.image.smoothing = true;
			this.image.width = _width;
			this.image.height = _height;
			this.currentImg.x = Math.floor(this.workingArea[0] + this.workingArea[2] / 2 - this.image.width / 2);
			this.currentImg.y = this.workingArea[1] + Math.floor(this.workingArea[3] / 2) - Math.floor(this.image.height / 2);
			if (this.currentImg.numChildren)
			{
				this.currentImg.removeChildAt(0);
			}
			this.currentImg.addChild(this.image);
			this.origMap = new Bitmap(this.image.bitmapData.clone());
			this.origMap.smoothing = true;
			this.origMap.x = this.currentImg.x;
			this.origMap.y = this.currentImg.y;
			this.origMap.width = this.image.width;
			this.origMap.height = this.image.height;
			this.origMap.visible = false;
			addChild(this.origMap);
			
			this.rect = new Rectangle(0, 0, Math.floor(this.image.width), Math.floor(this.image.height));
			this.displacementMap = new BitmapData(this.rect.width, this.rect.height, false, 0x808080);
			this.blurredDisplaceMap = this.displacementMap.clone();
			this.blurFilter = new BlurFilter(8, 8, 3);
			this.dispMapF = new DisplacementMapFilter(this.blurredDisplaceMap, new Point(0, 0), 2, 4, 70, 70, DisplacementMapFilterMode.IGNORE);
			this.displacementMap.fillRect(this.rect, 0x808080);
			this.blurredDisplaceMap.fillRect(this.rect, 0x808080);
			this.applyMap();
			this.initBrush();
			this.file_loaded = true;
			blDisMapBm = new Bitmap(blurredDisplaceMap)
			this.blDisMapBm.visible = false;
			addChild(this.blDisMapBm);
		
		} // end function	 
		
		/**
		 * ========================================================================================
		 * @param	param1
		 * @param	param2
		 * @return
		 */
		public static function asUtilsGetSize(param1:Rectangle, param2:Rectangle):Rectangle
		{
			trace("=== asUtilsGetSize");
			
			var _loc_5:Number = NaN;
			var _loc_3:Number = 0;
			var _loc_4:Number = 0;
			if (param2.height > param1.height)
			{
				_loc_4 = param1.height;
				_loc_5 = param2.height / param1.height;
				_loc_3 = Math.floor(param2.width / _loc_5);
				if (_loc_3 > param1.width)
				{
					_loc_3 = param1.width;
					_loc_5 = param2.width / _loc_3;
					_loc_4 = Math.floor(param2.height / _loc_5);
				}
			}
			else if (param2.width > param1.width)
			{
				_loc_3 = param1.width;
				_loc_5 = param2.width / param1.width;
				_loc_4 = Math.floor(param2.height / _loc_5);
				if (_loc_4 > param1.height)
				{
					_loc_4 = param1.height;
					_loc_5 = param2.height / _loc_4;
					_loc_3 = Math.floor(param2.width / _loc_5);
				}
			}
			else
			{
				_loc_4 = param2.height;
				_loc_3 = param2.width;
			}
			return new Rectangle(0, 0, Math.floor(_loc_3), Math.floor(_loc_4));
		} // end function		
		
		/**
		 * ========================================================================================
		 */ /*
		   private function _saveImage():void
		   {
		   var bmd:BitmapData = new BitmapData(this.currentImg.width, this.currentImg.height, true, 0);
		   bmd.draw(this.currentImg); // et ensuite ???????
		   } // end function
		 */
		
		/*
		   private function cursorSliderListener(event:SliderEvent) : void
		   {
		   var _loc_2:* = event.target.value;
		   this.cursor.setRadius(_loc_2);
		   this.mBrush.setRadius(_loc_2);
		   this.cursor.show();
		   this.cursor.x = this.workingArea[0] + Math.floor(this.workingArea[2] / 2);
		   this.cursor.y = this.workingArea[1] + Math.floor(this.workingArea[3] / 2);
		   }// end function
		 */
		
		/**
		 * ========================================================================================
		 * @return
		 */
		public function getImageData_OBSOLETE():BitmapData
		{
			var scale:Number = Math.round(70 * (this.originalImage.width / this.blurredDisplaceMap.width));
			var bmd:BitmapData = this.originalImage.clone();
			var dmf:DisplacementMapFilter = new DisplacementMapFilter(this.resize(this.blurredDisplaceMap, this.originalImage.width), new Point(0, 0), 2, 4, scale, scale, DisplacementMapFilterMode.IGNORE);
			bmd.applyFilter(bmd, bmd.rect, new Point(), dmf);
			
			trace("=== getImageData " + scale);
			
			return bmd;
		} // end function
	
	} // end class ================================================================================

} // end package ==================================================================================
