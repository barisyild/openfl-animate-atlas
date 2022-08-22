package openfl.extensions.animate.display;

import openfl.extensions.animate.type.LoopMode;
import openfl.geom.Rectangle;
import openfl.events.MouseEvent;
import openfl.extensions.animate.data.SymbolData;
import openfl.events.Event;
import haxe.Constraints.Function;
import openfl.display.Sprite;
import openfl.extensions.animate.type.ObjectType;

@:access(openfl.extensions.animate.display.AnimateAtlasSprite)
@:access(openfl.extensions.animate.display.AnimateAtlasPlayer)
class AnimateAtlasButton extends Sprite
{
    /*
        up - default
        hit - mouse up state
        down - mouse down state
        over - mouse over state
     */

    private var animateAtlasSprite:AnimateAtlasSprite;

    @:access(openfl.extensions.animate.AnimateAtlasSheet)
    public function new(atlas:AnimateSpriteAtlasSheet, name:String = null, smoothing:Bool = false)
    {
        super();
        animateAtlasSprite = new AnimateAtlasSprite(atlas, name, smoothing);
        addChild(animateAtlasSprite);

        gotoAndStop("up");


        animateAtlasSprite.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
        animateAtlasSprite.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
        animateAtlasSprite.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
        animateAtlasSprite.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
    }

    private function onMouseDown(e:MouseEvent):Void
    {
        trace("onMouseDown");
        animateAtlasSprite.removeEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
        animateAtlasSprite.removeEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
        gotoAndStop("down");
    }

    private function onMouseUp(e:MouseEvent):Void
    {
        animateAtlasSprite.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
        animateAtlasSprite.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
        gotoAndStop("hit");
    }

    private function onMouseOver(e:MouseEvent):Void
    {
        trace("onMouseOver");
        gotoAndStop("over");
    }

    private function onMouseOut(e:MouseEvent):Void
    {
        trace("onMouseOut");
        gotoAndStop("up");
    }

    public function gotoAndStop(frame:String):Void
    {
        if(!hasFrame(frame))
            return;

        animateAtlasSprite._player.gotoAndStop(frame);
    }

    public inline function hasFrame(label : String):Bool
    {
        return getFrame(label) != -1;
    }

    public function getFrame(label : String) : Int
    {
        return animateAtlasSprite._player.getFrame(label);
    }
}
