package openfl.extensions.animate;

import openfl.extensions.animate.display.AnimateAtlasTile;
import openfl.display.Tile;
import openfl.display.TileContainer;
import openfl.extensions.animate.display.AnimateAtlasTileContainer;
import openfl.extensions.animate.utils.MathUtil;
import openfl.extensions.animate.AnimationAtlasData;
import openfl.display.BitmapData;
import openfl.extensions.animate.display.Image;
import openfl.extensions.animate.SymbolType;
import openfl.filters.ColorMatrixFilter;
import openfl.display.FrameLabel;
import openfl.errors.ArgumentError;
import openfl.errors.Error;
import openfl.geom.Matrix;

class Symbol extends AnimateAtlasTileContainer
{
    public var currentLabel(get, never):String;
    public var currentFrame(get, set):Int;
    public var type(get, set):String;
    public var loopMode(get, set):String;
    public var symbolName(get, never):String;
    public var numLayers(get, never):Int;
    public var numFrames(get, never):Int;
    public var frameRate(get, never):Float;

    public static inline var BITMAP_SYMBOL_NAME : String = "___atlas_sprite___";

    private var _cumulatedTime : Float = 0.0;
    private var _stopped:Bool = false;
    private var _data : SymbolData;
    private var _atlas : AnimationAtlas;
    private var _symbolName : String;
    private var _type : String;
    private var _loopMode : String;
    private var _currentFrame : Int = 0;
    private var _composedFrame : Int = 0;
    private var _layers:TileContainer;
    private var _bitmap:AnimateAtlasTile;
    private var _numFrames : Int = 0;
    private var _numLayers : Int = 0;
    private var _frameLabels : Array<FrameLabel>;
    private var _colorTransform:ColorMatrixFilter;

    private static var ALPHA_MODES = ["Alpha", "Advanced", "AD"];
    private static var sMatrix : Matrix = new Matrix();

    @:access(openfl.extensions.animate.AnimationAtlas)
    public static function createFromAtlas(atlas:AnimationAtlas, name:String = null)
    {
        return new Symbol(atlas.getSymbolData(name == null ? atlas._defaultSymbolName : name), atlas);
    }

    @:access(openfl.extensions.animate.AnimationAtlas)
    public function new(data:SymbolData, atlas:AnimationAtlas)
    {
        super();
        _data = data;
        _atlas = atlas;
        _composedFrame = -1;
        _numLayers = data.timeline.layers.length;
        _numFrames = getNumFrames();
        _frameLabels = getFrameLabels();
        _symbolName = data.symbolName;
        _type = SymbolType.GRAPHIC;
        _loopMode = LoopMode.LOOP;
        this.tileset = atlas._tileset;


        createLayers();
        update();
    }

    public function gotoAndPlay(frame:Dynamic)
    {
        currentFrame = Std.isOfType(frame, String) ? getFrame(cast(frame, String)) : Std.int(frame);
        play();
    }

    public function gotoAndStop(frame:Dynamic)
    {
        gotoAndPlay(frame);
        stop();
    }

    public function play():Void
    {
        _stopped = false;
    }

    public function stop():Void
    {
        _stopped = true;
    }

    public function getSymbolByName(name:String):Symbol
    {
        for (l in 0..._numLayers)
        {
            var layer:TileContainer = getLayer(l);
            var numElements:Int = layer.numTiles;

            for (e in 0...numElements)
            {
                if(cast(layer.getTileAt(e),Symbol).name == name)
                    return cast(layer.getTileAt(e),Symbol);
            }
        }

        return null;
    }

    public function reset():Void
    {
        matrix = sMatrix;

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
            currentFrame += 1;
            nextFrame_MovieClips();
        }
    }

    /** To be called whenever sufficient time for one frame has passed. Does not necessarily
         *  move 'currentFrame' ahead - depending on the 'loop' mode. MovieClips all move
         *  forward, though (recursively). */
    /*public function nextFrame():Void
    {
        if (_loopMode != LoopMode.SINGLE_FRAME)
            currentFrame += 1;

        nextFrame_MovieClips();
    }*/

    /** Moves all movie clips ahead one frame, recursively. */
    public function nextFrame_MovieClips():Void
    {
        if(_stopped)
            return;

        if (_type == SymbolType.MOVIE_CLIP)
            currentFrame += 1;

        for (l in 0..._numLayers)
        {
            var layer:TileContainer = getLayer(l);
            var numElements:Int = layer.numTiles;

            for (e in 0...numElements)
                cast(layer.getTileAt(e), Symbol).nextFrame_MovieClips();
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

        var oldSymbol:Symbol = null;

        for (i in 0...numElements)
        {
            var elementData:SymbolInstanceData = elements[i].symbolInstance;
            oldSymbol = layer.numTiles > i ? cast(layer.getTileAt(i),Symbol) : null;
            var newSymbol:Symbol = null;
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
            oldSymbol = cast(layer.removeTileAt(numElements), Symbol);
            _atlas.putSymbol(oldSymbol);
        }
    }

    private function createLayers():Void
    {
        if (_layers != null)
            throw new Error("Method must only be called once");

        _layers = new TileContainer();
        addTile(_layers);

        for (i in 0..._numLayers)
        {
            var layer:TileContainer = new TileContainer();
            _layers.addTile(layer);
        }
    }

    @:access(openfl.extensions.animate.display.AnimateAtlasTile)
    public inline function setBitmap(data:Dynamic):Void
    {
        if (data != null)
        {
            id = _atlas.getId(data.name);

            if (_bitmap == null)
            {
                _bitmap = new AnimateAtlasTile();
                addTile(_bitmap);
            }

            _bitmap.id = id;

            if(data.position != null)
            {
                _bitmap.x = data.position.x;
                _bitmap.y = data.position.y;
            }else{
                _bitmap.x = data.decomposedMatrix.position.x;
                _bitmap.y = data.decomposedMatrix.position.y;
            }
        }
        else if (_bitmap != null)
        {
            _bitmap.x = 0;
            _bitmap.y = 0;
            removeTile(_bitmap);
            _bitmap = null;
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

    private function setLoop(data:String):Void
    {
        if (data != null)
            _loopMode = LoopMode.parse(data);
        else
            _loopMode = LoopMode.LOOP;
    }

    private function setType(data:String):Void
    {
        if (data != null)
            _type = SymbolType.parse(data);
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

    function sortLabels(i1:FrameLabel, i2:FrameLabel):Int
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
        return cast(_layers.getTileAt(layerIndex), TileContainer);
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

        if (_loopMode == LoopMode.PLAY_ONCE)
            _currentFrame = Std.int(MathUtil.clamp(value, 0, _numFrames - 1));
        else
            _currentFrame = Std.int(Math.abs(value % _numFrames));

        if (_composedFrame != _currentFrame)
            update();

        return value;
    }

    private function get_type() : String
    {
        return _type;
    }
    private function set_type(value : String) : String
    {
        if (SymbolType.isValid(value))
            _type = value;
        else
            throw new ArgumentError("Invalid symbol type: " + value);
        return value;
    }

    private function get_loopMode() : String
    {
        return _loopMode;
    }
    private function set_loopMode(value : String) : String
    {
        if (LoopMode.isValid(value))
            _loopMode = value;
        else
            throw new ArgumentError("Invalid loop mode: " + value);
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

    private function getLayerData(layerIndex : Int) : LayerData
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
