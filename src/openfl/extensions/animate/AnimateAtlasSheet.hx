package openfl.extensions.animate;

import openfl.extensions.animate.display.IAtlasObjectContainer;
import openfl.display.Bitmap;
import openfl.extensions.animate.display.AnimateAtlasSprite;
import openfl.geom.Matrix;
import openfl.extensions.animate.display.AnimateAtlasPlayer;
import openfl.extensions.animate.data.AtlasSpriteInstance;
import openfl.extensions.animate.data.Matrix3DData;
import openfl.extensions.animate.data.PointData;
import openfl.extensions.animate.data.SymbolInstanceData;
import openfl.extensions.animate.type.LoopMode;
import openfl.extensions.animate.type.SymbolType;
import openfl.extensions.animate.data.ElementData;
import openfl.extensions.animate.data.LayerFrameData;
import openfl.extensions.animate.data.SymbolTimelineData;
import openfl.extensions.animate.data.LayerData;
import openfl.extensions.animate.data.SymbolData;
import openfl.extensions.animate.display.AnimateAtlasTile;
import openfl.geom.Rectangle;
import openfl.extensions.animate.display.AnimateAtlasTileset;
import openfl.display.BitmapData;
import openfl.errors.ArgumentError;
import openfl.geom.Point;

class AnimateAtlasSheet
{
    public static inline var BITMAP_SYMBOL_NAME : String = "___atlas_sprite___";
    public static var ALPHA_MODES = ["Alpha", "Advanced", "AD"];
    private static var sMatrix:Matrix = new Matrix();

    public var frameRate(get, set) : Float;

    private var _defaultSymbolName:String;
    public var defaultSymbolName(get, never):String;

    public static inline var ASSET_TYPE : String = "animationAtlas";

    private var spritemap:BitmapData;
    private var _symbolData : Map<String, SymbolData>;
    private var _symbolPool : Map<String, Array<IAtlasObjectContainer>>;
    private var _frameRate : Float;

    private static var STD_MATRIX3D_DATA:Dynamic =
    {
        m00: 1, m01: 0, m02: 0, m03: 0,
        m10: 0, m11: 1, m12: 0, m13: 0,
        m20: 0, m21: 0, m22: 1, m23: 0,
        m30: 0, m31: 0, m32: 0, m33: 1
    };

    public function new()
    {

    }

    public function process(spritemap:BitmapData, atlas:openfl.extensions.animate.struct.ATLAS, rawAnimationData:Dynamic):Void
    {
        if (rawAnimationData  == null) throw new ArgumentError("data must not be null");
        if (spritemap == null) throw new ArgumentError("spritemap must not be null");

        var data:openfl.extensions.animate.struct.AnimationAtlasData = cast AnimateAtlasSheet.normalizeJsonKeys(rawAnimationData);
        parseData(data, atlas);
        parseDisplay(spritemap, atlas);

        _symbolPool = new Map<String, Array<IAtlasObjectContainer>>();
    }

    public inline function hasAnimation(name : String) : Bool
    {
        return hasSymbol(name);
    }

    public function getAnimationNames(prefix : String = "", out : Array<String> = null) : Array<String>
    {
        out = (out != null) ? out : new Array<String>();

        for (name in _symbolData.keys())
        {
            if (name != AnimateAtlasSheet.BITMAP_SYMBOL_NAME && name.indexOf(prefix) == 0)
            {
                out[out.length] = name;
            }
        }

        //out.sort(Array.CASEINSENSITIVE);
        out.sort(function(a1, a2) : Int {
            a1 = a1.toLowerCase();
            a2 = a2.toLowerCase();
            if (a1 < a2){
                return -1;
            }else if (a1 > a2){
                return 1;
            }else{
                return 0;
            }
        });
        return out;
    }

    // pooling

    @:allow(openfl.extensions.animate)
    private inline function hasSymbol(name : String) : Bool
    {
        return _symbolData.exists(name);
    }

    @:allow(openfl.extensions.animate)
    private function getSymbol(name:String) : IAtlasObjectContainer
    {
        throw "Override required";
    }

    @:access(openfl.extensions.animate.display.IAtlasObjectContainer)
    @:allow(openfl.extensions.animate)
    private function putSymbol(symbol : IAtlasObjectContainer) : Void
    {
        symbol._player.reset();
        var pool:Array<IAtlasObjectContainer> = getSymbolPool(symbol.symbolName);
        pool[pool.length] = symbol;
        symbol.currentFrame = 0;
    }

    // helpers

    private function parseData(data:openfl.extensions.animate.struct.AnimationAtlasData, atlas:openfl.extensions.animate.struct.ATLAS) : Void
    {
        var metaData = data.metadata;

        if (metaData != null && metaData.frameRate > 0)
            _frameRate = Std.int(metaData.frameRate);
        else
            _frameRate = 24;

        _symbolData = new Map<String, SymbolData>();

        // the actual symbol dictionary
        if (data.symbolDictionary != null) {
            for (symbolData in data.symbolDictionary.symbols)
            {
                _symbolData[symbolData.symbolName] = preprocessSymbolData(symbolData);
            }
        }

        // the main animation
        var defaultSymbolData:SymbolData = preprocessSymbolData(data.animation);
        _defaultSymbolName = defaultSymbolData.symbolName;
        _symbolData[_defaultSymbolName] = defaultSymbolData;

        // a purely internal symbol for bitmaps - simplifies their handling
        var symbolData:SymbolData = new SymbolData();
        symbolData.symbolName = AnimateAtlasSheet.BITMAP_SYMBOL_NAME;
        symbolData.timeline = new SymbolTimelineData();
        symbolData.timeline.layers = [];
        _symbolData[AnimateAtlasSheet.BITMAP_SYMBOL_NAME] = symbolData;
    }

    private function parseDisplay(spritemap:BitmapData, atlas:openfl.extensions.animate.struct.ATLAS):Void
    {

    }

    private static function preprocessSymbolData(symbolData:openfl.extensions.animate.struct.AnimationAtlasData.SymbolData) : SymbolData
    {
        var symbolData:SymbolData = SymbolData.createFromAnimationAtlasData(symbolData);
        var timeLineData:SymbolTimelineData  = symbolData.timeline;
        var layerDates:Array<LayerData> = timeLineData.layers;

        // In Animate CC, layers are sorted front to back.
        // In Starling, it's the other way round - so we simply reverse the layer data.

        if (!timeLineData.sortedForRender)
        {
            timeLineData.sortedForRender = true;
            layerDates.reverse();
        }

        // We replace all "ATLAS_SPRITE_instance" elements with symbols of the same contents.
        // That way, we are always only dealing with symbols.

        var numLayers:Int = layerDates.length;

        for (l in 0...numLayers)
        {
            var layerData:LayerData = layerDates[l];
            var frames:Array<LayerFrameData> = layerData.frames;
            var numFrames:Int = frames.length;

            for (f in 0...numFrames)
            {
                var elements:Array<ElementData> = cast frames[f].elements;
                var numElements:Int = elements.length;

                for (e in 0...numElements)
                {
                    var element:ElementData = elements[e];

                    if (element.atlasSpriteInstance != null)
                    {
                        element.symbolInstance = new SymbolInstanceData();
                        element.symbolInstance.symbolName = AnimateAtlasSheet.BITMAP_SYMBOL_NAME;
                        element.symbolInstance.instanceName = "InstName";
                        element.symbolInstance.bitmap = element.atlasSpriteInstance;
                        element.symbolInstance.symbolType = SymbolType.GRAPHIC;
                        element.symbolInstance.firstFrame = 0;
                        element.symbolInstance.loop = LoopMode.LOOP;
                        element.symbolInstance.transformationPoint = new PointData(0, 0);
                        element.symbolInstance.matrix3D = new Matrix3DData();
                        element.symbolInstance.matrix3D.m00 = 1;
                        element.symbolInstance.matrix3D.m01 = 0;
                        element.symbolInstance.matrix3D.m10 = 0;
                        element.symbolInstance.matrix3D.m11 = 1;
                        element.symbolInstance.matrix3D.m30 = 0;
                        element.symbolInstance.matrix3D.m31 = 0;
                    }

                    // not needed - remove decomposed matrix to save some memory
                    if (element.symbolInstance.decomposedMatrix != null)
                    {
                        element.symbolInstance.decomposedMatrix = null;
                    }
                }
            }
        }

        return symbolData;
    }

    public inline function getSymbolData(name : String):SymbolData
    {
        return _symbolData.get(name);
    }

    private function getSymbolPool(name : String) : Array<IAtlasObjectContainer>
    {
        var pool:Array<IAtlasObjectContainer> = cast _symbolPool.get(name);
        if (pool == null)
        {
            pool = new Array<IAtlasObjectContainer>();
            _symbolPool.set(name, cast pool);
        }
        return pool;
    }

    // properties

    private function get_defaultSymbolName() : String
    {
        return _defaultSymbolName;
    }

    private function get_frameRate() : Float
    {
        return _frameRate;
    }

    private function set_frameRate(value : Float) : Float
    {
        _frameRate = value;
        return value;
    }

    private static function normalizeJsonKeys(data:Dynamic):Dynamic
    {
        if (Std.isOfType(data, String) || Std.isOfType(data, Float) || Std.isOfType(data, Int))
            return data;
        else if (Std.isOfType(data, Array))
        {
            var array:Array<Dynamic> = [];
            var arrayLength:Int = data.length;
            for (i in 0...arrayLength)
                array[i] = normalizeJsonKeys(data[i]);
            return array;
        }
        else
        {
            var out:Dynamic = {};

            for (key in Reflect.fields(data))
            {
                var newData:Dynamic = Reflect.field(data, key);
                var value:Dynamic = normalizeJsonKeys(newData);
                if (Reflect.field(JsonKeys, key) != null)
                    key = Reflect.field(JsonKeys, key);
                Reflect.setField(out, key, value);
            }
            return out;
        }
    }


    private static var JsonKeys : Dynamic =
    {
        ANIMATION : "animation",
        ATLAS_SPRITE_instance : "atlasSpriteInstance",
        DecomposedMatrix : "decomposedMatrix",
        Frames : "frames",
        framerate : "frameRate",
        Layer_name : "layerName",
        LAYERS : "layers",
        Matrix3D : "matrix3D",
        Position : "position",
        Rotation : "rotation",
        name : "name",
        Scaling : "scaling",
        SYMBOL_DICTIONARY : "symbolDictionary",
        SYMBOL_Instance : "symbolInstance",
        SYMBOL_name : "symbolName",
        Instance_Name : "instanceName",
        Symbols : "symbols",
        TIMELINE : "timeline",
        AN : "animation",
        AM : "alphaMultiplier",
        ASI : "atlasSpriteInstance",
        BM : "bitmap",
        C : "color",
        DU : "duration",
        E : "elements",
        FF : "firstFrame",
        FR : "frames",
        FRT : "frameRate",
        I : "index",
        IN : "instanceName",
        L : "layers",
        LN : "layerName",
        LP : "loop",
        M3D : "matrix3D",
        MD : "metadata",
        M : "mode",
        N : "name",
        POS : "position",
        S : "symbols",
        SD : "symbolDictionary",
        SI : "symbolInstance",
        SN : "symbolName",
        ST : "symbolType",
        TL : "timeline",
        TRP : "transformationPoint"
    };
}
