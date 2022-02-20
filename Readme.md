## WARNING: **Under Development**, API CAN BE CHANGED IN FUTURE!
### Tested on Adobe Animate 2020

```haxe
Juggler.init(); //Initialize update animation class
    
var animateAtlasAssetManager:AnimateAtlasAssetManager<AnimateAtlasSheet> = new AnimateAtlasAssetManager<AnimateAtlasSheet>(AnimateAtlasSheet);
    
var animationAtlas:AnimateAtlasSheet = animateAtlasAssetManager.loadAssetSync("assets/ninja-girl");

var tilemap:Tilemap = new Tilemap(stage.stageWidth, stage.stageHeight);
tilemap.smoothing = false;
addChild(tilemap);

var animation = new AnimateAtlasTile.create(animationAtlas); //I am planning to make the API similar to flash's DisplayObject API.
animation.x = stage.stageWidth / 2;
animation.y = stage.stageHeight / 2;
tilemap.addTile(animation);
Juggler.add(animation); //Add animation to animation class, make sure to call "Juggler.remove(animation);" when you're done with the animation.

//Note: I plan to delete Juggler in the long run so anyone can create their own animation update solution.
```

# Sprite support coming soon!

Benchmark: http://openfl-animate-atlas.surge.sh/

**Important: Optimized atlases are not supported!**