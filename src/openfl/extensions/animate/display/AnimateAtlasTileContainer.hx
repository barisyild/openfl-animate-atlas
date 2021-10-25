package openfl.extensions.animate.display;
import openfl.display.TileContainer;
class AnimateAtlasTileContainer extends AnimateSymbol {

    @:access(openfl.extensions.animate.AnimationAtlas)
    public function new(atlas:AnimationAtlas, name:String = null) {
        super(atlas.getSymbolData(name == null ? atlas._defaultSymbolName : name), atlas);
        tileset = atlas._tileset;
    }
}
