package lab
{
	import flash.display.Stage;
	import flash.display.BitmapData;
	
	/**
	 * ...
	 * @author Duc-Tri
	 */
	public class Mediator
	{
		public static var instance:Mediator;
		private static var brushMInstance:BrushManager;
		private static var guiMInstance:GUIManager;
		private static var m_stage:Stage;
		
		public function Mediator(s:SingletonEnforcer)
		{
			brushMInstance = BrushManager.getInstance(m_stage);
			guiMInstance = GUIManager.getInstance(m_stage);
			guiMInstance.set(m_stage.stageWidth / 2, 0, m_stage.stageWidth / 2, m_stage.stageHeight / 2);
			BrushManager.setMediator(this);
			GUIManager.setMediator(this);
		}
		
		public function setBrush(s:String):void
		{
			switch (s)
			{
				case GUIManager.FISH_EYE_BRUSH: 
					brushMInstance.fishEyeBrush();
					break;
				
				case GUIManager.SHRINK_BRUSH: 
					brushMInstance.shrinkBrush();
					break;
				
				case GUIManager.ERASE_BRUSH: 
					brushMInstance.eraseBrush();
					break;
				
				case GUIManager.MOVE_BRUSH: 
					brushMInstance.moveBrush();
					break;
			}
		
		}
		
		public static function getInstance(_s:Stage):Mediator
		{
			if (!instance)
			{
				m_stage = _s;
				instance = new Mediator(new SingletonEnforcer());
			}
			
			return instance;
		}
		
		/**
		 *
		 * @param	_s
		 */
		public function setDisplacementScale(_s:Number):void
		{
			while (brushMInstance.gradientView.numChildren != 0)
				brushMInstance.gradientView.removeChildAt(0);
			
			brushMInstance.m_disScale = _s;
			brushMInstance.updateGooBrush();
		}
		
		/**
		 *
		 * @param	_s
		 */
		public function setDisplacementSize(_s:Number):void
		{
			while (brushMInstance.gradientView.numChildren != 0)
				brushMInstance.gradientView.removeChildAt(0);
			
			brushMInstance.m_brushSize = _s;
			brushMInstance.updateGooBrush();
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
	
	} // end class ================================================================================

} // end package ==================================================================================

internal class SingletonEnforcer
{
}
