package openfl.extensions.animate.display;

import openfl.display.TileContainer;
import openfl.errors.TypeError;
import openfl.extensions.animate.type.LoopMode;
import openfl.extensions.animate.type.SymbolType;
import openfl.display.Tile;

//Credits: Joshua Granick
//Source: https://github.com/openfl/openfl/blob/aaf61de420c14515d53326c926cc1bd6a701031c/src/openfl/display/ChildAccess.hx

@:access(openfl.extensions.animate.display.AnimateSymbol)
@:transitive
@:forward
abstract AnimateChildAccess<T:AnimateSymbol>(T) from T to T
{
    @:op(a.b)
    @:arrayAccess
    private function __resolve(childName:String):AnimateChildAccess<AnimateSymbol>
    {
        if (this != null && #if (haxe_ver >= 4.2) Std.isOfType #else Std.is #end(this, AnimateSymbol))
        {
            var container:AnimateSymbol = cast this;
            return container.getSymbolByName(childName);
        }
        return null;
    }

    public var currentLabel(get, never):String;

    private inline function get_currentLabel():String
    {
        return this.currentLabel;
    }

    public var currentFrame(get, set):Int;

    private inline function get_currentFrame():Int
    {
        return this.currentFrame;
    }

    private inline function set_currentFrame(value:Int):Int
    {
        return this.currentFrame = value;
    }

    public var symbolName(get, never):String;

    private inline function get_symbolName():String
    {
        return this.symbolName;
    }

    public var numLayers(get, never):Int;

    private inline function get_numLayers():Int
    {
        return this.numLayers;
    }

    public var numFrames(get, never):Int;

    private inline function get_numFrames():Int
    {
        return this.numFrames;
    }

    public var frameRate(get, never):Float;

    private inline function get_frameRate():Float
    {
        return this.frameRate;
    }

    public var numTiles(get, never):Int;

    private inline function get_numTiles():Int
    {
        return this.numTiles;
    }

    public function addTile(tile:Tile):Tile
    {
        return addTile(tile);
    }

    public function addTileAt(tile:Tile, index:Int):Tile
    {
        return addTileAt(tile, index);
    }

    public function addTiles(tiles:Array<Tile>):Array<Tile>
    {
        return addTiles(tiles);
    }

    public function contains(tile:Tile):Bool
    {
        return contains(tile);
    }

    public function getTileAt(index:Int):Tile
    {
        return getTileAt(index);
    }

    public function getTileIndex(tile:Tile):Int
    {
        return getTileIndex(tile);
    }

    public function removeTile(tile:Tile):Tile
    {
        return removeTile(tile);
    }

    public function removeTileAt(index:Int):Tile
    {
        return removeTileAt(index);
    }

    public function removeTiles(beginIndex:Int = 0, endIndex:Int = 0x7fffffff):Void
    {
        removeTiles(beginIndex, endIndex);
    }

    public function setTileIndex(tile:Tile, index:Int):Void
    {
        setTileIndex(tile, index);
    }

    public function swapTiles(tile1:Tile, tile2:Tile):Void
    {
        swapTiles(tile1, tile2);
    }

    public function swapTilesAt(index1:Int, index2:Int):Void
    {
        swapTilesAt(index1, index2);
    }

    public inline function new(animateSymbol:T)
    {
        this = animateSymbol;
    }

    @:to private static inline function __toAnimateSymbol(value:AnimateChildAccess<AnimateSymbol>):AnimateSymbol
    {
        if (value != null && !#if (haxe_ver >= 4.2) Std.isOfType #else Std.is #end(value, AnimateSymbol))
        {
            throw new TypeError("Cannot cast object reference to AnimateSymbol");
        }

        return cast value;
    }
}
