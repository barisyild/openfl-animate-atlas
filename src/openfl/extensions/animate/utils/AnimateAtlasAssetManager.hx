package openfl.extensions.animate.utils;

import openfl.events.IOErrorEvent;
import openfl.events.Event;
import openfl.net.URLLoaderDataFormat;
import openfl.net.URLLoader;
import openfl.net.URLRequest;
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

@:generic
class AnimateAtlasAssetManager {
    //Read content from memory
    public static function loadAssetSync(directory:String, typeInstance:Class<AnimateAtlasSheet>):AnimateAtlasSheet {
        directory = haxe.io.Path.addTrailingSlash(directory);

        var spritemap:BitmapData = Assets.getBitmapData(directory +  "spritemap1.png");
        var spritemapJson:String = Assets.getText(directory +  "spritemap1.json");
        var animationJson:String = Assets.getText(directory +  "Animation.json");

        return AnimateAtlasParser.parseAssetSync(spritemap, spritemapJson, animationJson, typeInstance);
    }

    /*public static function loadCompressedAssetSync(path:String):AnimationAtlas {
        var bytes:Bytes = cast Assets.getBytes(path);
        return AnimateAtlasParser.parseCompressedAsset(bytes);
    }*/

    //Load required library contents from storage/internet
    public static function loadAsset(directory:String, typeInstance:Class<AnimateAtlasSheet>, useCache:Null<Bool> = true):Future<AnimateAtlasSheet> {
        directory = haxe.io.Path.addTrailingSlash(directory);

        var promise = new Promise<AnimateAtlasSheet>();
        var count = 3;

        var spritemap:BitmapData = null;
        var spritemapJson:String = null;
        var animationJson:String = null;

        function tryProcess():Void
        {
            count--;

            if(count == 0)
            {
                var atlas = AnimateAtlasParser.parseAssetSync(spritemap, spritemapJson, animationJson, typeInstance);
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

    public static function loadCompressedAssetSync(path:String, typeInstance:Class<AnimateAtlasSheet>):AnimateAtlasSheet {
        #if flash
        return AnimateAtlasParser.parseCompressedAssetSync(cast Assets.getBytes(path), typeInstance);
        #else
        return AnimateAtlasParser.parseCompressedAssetSync(Assets.getBytes(path), typeInstance);
        #end

    }

    public static function loadCompressedAsset(path:String, typeInstance:Class<AnimateAtlasSheet>):Future<AnimateAtlasSheet> {
        var promise = new Promise<AnimateAtlasSheet>();

        Assets.loadBytes(path).onComplete (function (byteArray:ByteArray) {
            AnimateAtlasParser.parseCompressedAsset(#if flash cast #end byteArray, typeInstance).onComplete(function (atlas:AnimateAtlasSheet) {
                promise.complete(atlas);
            }).onError(function (msg:Dynamic) {
                promise.error(msg);
            });
        }).onError(function (msg:Dynamic) {
            promise.error(msg);
        });

        return promise.future;
    }

    //Load required content from internet

    //TODO: implement requestAsset

    public static function requestCompressedAsset(url:String, typeInstance:Class<AnimateAtlasSheet>):Future<AnimateAtlasSheet> {
        var promise = new Promise<AnimateAtlasSheet>();

        var urlLoader:URLLoader = new URLLoader();
        urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
        urlLoader.addEventListener(Event.COMPLETE, function (e:Event) {
            var byteArray:ByteArray = urlLoader.data;
            #if flash
            var bytes:Bytes = Bytes.ofData(byteArray);
            #else
            var bytes:Bytes = cast byteArray;
            #end
            AnimateAtlasParser.parseCompressedAsset(bytes, typeInstance).onComplete(function (atlas) {
                promise.complete(atlas);
            }).onError(function (msg:Dynamic) {
                promise.error(msg);
            });
        });
        urlLoader.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent) {
            promise.error(e.errorID);
        });
        urlLoader.load(new URLRequest(url));

        return promise.future;
    }
}
