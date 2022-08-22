package openfl.extensions.animate.display;

import openfl.extensions.animate.type.LoopMode;
import openfl.events.Event;
import openfl.display.Sprite;
import openfl.utils.Function;
import openfl.display.Tile;
import openfl.display.TileContainer;
import openfl.extensions.animate.data.SymbolData;
import openfl.extensions.animate.type.ObjectType;

@:access(openfl.extensions.animate.display.AnimateAtlasPlayer)
class AnimateAtlasSprite extends Sprite implements IAtlasDisplayObjectContainer
{
    private var _frameTimestamp:Float = 0.0;

    public var loopMode(get, set):LoopMode;
    public var currentLabel(get, never):String;
    public var currentFrame(get, set):Int;
    public var symbolName(get, never):String;
    public var numLayers(get, never):Int;
    public var numFrames(get, never):Int;
    public var frameRate(get, never):Float;
    public var _bitmap:Bitmap;

    private var _player:AnimateAtlasPlayer;

    @:access(openfl.extensions.animate.AnimateAtlasSheet)
    public function new(atlas:AnimateSpriteAtlasSheet, name:String = null, smoothing:Bool = false)
    {
        super();
        var data = atlas.getSymbolData(name == null ? atlas._defaultSymbolName : name);

        _bitmap = new Bitmap();
        addChild(_bitmap);
        _bitmap.visible = false;

        _player = new AnimateAtlasPlayer(ObjectType.DISPLAYOBJECT, data, atlas, this, _bitmap);
        _player.smoothing = smoothing;
        #if flash
        this.addEventListener(Event.ENTER_FRAME, onEnterFrame);
        #end
    }

    private function onEnterFrame(e:Event):Void
    {
        #if flash
        @:inline __enterFrame(0);
        #end
    }

    private #if !flash override #end function __enterFrame(deltaTime:Int):Void
    {
        var now:Float = Lib.getTimer() / 1000.0;
        var passedTime:Float = now - _frameTimestamp;
        _frameTimestamp = now;

        if (passedTime > 1.0) passedTime = 1.0;

        if (passedTime < 0.0) passedTime = 1.0 / openfl.Lib.current.stage.frameRate;

        updateFrame(passedTime);
    }

    public inline function addFrameScript(frame:Int, func:Function):Void
    {
        _player.addFrameScript(frame, func);
    }

    public inline function removeFrameScript(frame:Int, func:Function):Void
    {
        _player.removeFrameScript(frame, func);
    }

    public inline function gotoAndPlay(frame:Dynamic)
    {
        _player.gotoAndPlay(frame);
    }

    public inline function gotoAndStop(frame:Dynamic)
    {
        _player.gotoAndStop(frame);
    }

    public inline function play():Void
    {
        _player.play();
    }

    public inline function stop():Void
    {
        _player.stop();
    }

    public inline function getSymbolByName(name:String):IAtlasObjectContainer
    {
        return _player.getSymbolByName(name);
    }

    public inline function updateFrame(delta:Float):Void
    {
        _player.updateFrame(delta);
    }

    public inline function update():Void
    {
        _player.update();
    }

    public function nextFrame_MovieClips():Void
    {
        _player.nextFrame_MovieClips();
    }

    public function get_loopMode():LoopMode
    {
        return _player.loopMode;
    }

    public function set_loopMode(loopMode:LoopMode):LoopMode
    {
        return _player.loopMode = loopMode;
    }

    public function get_currentLabel():String
    {
        return _player.currentLabel;
    }

    public function get_currentFrame():Int
    {
        return _player.currentFrame;
    }

    public function set_currentFrame(value : Int):Int
    {
        return _player.currentFrame = value;
    }

    public function get_symbolName():String
    {
        return _player.symbolName;
    }

    public function get_numLayers():Int
    {
        return _player.numLayers;
    }

    public function get_numFrames():Int
    {
        return _player.numFrames;
    }

    public function get_frameRate():Float
    {
        return _player.frameRate;
    }
}