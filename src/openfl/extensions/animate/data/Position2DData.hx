package openfl.extensions.animate.data;
class Position2DData {
    public var x:Float;
    public var y:Float;

    public function new() {

    }

    public static function createFromAnimationAtlasData(data:openfl.extensions.animate.struct.AnimationAtlasData.Position2DData):Position2DData
    {
        var position2DData:Position2DData = new Position2DData();
        position2DData.x = data.x;
        position2DData.y = data.y;
        return position2DData;
    }
}
