package openfl.extensions.animate.data;
class Matrix3DData {
    public var m00:Float;
    public var m01:Float;
    public var m10:Float;
    public var m11:Float;
    public var m30:Float;
    public var m31:Float;
    
    public function new() {

    }

    public static inline function createFromAnimationAtlasData(data:openfl.extensions.animate.struct.AnimationAtlasData.Matrix3DData):Matrix3DData
    {
        var matrix3DData = new Matrix3DData();
        matrix3DData.m00 = data.m00;
        matrix3DData.m01 = data.m01;
        matrix3DData.m10 = data.m10;
        matrix3DData.m11 = data.m11;
        matrix3DData.m30 = data.m30;
        matrix3DData.m31 = data.m31;
        return matrix3DData;
    }
}
