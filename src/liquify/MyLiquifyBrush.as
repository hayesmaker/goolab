/**
 * ...
 * @author Duc-Tri VU
 */

package liquify
{
	import flash.display.*;
	import flash.geom.*;
	
	public class MyLiquifyBrush extends Sprite
	{
		private var cStrength:Number = 1;
		public var cRadius:Number = 50;
		private var brushType:String = "move";
		
		public function MyLiquifyBrush()
		{
			this.setBrush();
		} // end function
		
		public function setBrush(param1:String = "0"):void
		{
			this.brushType = param1 == "0" ? (this.brushType) : (param1);
			this.clear();
			switch (this.brushType)
			{
				case "move": 
				{
					this.cStrength = 1;
					this.createMoveBrush();
					break;
				}
				case "min": 
				{
					this.createZoomBrush("min");
					break;
				}
				case "max": 
				{
					this.createZoomBrush("max");
					break;
				}
				case "erase": 
				{
					this.cStrength = 0.2;
					this.createEraseBrush();
					break;
				}
				default: 
				{
					break;
				}
			}
			return;
		} // end function
		
		/**
		 *
		 */
		private function createMoveBrush():void
		{
			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(this.cRadius, this.cRadius, 0, (-this.cRadius) / 2, (-this.cRadius) / 2);
			graphics.clear();
			graphics.beginGradientFill(GradientType.RADIAL, [0x808080, 0x808080], [this.cStrength, 0], [1, 255], matrix, SpreadMethod.PAD, InterpolationMethod.RGB);
			graphics.drawCircle(0, 0, this.cRadius / 2);
			graphics.endFill();
			matrix = null;
		} // end function
		
		/**
		 *
		 */
		private function createEraseBrush():void
		{
			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(this.cRadius, this.cRadius, 0, (-this.cRadius) / 2, (-this.cRadius) / 2);
			graphics.clear();
			graphics.beginGradientFill(GradientType.RADIAL, [0x808080, 0x808080], [this.cStrength, 0], [0, 255], matrix, SpreadMethod.PAD, InterpolationMethod.RGB);
			graphics.drawCircle(0, 0, this.cRadius / 2);
			graphics.endFill();
			matrix = null;
			return;
		} // end function
		
		public function createZoomBrush(param1:String = "max"):void
		{
			var gradients:Array;
			var gradientsPos:Array;
			var radius:Number = this.cRadius;
			
			
			var mat1:Matrix = new Matrix();
			mat1.createGradientBox(radius, radius, 0);
			var shape1:Shape = new Shape();
			shape1.graphics.beginGradientFill(GradientType.RADIAL, [0, 0], [0.1, 0], [0, 255], mat1, SpreadMethod.PAD, InterpolationMethod.RGB);
			shape1.graphics.drawCircle(radius / 2, radius / 2, radius / 2);
			shape1.graphics.endFill();
			var bmd1:BitmapData = new BitmapData(radius, radius, true, 16777215);
			bmd1.draw(shape1);
						
			
			var mat2:Matrix = new Matrix();
			mat2.createGradientBox(radius, radius, 0);
			if (param1 == "min")
			{
				gradients = [0, 65280];
				gradientsPos = [0, 255];
			}
			else
			{
				gradients = [65280, 0];
				gradientsPos = [255, 0];
			}
			var shape2:Shape = new Shape();
			shape2.graphics.beginGradientFill(GradientType.LINEAR, gradients, [1, 1], [0, 255], mat2, SpreadMethod.PAD, InterpolationMethod.RGB);
			shape2.graphics.drawCircle(radius / 2, radius / 2, radius / 2);
			shape2.graphics.endFill();
			var bmd2:BitmapData = new BitmapData(radius, radius, false, 0x808080);
			bmd2.draw(shape2);

			
			var mat3:Matrix = new Matrix();
			mat3.createGradientBox(radius, radius, Math.PI / 2);
			var shape3:Shape = new Shape();
			shape3.graphics.beginGradientFill(GradientType.LINEAR, gradientsPos, [1, 1], [0, 255], mat3, SpreadMethod.PAD, InterpolationMethod.RGB);
			shape3.graphics.drawCircle(radius / 2, radius / 2, radius / 2);
			shape3.graphics.endFill();
			var bmd3:BitmapData = new BitmapData(radius, radius, false, 0x808080);
			bmd3.draw(shape3);
			
			
			bmd1.copyChannel(bmd2, bmd2.rect, new Point(0, 0), BitmapDataChannel.GREEN, BitmapDataChannel.GREEN);
			bmd1.copyChannel(bmd3, bmd3.rect, new Point(0, 0), BitmapDataChannel.BLUE, BitmapDataChannel.BLUE);
			bmd2.dispose();
			bmd3.dispose();
			
			
			var bitmap:Bitmap = new Bitmap(bmd1);
			bitmap.x = (-bitmap.width) / 2;
			bitmap.y = (-bitmap.width) / 2;
			this.addChild(bitmap);
			
			shape1.x = 500;
			shape1.y = 50;
			stage.addChild(shape1); ///////////////////////////////////////
			shape2.x = 550;
			shape2.y = 100;
			stage.addChild(shape2); ///////////////////////////////////////
			shape3.x = 600;
			shape3.y = 150;
			stage.addChild(shape3); ///////////////////////////////////////			
		} // end function
		
		/**
		 *
		 * @param	param1
		 */
		public function createZoomBrush2(param1:String = "max"):void
		{
			var gradients:Array;
			var gradientsPos:Array;
			
			var radius:Number = this.cRadius;
			
			var matrix1:Matrix = new Matrix();
			matrix1.createGradientBox(radius, radius, 0);
			var shape1:Shape = new Shape();
			shape1.graphics.beginGradientFill(GradientType.RADIAL, [0, 0], [0.1, 0], [0, 255], matrix1, SpreadMethod.PAD, InterpolationMethod.RGB);
			shape1.graphics.drawCircle(radius / 2, radius / 2, radius / 2);
			shape1.graphics.endFill();
			var bitmapData1:BitmapData = new BitmapData(radius, radius, true, 0x808080);
			bitmapData1.draw(shape1);
			
			var matrix2:Matrix = new Matrix();
			matrix2.createGradientBox(radius, radius, 0);
			gradients = [0, 0x00ff00];
			gradientsPos = (param1 == "min") ? [0, 255] : [255, 0];
			var shape2:Shape = new Shape();
			shape2.graphics.beginGradientFill(GradientType.LINEAR, gradients, [1, 1], [0, 255], matrix2, SpreadMethod.PAD, InterpolationMethod.RGB);
			shape2.graphics.drawCircle(radius / 2, radius / 2, radius / 2);
			shape2.graphics.endFill();
			var bitmapData2:BitmapData = new BitmapData(radius, radius, false, 0x808080);
			bitmapData2.draw(shape2);
			
			var matrix3:Matrix = new Matrix();
			matrix3.createGradientBox(radius, radius, Math.PI / 2);
			var shape3:Shape = new Shape();
			shape3.graphics.beginGradientFill(GradientType.LINEAR, gradientsPos, [1, 1], [0, 255], matrix3, SpreadMethod.PAD, InterpolationMethod.RGB);
			shape3.graphics.drawCircle(radius / 2, radius / 2, radius / 2);
			shape3.graphics.endFill();
			var bitmapData3:BitmapData = new BitmapData(radius, radius, false, 0x808080);
			bitmapData3.draw(shape3);
			
			//shape1.x = 500; shape1.y = 50;
			//stage.addChild(shape1); ///////////////////////////////////////
			//shape2.x = 550; shape2.y = 100;
			//stage.addChild(shape2); ///////////////////////////////////////
			//shape3.x = 600; shape3.y = 150;
			//stage.addChild(shape3); ///////////////////////////////////////
			
			bitmapData1.copyChannel(bitmapData2, bitmapData2.rect, new Point(0, 0), BitmapDataChannel.GREEN, BitmapDataChannel.GREEN);
			bitmapData1.copyChannel(bitmapData3, bitmapData3.rect, new Point(0, 0), BitmapDataChannel.BLUE, BitmapDataChannel.BLUE);
			var bitmap:Bitmap = new Bitmap(bitmapData1);
			
			bitmapData2.dispose();
			bitmapData3.dispose();
			bitmap.x = (-bitmap.width) / 2;
			bitmap.y = (-bitmap.width) / 2;
			this.addChild(bitmap);
			
			var bbb:Bitmap = new Bitmap(bitmap.bitmapData);
			bbb.x = 500;
			bbb.y = 300;
			stage.addChild(bbb); ////////////////////////////////////////////////////
		
		} // end function
		
		public function setPoint(param1:Point):void
		{
			this.x = param1.x;
			this.y = param1.y;
			return;
		} // end function
		
		public function setStr(param1:Number):void
		{
			this.cStrength = param1;
			this.setBrush();
		} // end function
		
		public function setRadius(param1:Number):void
		{
			this.cRadius = param1;
			this.setBrush();
		} // end function
		
		public function clear():void
		{
			graphics.clear();
			while (this.numChildren)
			{
				this.removeChildAt(0);
			}
		} // end function
	
	}
}
