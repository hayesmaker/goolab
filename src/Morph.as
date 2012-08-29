package  
{
    import flash.display.*;
    import flash.events.*;
    import flash.geom.*;
    import flash.filters.*;

    /**
     * @author Grant Skiner - original code: http://incomplet.gskinner.com/index2.html#camgoo
     * @author port - George Profenza
     */
    public class Morph extends Sprite
    {
        private var rect:Rectangle;
        private var mapBmp:BitmapData;
        private var blurredMapBmp:BitmapData;
        private var blurF:BlurFilter;
        private var pt:Point;
        private var dispMapF:DisplacementMapFilter;
        // holder for transient values (ex. during drag, animation)
        private var tmp:Object;

        private var mapHolder:MovieClip;
        private var debugBitmap:Bitmap;
        private var img:MovieClip;
        private var brush:MovieClip;
        private var isAnimating:Boolean = false;
        private var btn:Sprite;
        private var btn2:Sprite;

        public function Morph() 
        {
            init();
        }

        private function init():void
        {
            trace('init');

            img = new Img();
            addChild(img);
            brush = new Brush();
            brush.scaleX = brush.scaleY = .75;
            addChild(brush);

            mapHolder = new MovieClip();
            addChild(mapHolder);
            debugBitmap = new Bitmap(new BitmapData(img.width, img.height, false, 0x808080));
            debugBitmap.alpha = 0;
            mapHolder.addChild(debugBitmap);

            rect = new Rectangle(0,0,Math.floor(img.width),Math.floor(img.height));
            pt = new Point(0,0);

            // set up bitmaps:
            mapBmp = new BitmapData(rect.width,rect.height,false,0x808080);
            blurredMapBmp = mapBmp.clone();

            // set up filters:
            blurF = new BlurFilter(8,8,2);
            dispMapF = new DisplacementMapFilter(blurredMapBmp, pt,BitmapDataChannel.RED, BitmapDataChannel.GREEN, 100, 100, DisplacementMapFilterMode.CLAMP);

            brush.visible = false;
            this.addEventListener(MouseEvent.MOUSE_DOWN, startGoo);

            btn = new Sprite();
            btn.graphics.beginFill(0);
            btn.graphics.drawRect(0, 0, 50, 50);
            btn.graphics.endFill();
            btn.visible = false;
            addChild(btn);
            btn.addEventListener(MouseEvent.CLICK, onAnimClick);
            btn2 = new Sprite();
            btn2.graphics.beginFill(0);
            btn2.graphics.drawRect(0, 0, 50, 50);
            btn2.graphics.endFill();
            btn2.y = btn.height + 5;
            btn2.visible = false;
            addChild(btn2);
            btn2.addEventListener(MouseEvent.CLICK, endAnimate);
        }

        private function onAnimClick(e:MouseEvent):void 
        {
            isAnimating = true;
            animateGoo();
        }

        private function startGoo(e:MouseEvent):void{
            tmp = { oldx:mouseX, oldy:mouseY };
            this.addEventListener(MouseEvent.MOUSE_UP, endGoo);
            this.addEventListener(MouseEvent.MOUSE_MOVE, gooify);
        }

        private function endGoo(e:MouseEvent):void{
            tmp = null;
            this.removeEventListener(MouseEvent.MOUSE_UP, endGoo);
            this.removeEventListener(MouseEvent.MOUSE_MOVE, gooify);
        }

        private function clearGoo():void {
            mapBmp.fillRect(rect,0x808080);
            blurredMapBmp.fillRect(rect,0x808080);
            applyMap();
        }

        private function gooify(e:MouseEvent):void{
            var dx:Number = mouseX-tmp.oldx;
            var dy:Number = mouseY-tmp.oldy;
            tmp = {oldx:mouseX,oldy:mouseY};

            brush.rotation = (Math.atan2(dy, dx)) * 180 / Math.PI;
            brush.x = mouseX;
            brush.y = mouseY;

            var g:Number = 0x80+Math.min(0x79,Math.max(-0x80,  -dx*2  ));
            var b:Number = 0x80+Math.min(0x79,Math.max(-0x80,  -dy*2  ));
            var ct:ColorTransform = new ColorTransform(0,0,0,1,0x80,g,b,0);

            mapBmp.draw(brush,brush.transform.matrix,ct,BlendMode.HARDLIGHT);
            applyMap();
        }

        private function applyMap() {

            blurredMapBmp.applyFilter(mapBmp, rect, pt, blurF);
            img.filters = [dispMapF];
        }

        private function animateGoo():void {
            removeEventListener(MouseEvent.MOUSE_DOWN, startGoo);
            addEventListener(MouseEvent.MOUSE_DOWN, endAnimate);
            addEventListener(Event.ENTER_FRAME, animate);
            tmp = {count:100,dir:-4,scale:dispMapF.scaleX}
        }

        private function animate(e:Event):void {
            tmp.count+=tmp.dir;
            if (tmp.count >= 100 || tmp.count <= 0) { tmp.dir *= -1; }
            dispMapF.scaleX = dispMapF.scaleY = tmp.count / 100 * tmp.scale;
            applyMap();
        }

        private function endAnimate(e:MouseEvent):void {
            isAnimating = false;
            removeEventListener(MouseEvent.MOUSE_DOWN, endAnimate);
            removeEventListener(Event.ENTER_FRAME, animate);
            addEventListener(MouseEvent.MOUSE_DOWN, startGoo);
            tmp = null;
            dispMapF = new DisplacementMapFilter(blurredMapBmp, pt,BitmapDataChannel.RED, BitmapDataChannel.GREEN, 100, 100, DisplacementMapFilterMode.CLAMP);
            applyMap();
        }

        public function set anim(value:Boolean):void {
            value ? btn.dispatchEvent(new MouseEvent(MouseEvent.CLICK)) : btn2.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
            isAnimating = value;
        }

        public function get anim():Boolean {
            return isAnimating;
        }
    }

}
