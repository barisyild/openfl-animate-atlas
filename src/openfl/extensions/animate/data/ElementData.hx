package openfl.extensions.animate.data;
class ElementData {
    public var atlasSpriteInstance:Null<Dynamic>;
    public var symbolInstance:Null<SymbolInstanceData>;

    public function new() {
    }

    public static function createFromAnimationAtlasData(data:openfl.extensions.animate.struct.AnimationAtlasData.ElementData):ElementData
    {
        var elementData:ElementData = new ElementData();
        elementData.atlasSpriteInstance = data.atlasSpriteInstance; //Fix dynamic

        if(data.symbolInstance != null)
            elementData.symbolInstance = SymbolInstanceData.createFromAnimationAtlasData(data.symbolInstance);
        return elementData;
    }
}
