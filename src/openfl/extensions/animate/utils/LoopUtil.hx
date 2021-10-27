package openfl.extensions.animate.utils;

import openfl.extensions.animate.type.LoopMode;
import openfl.errors.ArgumentError;

class LoopUtil {
    public static function parse(value:String):LoopMode
    {
        switch (value)
        {
            case "loop":
                return LoopMode.LOOP;
            case "LP":
                return LoopMode.LOOP;
            case "playonce":
                return LoopMode.PLAY_ONCE;
            case "PO":
                return LoopMode.PLAY_ONCE;
            case "singleframe":
                return LoopMode.SINGLE_FRAME;
            case "SF":
                return LoopMode.SINGLE_FRAME;
            default:throw new ArgumentError("Invalid loop mode: " + value);
        }
    }
}
