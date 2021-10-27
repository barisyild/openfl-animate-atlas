package openfl.extensions.animate.data;
class ColorData {

    public var mode: String;
    public var RedMultiplier:Null<Float>;
    public var greenMultiplier:Null<Float>;
    public var blueMultiplier:Null<Float>;
    public var alphaMultiplier:Null<Float>;
    public var redOffset:Null<Float>;
    public var greenOffset:Null<Float>;
    public var blueOffset:Null<Float>;
    public var AlphaOffset:Null<Float>;

    public function new(mode:String) {
        this.mode = mode;
    }

    public static function createFromAnimationAtlasData(data:openfl.extensions.animate.struct.AnimationAtlasData.ColorData):ColorData
    {
        var colorData:ColorData = new ColorData(data.mode);
        colorData.RedMultiplier = data.RedMultiplier;
        colorData.greenMultiplier = data.greenMultiplier;
        colorData.blueMultiplier = data.blueMultiplier;
        colorData.alphaMultiplier = data.alphaMultiplier;
        colorData.redOffset = data.redOffset;
        colorData.greenOffset = data.greenOffset;
        colorData.blueOffset = data.blueOffset;
        colorData.AlphaOffset = data.AlphaOffset;
        return colorData;
    }
}
