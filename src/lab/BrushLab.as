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
			const GRAD_SIZE:uint = m_stage.stageWidth / 4;
			gradientView = new Sprite();
			addChild(gradientView);
			gradientView.x = 0;
			gradientView.y = m_stage.stageHeight / 2;			
			gui = new MainGUI(this, m_stage.stageWidth / 2, 0, m_stage.stageWidth / 2, m_stage.stageHeight / 2);
			
			// GRADIENT VERTICAL ==================================================================
			var graVer:Shape = createGradient(GradientType.LINEAR,GRAD_SIZE, GRAD_SIZE, 90, [0x0000ff, 0], [1, 1], [0, 255]);
			var tempBmd1:BitmapData = new BitmapData(graVer.width, graVer.height,false,0x808080);
			tempBmd1.draw(graVer);
			gradientView.addChild(graVer);
			
			// GRADIENT HORIZONTAL ================================================================
			var graHor:Shape = createGradient(GradientType.LINEAR,GRAD_SIZE, GRAD_SIZE, 0, [0x00ff00, 0], [1, 1], [0, 255]);
			var tempBmd2:BitmapData = new BitmapData(graHor.width, graHor.height,false,0x808080);
			tempBmd2.draw(graHor);
			gradientView.addChild(graHor);
			graHor.x = m_stage.stageWidth / 4;
			
			// GRADIENT SMOOTH + MERGE DES DEUX GRADIENTS =========================================
			var gra3:Shape = createGradient(GradientType.RADIAL, GRAD_SIZE, GRAD_SIZE, 0, [0, 0], [0, 0], [0, 255]);
			var smoothBMD:BitmapData = new BitmapData(GRAD_SIZE, GRAD_SIZE, true,0xff808080); // false 0x808080 IMPORTANT !!!
			smoothBMD.draw(gra3);
			var smoothBM:Bitmap = new Bitmap(smoothBMD);
			gradientView.addChild(smoothBM);
			smoothBM.x = 0;
			smoothBM.y = m_stage.stageHeight / 4;
			smoothBMD.copyChannel(tempBmd1, tempBmd1.rect, new Point(), BitmapDataChannel.BLUE, BitmapDataChannel.BLUE);
			smoothBMD.copyChannel(tempBmd2, tempBmd2.rect, new Point(), BitmapDataChannel.GREEN, BitmapDataChannel.GREEN);
			//randomize(bmd);
			/////////////////////////////
			var blf:BlurFilter = new BlurFilter(8,8 ,BitmapFilterQuality.HIGH);
			smoothBMD.applyFilter(smoothBMD, smoothBMD.rect, new Point(), blf);
			
			// DISPLACEMENT MAP ============================================================
			const SCALE:uint = 20;
			var disMap:DisplacementMapFilter = new DisplacementMapFilter(smoothBMD, new Point(150, m_stage.stageHeight/8), 
			BitmapDataChannel.GREEN, BitmapDataChannel.BLUE, SCALE, SCALE, DisplacementMapFilterMode.IGNORE);
			
			targetImage = new ImageClass1();
			addChild(targetImage);
			targetImage.x = targetImage.y = 0;
			targetImage.filters = [disMap];
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