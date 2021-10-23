//Credits: https://github.com/mathieuanthoine/OpenFl-Animate-Atlas-Player/blob/master/src/animateAtlasPlayer/utils/ArrayUtil.hx

package openfl.extensions.animate.utils;

class ArrayUtil {
    public static inline function CASEINSENSITIVE (pA:String, pB:String) : Int { return pA.toLowerCase() < pB.toLowerCase() ? -1 : 1; }
}
