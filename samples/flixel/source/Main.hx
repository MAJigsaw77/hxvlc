package;

#if android
import android.content.Context;
import android.os.Build;
#end
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxGame;
import haxe.io.Path;
import haxe.CallStack;
import haxe.Exception;
import haxe.Log;
import lime.system.System;
import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.errors.Error;
import openfl.events.ErrorEvent;
import openfl.events.UncaughtErrorEvent;
import openfl.Lib;
import sys.io.File;
import sys.FileSystem;

using StringTools;

class Main extends Sprite
{
	public static var fps:FPS;

	public function new():Void
	{
		super();

		#if android
		Sys.setCwd(Path.addTrailingSlash(VERSION.SDK_INT > 30 ? Context.getObbDir() : Context.getExternalFilesDir()));
		#elseif ios
		Sys.setCwd(System.documentsDirectory);
		#end

		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onUncaughtError);

		#if (mobile && debug)
		FlxG.log.redirectTraces = true;
		#end

		FlxG.signals.gameResized.add(onResizeGame);

		final refreshRate:Int = #if linux 60 #else Lib.application.window.displayMode.refreshRate #end;

		addChild(new FlxGame(1280, 720, PlayState, refreshRate, refreshRate));

		#if FLX_MOUSE
		FlxG.mouse.useSystemCursor = true;
		#end

		fps = new FPS(10, 10, FlxColor.WHITE);
		fps.defaultTextFormat.size = 16;
		FlxG.game.addChild(fps);
	}

	private inline function onUncaughtError(event:UncaughtErrorEvent):Void
	{
		event.preventDefault();
		event.stopImmediatePropagation();

		final log:Array<String> = [];

		if (Std.isOfType(event.error, Error))
			log.push(cast(event.error, Error).message);
		else if (Std.isOfType(event.error, ErrorEvent))
			log.push(cast(event.error, ErrorEvent).text);
		else
			log.push(Std.string(event.error));

		for (item in CallStack.exceptionStack(true))
		{
			switch (item)
			{
				case CFunction:
					log.push('C Function');
				case Module(m):
					log.push('Module [$m]');
				case FilePos(s, file, line, column):
					log.push('$file [line $line]');
				case Method(classname, method):
					log.push('$classname [method $method]');
				case LocalFunction(name):
					log.push('Local Function [$name]');
			}
		}

		final msg:String = log.join('\n');

		try
		{
			if (!FileSystem.exists('errors'))
				FileSystem.createDirectory('errors');

			File.saveContent('errors/' + Date.now().toString().replace(' ', '-').replace(':', "'") + '.txt', msg);
		}
		catch (e:Exception)
			Log.trace('Couldn\'t save error message "${e.message}"', null);

		Sys.println(msg);
		Lib.application.window.alert(msg, 'Error!');
		System.exit(1);
	}

	private inline function onResizeGame(width:Int, height:Int):Void
	{
		final scale:Float = Math.min(FlxG.stage.stageWidth / FlxG.width, FlxG.stage.stageHeight / FlxG.height);

		if (fps != null)
			fps.scaleX = fps.scaleY = (scale > 1 ? scale : 1);
	}
}
