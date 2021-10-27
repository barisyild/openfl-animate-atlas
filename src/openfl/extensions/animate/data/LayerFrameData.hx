package openfl.extensions.animate.data;
class LayerFrameData {
    public var index: Int;
    public var name:Null<String>;
    public var duration: Int;
    public var elements:Array<ElementData>;

    public function new() {

    }

    public static function createFromAnimationAtlasData(data:openfl.extensions.animate.struct.AnimationAtlasData.LayerFrameData):LayerFrameData
    {
        var layerFrameData:LayerFrameData = new LayerFrameData();
        layerFrameData.index = data.index;
        layerFrameData.name = data.name;
        layerFrameData.duration = data.duration;

        layerFrameData.elements = [];
        for(element in data.elements)
        {
            layerFrameData.elements.push(ElementData.createFromAnimationAtlasData(element));
        }

        return layerFrameData;
    }
}
