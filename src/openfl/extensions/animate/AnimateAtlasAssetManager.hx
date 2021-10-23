package openfl.extensions.animate;

import openfl.extensions.animate.display.AnimateAtlasTileset;
import haxe.Json;
import openfl.display.BitmapData;
import openfl.utils.Assets;

class AnimateAtlasAssetManager {
    @:deprecated public static function loadAsset(directory:String):AnimationAtlas {
        directory = haxe.io.Path.addTrailingSlash(directory);
        var spritemap:BitmapData = Assets.getBitmapData(directory +  "spritemap1.png");
        var animationAtlasData:ATLAS = Json.parse(Assets.getText(directory +  "spritemap1.json"));
        var rawAnimationData:Dynamic = Json.parse(Assets.getText(directory +  "Animation.json"));

        var animateAtlasTileset:AnimateAtlasTileset = new AnimateAtlasTileset(spritemap);

        return new AnimationAtlas(rawAnimationData, animationAtlasData, animateAtlasTileset);
    }
}
