package openfl.extensions.animate.display;

import openfl.extensions.animate.type.LoopMode;
import openfl.utils.Function;
import openfl.display.Bitmap;
import openfl.display.Tile;

interface IAtlasDisplayObjectContainer extends IAtlasObjectContainer {
    #if flash
	public var name:String;
	#else
    public var name(get, set):String;
    #end

    #if flash
	public var visible:Bool;
	#else
    public var visible(get, set):Bool;
    #end

    #if flash
	public var alpha:Float;
	#else
    public var alpha(get, set):Float;
    #end

    #if flash
	public var x:Float;
	#else
    public var x(get, set):Float;
    #end

    #if flash
	public var y:Float;
	#else
    public var y(get, set):Float;
    #end
}
