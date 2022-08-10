package openfl.extensions.animate.display;

import openfl.extensions.animate.type.LoopMode;
import openfl.utils.Function;
import openfl.display.Bitmap;
import openfl.display.Tile;

interface IAtlasObjectContainer {
    public var symbolName(get, never):String;
    public var currentFrame(get, set):Int;
    public var loopMode(get, set):LoopMode;

    private var _player:AnimateAtlasPlayer;

    public function addFrameScript(frame:Int, func:Function):Void;
    public function removeFrameScript(frame:Int, func:Function):Void;
    public function gotoAndPlay(frame:Dynamic):Void;
    public function gotoAndStop(frame:Dynamic):Void;
    public function play():Void;
    public function stop():Void;
    public function getSymbolByName(name:String):IAtlasObjectContainer;
    public function updateFrame(delta:Float):Void;
    public function nextFrame_MovieClips():Void;

    #if !flash
    private function __setRenderDirty():Void;
    #end
}
