package openfl.extensions.animate.parser;

import haxe.Exception;
import lime.app.Promise;
import openfl.utils.Future;
import lime._internal.format.Deflate;
import haxe.io.BytesInput;
import haxe.zip.Entry;
import haxe.io.Bytes;
import haxe.Json;
import openfl.display.BitmapData;

class AnimateAtlasParser {
    public static inline function readCompressedContent(bytes:Bytes):{spritemapBytes:Bytes, spritemapJson:String, animationJson:String}
    {
        var spritemapBytes:Bytes = null;
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
                    spritemapBytes = bytes;
                case "spritemap1.json":
                    spritemapJson = bytes.toString();
                case "Animation.json":
                    animationJson = bytes.toString();
            }
        }

        return {
            spritemapBytes: spritemapBytes,
            spritemapJson: spritemapJson,
            animationJson: animationJson
        }
    }

    public static function parseCompressedAsset(bytes:Bytes):Future<AnimateAtlasSheet>
    {
        var promise:Promise<AnimateAtlasSheet> = new Promise();

        var compressedContent = readCompressedContent(bytes);

        var spritemap:BitmapData;

        lime.graphics.Image.loadFromBytes(compressedContent.spritemapBytes).onComplete(function(image) {
            try
            {
                var animationAtlas = parseAssetSync(BitmapData.fromImage(image), compressedContent.spritemapJson, compressedContent.animationJson);
                promise.complete(animationAtlas);
            }
            catch(e:Exception)
            {
                promise.error(e);
            }
        });

        return promise.future;
    }

    public static function parseCompressedAssetSync(bytes:Bytes):AnimateAtlasSheet
    {
        var compressedContent = readCompressedContent(bytes);

        var spritemap:BitmapData = BitmapData.fromImage(lime.graphics.Image.fromBytes(compressedContent.spritemapBytes));

        return parseAssetSync(spritemap, compressedContent.spritemapJson, compressedContent.animationJson);
    }

    public static function parseAssetSync(spritemap:BitmapData, spritemapJson:String, animationJson:String):AnimateAtlasSheet
    {
        var animationAtlasData:openfl.extensions.animate.struct.ATLAS = Json.parse(spritemapJson);
        var rawAnimationData:Dynamic = Json.parse(animationJson);

        return new AnimateAtlasSheet(spritemap, animationAtlasData, rawAnimationData);
    }
}
