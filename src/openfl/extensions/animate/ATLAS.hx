package openfl.extensions.animate;

typedef ATLAS = {
    var ATLAS:{
        var SPRITES:Array<SPRITE>;
        var meta:Meta;
    };
}

typedef SPRITE = {
    var SPRITE:{
        var name:String;
        var x:Int;
        var y:Int;
        var w:Int;
        var h:Int;
        var rotated:Bool;
    };
}

typedef Meta = {
    var app:String;
    var version:String;
    var image:String;
    var format:String;
    var size:Size;
    var resolution:String;
}

typedef Size = {
    var w:Int;
    var h:Int;
}