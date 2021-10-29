package openfl.extensions.animate.display;

import openfl.extensions.animate.data.AtlasSpriteInstance;
import openfl.extensions.animate.data.ColorData;
import openfl.extensions.animate.data.Matrix3DData;
import openfl.extensions.animate.data.ElementData;
import openfl.extensions.animate.data.SymbolInstanceData;
import openfl.extensions.animate.data.LayerData;
import openfl.extensions.animate.data.LayerFrameData;
import openfl.extensions.animate.data.SymbolData;
import openfl.extensions.animate.type.LoopMode;
import haxe.Constraints.Function;
import openfl.extensions.animate.display.AnimateAtlasTile;
import openfl.display.Tile;
import openfl.display.TileContainer;
import openfl.extensions.animate.display.AnimateAtlasTileContainer;
import openfl.extensions.animate.utils.MathUtil;
import openfl.display.BitmapData;
import openfl.extensions.animate.type.SymbolType;
import openfl.filters.ColorMatrixFilter;
import openfl.display.FrameLabel;
import openfl.errors.ArgumentError;
import openfl.errors.Error;
import openfl.geom.Matrix;

class AnimateSymbol extends TileContainer
{
    public var currentLabel(get, never):String;
    public var currentFrame(get, set):Int;
    public var symbolName(get, never):String;
    public var numLayers(get, never):Int;
    public var numFrames(get, never):Int;
    public var frameRate(get, never):Float;

    public static inline var BITMAP_SYMBOL_NAME : String = "___atlas_sprite___";

    public var name:String;
    public var type:SymbolType;
    public var loopMode:LoopMode;

    private var _cumulatedTime : Float = 0.0;
    private var _playing:Bool = true;
    private var _data : SymbolData;
    private var _atlas : AnimateAtlasSheet;
    private var _symbolName : String;
    private var _currentFrame : Int = 0;
    private var _composedFrame : Int = 0;
    private var _bitmap:AnimateAtlasTile;
    private var _numFrames : Int = 0;
    private var _numLayers : Int = 0;
    private var _frameLabels : Array<FrameLabel>;
    private var _colorTransform:ColorMatrixFilter;
    private var _frameScripts:Map<Int, Function>;

    private static var ALPHA_MODES = ["Alpha", "Advanced", "AD"];
    private static var sMatrix : Matrix = new Matrix();

    @:access(openfl.extensions.animate.AnimateAtlasSheet)
    public function new(data:SymbolData, atlas:AnimateAtlasSheet)
    {
        super();
        _data = data;
        _atlas = atlas;
        _composedFrame = -1;
        _numLayers = data.timeline.layers.length;
        _numFrames = getNumFrames();
        _frameLabels = getFrameLabels();
        _symbolName = data.symbolName;
        type = SymbolType.GRAPHIC;
        loopMode = LoopMode.LOOP;
        _frameScripts = new Map<Int, Function>();
        _bitmap = new AnimateAtlasTile();

        addTile(_bitmap);
        _bitmap.visible = false;

        createLayers();
        update();
    }

    public function addFrameScript(frame:Int, func:Function):Void
    {
        _frameScripts.set(frame, func);
    }

    public function removeFrameScript(frame:Int, func:Function):Void
    {
        _frameScripts.remove(frame);
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
        _playing = true;
    }

    public function stop():Void
    {
        _playing = false;
    }

    public function getSymbolByName(name:String):AnimateSymbol
    {
        for (l in 0..._numLayers)
        {
            var layer:TileContainer = getLayer(l);
            var numElements:Int = layer.numTiles;

            for (e in 0...numElements)
            {
                if(cast(layer.getTileAt(e),AnimateSymbol).name == name)
                    return cast layer.getTileAt(e);
            }
        }

        return null;
    }

    public function reset():Void
    {
        alpha = 1.0;
        _currentFrame = 0;
        _composedFrame = -1;
    }

    public function updateFrame(delta:Float):Void
    {
        var frameRate : Float = _atlas.frameRate;
        var prevTime : Float = _cumulatedTime;

        _cumulatedTime += delta;

        if (Std.int(prevTime * frameRate) != Std.int(_cumulatedTime * frameRate))
        {
            if(_playing)
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
        if (type == SymbolType.MOVIE_CLIP && _playing)
            currentFrame += 1;

        for (l in 0..._numLayers)
        {
            var layer:TileContainer = getLayer(l);
            var numElements:Int = layer.numTiles;

            for (e in 0...numElements)
                cast(layer.getTileAt(e), AnimateSymbol).nextFrame_MovieClips();
        }
    }

    public function update():Void
    {
        for (i in 0..._numLayers)
            updateLayer(i);

        _composedFrame = _currentFrame;
    }

    private function updateLayer(layerIndex:Int):Void
    {
        var layer:TileContainer = getLayer(layerIndex);
        var frameData:LayerFrameData = getFrameData(layerIndex, _currentFrame);
        var elements:Array<ElementData> = frameData != null ? frameData.elements : null;
        var numElements:Int = elements != null ? elements.length : 0;

        var oldSymbol:AnimateSymbol = null;

        for (i in 0...numElements)
        {
            var elementData:SymbolInstanceData = elements[i].symbolInstance;
            oldSymbol = layer.numTiles > i ? cast layer.getTileAt(i) : null;
            var newSymbol:AnimateSymbol = null;
            var symbolName:String = elementData.symbolName;

            if (!_atlas.hasSymbol(symbolName))
                symbolName = BITMAP_SYMBOL_NAME;

            if (oldSymbol != null && oldSymbol._symbolName == symbolName)
                newSymbol = oldSymbol;
            else
            {
                if (oldSymbol != null)
                {
                    layer.removeTile(oldSymbol);
                }

                newSymbol = _atlas.getSymbol(symbolName);
                layer.addTileAt(newSymbol, i);
            }

            newSymbol.name = elementData.instanceName;
            newSymbol.setTransformationMatrix(elementData.matrix3D);
            newSymbol.setBitmap(elementData.bitmap);
            newSymbol.setColor(elementData.color);
            newSymbol.setLoop(elementData.loop);
            newSymbol.setType(elementData.symbolType);

            if (newSymbol.type == SymbolType.GRAPHIC)
            {
                var firstFrame:Int = elementData.firstFrame;
                var frameAge:Int = Std.int(_currentFrame - frameData.index);

                if (newSymbol.loopMode == LoopMode.SINGLE_FRAME)
                {
                    stop();
                    newSymbol.currentFrame = firstFrame;
                }
                else if (newSymbol.loopMode == LoopMode.LOOP)
                {
                    newSymbol.currentFrame = (firstFrame + frameAge) % newSymbol._numFrames;
                }
                else
                {
                    newSymbol.currentFrame = firstFrame + frameAge;
                }
            }
        }

        var numObsoleteSymbols:Int = layer.numTiles - numElements;

        for (i in 0...numObsoleteSymbols)
        {
            oldSymbol = cast layer.removeTileAt(numElements);
            _atlas.putSymbol(oldSymbol);
        }

        if(_frameScripts.exists(_currentFrame))
        {
            _frameScripts.get(_currentFrame)();
        }
    }

    private function createLayers():Void
    {
        for (i in 0..._numLayers)
        {
            var layer:TileContainer = new TileContainer();
            addTile(layer);
        }
    }

    @:access(openfl.extensions.animate.display.AnimateAtlasTile)
    public inline function setBitmap(data:AtlasSpriteInstance):Void
    {
        if (data != null)
        {
            id = _atlas.getId(data.name);

            _bitmap.visible = true;

            _bitmap.id = id;

            if(data.position != null)
            {
                _bitmap.x = data.position.x;
                _bitmap.y = data.position.y;
            }else{
                if(_bitmap.matrix.a != data.matrix3D.m00 || _bitmap.matrix.b != data.matrix3D.m01 || _bitmap.matrix.c != data.matrix3D.m10 || _bitmap.matrix.d != data.matrix3D.m11 || _bitmap.matrix.tx != data.matrix3D.m30 || _bitmap.matrix.ty != data.matrix3D.m31)
                {
                    _bitmap.matrix.setTo(data.matrix3D.m00, data.matrix3D.m01, data.matrix3D.m10, data.matrix3D.m11, data.matrix3D.m30, data.matrix3D.m31);
                    _bitmap.__setRenderDirty();
                }
            }
        }
        else if (_bitmap != null)
        {
            _bitmap.visible = false;
        }
    }

    private inline function setTransformationMatrix(data:Matrix3DData):Void
    {
        if(matrix.a != data.m00 || matrix.b != data.m01 || matrix.c != data.m10 || matrix.d != data.m11 || matrix.tx != data.m30 || matrix.ty != data.m31)
        {
            matrix.setTo(data.m00, data.m01, data.m10, data.m11, data.m30, data.m31);
            __setRenderDirty();
        }
    }

    private inline function setColor(data:ColorData):Void
    {
        if (data != null)
        {
            var mode:String = data.mode;
            alpha = (ALPHA_MODES.indexOf(mode) >= 0) ? data.alphaMultiplier : 1.0;
        }
        else
        {
            alpha = 1.0;
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

        for (i in 0..._numLayers)
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

        for (i in 0..._numLayers)
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
        return cast getTileAt(layerIndex + 1);
    }

    public function getNextLabel(afterLabel:String=null):String
    {
        var numLabels:Int = _frameLabels.length;
        var startFrame:Int = getFrame(afterLabel == null ? currentLabel : afterLabel);
        //todo check getFrame

        for (i in 0...numLabels)
        {
            var label:FrameLabel = _frameLabels[i];
            if (label.frame > startFrame)
                return label.name;
        }

        return _frameLabels != null ? _frameLabels[0].name : null; // wrap around
    }

    private function get_currentLabel() : String
    {
        var numLabels:Int = _frameLabels.length;
        var highestLabel:FrameLabel = numLabels != 0 ? _frameLabels[0] : null;

        for (i in 0...numLabels)
        {
            var label:FrameLabel = _frameLabels[i];

            if (label.frame <= _currentFrame)
                highestLabel = label;
            else
                break;
        }

        return highestLabel != null ? highestLabel.name : null;
    }

    public function getFrame(label : String) : Int
    {
        var numLabels:Int = _frameLabels.length;
        for (i in 0...numLabels)
        {
            var frameLabel:FrameLabel = _frameLabels[i];
            if (frameLabel.name == label)
                return frameLabel.frame;
        }
        return -1;
    }

    private function get_currentFrame() : Int
    {
        return _currentFrame;
    }

    private function set_currentFrame(value : Int) : Int
    {
        while (value < 0)
            value += _numFrames;

        if (loopMode == LoopMode.PLAY_ONCE)
            _currentFrame = Std.int(MathUtil.clamp(value, 0, _numFrames - 1));
        else
            _currentFrame = Std.int(Math.abs(value % _numFrames));

        if (_composedFrame != _currentFrame)
            update();

        return value;
    }

    private function get_symbolName() : String
    {
        return _symbolName;
    }

    private function get_numLayers() : Int
    {
        return _numLayers;
    }

    private function get_numFrames() : Int
    {
        return _numFrames;
    }

    private function get_frameRate():Float
    {
        return _atlas.frameRate;
    }

    // data access

    private inline function getLayerData(layerIndex : Int) : LayerData
    {
        return _data.timeline.layers[layerIndex];
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
