// http://anymaking.com/fun-liquify-photo-maker-effects
package lab
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.Stage;
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
	
	/**
	 * ...
	 * @author ductri
	 */
	public class BrushLab extends Sprite
	{
		private var m_stage:Stage;
		
		private var m_targetImage:Bitmap; // l'image surlaquelle est appliquée le filtre (le damier)
		private var m_displaceMap:BitmapData; // la displacemap, sur laquelle est dessiné le pinceau
		private var m_blurredDisplaceMap:BitmapData; // la displacemap blurrée
		private var m_displacementMapFilter:DisplacementMapFilter; // le filtre, qui s'appuie sur la displacemap blurrée
		private var m_blurFilter:BlurFilter;
		
		private var m_brush:Bitmap;
		
		private var gui:MainGUI; // PANEL des commandes
		private var gradientView:Sprite; // PANEL des gradients
		
		[Embed(source="../assets/checker.jpg")]
		public var ImageClass:Class;
		[Embed(source="../assets/keira.jpg")]
		public var ImageClass1:Class;
		
		/**
		 *
		 * @param	_s
		 */
		public function BrushLab(_s:Stage)
		{
			m_stage = _s;
			
			gradientView = new Sprite();
			
			addChild(gradientView);
			gradientView.x = 0;
			gradientView.y = m_stage.stageHeight / 2;
			gui = new MainGUI(this, m_stage.stageWidth / 2, 0, m_stage.stageWidth / 2, m_stage.stageHeight / 2);
			gui.view = this;
			
			m_targetImage = new ImageClass1();
			m_stage.addEventListener(MouseEvent.MOUSE_DOWN, onImageMouseDown);
			addChild(m_targetImage);
			m_targetImage.x = m_targetImage.y = 0;
			m_targetImage.smoothing = true;
			
			m_displaceMap = new BitmapData(m_targetImage.width, m_targetImage.height, false, 0x808080);
			m_blurredDisplaceMap = m_displaceMap.clone();
			m_blurFilter = new BlurFilter(8, 8, BitmapFilterQuality.HIGH);
			
			
			const bm:Bitmap = new Bitmap(m_blurredDisplaceMap);
			bm.x = m_stage.stageWidth / 2
			bm.y = m_stage.stageHeight / 2;
			addChild(bm);
			
			m_displacementMapFilter = new DisplacementMapFilter(m_blurredDisplaceMap, new Point(), BitmapDataChannel.GREEN, BitmapDataChannel.BLUE, m_disScale, m_disScale, DisplacementMapFilterMode.IGNORE);
			
			//	smoothBMD.applyFilter(smoothBMD, smoothBMD.rect, new Point(), new BlurFilter(16, 16, BitmapFilterQuality.HIGH));
			//	DISPLACEMENT MAP ===================================================================
			//var disMapF:DisplacementMapFilter = 

			//m_targetImage.filters = [];
		}
		
		private function onImageMouseDown(e:MouseEvent):void
		{
			trace(e.target + "::" + e.stageX + " / " + e.stageY);
			if (e.stageX < m_targetImage.width && e.stageY < m_targetImage.height)
			{
				//setApplyPos(e.stageX - m_brushSize / 2, e.stageY - m_brushSize / 2);
				makeDisplacementBrush();
				m_brush.x = e.stageX - m_brushSize / 2;
				m_brush.y = e.stageY - m_brushSize / 2;
				applyMap();
			}
		}
		
		private function applyMap():void
		{
			var mat:Matrix = new Matrix();
			mat.translate(m_brush.x, m_brush.y);
			m_displaceMap.draw(m_brush,mat);
			m_blurredDisplaceMap.applyFilter(m_displaceMap, m_displaceMap.rect, new Point(), m_blurFilter);
			m_targetImage.filters = [m_displacementMapFilter];
		}
		
		private var m_disScale:Number = 50;
		private var m_targetX:Number = 20;
		private var m_targetY:Number = 20;
		private var m_brushSize:Number = 10;
		
		/**
		 * ████████████████████████████████████████████████████████████████████████████████████████
		 *
		 * @return
		 */
		private function makeDisplacementBrush():BitmapData
		{
			// GRADIENT VERTICAL ==================================================================
			var s1:Shape = createGradient(GradientType.LINEAR, m_brushSize, m_brushSize, [0x0000ff, 0], [1, 1], 90);
			var graVer:BitmapData = new BitmapData(m_brushSize, m_brushSize, false, 0x808080);
			graVer.draw(s1);
			
			// GRADIENT HORIZONTAL ================================================================
			var s2:Shape = createGradient(GradientType.LINEAR, m_brushSize, m_brushSize, [0x00ff00, 0], [1, 1]);
			var graHor:BitmapData = new BitmapData(m_brushSize, m_brushSize, false, 0x808080);
			graHor.draw(s2);
			
			// GRADIENT SMOOTH + MERGE DES DEUX GRADIENTS =========================================
			var gra3:Shape = createGradient(GradientType.RADIAL, m_brushSize, m_brushSize, [0, 0], [1, 0]);
			var brush:BitmapData = new BitmapData(m_brushSize, m_brushSize, true, 0xFFFFFF); 
			// false, 0x808080 pour une application immédiate / true, 0xFFFFFF pour un draw() plus tard
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
			
			
			
			return brush;
		}
		
		private function testDisplaceBrush2():DisplacementMapFilter
		{
			// GRADIENT VERTICAL ==================================================================
			var s1:Shape = createGradient(GradientType.LINEAR, m_brushSize, m_brushSize, [0x0000ff, 0], [1, 1], 90);
			var graVer:BitmapData = new BitmapData(s1.width, s1.height, false, 0x808080);
			graVer.draw(s1);
			
			// GRADIENT HORIZONTAL ================================================================
			var s2:Shape = createGradient(GradientType.LINEAR, m_brushSize, m_brushSize, [0x00ff00, 0], [1, 1]);
			var graHor:BitmapData = new BitmapData(s2.width, s2.height, false, 0x808080);
			graHor.draw(s2);
			
			// GRADIENT SMOOTH + MERGE DES DEUX GRADIENTS =========================================
			var gra3:Shape = createGradient(GradientType.RADIAL, m_brushSize, m_brushSize, [0, 0], [0.1, 0]);
			var smoothBMD:BitmapData = new BitmapData(m_brushSize, m_brushSize, false, 0x808080); // false 0x808080 IMPORTANT !!!
			smoothBMD.draw(gra3);
			smoothBMD.copyChannel(graVer, graVer.rect, new Point(), BitmapDataChannel.BLUE, BitmapDataChannel.BLUE);
			smoothBMD.copyChannel(graHor, graHor.rect, new Point(), BitmapDataChannel.GREEN, BitmapDataChannel.GREEN);
			smoothBMD.applyFilter(smoothBMD, smoothBMD.rect, new Point(), new BlurFilter(20, 20, BitmapFilterQuality.HIGH));
			
			// DISPLACEMENT MAP ===================================================================
			var disMapF:DisplacementMapFilter = new DisplacementMapFilter(smoothBMD, new Point(m_targetX, m_targetY), BitmapDataChannel.GREEN, BitmapDataChannel.BLUE, m_disScale, m_disScale, DisplacementMapFilterMode.IGNORE);
			
			// FOR DEBUG ==========================================================================
			gradientView.addChild(s1);
			s2.x = m_stage.stageWidth / 4;
			gradientView.addChild(s2);
			var dbgBM:Bitmap = new Bitmap(smoothBMD);
			dbgBM.x = 0;
			dbgBM.y = m_stage.stageHeight / 4;
			gradientView.addChild(dbgBM);
			
			return disMapF;
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
		
		/**
		 *
		 * @param	_s
		 */
		public function setDisplacementScale(_s:Number):void
		{
			while (gradientView.numChildren != 0)
				gradientView.removeChildAt(0);
			
			m_disScale = _s;
			makeDisplacementBrush();
		}
		
		/**
		 *
		 * @param	_s
		 */
		public function setDisplacementSize(_s:Number):void
		{
			while (gradientView.numChildren != 0)
				gradientView.removeChildAt(0);
			
			m_brushSize = _s;
			makeDisplacementBrush();
		}
		
		public function setApplyPos(_x:Number, _y:Number):void
		{
			while (gradientView.numChildren != 0)
				gradientView.removeChildAt(0);
			
			m_targetX = _x;
			m_targetY = _y;
			makeDisplacementBrush();
		}
		
		private function randomize(b:BitmapData):void
		{
			for (var w:int = 0; w < b.width; w++)
			{
				for (var h:int = 0; h < b.height; h++)
				{
					b.setPixel(w, h, Math.random() * 65536);
				}
			}
		}
		
		private function initDisplacementMap2():void
		{
			var bm:Bitmap = new ImageClass();
			var bmd:BitmapData = new BitmapData(bm.width, bm.height, true, 0x808080);
			
			var disMap:DisplacementMapFilter = new DisplacementMapFilter(bmd, new Point(0, 0), BitmapDataChannel.GREEN, BitmapDataChannel.BLUE, 0, 0, DisplacementMapFilterMode.IGNORE);
			
			this.addChild(bm);
			bm.filters = [disMap];
		}
	
	} // end class ================================================================================

} // end package ==================================================================================
