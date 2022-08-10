package openfl.extensions.animate.display;

import openfl.extensions.animate.type.LoopMode;
import openfl.extensions.animate.type.ObjectType;
import openfl.extensions.animate.data.SymbolData;
import openfl.utils.Function;
import openfl.display.TileContainer;

@:access(openfl.extensions.animate.display.AnimateAtlasPlayer)
class AnimateAtlasTile extends TileContainer implements IAtlasTileContainer
{
    public var _bitmap:Tile;

    private var _player:AnimateAtlasPlayer;

    @:access(openfl.extensions.animate.AnimateAtlasSheet)
    public function new(atlas:AnimateTileAtlasSheet, name:String = null)
    {
        super();
        var data = atlas.getSymbolData(name == null ? atlas._defaultSymbolName : name);
        this.tileset = atlas.tileset;

        _bitmap = new Tile();
        addTile(_bitmap);
        _bitmap.visible = false;

        _player = new AnimateAtlasPlayer(ObjectType.TILE, data, atlas, this, _bitmap);
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

    @:isVar public var name(get, set):String;
    public function get_name():String
    {
        return name;
    }

    public function set_name(value:String):String
    {
        return name = value;
    }

    public var loopMode(get, set):LoopMode;
    public function get_loopMode():LoopMode
    {
        return _player.loopMode;
    }

    public function set_loopMode(loopMode:LoopMode):LoopMode
    {
        return _player.loopMode = loopMode;
    }

    public var currentLabel(get, never):String;
    public function get_currentLabel():String
    {
        return _player.currentLabel;
    }

    public var currentFrame(get, set):Int;
    public function get_currentFrame():Int
    {
        return _player.currentFrame;
    }

    public function set_currentFrame(value : Int):Int
    {
        return _player.currentFrame = value;
    }

    public var symbolName(get, never):String;
    public function get_symbolName():String
    {
        return _player.symbolName;
    }

    public var numLayers(get, never):Int;
    public function get_numLayers():Int
    {
        return _player.numLayers;
    }

    public var numFrames(get, never):Int;
    public function get_numFrames():Int
    {
        return _player.numFrames;
    }

    public var frameRate(get, never):Float;
    public function get_frameRate():Float
    {
        return _player.frameRate;
    }
}
