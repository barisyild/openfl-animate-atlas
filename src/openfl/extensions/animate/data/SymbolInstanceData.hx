package openfl.extensions.animate.data;

import flash.geom.Point;
import openfl.extensions.animate.utils.LoopUtil;
import openfl.extensions.animate.type.LoopMode;
import openfl.extensions.animate.utils.SymbolTypeUtil;
import openfl.extensions.animate.type.SymbolType;

class SymbolInstanceData {
    public var symbolName: String;
    public var instanceName: String;
    public var bitmap:AtlasSpriteInstance;
    public var symbolType:SymbolType;
    public var transformationPoint:PointData;
    public var matrix3D: Matrix3DData;
    public var decomposedMatrix:Null<Decomposed3DData>;
    public var color:Null<ColorData>;
    public var loop:Null<LoopMode>;
    public var firstFrame:Int;

    public function new() {

    }

    public static inline function createFromAnimationAtlasData(data:openfl.extensions.animate.struct.AnimationAtlasData.SymbolInstanceData):SymbolInstanceData
    {
        var symbolInstanceData:SymbolInstanceData = new SymbolInstanceData();
        symbolInstanceData.symbolName = data.symbolName;
        symbolInstanceData.instanceName = data.instanceName;
        symbolInstanceData.bitmap = data.bitmap;
        symbolInstanceData.symbolType = SymbolTypeUtil.parse(data.symbolType);
        symbolInstanceData.transformationPoint = new PointData(data.transformationPoint.x, data.transformationPoint.y);
        symbolInstanceData.matrix3D = Matrix3DData.createFromAnimationAtlasData(data.matrix3D);

        if(symbolInstanceData.matrix3D == null)
        {
            trace("matrix3D is null!");
        }

        if(data.decomposedMatrix != null)
        {
            symbolInstanceData.decomposedMatrix = Decomposed3DData.createFromAnimationAtlasData(data.decomposedMatrix);
        }

        if(data.color != null)
        {
            symbolInstanceData.color = ColorData.createFromAnimationAtlasData(data.color);
        }

        if(data.loop == null)
        {
            symbolInstanceData.loop = LoopMode.LOOP;
        }else{
            symbolInstanceData.loop = LoopUtil.parse(data.loop);
        }

        symbolInstanceData.firstFrame = data.firstFrame;
        return symbolInstanceData;
    }
}
