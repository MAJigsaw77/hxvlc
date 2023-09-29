package;

#if android
import android.content.Context;
#end
import flixel.FlxG;
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

		addChild(new FPS(10, 10, 0xFFFFFFFF));
	}
}
