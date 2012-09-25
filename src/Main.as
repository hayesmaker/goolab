/*

https://apps.facebook.com/flash_test_ductri/

http://facebook.com/developers/

*/

package

{
	
	import flash.display.Sprite;
	
	import flash.events.Event;

	import lab.*;
	/*
	import liquify.TestLiquify;
	*/
	
	/**
	 * ...
	 * @author Duc-Tri VU
	 */
	//[Frame(factoryClass="Preloader")]
	
//	[SWF(120,102,76)]

	public class Main extends Sprite
	{
		
		public function Main():void
		{
			if (stage)
				init();
			else
				addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void
		{
			
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
		
			{
				//addChild(picture);
				//addChild(new TestLiquify(stage));
				//addChild(BrushManager.getInstance(stage));
				Mediator.getInstance(stage);
			}
		
			//tf.appendText(" +++"+Facebook.login(onFacebookLogin));
			//tf.appendText("___ trying to login");
		}
		
		
	} // end class ================================================================================

} // end package ██████████████████████████████████████████████████████████████████████████████████