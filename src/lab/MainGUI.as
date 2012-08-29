package lab
{
	import com.bit101.components.ComboBox;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author ductri
	 */
	public class MainGUI extends Sprite
	{
		
		public function MainGUI(_container:DisplayObjectContainer,_x:uint,_y:uint,_w:uint,_h:uint) 
		{
			_container.addChild(this);
			this.x = _x;
			this.y = _y;

			var cb:ComboBox = new ComboBox(this, 0, 0, "gradient", ["gradient 1", "gradient 2"]);
			cb.addEventListener(Event.SELECT, onComboSelect);
			this.graphics.beginFill(0x606060);
			this.graphics.drawRect(0, 0, _w, _h);
			this.graphics.endFill();

			this.width = _w;
			this.height = _h;
			
			addChild(cb);
			//initDisplacementMap();
			//initGradient();
			
		}
		
		private function onComboSelect(e:Event):void
		{
			var cb:ComboBox = e.target as ComboBox;
			trace("-------------------- " + cb.selectedItem);
			
		}
		
	}

}