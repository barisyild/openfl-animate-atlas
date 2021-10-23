package openfl.extensions.animate;
import openfl.events.Event;
class Juggler {
    private static var array:Array<Symbol> = [];

    public static function init():Void
    {
        openfl.Lib.current.stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
    }

    public static function has(symbol:Symbol):Bool {
        return array.contains(symbol);
    }

    public static function add(symbol:Symbol):Void {
        array.push(symbol);
    }

    public static function remove(symbol:Symbol):Void {
        array.remove(symbol);
    }

    private static function onEnterFrame(e:Event):Void
    {
        for(animation in array)
        {
            animation.updateFrame(0.016);
        }
    }
}
