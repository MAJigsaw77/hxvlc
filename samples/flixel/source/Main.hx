package;

#if android
import android.content.Context;
#end
import flixel.FlxGame;
import haxe.io.Path;
import openfl.display.FPS;
import openfl.display.Sprite;

class Main extends Sprite
{
	public function new():Void
	{
		super();

		#if android
		Sys.setCwd(Path.addTrailingSlash(Context.getExternalFilesDir()));
		#end

		addChild(new FlxGame(1280, 720, PlayState));

		var overlay:FPS = new FPS(10, 10, 0xFFFFFFFF);
		overlay.scaleX = overlay.scaleY = stage.window.scale;
		addChild(overlay);
	}
}
