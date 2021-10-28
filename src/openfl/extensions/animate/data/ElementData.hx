package openfl.extensions.animate.data;
class ElementData {
    public var atlasSpriteInstance:Null<AtlasSpriteInstance>;
    public var symbolInstance:Null<SymbolInstanceData>;

    public function new() {
    }

    public static function createFromAnimationAtlasData(data:openfl.extensions.animate.struct.AnimationAtlasData.ElementData):ElementData
    {
        var elementData:ElementData = new ElementData();

        if(data.atlasSpriteInstance != null)
            elementData.atlasSpriteInstance = AtlasSpriteInstance.createFromAnimationAtlasData(data.atlasSpriteInstance);

        if(data.symbolInstance != null)
            elementData.symbolInstance = SymbolInstanceData.createFromAnimationAtlasData(data.symbolInstance);
        return elementData;
    }
}
