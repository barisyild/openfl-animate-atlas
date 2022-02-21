package openfl.extensions.animate.display;
interface IAtlasDisplayObject {
    public var visible(get, set):Bool;
    public var alpha(get, set):Float;
    public var x(get, set):Float;
    public var y(get, set):Float;

    private function __setRenderDirty():Void;
}
