package openfl.extensions.animate.utils;

import openfl.extensions.animate.type.SymbolType;
import openfl.errors.ArgumentError;

class SymbolTypeUtil {
    public static function parse(value:String):SymbolType
    {
        switch (value)
        {
            case "G":
                return SymbolType.GRAPHIC;
            case "graphic":
                return SymbolType.GRAPHIC;
            case "MC":
                return SymbolType.MOVIE_CLIP;
            case "movieclip":
                return SymbolType.MOVIE_CLIP;
            case "B":
                return SymbolType.BUTTON;
            case "button":
                return SymbolType.BUTTON;
            default: throw new ArgumentError("Invalid symbol type: " + value);
        }
    }
}
