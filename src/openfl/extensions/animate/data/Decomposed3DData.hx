package openfl.extensions.animate.data;

import openfl.geom.Vector3D;

class Decomposed3DData {
    public var position:Vector3D;
    public var rotation:Vector3D;
    public var scaling:Vector3D;

    public function new(position:Vector3D, rotation:Vector3D, scaling:Vector3D) {
        this.position = position;
        this.rotation = rotation;
        this.scaling = scaling;
    }

    public static inline function createFromAnimationAtlasData(data:openfl.extensions.animate.struct.AnimationAtlasData.Decomposed3DData):Decomposed3DData
    {
        return new Decomposed3DData(
            new Vector3D(data.position.x, data.position.y, data.position.z),
            new Vector3D(data.rotation.x, data.rotation.y, data.rotation.z),
            new Vector3D(data.scaling.x, data.scaling.y, data.scaling.z)
        );
    }
}