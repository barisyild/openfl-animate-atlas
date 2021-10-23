package openfl.extensions.animate.display;

import openfl.geom.Rectangle;
import openfl.display.BitmapData;
import openfl.display.Tileset;

class AnimateAtlasTileset extends Tileset {
    private var __rotate:Array<Bool>;
    public var __names:Map<String, Int>;

    public function new(bitmapData:BitmapData, rects:Array<Rectangle> = null) {
        super(bitmapData, rects);
        __rotate = [];
        __names = new Map<String, Int>();
    }

    public function addRotate(rotate:Bool):Int
    {
        return __rotate.push(rotate);
    }
}
