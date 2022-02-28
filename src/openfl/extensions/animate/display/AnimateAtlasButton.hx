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

    private var colission:Sprite;
    private var animateAtlasSprite:AnimateAtlasSprite;

    @:access(openfl.extensions.animate.AnimateAtlasSheet)
    public function new(atlas:AnimateSpriteAtlasSheet, name:String = null)
    {
        super();
        animateAtlasSprite = new AnimateAtlasSprite(atlas, name);
        addChild(animateAtlasSprite);

        colission = animateAtlasSprite;

        gotoAndStop("up");


        colission.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
        colission.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
        colission.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
        colission.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
    }

    private function onMouseDown(e:MouseEvent):Void
    {
        trace("onMouseDown");
        colission.removeEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
        colission.removeEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
        gotoAndStop("down");
    }

    private function onMouseUp(e:MouseEvent):Void
    {
        colission.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
        colission.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
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
