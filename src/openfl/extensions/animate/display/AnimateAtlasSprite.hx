package openfl.extensions.animate.display;

import openfl.display.Sprite;
import haxe.Constraints.Function;
import openfl.display.Tile;
import openfl.display.TileContainer;
import openfl.extensions.animate.data.SymbolData;
import openfl.extensions.animate.type.ObjectType;

@:access(openfl.extensions.animate.display.AnimateAtlasPlayer)
class AnimateAtlasSprite extends Sprite implements IAtlasDisplayObjectContainer
{
    public var currentLabel(get, never):String;
    public var currentFrame(get, set):Int;
    public var symbolName(get, never):String;
    public var numLayers(get, never):Int;
    public var numFrames(get, never):Int;
    public var frameRate(get, never):Float;
    public var _bitmap:Bitmap;


    private var _player:AnimateAtlasPlayer;

    @:access(openfl.extensions.animate.AnimateAtlasSheet)
    public function new(atlas:AnimateSpriteAtlasSheet, name:String = null)
    {
        super();
        var data = atlas.getSymbolData(name == null ? atlas._defaultSymbolName : name);

        _bitmap = new Bitmap();
        addChild(_bitmap);
        _bitmap.visible = false;

        _player = new AnimateAtlasPlayer(ObjectType.DISPLAYOBJECT, data, atlas, this, _bitmap);
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

    public inline function getSymbolByName(name:String):IAtlasDisplayObjectContainer
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
