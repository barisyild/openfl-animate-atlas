package openfl.extensions.animate.display;

import openfl.display.Tileset;
import openfl.display.Tile;
import openfl.display.BitmapData;
import openfl.display.Bitmap;

class Image extends Tile {
    private var _paddingX:Float = 0.0;
    private var _paddingY:Float = 0.0;

    public function new() {
        super();
    }

    public function parseBitmapData(bitmapData:BitmapData = null)
    {
        if(bitmapData != null)
        {
            tileset = new Tileset(bitmapData);
            tileset.addRect(bitmapData.rect);
        }
    }

    public inline function readjustSize():Void
    {
        //TODO: no need
    }

    public function removeFromParent()
    {
        //TODO: Check functionality, not tested
        parent.removeTile(this);
    }

    @:setter(x) private #if !flash override #end function set_x(value:Float)
    {
        _paddingX = value;
        return _paddingX;
    }

    @:setter(y) private #if !flash override #end function set_y(value:Float)
    {
        _paddingY = value;
        return _paddingY;
    }
}
