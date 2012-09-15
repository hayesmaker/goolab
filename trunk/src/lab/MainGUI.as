package lab
{
	import com.bit101.components.ComboBox;
	import com.bit101.components.HRangeSlider;
	import com.bit101.components.HUISlider;
	import com.bit101.components.Slider;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author ductri
	 */
	public class MainGUI extends Sprite
	{
		private var m_brushlab:BrushLab;
		
		private var slY:HUISlider;
		private var slX:HUISlider;
		
		public function MainGUI(_container:DisplayObjectContainer,_x:uint,_y:uint,_w:uint,_h:uint) 
		{
			_container.addChild(this);
			this.x = _x;
			this.y = _y;
			this.graphics.beginFill(0xa0a0a0);
			this.graphics.drawRect(0, 0, _w, _h);
			this.graphics.endFill();
			this.width = _w;
			this.height = _h;
			
			var slSize:HUISlider = new HUISlider(this, 10, 15, "Size",onSlideSize);
			slSize.setSliderParams(1, 200, 0);
			addChild(slSize);

			var sl01:HUISlider = new HUISlider(this, 10, 25, "Scale",onSlide);
			sl01.setSliderParams(1, 200, 0);
			addChild(sl01);

			//slX = new HUISlider(this, 10, 35, "X",onSlideXY);
			//slX.setSliderParams(0, 300, 0);
			//addChild(slX);

			//slY = new HUISlider(this, 10, 45, "Y",onSlideXY);
			//slY.setSliderParams(0, 300, 0);
			//addChild(slY);
			
			//var cb:ComboBox = new ComboBox(this, 0, 0, "gradient", ["gradient 1", "gradient 2"]);
			//cb.addEventListener(Event.SELECT, onComboSelect);
			//addChild(cb);
		}
		
		public function set view(_b:BrushLab):void
		{
			m_brushlab = _b;
		}

		
		private function onSlideXY(e:Event):void
		{
			//trace("-------------------- " + e.target.value);
			m_brushlab.setApplyPos(slX.value, slY.value);
		}

		
		private function onSlide(e:Event):void
		{
			//trace("-------------------- " + e.target.value);
			m_brushlab.setDisplacementScale(e.target.value);
		}

		
		private function onSlideSize(e:Event):void
		{
			//trace("-------------------- " + e.target.value);
			m_brushlab.setDisplacementSize(e.target.value);
		}

		
		private function onComboSelect(e:Event):void
		{
			var cb:ComboBox = e.target as ComboBox;
			//trace("-------------------- " + cb.selectedItem);
			
		}
		
	}

}