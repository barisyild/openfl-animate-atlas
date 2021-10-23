## WARNING: **Under Development**, API CAN BE CHANGED IN FUTURE!
### Tested on Adobe Animate 2020

```
Juggler.init(); //Initialize update animation class

var animationAtlas:AnimationAtlas = AnimateAtlasAssetManager.loadAsset("assets/ninja-girl"); //Dummy loadAsset function, this function will change completely.

var tilemap:Tilemap = new Tilemap(stage.stageWidth, stage.stageHeight);
tilemap.smoothing = false;
addChild(tilemap);

var animation = Symbol.createFromAtlas(animationAtlas); //I am planning to make the API similar to flash's DisplayObject API.
animation.x = stage.stageWidth / 2;
animation.y = stage.stageHeight / 2;
tilemap.addTile(animation);
Juggler.add(animation); //Add animation to animation class, make sure to call "Juggler.remove(animation);" when you're done with the animation.

//Note: I plan to delete Juggler in the long run so anyone can create their own animation update solution.
```

