package;

import openfl.text.TextFormat;

import flixel.system.FlxAssets;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxSprite;

import openfl.Lib;
import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.events.Event;

class Main extends Sprite
{
	public static function main():Void
	{
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

		FlxSprite.defaultAntialiasing = true;

		#if run_uncapped
		#if lime_funkin
		final framerate:Int = 0;
		#else
		final framerate:Int = 999;
		#end
		#else
		final framerate:Int = stage.window.displayMode.refreshRate;
		#end

		final game:FlxGame = new FlxGame(1280, 720, VideoState, framerate, framerate);
		game.focusLostFramerate = framerate;
		addChild(game);

		#if FLX_MOUSE
		FlxG.mouse.useSystemCursor = true;
		#end

		final fps:FPS = new FPS(10, 10, 0xFF0000);

		final fpsDefaultTextFormat:TextFormat = fps.defaultTextFormat;
		fpsDefaultTextFormat.font = FlxAssets.FONT_DEBUGGER;
		fpsDefaultTextFormat.align = JUSTIFY;
		fps.setTextFormat(fpsDefaultTextFormat);

		FlxG.game.addChild(fps);
	}
}
