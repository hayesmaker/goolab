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
		
		private var gui:MainGUI; // PANEL des commandes
		private var targetImage:Bitmap; // PANEL de l'image (le damier)
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
			
			targetImage = new ImageClass1();
			addChild(targetImage);
			targetImage.x = targetImage.y = 0;
			
			targetImage.filters = [buildDisplacementFilter()];
		}
		
		
		
		
		
		private var m_disScale:Number = 10;
		private var m_targetX:Number = 20;
		private var m_targetY:Number = 20;
		private var m_size:Number = 10;
		
		/**
		 * ████████████████████████████████████████████████████████████████████████████████████████
		 * 
		 * @return
		 */
		private function buildDisplacementFilter():DisplacementMapFilter
		{
			// GRADIENT VERTICAL ==================================================================
			var s1:Shape = createGradient(GradientType.LINEAR,m_size, m_size, 90, [0x0000ff, 0], [1, 1], [0, 255]);
			var graVer:BitmapData = new BitmapData(s1.width, s1.height,false,0x808080);
			graVer.draw(s1);
			
			// GRADIENT HORIZONTAL ================================================================
			var s2:Shape = createGradient(GradientType.LINEAR,m_size, m_size, 0, [0x00ff00, 0], [1, 1], [0, 255]);
			var graHor:BitmapData = new BitmapData(s2.width, s2.height,false,0x808080);
			graHor.draw(s2);
			
			// GRADIENT SMOOTH + MERGE DES DEUX GRADIENTS =========================================
			var gra3:Shape = createGradient(GradientType.RADIAL, m_size, m_size, 0, [0, 0], [0.5, 0], [0, 255]);
			var smoothBMD:BitmapData = new BitmapData(m_size, m_size, true,0xff808080); // false 0x808080 IMPORTANT !!!
			smoothBMD.draw(gra3);
			var smoothBM:Bitmap = new Bitmap(smoothBMD);
			smoothBMD.copyChannel(graVer, graVer.rect, new Point(), BitmapDataChannel.BLUE, BitmapDataChannel.BLUE);
			smoothBMD.copyChannel(graHor, graHor.rect, new Point(), BitmapDataChannel.GREEN, BitmapDataChannel.GREEN);
			
			/////////////////////////////
			//randomize(bmd);
			var blf:BlurFilter = new BlurFilter(4,4 ,BitmapFilterQuality.HIGH);
			smoothBMD.applyFilter(smoothBMD, smoothBMD.rect, new Point(), blf);
			
			// DISPLACEMENT MAP ===================================================================
			var disMapF:DisplacementMapFilter = new DisplacementMapFilter(smoothBMD, new Point(m_targetX, m_targetY), 
			BitmapDataChannel.GREEN, BitmapDataChannel.BLUE, m_disScale, m_disScale, DisplacementMapFilterMode.IGNORE);			
			
			
			// FOR DEBUG ==========================================================================
			s2.x = m_stage.stageWidth / 4;
			smoothBM.x = 0;
			smoothBM.y = m_stage.stageHeight / 4;
			gradientView.addChild(s1);
			gradientView.addChild(s2);
			gradientView.addChild(smoothBM);
			
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
		private function createGradient(_type:String, _w:uint, _h:uint, _angle:Number, _colors:Array, _alphas:Array, _ratios:Array):Shape
		{
			var sh:Shape = new Shape();
			var mat:Matrix = new Matrix();
			mat.createGradientBox(_w, _h, _angle * (Math.PI / 180));
			var graph:Graphics = sh.graphics;
			graph.beginGradientFill(_type, _colors, _alphas, _ratios, mat);
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
			m_disScale = _s;
			targetImage.filters = [buildDisplacementFilter()];
		}

		
		/**
		 * 
		 * @param	_s
		 */
		public function setDisplacementSize(_s:Number):void
		{
			while (gradientView.numChildren != 0)
				gradientView.removeChildAt(0);
				
			m_size = _s;
			targetImage.filters = [buildDisplacementFilter()];
		}

		
		public function setApplyPos(_x:Number, _y:Number):void
		{
			m_targetX = _x;
			m_targetY = _y;
			targetImage.filters = [buildDisplacementFilter()];
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
