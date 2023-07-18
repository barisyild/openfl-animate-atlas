package openfl.extensions.animate.parser;

import haxe.Constraints.Constructible;
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
    private static function readCompressedContent(bytes:Bytes):{spritemapBytes:Bytes, spritemapJson:String, animationJson:String}
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

    public static function parseCompressedAsset(bytes:Bytes, typeInstance:Class<AnimateAtlasSheet>):Future<AnimateAtlasSheet>
    {
        var promise:Promise<AnimateAtlasSheet> = new Promise();

        var compressedContent = readCompressedContent(bytes);

        var spritemap:BitmapData;

        lime.graphics.Image.loadFromBytes(compressedContent.spritemapBytes).onComplete(function(image) {
            try
            {
                new Future<AnimateAtlasSheet>(function(){
                    return parseAssetSync(BitmapData.fromImage(image), compressedContent.spritemapJson, compressedContent.animationJson, typeInstance);
                }, true).onComplete(function(animationAtlas) {
                    promise.complete(animationAtlas);
                }).onError(function(e) {
                    promise.error(e);
                });
            }
            catch(e:Exception)
            {
                promise.error(e);
            }
        });

        return promise.future;
    }

    public static function parseCompressedAssetSync(bytes:Bytes, typeInstance:Class<AnimateAtlasSheet>):AnimateAtlasSheet
    {
        var compressedContent = readCompressedContent(bytes);

        var spritemap:BitmapData = BitmapData.fromImage(lime.graphics.Image.fromBytes(compressedContent.spritemapBytes));

        return parseAssetSync(spritemap, compressedContent.spritemapJson, compressedContent.animationJson, typeInstance);
    }

    public static function parseAssetSync(spritemap:BitmapData, spritemapJson:String, animationJson:String, typeInstance:Class<AnimateAtlasSheet>):AnimateAtlasSheet
    {
        var animationAtlasData:openfl.extensions.animate.struct.ATLAS = Json.parse(spritemapJson);
        var rawAnimationData:Dynamic = Json.parse(animationJson);

        var animateAtlasSheet = cast(Type.createInstance(typeInstance, []), AnimateAtlasSheet);

        animateAtlasSheet.process(spritemap, animationAtlasData, rawAnimationData);

        return animateAtlasSheet;
    }
}
