package openfl.extensions.animate.display;

interface IAtlasDisplayObjectContainer extends IAtlasObjectContainer {
    #if flash
	@:flash.property var name(get, set):String;
	#else
    public var name(get, set):String;
    #end

    #if flash
	@:flash.property var visible(get, set):Bool;
	#else
    public var visible(get, set):Bool;
    #end

    #if flash
	@:flash.property var alpha(get, set):Float;
	#else
    public var alpha(get, set):Float;
    #end

    #if flash
	@:flash.property var x(get, set):Float;
	#else
    public var x(get, set):Float;
    #end

    #if flash
	@:flash.property var y(get, set):Float;
	#else
    public var y(get, set):Float;
    #end
}
