package openfl.extensions.animate;

import openfl.display.BitmapData;
import openfl.extensions.animate.display.AnimateAtlasSprite;
import openfl.extensions.animate.display.IAtlasDisplayObjectContainer;
import openfl.geom.Point;
import openfl.geom.Rectangle;

class AnimateSpriteAtlasSheet extends AnimateAtlasSheet {
    public var bitmapDataMap:Map<String, BitmapData>;

    public function new(spritemap:BitmapData, atlas:openfl.extensions.animate.struct.ATLAS, rawAnimationData:Dynamic) {
        bitmapDataMap = new Map<String, BitmapData>();

        super(spritemap, atlas, rawAnimationData);
    }

    @:allow(openfl.extensions.animate)
    public inline function getBitmapData(name : String):BitmapData
    {
        return bitmapDataMap.get(name);
    }

    private override function getSymbol(name:String) : IAtlasDisplayObjectContainer
    {
        var pool:Array<IAtlasDisplayObjectContainer> = getSymbolPool(name);
        if (pool.length == 0)
            return new AnimateAtlasSprite(this, name);
        else return pool.pop();
    }

    private override function parseDisplay(spritemap:BitmapData, atlas:openfl.extensions.animate.struct.ATLAS):Void
    {
        for(SPRITE in atlas.ATLAS.SPRITES)
        {
            var rect:Rectangle = new Rectangle(SPRITE.SPRITE.x, SPRITE.SPRITE.y, SPRITE.SPRITE.w, SPRITE.SPRITE.h);
            var bitmapData:BitmapData = new BitmapData(Std.int(rect.width), Std.int(rect.height));
            bitmapData.copyPixels(spritemap, rect, new Point(0, 0));
            bitmapDataMap.set(SPRITE.SPRITE.name, bitmapData);
        }
    }
}
