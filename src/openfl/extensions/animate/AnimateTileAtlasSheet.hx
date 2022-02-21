package openfl.extensions.animate;

import openfl.geom.Rectangle;
import openfl.extensions.animate.display.AnimateAtlasTileset;
import openfl.display.BitmapData;
import openfl.extensions.animate.display.AnimateAtlasTile;
import openfl.extensions.animate.display.IAtlasDisplayObjectContainer;

class AnimateTileAtlasSheet extends AnimateAtlasSheet {
    public var tileset(default, null):AnimateAtlasTileset;

    public function new(spritemap:BitmapData, atlas:openfl.extensions.animate.struct.ATLAS, rawAnimationData:Dynamic) {
        tileset = new AnimateAtlasTileset(spritemap);

        super(spritemap, atlas, rawAnimationData);
    }

    @:allow(openfl.extensions.animate)
    public function getId(name : String):Int
    {
        return tileset.__names.get(name);
    }

    private override function parseDisplay(spritemap:BitmapData, atlas:openfl.extensions.animate.struct.ATLAS):Void
    {
        for(SPRITE in atlas.ATLAS.SPRITES)
        {
            //TODO: Use rect pooling
            var rect:Rectangle = new Rectangle(SPRITE.SPRITE.x, SPRITE.SPRITE.y, SPRITE.SPRITE.w, SPRITE.SPRITE.h);
            tileset.__names.set(SPRITE.SPRITE.name, tileset.addRect(rect));
        }

        /*for (symbolData in data.symbolDictionary.symbols)
        {
            tileset.__names.set(symbolData.symbolName, tileset.addRect(new Rectangle(0, 337, 257, 166)));
        }*/
    }

    private override function getSymbol(name:String) : IAtlasDisplayObjectContainer
    {
        var pool:Array<IAtlasDisplayObjectContainer> = getSymbolPool(name);
        if (pool.length == 0)
            return new AnimateAtlasTile(this, name);
        else return pool.pop();
    }
}
