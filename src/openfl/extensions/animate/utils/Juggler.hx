package openfl.extensions.animate.utils;

import openfl.extensions.animate.display.IAtlasObjectContainer;
import openfl.extensions.animate.display.AnimateAtlasTile;
import openfl.events.Event;

class Juggler {
    private static var _array:Array<IAtlasObjectContainer> = [];
    private static var _frameTimestamp:Float = 0.0;

    public static function init():Void
    {
        openfl.Lib.current.stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
    }

    public static function has(symbol:IAtlasObjectContainer):Bool {
        return _array.contains(symbol);
    }

    public static function add(symbol:IAtlasObjectContainer):Void {
        _array.push(symbol);
    }

    public static function remove(symbol:IAtlasObjectContainer):Void {
        _array.remove(symbol);
    }

    private static function onEnterFrame(e:Event):Void
    {
        //Source: https://github.com/Gamua/Starling-Framework/blob/5afc2c25219508d1173e7e683874d898bc33cc81/starling/src/starling/core/Starling.as#L396
        var now:Float = Lib.getTimer() / 1000.0;
        var passedTime:Float = now - _frameTimestamp;
        _frameTimestamp = now;

        if (passedTime > 1.0) passedTime = 1.0;

        if (passedTime < 0.0) passedTime = 1.0 / openfl.Lib.current.stage.frameRate;

        for(animation in _array)
        {
            animation.updateFrame(passedTime);
        }
    }
}
