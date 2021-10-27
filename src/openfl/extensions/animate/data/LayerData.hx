package openfl.extensions.animate.data;
class LayerData {
    public var layerName: String;
    public var frames: Array<LayerFrameData>;
    public var FrameMap: Map<Int, LayerFrameData>;

    public function new() {

    }

    public static function createFromAnimationAtlasData(data:openfl.extensions.animate.struct.AnimationAtlasData.LayerData):LayerData
    {
        var layerData:LayerData = new LayerData();
        layerData.layerName = data.layerName;

        layerData.frames = [];
        for(layerFrameData in data.frames)
        {
            layerData.frames.push(LayerFrameData.createFromAnimationAtlasData(layerFrameData));
        }

        layerData.FrameMap = new Map<Int, LayerFrameData>();
        if(data.FrameMap != null)
        {
            for(key in data.FrameMap.keys())
            {
                layerData.FrameMap.set(key, LayerFrameData.createFromAnimationAtlasData(data.FrameMap.get(key)));
            }
        }

        return layerData;
    }
}
