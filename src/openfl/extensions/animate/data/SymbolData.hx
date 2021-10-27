package openfl.extensions.animate.data;
class SymbolData {
    public var name:Null<String>;
    public var symbolName: String;
    public var timeline:Null<SymbolTimelineData>;

    public function new() {

    }

    public static function createFromAnimationAtlasData(data:openfl.extensions.animate.struct.AnimationAtlasData.SymbolData):SymbolData
    {
        var symbolData:SymbolData = new SymbolData();
        symbolData.name = data.name;
        symbolData.symbolName = data.symbolName;

        if(data.timeline != null)
            symbolData.timeline = SymbolTimelineData.createFromAnimationAtlasData(data.timeline);

        return symbolData;
    }
}
