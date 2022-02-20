package openfl.extensions.animate.display;

import openfl.extensions.animate.data.LayerData;
import openfl.extensions.animate.utils.MathUtil;
import openfl.geom.Matrix;
import openfl.extensions.animate.data.ColorData;
import openfl.extensions.animate.data.Matrix3DData;
import openfl.extensions.animate.data.AtlasSpriteInstance;
import openfl.extensions.animate.data.SymbolInstanceData;
import openfl.extensions.animate.data.ElementData;
import openfl.extensions.animate.data.LayerFrameData;
import openfl.display.Tile;
import openfl.display.TileContainer;
import openfl.extensions.animate.type.LoopMode;
import openfl.extensions.animate.type.SymbolType;
import openfl.filters.ColorMatrixFilter;
import openfl.display.FrameLabel;
import openfl.extensions.animate.data.SymbolData;
import openfl.utils.Function;

@:access(openfl.display.TileContainer)
@:access(openfl.display.Tile)
class AnimateAtlasPlayer {
    public static inline var BITMAP_SYMBOL_NAME : String = "___atlas_sprite___";

    private static var ALPHA_MODES = ["Alpha", "Advanced", "AD"];
    private static var sMatrix:Matrix = new Matrix();

    private var _currentFrame : Int = 0;
    public var currentFrame(get, set):Int;
    public var currentLabel(get, never):String;
    public var frameRate(get, never):Float;

    private var type:SymbolType;
    private var loopMode:LoopMode;

    private var data : SymbolData;
    private var atlas : AnimateAtlasSheet;
    private var frameScripts:Map<Int, Function>;
    private var cumulatedTime : Float = 0.0;
    private var playing:Bool = true;
    private var symbolName : String;
    private var composedFrame : Int = 0;
    private var numFrames : Int = 0;
    private var numLayers : Int = 0;
    private var frameLabels : Array<FrameLabel>;
    private var colorTransform:ColorMatrixFilter;

    private var container:TileContainer;
    private var display:Tile;


    public function new(data:SymbolData, atlas:AnimateAtlasSheet, container:TileContainer, display:Tile) {
        this.data = data;
        this.atlas = atlas;
        this.container = container;
        this.display = display;

        frameScripts = new Map<Int, Function>();

        composedFrame = -1;
        numLayers = data.timeline.layers.length;
        numFrames = getNumFrames();
        frameLabels = getFrameLabels();
        symbolName = data.symbolName;
        type = SymbolType.GRAPHIC;
        loopMode = LoopMode.LOOP;

        createLayers();
        update();
    }

    public function addFrameScript(frame:Int, func:Function):Void
    {
        frameScripts.set(frame, func);
    }

    public function removeFrameScript(frame:Int, func:Function):Void
    {
        frameScripts.remove(frame);
    }

    public function gotoAndPlay(frame:Dynamic)
    {
        currentFrame = Std.isOfType(frame, String) ? getFrame(cast frame) : Std.int(frame);
        play();
    }

    public function gotoAndStop(frame:Dynamic)
    {
        gotoAndPlay(frame);
        stop();
    }

    public function play():Void
    {
        playing = true;
    }

    public function stop():Void
    {
        playing = false;
    }

    public function getSymbolByName(name:String):AnimateAtlasTile
    {
        for (l in 0...numLayers)
        {
            var layer:TileContainer = getLayer(l);
            var numElements:Int = layer.numTiles;

            for (e in 0...numElements)
            {
                if(cast(layer.getTileAt(e),AnimateAtlasTile).name == name)
                    return cast layer.getTileAt(e);
            }
        }

        return null;
    }

    public function reset():Void
    {
        container.alpha = 1.0;
        currentFrame = 0;
        composedFrame = -1;
    }

    public function updateFrame(delta:Float):Void
    {
        var frameRate : Float = atlas.frameRate;
        var prevTime : Float = cumulatedTime;

        cumulatedTime += delta;

        if (Std.int(prevTime * frameRate) != Std.int(cumulatedTime * frameRate))
        {
            if(playing)
                currentFrame += 1;
            nextFrame_MovieClips();
        }
    }

    /** To be called whenever sufficient time for one frame has passed. Does not necessarily
         *  move 'currentFrame' ahead - depending on the 'loop' mode. MovieClips all move
         *  forward, though (recursively). */
    /*public function nextFrame():Void
    {
        if (loopMode != LoopMode.SINGLE_FRAME)
            currentFrame += 1;

        nextFrame_MovieClips();
    }*/

    /** Moves all movie clips ahead one frame, recursively. */
    public function nextFrame_MovieClips():Void
    {
        if (type == SymbolType.MOVIE_CLIP && playing)
            currentFrame += 1;

        for (l in 0...numLayers)
        {
            var layer:TileContainer = getLayer(l);
            var numElements:Int = layer.numTiles;

            for (e in 0...numElements)
            {
                var layerTile:AnimateAtlasTile = cast layer.getTileAt(e);
                layerTile.nextFrame_MovieClips();
            }
        }
    }

    public function update():Void
    {
        for (i in 0...numLayers)
            updateLayer(i);

        composedFrame = currentFrame;
    }

    private function updateLayer(layerIndex:Int):Void
    {
        var layer:TileContainer = getLayer(layerIndex);
        var frameData:LayerFrameData = getFrameData(layerIndex, currentFrame);
        var elements:Array<ElementData> = frameData != null ? frameData.elements : null;
        var numElements:Int = elements != null ? elements.length : 0;

        var oldSymbol:AnimateAtlasTile = null;

        for (i in 0...numElements)
        {
            var elementData:SymbolInstanceData = elements[i].symbolInstance;
            oldSymbol = layer.numTiles > i ? cast layer.getTileAt(i) : null;
            var newSymbol:AnimateAtlasTile = null;
            var symbolName:String = elementData.symbolName;

            if (!atlas.hasSymbol(symbolName))
                symbolName = BITMAP_SYMBOL_NAME;

            if (oldSymbol != null && oldSymbol.symbolName == symbolName)
                newSymbol = oldSymbol;
            else
            {
                if (oldSymbol != null)
                {
                    layer.removeTile(oldSymbol);
                }

                newSymbol = atlas.getSymbol(symbolName);
                layer.addTileAt(newSymbol, i);
            }

            newSymbol.name = elementData.instanceName;

            var atlasPlayer:AnimateAtlasPlayer = cast newSymbol._player;
            atlasPlayer.setTransformationMatrix(elementData.matrix3D);
            atlasPlayer.setBitmap(elementData.bitmap);
            atlasPlayer.setColor(elementData.color);
            atlasPlayer.setLoop(elementData.loop);
            atlasPlayer.setType(elementData.symbolType);

            if (atlasPlayer.type == SymbolType.GRAPHIC)
            {
                var firstFrame:Int = elementData.firstFrame;
                var frameAge:Int = Std.int(currentFrame - frameData.index);

                if (atlasPlayer.loopMode == LoopMode.SINGLE_FRAME)
                {
                    stop();
                    atlasPlayer.currentFrame = firstFrame;
                }
                else if (atlasPlayer.loopMode == LoopMode.LOOP)
                {
                    atlasPlayer.currentFrame = (firstFrame + frameAge) % atlasPlayer.numFrames;
                }
                else
                {
                    atlasPlayer.currentFrame = firstFrame + frameAge;
                }
            }
        }

        var numObsoleteSymbols:Int = layer.numTiles - numElements;

        for (i in 0...numObsoleteSymbols)
        {
            oldSymbol = cast layer.removeTileAt(numElements);
            atlas.putSymbol(oldSymbol);
        }

        if(frameScripts.exists(currentFrame))
        {
            frameScripts.get(currentFrame)();
        }
    }

    private function createLayers():Void
    {
        for (i in 0...numLayers)
        {
            var layer:TileContainer = new TileContainer();
            container.addTile(layer);
        }
    }

    @:access(openfl.extensions.animate.display.AnimateAtlasTile)
    public inline function setBitmap(data:AtlasSpriteInstance):Void
    {
        if (data != null)
        {
            display.visible = true;

            display.id = atlas.getId(data.name);

            if(data.position != null)
            {
                display.x = data.position.x;
                display.y = data.position.y;
            }else{
                if(display.matrix.a != data.matrix3D.m00 || display.matrix.b != data.matrix3D.m01 || display.matrix.c != data.matrix3D.m10 || display.matrix.d != data.matrix3D.m11 || display.matrix.tx != data.matrix3D.m30 || display.matrix.ty != data.matrix3D.m31)
                {
                    display.matrix.setTo(data.matrix3D.m00, data.matrix3D.m01, data.matrix3D.m10, data.matrix3D.m11, data.matrix3D.m30, data.matrix3D.m31);
                    display.__setRenderDirty();
                }
            }
        }
        else if (display != null)
        {
            display.visible = false;
        }
    }

    private inline function setTransformationMatrix(data:Matrix3DData):Void
    {
        if(container.matrix.a != data.m00 || container.matrix.b != data.m01 || container.matrix.c != data.m10 || container.matrix.d != data.m11 || container.matrix.tx != data.m30 || container.matrix.ty != data.m31)
        {
            container.matrix.setTo(data.m00, data.m01, data.m10, data.m11, data.m30, data.m31);
            container.__setRenderDirty();
        }
    }

    private inline function setColor(data:ColorData):Void
    {
        if (data != null)
        {
            var mode:String = data.mode;
            container.alpha = (ALPHA_MODES.indexOf(mode) >= 0) ? data.alphaMultiplier : 1.0;
        }
        else
        {
            container.alpha = 1.0;
        }
    }

    private function setLoop(data:Null<LoopMode>):Void
    {
        if (data != null)
            loopMode = data;
        else
            loopMode = LoopMode.LOOP;
    }

    private inline function setType(data:Null<SymbolType>):Void
    {
        if (data != null)
            type = data;
    }

    private function getNumFrames() : Int
    {
        var numFrames : Int = 0;

        for (i in 0...numLayers)
        {
            var frameDates:Array<LayerFrameData> = getLayerData(i).frames;
            var numFrameDates:Int = frameDates != null ? frameDates.length : 0;
            var layerNumFrames:Int = numFrameDates != 0 ? frameDates[0].index : 0;

            for (j in 0...numFrameDates)
                layerNumFrames += frameDates[j].duration;

            if (layerNumFrames > numFrames)
                numFrames = layerNumFrames;
        }

        return numFrames == 0 ? 1 : numFrames;
    }

    private function getFrameLabels():Array<FrameLabel>
    {
        var labels:Array<FrameLabel> = [];

        for (i in 0...numLayers)
        {
            var frameDates:Array<LayerFrameData> = getLayerData(i).frames;
            var numFrameDates:Int = frameDates != null ? frameDates.length : 0;

            for (j in 0...numFrameDates)
            {
                var frameData:LayerFrameData = frameDates[j];
                //if ("name" in frameData)
                //todo check this
                if (frameData.name != null)
                {
                    labels[labels.length] = new FrameLabel(frameData.name, frameData.index);
                }else{
                    //trace(frameData);
                }
            }
        }

        //labels.sortOn('frame', Array.NUMERIC);
        labels.sort(sortLabels);
        return labels;
    }

    private function sortLabels(i1:FrameLabel, i2:FrameLabel):Int
    {
        var f1 = i1.frame;
        var f2 = i2.frame;
        if (f1 < f2){
            return -1;
        }else if (f1 > f2){
            return 1;
        }else{
            return 0;
        }
    }

    private inline function getLayer(layerIndex:Int):TileContainer
    {
        return cast container.getTileAt(layerIndex + 1);
    }

    public function getNextLabel(afterLabel:String=null):String
    {
        var numLabels:Int = frameLabels.length;
        var startFrame:Int = getFrame(afterLabel == null ? currentLabel : afterLabel);
        //todo check getFrame

        for (i in 0...numLabels)
        {
            var label:FrameLabel = frameLabels[i];
            if (label.frame > startFrame)
                return label.name;
        }

        return frameLabels != null ? frameLabels[0].name : null; // wrap around
    }

    private function get_currentLabel() : String
    {
        var numLabels:Int = frameLabels.length;
        var highestLabel:FrameLabel = numLabels != 0 ? frameLabels[0] : null;

        for (i in 0...numLabels)
        {
            var label:FrameLabel = frameLabels[i];

            if (label.frame <= currentFrame)
                highestLabel = label;
            else
                break;
        }

        return highestLabel != null ? highestLabel.name : null;
    }

    public function getFrame(label : String) : Int
    {
        var numLabels:Int = frameLabels.length;
        for (i in 0...numLabels)
        {
            var frameLabel:FrameLabel = frameLabels[i];
            if (frameLabel.name == label)
                return frameLabel.frame;
        }
        return -1;
    }

    private inline function get_currentFrame() : Int
    {
        return _currentFrame;
    }

    private function set_currentFrame(value : Int) : Int
    {
        while (value < 0)
            value += numFrames;

        if (loopMode == LoopMode.PLAY_ONCE)
            _currentFrame = Std.int(MathUtil.clamp(value, 0, numFrames - 1));
        else
            _currentFrame = Std.int(Math.abs(value % numFrames));

        if (composedFrame != _currentFrame)
            update();

        return value;
    }

    private inline function get_frameRate():Float
    {
        return atlas.frameRate;
    }

    // data access

    private inline function getLayerData(layerIndex : Int):LayerData
    {
        return data.timeline.layers[layerIndex];
    }

    private function getFrameData(layerIndex:Int, frameIndex:Int):LayerFrameData
    {
        var frames:Array<LayerFrameData> = getLayerData(layerIndex).frames;
        var numFrames:Int = frames.length;

        for (i in 0...numFrames)
        {
            var frame:LayerFrameData = frames[i];
            if (frame.index <= frameIndex && frame.index + frame.duration > frameIndex)
                return frame;
        }

        return null;
    }
}
