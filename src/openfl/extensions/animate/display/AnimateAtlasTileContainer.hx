package openfl.extensions.animate.display;
import openfl.display.TileContainer;
class AnimateAtlasTileContainer extends AnimateSymbol {

    @:access(openfl.extensions.animate.AnimateAtlasSheet)
    public function new(atlas:AnimateAtlasSheet, name:String = null) {
        super(atlas.getSymbolData(name == null ? atlas._defaultSymbolName : name), atlas);
        tileset = atlas.tileset;
    }
}
