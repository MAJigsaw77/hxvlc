package;

#if android
import android.content.Context;
import android.os.Build;
#end
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxGame;
import haxe.io.Path;
import lime.system.System;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.Lib;

class Main extends Sprite
{
	public static function main():Void
	{
		#if android
		Sys.setCwd(Path.addTrailingSlash(VERSION.SDK_INT > 30 ? Context.getObbDir() : Context.getExternalFilesDir()));
		#elseif ios
		Sys.setCwd(System.documentsDirectory);
		#end

		Lib.current.addChild(new Main());
	}

	public function new():Void
	{
		super();

		if (stage != null)
			onAddedToStage();
		else
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
	}

	private function onAddedToStage(?event:Event):Void
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);

		addChild(new FlxGame(1280, 720, VideoState, 999, 999));

		#if FLX_MOUSE
		FlxG.mouse.useSystemCursor = true;
		#end
	}
}
