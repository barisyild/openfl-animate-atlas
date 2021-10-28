package openfl.extensions.animate.data;
class Matrix3DData {
    public var m00:Float;
    public var m01:Float;
    public var m02:Float;
    public var m03:Float;
    public var m10:Float;
    public var m11:Float;
    public var m12:Float;
    public var m13:Float;
    public var m20:Float;
    public var m21:Float;
    public var m22:Float;
    public var m23:Float;
    public var m30:Float;
    public var m31:Float;
    public var m32:Float;
    public var m33:Float;
    
    public function new() {

    }

    public static inline function createFromAnimationAtlasData(data:openfl.extensions.animate.struct.AnimationAtlasData.Matrix3DData):Matrix3DData
    {
        var matrix3DData = new Matrix3DData();
        matrix3DData.m00 = data.m00;
        matrix3DData.m01 = data.m01;
        matrix3DData.m02 = data.m02;
        matrix3DData.m03 = data.m03;
        matrix3DData.m10 = data.m10;
        matrix3DData.m11 = data.m11;
        matrix3DData.m12 = data.m12;
        matrix3DData.m13 = data.m13;
        matrix3DData.m20 = data.m20;
        matrix3DData.m21 = data.m21;
        matrix3DData.m22 = data.m22;
        matrix3DData.m23 = data.m23;
        matrix3DData.m30 = data.m30;
        matrix3DData.m31 = data.m31;
        matrix3DData.m32 = data.m32;
        matrix3DData.m33 = data.m33;
        return matrix3DData;
    }
}
