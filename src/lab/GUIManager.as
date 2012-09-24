package lab
{
	import com.bit101.components.ComboBox;
	import com.bit101.components.HRangeSlider;
	import com.bit101.components.HUISlider;
	import com.bit101.components.RadioButton;
	import com.bit101.components.Slider;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author ductri
	 */
	public class GUIManager extends Sprite
	{
		//private var m_brushlab:BrushManager;
		
		private static var _container:DisplayObjectContainer;
		private static var instance:GUIManager;
		private static var mediator:GUIBrushMediator;
		
		
		public static const FISH_EYE_BRUSH:String = "Fish eye brush";
		public static const SHRINK_BRUSH:String = "Shrink brush";
		public static const ERASE_BRUSH:String = "Erase brush";
		public static const MOVE_BRUSH:String = "Move brush";
		
		
		
		public function GUIManager() 
		{
			_container.addChild(this);
			
			
			var slSize:HUISlider = new HUISlider(this, 10, 15, "Size",onSlideSize);
			slSize.setSliderParams(1, 200, 0);
			addChild(slSize);

			var sl01:HUISlider = new HUISlider(this, 10, 35, "Scale",onSlideScale);
			sl01.setSliderParams(1, 100, 0);
			addChild(sl01);

			var radio1:RadioButton = new RadioButton(this, 10, 55, FISH_EYE_BRUSH, true, onRadioSelect);
			var radio2:RadioButton = new RadioButton(this, 10, 75, SHRINK_BRUSH, false, onRadioSelect);
			var radio3:RadioButton = new RadioButton(this, 10, 95, ERASE_BRUSH, false, onRadioSelect);
			//var radio4:RadioButton = new RadioButton(this, 10, 115, MOVE_BRUSH, false, onRadioSelect);

			//var cb:ComboBox = new ComboBox(this, 0, 0, "gradient", ["gradient 1", "gradient 2"]);
			//cb.addEventListener(Event.SELECT, onComboSelect);
			//addChild(cb);
		}
		
		/**
		 * 
		 * @param	_x
		 * @param	_y
		 * @param	_w
		 * @param	_h
		 */
		public function set(_x:int, _y:int, _w:int, _h:int):void
		{
			this.x = _x;
			this.y = _y;
			//this.width = _w;
			//this.height = _h;

			this.graphics.beginFill(0xa0a0a0);
			this.graphics.drawRect(0, 0, _w, _h);
			this.graphics.endFill();
		}
		
		public static function getInstance(d:DisplayObjectContainer):GUIManager
		{
			if (!instance)
			{
				_container = d;
				instance = new GUIManager();
			}
			return instance;
		}
		
		public static function setMediator(m:GUIBrushMediator):void
		{
			mediator = m;
		}
		
		private function onRadioSelect(e:Event):void
		{
			var r:RadioButton = e.target as RadioButton;
			mediator.setBrush(r.label);
			//reverseBrush
		}
		
		/*
		private function onSlideXY(e:Event):void
		{
			//trace("-------------------- " + e.target.value);
			mediator.setApplyPos(slX.value, slY.value);
		}
		*/

		
		private function onSlideScale(e:Event):void
		{
			//trace("-------------------- " + e.target.value);
			mediator.setDisplacementScale(e.target.value);
		}

		
		private function onSlideSize(e:Event):void
		{
			//trace("-------------------- " + e.target.value);
			mediator.setDisplacementSize(e.target.value);
		}

		
		private function onComboSelect(e:Event):void
		{
			var cb:ComboBox = e.target as ComboBox;
			//trace("-------------------- " + cb.selectedItem);
			
		}
		
	}

}

internal class SingletonEnforcer{}