/*

   https://apps.facebook.com/flash_test_ductri/

   http://facebook.com/developers/

   http://

 */

package

{
	import com.facebook.graph.data.FacebookSession;
	import com.facebook.graph.Facebook;
	
	import flash.filters.ColorMatrixFilter;
	import flash.filters.GlowFilter;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.display.BitmapData;
	import flash.display.LoaderInfo;
	import flash.display.Loader;
	
	import flash.text.TextField;
	
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	import flash.system.Security;
	import flash.system.SecurityDomain;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.IEventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.ProgressEvent;
	
	import flash.geom.Rectangle;
	import flash.geom.Point;
	import flash.filters.BitmapFilterQuality;
	import flash.display.BlendMode;
	import flash.filters.BlurFilter;
	import flash.filters.ConvolutionFilter;
	import flash.display.BitmapDataChannel;
	
	import liquify.TestLiquify;
	import lab.BrushLab;
	/**
	 * ...
	 * @author Duc-Tri VU
	 */
	[Frame(factoryClass="Preloader")]
	

	public class Main extends Sprite
	{
		private static const ON_LINE:Boolean = false;
		
		
		private static const BACKGROUNDCOLOR:int = 6; // 0..12
		private var profilePic:Bitmap;
		private var tf:TextField;
		private var loaderContext:LoaderContext;
		private var loader:Loader;
		private var accessToken:String;
		private	var bg_color:Array= [0xff8040, 0xf0f0f0, 0xff8855, 0xffff00, 0x00ff80, 0x0080ff, 0xff80ff, 0x8080c0, 0xff8000, 0x8000ff, 0x008040, 0x808000, 0x408080];
		
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
			
			// BACKGROUND color for validating the modifications___________________________________
			var bgshape:Sprite = new Sprite();
			bgshape.graphics.beginFill(bg_color[BACKGROUNDCOLOR]); // 0..12
			bgshape.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			addChildAt(bgshape, 0);
			
			// TEXTFIELD for debug_________________________________________________________________
			tf = new TextField();
			tf.text = "Welcome\n=================================\n";
			tf.x = tf.y = 0;
			tf.wordWrap = true;
			tf.width = tf.height = 500;
			addChild(tf);
			
			if (ON_LINE)
			{
				// POLICY files________________________________________________________________________
				//Security.loadPolicyFile("http://www.facebook.com/crossdomain.xml");
				//Security.loadPolicyFile("https://api.facebook.com/crossdomain.xml");
				//Security.loadPolicyFile("http://profile.ak.fbcdn.net/crossdomain.xml");
				//Security.loadPolicyFile("https://graph.facebook.com/crossdomain.xml");
				//Security.loadPolicyFile("http://fbcdn-profile-a.akamaihd.net/crossdomain.xml");
				//Security.allowDomain("*");
				//Security.allowInsecureDomain("*");
				loaderContext = new LoaderContext();
				loaderContext.securityDomain = SecurityDomain.currentDomain;
				loaderContext.checkPolicyFile = true;		
				Facebook.init("180760975380687", onFacebookInit);
				tf.appendText("\n________________ trying to connect");
			}
			else
			{
				//addChild(picture);
				addChild(new TestLiquify(stage));
				//addChild(new BrushLab(stage));
			}
		
			//tf.appendText(" +++"+Facebook.login(onFacebookLogin));
			//tf.appendText("___ trying to login");
		}
		
		private function onFacebookLogout(response:Boolean):void
		{
			//trace(response ? "LOGOUT SUCCESS" : "LOGOUT FAIL");
			tf.appendText(response ? "\n*** LOGOUT SUCCESS" : "\n*** LOGOUT FAIL");
		}
		
		private function onFacebookLogin(success:Object, fail:Object):void
		{
			//trace(success ? "LOG SUCCESS" : "LOG FAIL");
			tf.appendText(success ? "\n*** LOG SUCCESS " + success.accessToken : "\n*** LOG FAIL " + success + " / " + fail);
			
			if (success)
			{
				accessToken = success.accessToken;
				doTests();
					//var fbs:FacebookSession = FacebookSession(success);
			}
		}
		
		private function onFacebookInit(success:Object, fail:Object):void
		{
			//trace(success ? "USER LOGGED IN" : "NO LOGGED USER");
			tf.appendText(success ? "\n*** USER LOGGED IN " + success.accessToken : "\n*** NO LOGGED USER " + fail + " / " + success);
			
			if (success)
			{
				//var fbs:FacebookSession = FacebookSession(success);
				accessToken = success.accessToken;
				doTests();
			}
			else
			{
				tf.appendText("\n________________ trying to login");
				var permissions:Array = ['publish_stream', 'user_photos'];
				//--- this method will call a html popup directly from facebook so the user can write his username and password securely. The first parameter is the callback function and the second is a string of the permissions you ask for.
				Facebook.login(onFacebookLogin, {perms: permissions.join(',')});
				
					//Facebook.login(onFacebookLogin);
			}
		}
		
		//Function where i pass the url of the FB image clicked
		private function getProfileImage(accessToken:String):void
		{
			
			var rawURL:String = Facebook.getImageUrl("me", "large");
			//"https://graph.facebook.com/me/picture?type=square&return_ssl_resources=1";
			//
			
			//var sess:FacebookSession = getSession();
			if (rawURL.indexOf("?") != -1)
			{
				rawURL += "&access_token=" + accessToken;
			}
			else
			{
				rawURL += "?access_token=" + accessToken;
			}
			
			tf.appendText("\n ####### getFBImage : rawURL:" + rawURL);
			
			//var my_loader:Loader = new Loader();
			//my_loader.load(new URLRequest(rawURL));
			//addChild(my_loader);
			
			loader = new Loader();
			var request:URLRequest;
			configureListeners(loader.contentLoaderInfo);
			request = new URLRequest(rawURL);
			loader.load(request, loaderContext);
			loader.x = loader.y = 50;
		}
		
		private function configureListeners(dispatcher:IEventDispatcher):void
		{
			dispatcher.addEventListener(Event.COMPLETE, onComplete2);
			dispatcher.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
			dispatcher.addEventListener(Event.INIT, initHandler);
			dispatcher.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			dispatcher.addEventListener(Event.OPEN, openHandler);
			dispatcher.addEventListener(ProgressEvent.PROGRESS, progressHandler);
			dispatcher.addEventListener(Event.UNLOAD, unLoadHandler);
		}
		
		private function onComplete2(event:Event):void
		{
			try
			{
				// the redirected url !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
				var path:String = LoaderInfo(event.target).url;
				var cut:int = path.indexOf("fbcdn-profile-a.akamaihd.net");
				if (cut != -1)
				{
					path = "http://" + path.substring(cut);
				}
				
				loader.unload();
				loader = new Loader();
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onRedirectComplete);
				
				// swap out the old loader with the new one into the same container
				//LoaderInfo(event.target).loader.parent.addChild(loader);
				//LoaderInfo(event.target).loader.parent.removeChild(LoaderInfo(event.target).loader);
				
				loader.load(new URLRequest(path), loaderContext);
				loader.x = loader.y = 0;
				tf.appendText("\n ###  onComplete2: " + path + " " + event.target.contentType);
			}
			catch (e:Error)
			{
				tf.appendText("\n >>>>>>> " + e.message + " - " + e.getStackTrace());
			}
		}
		
		private function onRedirectComplete(event:Event):void
		{
			var w:int = LoaderInfo(event.target).content.width;
			var h:int = LoaderInfo(event.target).content.height;
			profilePic = LoaderInfo(event.target).content as Bitmap;
			//profilePic.bitmapData = 
			toHAM(profilePic.bitmapData); //////////////////////////
			//profilePic.x = profilePic.y = 20;
			profilePic.smoothing = true;
			stage.addChild(profilePic);
			tf.appendText("\n ###### onRedirectComplete: " + event + "---" + w + "/" + h);
			//loader.unload();
		}
		
		private function httpStatusHandler(event:HTTPStatusEvent):void
		{
			tf.appendText("\n ### " + "httpStatusHandler: " + event);
		}
		
		private function initHandler(event:Event):void
		{
			tf.appendText("\n ### " + "initHandler: " + event);
		}
		
		private function ioErrorHandler(event:IOErrorEvent):void
		{
			tf.appendText("\n ### " + "ioErrorHandler: " + event);
		}
		
		private function openHandler(event:Event):void
		{
			tf.appendText("\n ### " + "openHandler: " + event);
		}
		
		private function progressHandler(event:ProgressEvent):void
		{
			tf.appendText("\n ### " + "progressHandler: bytesLoaded=" + event.bytesLoaded + " bytesTotal=" + event.bytesTotal);
		}
		
		private function unLoadHandler(event:Event):void
		{
			tf.appendText("\n ### " + "unLoadHandler: " + event);
		}
		
		private function errorHandler(event:Event):void
		{
			tf.appendText("\n ############ ERROR !");
		
		}
		
		private function onFriendsListLoaded(result:Object, fail:Object):void
		{
			//var divTarget = document.getElementById("friends-list-container");
			//var data = response.data;
			//alert("divTarget="+divTarget+"\ndata="+data);
			tf.appendText("\n*** FRIENDS_____________________________" + result.length);
			for (var friendIndex:int = 0; friendIndex < 10 /*result.length*/; friendIndex++)
			{
				//var divContainer = document.createElement("div");
				//divContainer.innerHTML = "<b>" + data[friendIndex].name + "</b>";
				//divTarget.appendChild(divContainer);
				tf.appendText("\n+++ " + result[friendIndex].name);
			}
		}
		
		private function onAlbumsLoaded(result:Object, fail:Object):void
		{
			//var divTarget = document.getElementById("friends-list-container");
			//var data = response.data;
			//alert("divTarget="+divTarget+"\ndata="+data);
			tf.appendText("\n*** ALBUMS_______________________________" + result.length);
			for (var albumindex:int = 0; albumindex < result.length; albumindex++)
			{
				//var divContainer = document.createElement("div");
				//divContainer.innerHTML = "<b>" + data[friendIndex].name + "</b>";
				//divTarget.appendChild(divContainer);
				tf.appendText("\n+++ " + result[albumindex].name);
				Facebook.api(result[albumindex].id + '/photos', onPhotosLoaded);
			}
		}
		
		private function randRange(min:Number, max:Number):Number
		{
			return Math.floor(min + (Math.random() * (max - min)));
		}
		
		private function randRange2(minNum:Number, maxNum:Number):Number
		{
			return (Math.floor(Math.random() * (maxNum - minNum + 1)) + minNum);
		}
		
		private function onPhotosLoaded(result:Object, fail:Object):void
		{
			//var divTarget = document.getElementById("friends-list-container");
			//var data = response.data;
			//alert("divTarget="+divTarget+"\ndata="+data);
			tf.appendText("\n*** PHOTOS" + result.length);
			
			var max:int = 1; // result.length;
			var albumindex:int = randRange(0, result.length);
			
			for (albumindex = 0; albumindex < result.length; albumindex++)
			{
				//var divContainer = document.createElement("div");
				//divContainer.innerHTML = "<b>" + data[friendIndex].name + "</b>";
				//divTarget.appendChild(divContainer);
				tf.appendText("\n+++ " + result[albumindex].source);
				//Facebook.api(result[albumindex].id+'me/photos', onPhotosLoaded);
				
				var loader:Loader;
				loader = new Loader();
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onRedirectComplete);
				
				// swap out the old loader with the new one into the same container
				//LoaderInfo(event.target).loader.parent.addChild(loader);
				//LoaderInfo(event.target).loader.parent.removeChild(LoaderInfo(event.target).loader);
				
				loader.load(new URLRequest(result[albumindex].source), loaderContext);
				loader.x = loader.y = 0;
			
			}
		}
		
		private function doTests():void
		{
			getProfileImage(accessToken);
			Facebook.api('me/friends', onFriendsListLoaded);
			Facebook.api('me/albums', onAlbumsLoaded);
		}
		
		private function setGreyScale(bd:BitmapData):BitmapData
		{
			var rLum:Number = 0.2225;
			var gLum:Number = 0.7169;
			var bLum:Number = 0.0606;
			var matrix:Array = [rLum, gLum, bLum, 0, 0, rLum, gLum, bLum, 0, 0, rLum, gLum, bLum, 0, 0, 0, 0, 0, 1, 0];
			var filter:ColorMatrixFilter = new ColorMatrixFilter(matrix);
			bd.applyFilter(bd, new Rectangle(0, 0, bd.width, bd.height), new Point(0, 0), filter);
			return bd;
		}
		
		private function setBlackWhite(bd:BitmapData, threshold:int = 50):BitmapData
		{
			var rLum:Number = 0.2225;
			var gLum:Number = 0.7169;
			var bLum:Number = 0.0606;
			var matrix:Array = [rLum * 256, gLum * 256, bLum * 256, 0, -256 * threshold, rLum * 256, gLum * 256, bLum * 256, 0, -256 * threshold, rLum * 256, gLum * 256, bLum * 256, 0, -256 * threshold, 0, 0, 0, 1, 0];
			var filter:ColorMatrixFilter = new ColorMatrixFilter(matrix);
			bd.applyFilter(bd, new Rectangle(0, 0, bd.width, bd.height), new Point(0, 0), filter);
			return bd;
		}
		
		private function roboview(bd:Bitmap):BitmapData
		{
			var color:Number = 0x33CCFF;
			var alpha:Number = 0.8;
			var blurX:Number = 50;
			var blurY:Number = 50;
			var strength:Number = 8;
			var inner:Boolean = true;
			var knockout:Boolean = false;
			var quality:Number = BitmapFilterQuality.HIGH;
			
			bd.filters = [new GlowFilter(color, alpha, blurX, blurY, strength, quality, inner, knockout)];
			
			return bd.bitmapData;
		} // end function		
		
		public static const MGUASSIAN:BlurFilter = new BlurFilter(4, 4, 1);
		public static const MGX:ConvolutionFilter = new ConvolutionFilter(3, 3, [-1, 0, 1, -2, 0, 2, -1, 0, 1], 1);
		public static const MGY:ConvolutionFilter = new ConvolutionFilter(3, 3, [1, 2, 1, 0, 0, 0, -1, -2, -1], 1);
		public static const MGXNEG:ConvolutionFilter = new ConvolutionFilter(3, 3, [1, 0, -1, 2, 0, -2, 1, 0, -1], 1);
		public static const MGYNEG:ConvolutionFilter = new ConvolutionFilter(3, 3, [-1, -2, -1, 0, 0, 0, 1, 2, 1], 1);
		public static const MPOINT:Point = new Point();
		public static const MOTION_THRESHOLD:int = 64;
		
		public static function Cartoonize(source:BitmapData):BitmapData
		{
			var mEdgeData:BitmapData = source.clone();
			var mRect:Rectangle = mEdgeData.rect;
			
			mEdgeData.applyFilter(mEdgeData, mRect, MPOINT, MGUASSIAN);
			var xData:BitmapData = new BitmapData(mRect.width, mRect.height);
			xData.applyFilter(mEdgeData, mRect, MPOINT, MGX);
			var xNegData:BitmapData = new BitmapData(mRect.width, mRect.height);
			xNegData.applyFilter(mEdgeData, mRect, MPOINT, MGXNEG);
			var yData:BitmapData = new BitmapData(mRect.width, mRect.height);
			yData.applyFilter(mEdgeData, mRect, MPOINT, MGY);
			mEdgeData.applyFilter(mEdgeData, mRect, MPOINT, MGYNEG);
			
			mEdgeData.draw(xData, null, null, BlendMode.ADD);
			mEdgeData.draw(xNegData, null, null, BlendMode.ADD);
			mEdgeData.draw(yData, null, null, BlendMode.ADD);
			
			mEdgeData.threshold(mEdgeData, mRect, MPOINT, ">", MOTION_THRESHOLD << 16, 0xFFFFFFFF, 0x00FF0000, false);
			mEdgeData.threshold(mEdgeData, mRect, MPOINT, "<", MOTION_THRESHOLD << 16, 0xFF000000, 0x00FF0000, false);
			
			mEdgeData.applyFilter(mEdgeData, mEdgeData.rect, MPOINT, new ColorMatrixFilter([-1, 0, 0, 0, 255, 0, -1, 0, 0, 255, 0, 0, -1, 0, 255, 0, 0, 0, 1, 0]));
			mEdgeData.draw(source, null, null, BlendMode.MULTIPLY); //try to use BlendMode.OVERLAY
			
			return mEdgeData;
		} //end of function
		
		public function reduceColors( img:BitmapData, number:int = 16, grayScale:Boolean = false, affectAlpha:Boolean = false ):void
		{
			var i:int;
			var j:int=0;
			
			var val:int = 0;
			
			
			var total:int = 255;
			number -= 2;
			if( number <= 0 ) number = 1;
			if( number >= 255) number = 254;
			
			var step:Number = total / number;
			var offset:Number = ( total - ( total / ( number + 1 ) ) ) / total;
			var values:Array = [];
			for ( i = 0; i < total; i++ )
			{
				
				if( i >= ( j * step * offset ) )
				{
					j++;
				}
				values.push( Math.floor( ( Math.ceil( j*step )-step ) ) );
				
			}
			var a:int;
			var r:int;
			var g:int;
			var b:int;
			var c:int;
			
			var iw:int = img.width;
			var ih:int = img.height;
		
			img.lock();
			
			if( affectAlpha )
			{
				// GRAYSCALE WITH ALPHA AFFECTED
				if( grayScale )
				{
					for ( i = 0; i < iw; i++ )
					{
						for ( j = 0; j < ih; j++ )
						{
							
							val = img.getPixel32( i, j );
							
							a = values[ ( val >>> 24 )- 1 ];
							r = values[ ( val >>> 16 & 0xFF )- 1 ];
							g = values[ ( val >>> 8  & 0xFF )- 1 ];
							b = values[ ( val & 0xFF )- 1 ];
							c = Math.ceil( ( ( r + g + b ) / 3 ) );
							img.setPixel32( i, j, ( a<<24 | c << 16 | c << 8 | c ) );
						
						}
					}
					
				}else{
					
					// COLORS WITH ALPHA AFFECTED
					for ( i = 0; i < iw; i++ )
					{
						for ( j = 0; j < ih; j++ )
						{
							
							val = img.getPixel32( i, j );
							
							a = values[ ( val >>> 24 )- 1 ];
							r = values[ ( val >>> 16 & 0xFF )- 1 ];
							g = values[ ( val >>> 8  & 0xFF )- 1 ];
							b = values[ ( val & 0xFF )- 1 ];
							
							img.setPixel32( i, j, ( a<<24 | r << 16 | g << 8 | b ) );
						
						}
					}
				}
				
			}else{
				
				// GRAYSCALE WITH ALPHA NOT AFFECTED
				if( grayScale ) 
				{
					for ( i = 0; i < iw; i++ )
					{
						for ( j = 0; j < ih; j++ )
						{
							
							val = img.getPixel32( i, j );
							
							r = values[ ( val >>> 16 & 0xFF )- 1 ];
							g = values[ ( val >>> 8  & 0xFF )- 1 ];
							b = values[ ( val & 0xFF )- 1 ];
							c = Math.ceil( ( ( r + g + b ) / 3 ) );
							img.setPixel32( i, j, ( (val >>> 24 )<<24 | c << 16 | c << 8 | c ) );
						
						}
					}
					
				}else{ 
					
					// COLORS WITH ALPHA NOT AFFECTED
					for ( i = 0; i < iw; i++ )
					{
						for ( j = 0; j < ih; j++ )
						{
							
							val = img.getPixel32( i, j );
							
							r = values[ ( val >>> 16 & 0xFF )- 1 ];
							g = values[ ( val >>> 8  & 0xFF )- 1 ];
							b = values[ ( val & 0xFF )- 1 ];
							
							img.setPixel32( i, j, ( (val >>> 24 )<<24 | r << 16 | g << 8 | b ) );
						
						}
					}
				}
			}
			img.unlock();
			
		}
		
		
		//SHORTCUTS
		
		public function toCGA( bmpd:BitmapData, grayscale:Boolean = false, alpha:Boolean = false ):void
		{
			 reduceColors( bmpd, 0, grayscale, alpha );
		}	
		
		public function toEGA( bmpd:BitmapData, grayscale:Boolean = false, alpha:Boolean = false ):void
		{
			 reduceColors( bmpd, 4, grayscale, alpha  );
		}
		
		public function toHAM( bmpd:BitmapData, grayscale:Boolean = false, alpha:Boolean = false ):void
		{
			 reduceColors( bmpd, 6, grayscale, alpha  );
		}	
		
		public function toVGA( bmpd:BitmapData, grayscale:Boolean = false, alpha:Boolean = false ):void
		{
			 reduceColors( bmpd, 8, grayscale, alpha  );
		}
		
		public function toSVGA( bmpd:BitmapData, grayscale:Boolean = false, alpha:Boolean = false ):void
		{
			 reduceColors( bmpd, 16, grayscale, alpha  );
		}
		
		
		public function reduceColor2( original:BitmapData, increment:int = 128, preserve:Boolean = false ):BitmapData
		{
			
			//preserve l'original ou pas dÃ©faut false > Ã©crase l'original
			var bmpd:BitmapData = original.clone();
			if( !preserve )
			{
				original.dispose();
			}
			
			//borne l'incrÃ©ment entre 1 et 254 sinon tout blanc ou tout noir
			increment = ( increment < 1 ) ? 1 : ( increment >= 255 ) ? 254 : increment;
			
			//tableaux pour les palleteMap
			var alp:Array = new Array(256);
			var red:Array = new Array(256);
			var green:Array = new Array(256);
			var blue:Array = new Array(256);
			
			var pas:int = 0;
			
			for(var i:uint = 1; i < 256; i++) 
			{
				
				//indexation des composantes en fonction du pas 
				alp[ i ] 	= ( pas & 0xFF ) << 24;
				red[ i ] 	= ( pas & 0xFF ) << 16;
				green[ i ] 	= ( pas & 0xFF ) << 8;
				blue[ i ] 	= ( pas & 0xFF );
				if( i % increment == 0 )
				{
					
					pas  += increment;
					
				}
			}
			
			var pt:Point = new Point(0, 0);
			var rect:Rectangle = bmpd.rect;
			
			//largeur / hauteur
			var W:int = bmpd.width;
			var H:int = bmpd.height;
			
			//bitmaps de travail
			var Final:BitmapData = new BitmapData( W, H , true, 0xFF000000 );
			var bmd:BitmapData = new BitmapData( W, H, true, 0xFF000000 );
			
			//traite la couche alpha
			bmd.copyChannel( bmpd, bmpd.rect, pt, BitmapDataChannel.ALPHA, BitmapDataChannel.ALPHA );
			bmd.paletteMap( bmd, rect, pt, alp, alp, alp, alp);
			Final.copyChannel(bmd, rect, pt, BitmapDataChannel.ALPHA, BitmapDataChannel.ALPHA );
			
			//traite la couche rouge
			bmd.fillRect( rect, 0xFF000000 );
			bmd.copyChannel( bmpd, bmpd.rect, pt, BitmapDataChannel.RED, BitmapDataChannel.RED );
			bmd.paletteMap( bmd, rect, pt, red, red, red);
			Final.copyChannel(bmd, rect, pt, BitmapDataChannel.RED, BitmapDataChannel.RED );
			
			//traite la couche verte
			bmd.fillRect( rect, 0xFF000000 );
			bmd.copyChannel( bmpd, bmpd.rect, pt, BitmapDataChannel.GREEN, BitmapDataChannel.GREEN );
			bmd.paletteMap( bmd, rect, pt, green, green, green);
			Final.copyChannel(bmd, rect, pt, BitmapDataChannel.GREEN, BitmapDataChannel.GREEN );
			
			//traite la couche bleue
			bmd.fillRect( rect, 0xFF000000 );
			bmd.copyChannel( bmpd, bmpd.rect, pt, BitmapDataChannel.BLUE, BitmapDataChannel.BLUE );
			bmd.paletteMap( bmd, rect, pt, blue, blue, blue);
			Final.copyChannel(bmd, rect, pt, BitmapDataChannel.BLUE, BitmapDataChannel.BLUE );
		
			//redessine le bitmap
			bmpd.draw( Final );
			
			//mÃ©nage
			bmd.dispose();
			Final.dispose();
			return bmpd;
			
		}
	
	} // end class ================================================================================

} // end package ██████████████████████████████████████████████████████████████████████████████████