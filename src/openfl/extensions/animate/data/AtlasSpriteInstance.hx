package openfl.extensions.animate.data;
class AtlasSpriteInstance {
    public var name:String;
    public var matrix3D:Matrix3DData;
    public var decomposedMatrix:Decomposed3DData;

    public function new() {

    }

    public static function createFromAnimationAtlasData(data:openfl.extensions.animate.struct.AnimationAtlasData.AtlasSpriteInstance):AtlasSpriteInstance
    {
        var atlasSpriteInstance:AtlasSpriteInstance = new AtlasSpriteInstance();
        atlasSpriteInstance.name = data.name;
        atlasSpriteInstance.matrix3D = Matrix3DData.createFromAnimationAtlasData(data.matrix3D);
        atlasSpriteInstance.decomposedMatrix = Decomposed3DData.createFromAnimationAtlasData(data.decomposedMatrix);
        return atlasSpriteInstance;
    }
}
