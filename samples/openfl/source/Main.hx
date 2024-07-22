package;

#if android
import android.content.Context;
import android.os.Build;
import android.widget.Toast;
#end
import haxe.io.Path;
import haxe.CallStack;
import haxe.Exception;
import hxvlc.openfl.Video;
import lime.system.System;
import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.errors.Error;
import openfl.events.ErrorEvent;
import openfl.events.UncaughtErrorEvent;
import openfl.events.Event;
import openfl.utils.Assets;
import openfl.Lib;
import sys.io.File;
import sys.FileSystem;

using StringTools;

class Main extends Sprite
{
	private var video:Video;

	public static function main():Void
	{
		#if android
		Sys.setCwd(Path.addTrailingSlash(VERSION.SDK_INT > 30 ? Context.getObbDir() : Context.getExternalFilesDir()));
		#elseif ios
		Sys.setCwd(System.documentsDirectory);
		#end

		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onUncaughtError);
		Lib.current.addChild(new Main());
	}

	public function new():Void
	{
		super();

		var refreshRate:Int = Lib.application.window.displayMode.refreshRate;

		if (refreshRate < 60)
			refreshRate = 60;

		Lib.current.stage.frameRate = refreshRate;

		video = new Video();
		video.onOpening.add(function():Void
		{
			stage.addEventListener(Event.ACTIVATE, stage_onActivate);
			stage.addEventListener(Event.DEACTIVATE, stage_onDeactivate);
		});
		video.onEndReached.add(function():Void
		{
			stage.removeEventListener(Event.ACTIVATE, stage_onActivate);
			stage.removeEventListener(Event.DEACTIVATE, stage_onDeactivate);

			if (stage.hasEventListener(Event.ENTER_FRAME))
				stage.removeEventListener(Event.ENTER_FRAME, stage_onEnterFrame);

			video.dispose();

			removeChild(video);
		});
		video.onFormatSetup.add(function():Void
		{
			stage.addEventListener(Event.ENTER_FRAME, stage_onEnterFrame);
		});
		addChild(video);

		if (video.load('http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4'))
			video.play();
	}

	private inline function stage_onEnterFrame(event:Event):Void
	{
		if (video.bitmapData == null)
			return;

		final aspectRatio:Float = video.bitmapData.width / video.bitmapData.height;

		if (stage.stageWidth / stage.stageHeight > aspectRatio)
		{
			video.width = stage.stageHeight * aspectRatio;
			video.height = stage.stageHeight;
		}
		else
		{
			video.width = stage.stageWidth;
			video.height = stage.stageWidth / aspectRatio;
		}

		video.x = (stage.stageWidth - video.width) / 2;
		video.y = (stage.stageHeight - video.height) / 2;
	}

	private inline function stage_onActivate(event:Event):Void
	{
		video.resume();
	}

	private inline function stage_onDeactivate(event:Event):Void
	{
		video.pause();
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
			Sys.println('Couldn\'t save error message "${e.message}"');

		Sys.println(msg);
		Lib.application.window.alert(msg, 'Error!');
		LimeSystem.exit(1);
	}
}
