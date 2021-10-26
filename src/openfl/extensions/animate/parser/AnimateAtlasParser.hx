package openfl.extensions.animate.parser;

import lime._internal.format.Deflate;
import haxe.io.BytesInput;
import haxe.zip.Entry;
import haxe.io.Bytes;
import haxe.Json;
import openfl.display.BitmapData;

class AnimateAtlasParser {
    public static function parseCompressedAsset(bytes:Bytes):AnimationAtlas
    {
        var spritemap:BitmapData = null;
        var spritemapJson:String = null;
        var animationJson:String = null;

        var entries:List<Entry> = haxe.zip.Reader.readZip(new BytesInput(bytes));

        for(entry in entries)
        {
            var bytes:Bytes = entry.data;

            if(entry.compressed)
            {
                bytes = Deflate.decompress(bytes);
            }

            switch(entry.fileName)
            {
                case "spritemap1.png":
                    spritemap = BitmapData.fromBytes(bytes);
                case "spritemap1.json":
                    spritemapJson = bytes.toString();
                case "Animation.json":
                    animationJson = bytes.toString();
            }
        }

        return parseAsset(spritemap, spritemapJson, animationJson);
    }

    public static function parseAsset(spritemap:BitmapData, spritemapJson:String, animationJson:String):AnimationAtlas
    {
        var animationAtlasData:ATLAS = Json.parse(spritemapJson);
        var rawAnimationData:Dynamic = Json.parse(animationJson);

        return new AnimationAtlas(spritemap, animationAtlasData, rawAnimationData);
    }
}
