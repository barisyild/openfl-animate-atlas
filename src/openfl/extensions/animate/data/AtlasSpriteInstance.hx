package openfl.extensions.animate.data;
class AtlasSpriteInstance {
    public var name:String;
    public var position:Position2DData;
    public var matrix3D:Matrix3DData;
    public var decomposedMatrix:Decomposed3DData;

    public function new() {

    }

    public static function createFromAnimationAtlasData(data:openfl.extensions.animate.struct.AnimationAtlasData.AtlasSpriteInstance):AtlasSpriteInstance
    {
        var atlasSpriteInstance:AtlasSpriteInstance = new AtlasSpriteInstance();
        atlasSpriteInstance.name = data.name;

        if(data.position != null)
            atlasSpriteInstance.position = Position2DData.createFromAnimationAtlasData(data.position);

        if(data.matrix3D != null)
            atlasSpriteInstance.matrix3D = Matrix3DData.createFromAnimationAtlasData(data.matrix3D);

        if(data.decomposedMatrix != null)
            atlasSpriteInstance.decomposedMatrix = Decomposed3DData.createFromAnimationAtlasData(data.decomposedMatrix);
        return atlasSpriteInstance;
    }
}
