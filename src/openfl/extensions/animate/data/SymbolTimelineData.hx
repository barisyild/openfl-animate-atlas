package openfl.extensions.animate.data;
class SymbolTimelineData {
    public var sortedForRender:Null<Bool>;
    public var layers:Array<LayerData>;

    public function new() {

    }

    public static function createFromAnimationAtlasData(data:openfl.extensions.animate.struct.AnimationAtlasData.SymbolTimelineData):SymbolTimelineData
    {
        var symbolTimelineData:SymbolTimelineData = new SymbolTimelineData();
        symbolTimelineData.sortedForRender = data.sortedForRender;

        symbolTimelineData.layers = [];
        for(layer in data.layers)
        {
            symbolTimelineData.layers.push(LayerData.createFromAnimationAtlasData(layer));
        }

        return symbolTimelineData;
    }
}
