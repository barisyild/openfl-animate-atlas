package openfl.extensions.animate;
import openfl.events.Event;
class Juggler {
    private static var arr:Array<Symbol> = [];

    public static function init():Void
    {
        openfl.Lib.current.stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
    }

    public static function add(animation:Symbol):Void {
        arr.push(animation);
    }

    private static function onEnterFrame(e:Event):Void
    {
        for(animation in arr)
        {
            animation.updateFrame(0.016);
        }
    }
}
