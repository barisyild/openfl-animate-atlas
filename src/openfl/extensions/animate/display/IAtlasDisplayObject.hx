package openfl.extensions.animate.display;
interface IAtlasDisplayObject extends IAtlasObject {
    #if flash
	public var name:String;
	#else
    public var name(get, set):String;
    #end

    #if flash
	public var visible:Bool;
	#else
    public var visible(get, set):Bool;
    #end

    #if flash
	public var alpha:Float;
	#else
    public var alpha(get, set):Float;
    #end

    #if flash
	public var x:Float;
	#else
    public var x(get, set):Float;
    #end

    #if flash
	public var y:Float;
	#else
    public var y(get, set):Float;
    #end

    #if !flash
    private function __setRenderDirty():Void;
    #end
}