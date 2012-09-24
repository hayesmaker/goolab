// http://anymaking.com/fun-liquify-photo-maker-effects

// MetaTools Kia's Power Goo Realtime Liquid Image Funware Graphic Software

package lab
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.KeyboardEvent;
	import flash.filters.BlurFilter;
	import flash.filters.DisplacementMapFilter;
	import flash.geom.Matrix;
	import flash.display.GradientType;
	import flash.geom.Point;
	import flash.display.BitmapDataChannel;
	import flash.filters.DisplacementMapFilterMode;
	import flash.text.TextField;
	import com.bit101.components.ComboBox;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.filters.BitmapFilterQuality;
	import flash.ui.Keyboard;
	
	/**
	 * ...
	 * @author ductri
	 */
	public final class BrushManager extends Sprite
	{
		private static var m_stage:Stage;
		
		private var m_targetImage:Bitmap; // l'image surlaquelle est appliquée le filtre (le damier)
		private var m_displaceMap:BitmapData; // la displacemap, sur laquelle est dessiné le pinceau
		private var m_blurredDisplaceMap:BitmapData; // la displacemap blurrée
		private var m_displacementMapFilter:DisplacementMapFilter; // le filtre, qui s'appuie sur la displacemap blurrée
		private var m_blurFilter:BlurFilter;
		private var m_brush:Bitmap; // le pinceau
		private var m_cursor:Shape;
		
		private var mouse_pressed:Boolean;
		
		private static var mediator:GUIBrushMediator;
		
		//private var gui:GUIManager; // PANEL des commandes
		public var gradientView:Sprite; // PANEL des gradients
		
		[Embed(source="../assets/checker.jpg")]
		public var ImageClass:Class;
		[Embed(source="../assets/keira.jpg")]
		public var ImageClass1:Class;
		
		private static var instance:BrushManager;
		
		/**
		 *
		 * @param	_s
		 */
		public function BrushManager(s:SingletonEnforcer)
		{
			init();
		}
		
		public static function getInstance(_s:Stage):BrushManager
		{
			if (!instance)
			{
				m_stage = _s;
				
				instance = new BrushManager(new SingletonEnforcer());
			}
			return instance;
		}
		
		public static function setMediator(m:GUIBrushMediator):void
		{
			mediator = m;
		}
		
		private function init():void
		{
			//m_stage = _s;
			m_stage.addChild(this);
			
			gradientView = new Sprite();
			
			addChild(gradientView);
			gradientView.x = 0;
			gradientView.y = m_stage.stageHeight / 2;
			
			m_targetImage = new ImageClass1();
			m_stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			m_stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			m_stage.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
			m_stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			m_stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			
			//m_stage.addEventListener(MouseEvent.MIDDLE_MOUSE_DOWN, onMouseDown);
			//m_stage.addEventListener(MouseEvent.MIDDLE_MOUSE_UP, onMouseUp);
			addChild(m_targetImage);
			m_targetImage.x = m_targetImage.y = 0;
			m_targetImage.smoothing = true;
			
			m_displaceMap = new BitmapData(m_targetImage.width, m_targetImage.height, false, 0x808080);
			m_blurredDisplaceMap = m_displaceMap.clone();
			m_blurFilter = new BlurFilter(4, 4, BitmapFilterQuality.HIGH);
			
			const bm:Bitmap = new Bitmap(m_blurredDisplaceMap);
			bm.x = m_stage.stageWidth / 2
			bm.y = m_stage.stageHeight / 2;
			addChild(bm);
			
			m_displacementMapFilter = new DisplacementMapFilter(m_blurredDisplaceMap, new Point(), BitmapDataChannel.GREEN, BitmapDataChannel.BLUE, m_disScale, m_disScale, DisplacementMapFilterMode.WRAP);
			
			//	smoothBMD.applyFilter(smoothBMD, smoothBMD.rect, new Point(), new BlurFilter(16, 16, BitmapFilterQuality.HIGH));
			//	DISPLACEMENT MAP ===================================================================
			//var disMapF:DisplacementMapFilter = 
			
			//m_targetImage.filters = [];
			
			initObjects();
			
			mouse_pressed = false;
			m_stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			m_cursor = new Shape();
			m_stage.addChild(m_cursor);
			updateCursor();
			updateGooBrush();
		}
		
		private function onMouseMove(e:MouseEvent):void
		{
			m_cursor.x = m_stage.mouseX // - m_brushSize / 2;
			m_cursor.y = m_stage.mouseY // - m_brushSize / 2;
		}
		
		private function onEnterFrame(e:Event):void
		{
			if (mouse_pressed)
			{
				onMouseDown();
			}
		}
		
		private function onKeyDown(e:KeyboardEvent):void
		{
			if (e.ctrlKey)
			{
				
			}
			
			switch (e.keyCode)
			{
				case Keyboard.SPACE: 
					reverseBrush();
					break;
			}
		}
		
		public function fishEyeBrush():void
		{
			m_greenVec = [0x00ff00, 0];
			m_blueVec = [0x0000ff, 0];
			updateGooBrush();
		}

		public function shrinkBrush():void
		{
			m_greenVec = [0,0x00ff00];
			m_blueVec = [0, 0x0000ff];
			updateGooBrush();
		}
		
		public function eraseBrush():void
		{
			m_greenVec = [0x808080, 0x808080];
			m_blueVec = [0x808080, 0x808080];
			updateGooBrush();
		}

		public function moveBrush():void
		{
			//m_greenVec = [0,0x00ff00];
			//m_blueVec = [0, 0x0000ff];
			//updateGooBrush();
		}

		public function reverseBrush():void
		{
			m_greenVec.reverse();
			m_blueVec.reverse();
			updateGooBrush();
		}
		
		private function onMouseWheel(e:MouseEvent):void
		{
			m_brushSize += e.delta;
			if (m_brushSize < 1)
				m_brushSize = 1;
			else if (m_brushSize > 300)
				m_brushSize = 300;
			
			trace(e.delta + " / " + m_brushSize);
			updateCursor();
			updateGooBrush();
		}
		
		private function onMouseUp(e:MouseEvent):void
		{
			//trace(e.target + "::" + e.stageX + " / " + e.stageY);
			mouse_pressed = false;
		}
		
		private function onMouseDown(e:MouseEvent = null):void
		{
			//trace(e.target + "::" + e.stageX + " / " + e.stageY);
			mouse_pressed = true;
			if (m_stage.mouseX < m_targetImage.width && m_stage.mouseY < m_targetImage.height)
			{
				//setApplyPos(e.stageX - m_brushSize / 2, e.stageY - m_brushSize / 2);
				//makeDisplacementBrush();
				m_brush.x = m_stage.mouseX - m_brushSize / 2;
				m_brush.y = m_stage.mouseY - m_brushSize / 2;
				applyMap();
			}
		}
		
		private function applyMap():void
		{
			var mat:Matrix = new Matrix();
			mat.translate(m_brush.x, m_brush.y);
			m_displaceMap.draw(m_brush, mat);
			m_blurredDisplaceMap.applyFilter(m_displaceMap, m_displaceMap.rect, new Point(), m_blurFilter);
			m_targetImage.filters = [m_displacementMapFilter];
		}
		
		public var m_disScale:Number = 40; // scale in DisplacementMapFilter
		private var m_targetX:Number = 20;
		private var m_targetY:Number = 20;
		public var m_brushSize:Number = 10;
		private var m_greenVec:Array;
		private var m_blueVec:Array;
		
		private function initObjects():void
		{
			fishEyeBrush();
		}
		
		private function updateCursor():void
		{
			var g:Graphics = m_cursor.graphics;
			g.clear();
			//g.beginFill(0x808080, 0.5);
			g.lineStyle(1, 0xff00ff, 0.5);
			g.drawCircle(0, 0, m_brushSize / 2);
		/*
		   m_cursor.x = m_targetX;
		   m_cursor.y = m_targetY;
		 */
		}
		
		/**
		 * ████████████████████████████████████████████████████████████████████████████████████████
		 *
		 * @return
		 */
		public function updateGooBrush():BitmapData
		{
			
			// GRADIENT VERTICAL ==================================================================
			var s1:Shape = createGradient(GradientType.LINEAR, m_brushSize, m_brushSize, m_blueVec, [1, 1], 90);
			var graVer:BitmapData = new BitmapData(m_brushSize, m_brushSize, false, 0x808080);
			graVer.draw(s1);
			
			// GRADIENT HORIZONTAL ================================================================
			var s2:Shape = createGradient(GradientType.LINEAR, m_brushSize, m_brushSize, m_greenVec, [1, 1]);
			var graHor:BitmapData = new BitmapData(m_brushSize, m_brushSize, false, 0x808080);
			graHor.draw(s2);
			
			// GRADIENT SMOOTH + MERGE DES DEUX GRADIENTS =========================================
			var gra3:Shape = createGradient(GradientType.RADIAL, m_brushSize, m_brushSize, [0, 0], [1, 0]);
			var brush:BitmapData = new BitmapData(m_brushSize, m_brushSize, true, 0);
			// false et 0x808080 pour une application immédiate / true pour un draw() plus tard
			brush.draw(gra3);
			brush.copyChannel(graVer, graVer.rect, new Point(), BitmapDataChannel.BLUE, BitmapDataChannel.BLUE);
			brush.copyChannel(graHor, graHor.rect, new Point(), BitmapDataChannel.GREEN, BitmapDataChannel.GREEN);
			
			m_brush = new Bitmap(brush);
			
			// FOR DEBUG ==========================================================================
			while (gradientView.numChildren != 0)
				gradientView.removeChildAt(0);
			
			s1.y = s2.y = m_stage.stageHeight / 4;
			gradientView.addChild(s1);
			s2.x = m_stage.stageWidth / 4;
			gradientView.addChild(s2);
			//var dbgBM:Bitmap = new Bitmap(brush);
			//dbgBM.x = 0;
			//dbgBM.y = 0; // m_stage.stageHeight / 4;
			gradientView.addChild(m_brush);
			
			m_displacementMapFilter = 
//m_targetImage.filters.push // don't work
				(new DisplacementMapFilter(m_blurredDisplaceMap, new Point(), BitmapDataChannel.GREEN, BitmapDataChannel.BLUE, m_disScale, m_disScale, DisplacementMapFilterMode.IGNORE));
			
			return brush;
		}
		
		/**
		 *
		 * @param	_type
		 * @param	_w
		 * @param	_h
		 * @param	_angle
		 * @param	_colors
		 * @param	_alphas
		 * @param	_ratios
		 * @return
		 */
		private function createGradient(_type:String, _w:uint, _h:uint, _colors:Array, _alphas:Array, _angle:Number = 0):Shape
		{
			var sh:Shape = new Shape();
			var mat:Matrix = new Matrix();
			mat.createGradientBox(_w, _h, _angle * (Math.PI / 180));
			var graph:Graphics = sh.graphics;
			graph.beginGradientFill(_type, _colors, _alphas, [0, 255], mat);
			graph.drawCircle(_w / 2, _h / 2, _w / 2);
			graph.endFill();
			
			return sh;
		}
		
		public function setApplyPos(_x:Number, _y:Number):void
		{
			while (gradientView.numChildren != 0)
				gradientView.removeChildAt(0);
			
			m_targetX = _x;
			m_targetY = _y;
			updateGooBrush();
		}
	
	/*
	   private function initDisplacementMap_OBSOLETE():void
	   {
	   var bm:Bitmap = new ImageClass();
	   var bmd:BitmapData = new BitmapData(bm.width, bm.height, true, 0x808080);
	
	   var disMap:DisplacementMapFilter = new DisplacementMapFilter(bmd, new Point(0, 0), BitmapDataChannel.GREEN, BitmapDataChannel.BLUE, 0, 0, DisplacementMapFilterMode.IGNORE);
	
	   this.addChild(bm);
	   bm.filters = [disMap];
	   }
	 */
	
	} // end class ================================================================================

} // end package ==================================================================================

internal class SingletonEnforcer
{
}