package openfl.extensions.animate.display;

import openfl.events.Event;
import haxe.Constraints.Function;
import openfl.display.Sprite;
import openfl.extensions.animate.type.ObjectType;

@:access(openfl.extensions.animate.display.AnimateAtlasPlayer)
class AnimateAtlasButton extends AnimateAtlasSprite implements IAtlasDisplayObjectContainer
{
    @:access(openfl.extensions.animate.AnimateAtlasSheet)
    public function new(atlas:AnimateSpriteAtlasSheet, name:String = null)
    {
        super(atlas, name);
    }
}
