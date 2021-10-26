package openfl.extensions.animate;

import flash.net.URLRequest;
import openfl.extensions.animate.parser.AnimateAtlasParser;
import openfl.display.Loader;
import openfl.utils.ByteArray;
import openfl.utils.Future;
import openfl.display.BitmapData;
import openfl.display.Bitmap;
import openfl.utils.Assets;
import lime.app.Promise;
import lime._internal.format.Deflate;
import haxe.zip.Entry;
import haxe.io.BytesInput;
import haxe.io.Bytes;
import haxe.Json;

class AnimateAtlasAssetManager {

    //Read content from memory
    public static function loadAssetSync(directory:String):AnimationAtlas {
        directory = haxe.io.Path.addTrailingSlash(directory);

        var spritemap:BitmapData = Assets.getBitmapData(directory +  "spritemap1.png");
        var spritemapJson:String = Assets.getText(directory +  "spritemap1.json");
        var animationJson:String = Assets.getText(directory +  "Animation.json");

        return AnimateAtlasParser.parseAsset(spritemap, spritemapJson, animationJson);
    }

    public static function loadCompressedAssetSync(path:String):AnimationAtlas {
        var bytes:Bytes = cast Assets.getBytes(path);
        return AnimateAtlasParser.parseCompressedAsset(bytes);
    }

    //Load required library contents from storage/internet
    public static function loadAsset(directory:String, useCache:Null<Bool> = true):Future<AnimationAtlas> {
        directory = haxe.io.Path.addTrailingSlash(directory);

        var promise = new Promise<AnimationAtlas>();
        var count = 3;

        var spritemap:BitmapData;
        var spritemapJson:String;
        var animationJson:String;

        function tryProcess():Void
        {
            count--;

            if(count == 0)
            {
                var atlas = AnimateAtlasParser.parseAsset(spritemap, spritemapJson, animationJson);
                promise.complete(atlas);
            }
        }

        Assets.loadBitmapData(directory + "spritemap1.png", useCache).onComplete (function (bitmapData:BitmapData) {
            spritemap = bitmapData;
            tryProcess();
        }).onError(function (msg:Dynamic) {
            promise.error(msg);
        });

        Assets.loadText(directory +  "spritemap1.json").onComplete (function (string:String) {
            spritemapJson = string;
            tryProcess();
        }).onError(function (msg:Dynamic) {
            promise.error(msg);
        });

        Assets.loadText(directory +  "Animation.json").onComplete (function (string:String) {
            animationJson = string;
            tryProcess();
        }).onError(function (msg:Dynamic) {
            promise.error(msg);
        });

        return promise.future;
    }

    public static function loadCompressedAsset(path:String):Future<AnimationAtlas> {
        var promise = new Promise<AnimationAtlas>();

        Assets.loadBytes(path).onComplete (function (bytes:Bytes) {
            var atlas = AnimateAtlasParser.parseCompressedAsset(bytes);
            promise.complete(atlas);
        }).onError(function (msg:Dynamic) {
            promise.error(msg);
        });

        return promise.future;
    }

    //Load required content from internet

    //TODO: implement requestAsset

    public static function requestCompressedAsset(url:String):Future<AnimationAtlas> {
        var promise = new Promise<AnimationAtlas>();

        var http = new haxe.Http(url);

        http.onBytes = function (bytes:Bytes) {
            var atlas = AnimateAtlasParser.parseCompressedAsset(bytes);
            promise.complete(atlas);
        }
        http.onError = function(msg:String) {
            promise.error(msg);
        }

        http.request(false);

        return promise.future;
    }
}
