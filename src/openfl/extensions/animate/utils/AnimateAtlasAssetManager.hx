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
class AnimateAtlasAssetManager<T> {
    private var animateAtlasParser:AnimateAtlasParser<T>;

    public function new(typeInstance:Class<T>) {
        animateAtlasParser = new AnimateAtlasParser<T>(typeInstance);
    }

    //Read content from memory
    public function loadAssetSync(directory:String):T {
        directory = haxe.io.Path.addTrailingSlash(directory);

        var spritemap:BitmapData = Assets.getBitmapData(directory +  "spritemap1.png");
        var spritemapJson:String = Assets.getText(directory +  "spritemap1.json");
        var animationJson:String = Assets.getText(directory +  "Animation.json");

        return animateAtlasParser.parseAssetSync(spritemap, spritemapJson, animationJson);
    }

    /*public static function loadCompressedAssetSync(path:String):AnimationAtlas {
        var bytes:Bytes = cast Assets.getBytes(path);
        return AnimateAtlasParser.parseCompressedAsset(bytes);
    }*/

    //Load required library contents from storage/internet
    public function loadAsset(directory:String, useCache:Null<Bool> = true):Future<T> {
        directory = haxe.io.Path.addTrailingSlash(directory);

        var promise = new Promise<T>();
        var count = 3;

        var spritemap:BitmapData;
        var spritemapJson:String;
        var animationJson:String;

        function tryProcess():Void
        {
            count--;

            if(count == 0)
            {
                var atlas = animateAtlasParser.parseAssetSync(spritemap, spritemapJson, animationJson);
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

    public function loadCompressedAssetSync(path:String):T {
        return animateAtlasParser.parseCompressedAssetSync(Assets.getBytes(path));
    }

    public function loadCompressedAsset(path:String):Future<T> {
        var promise = new Promise<T>();

        Assets.loadBytes(path).onComplete (function (bytes:Bytes) {
            animateAtlasParser.parseCompressedAsset(bytes).onComplete(function (atlas:T) {
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

    public function requestCompressedAsset(url:String):Future<T> {
        var promise = new Promise<T>();

        var urlLoader:URLLoader = new URLLoader();
        urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
        urlLoader.addEventListener(Event.COMPLETE, function (e:Event) {
            var bytes:Bytes = urlLoader.data;
            animateAtlasParser.parseCompressedAsset(bytes).onComplete(function (atlas) {
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
