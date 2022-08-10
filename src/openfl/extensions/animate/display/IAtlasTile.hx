package openfl.extensions.animate.display;
interface IAtlasTile extends IAtlasObject {
    public var visible(get, set):Bool;
    public var alpha(get, set):Float;
    public var x(get, set):Float;
    public var y(get, set):Float;

    #if !flash
    private function __setRenderDirty():Void;
    #end
}
