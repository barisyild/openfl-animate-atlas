// =================================================================================================
//
//	Starling Framework
//	Copyright Gamua GmbH. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package openfl.extensions.animate.utils;

class MathUtil {
    /** Moves <code>value</code> into the range between <code>min</code> and <code>max</code>. */
    public static function clamp(value:Float, min:Float, max:Float):Float
    {
        return value < min ? min : (value > max ? max : value);
    }
}
