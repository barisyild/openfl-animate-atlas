package openfl.extensions.animate.display;

import openfl.extensions.animate.type.LoopMode;
import openfl.utils.Function;
import openfl.display.Bitmap;
import openfl.display.Tile;
import openfl.display.TileContainer;

interface IAtlasTileContainer extends IAtlasObjectContainer {
    public var name(get, set):String;
    public var x(get, set):Float;
    public var y(get, set):Float;
    public var visible(get, set):Bool;
    public var alpha(get, set):Float;
}
