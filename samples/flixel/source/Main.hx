package;

#if android
import android.content.Context;
#end
import flixel.FlxGame;
import haxe.io.Path;
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
	}
}
