package;

#if android
import android.content.Context;
import android.os.Build;
import android.widget.Toast;
#end
import haxe.io.Path;
import haxe.CallStack;
import haxe.Exception;
import haxe.Log;
import hxvlc.openfl.Video;
import lime.system.System as LimeSystem;
import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.errors.Error;
import openfl.events.ErrorEvent;
import openfl.events.UncaughtErrorEvent;
import openfl.events.Event;
import openfl.system.System as OpenFLSystem;
import openfl.utils.Assets;
import openfl.Lib;
import sys.io.File;
import sys.FileSystem;

using StringTools;

class Main extends Sprite
{
	private var video:Video;

	public function new():Void
	{
		super();

		#if android
		if (VERSION.SDK_INT > 30)
			Sys.setCwd(Path.addTrailingSlash(Context.getObbDir()));
		else
			Sys.setCwd(Path.addTrailingSlash(Context.getExternalFilesDir()));
		#elseif ios
		Sys.setCwd(LimeSystem.documentsDirectory);
		#end

		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onUncaughtError);

		#if !linux
		Lib.current.stage.frameRate = Lib.application.window.displayMode.refreshRate;
		#end

		#if mobile
		copyFiles();
		#end
		
		video = new Video();
		video.onOpening.add(function()
		{
			stage.addEventListener(Event.ACTIVATE, stage_onActivate);
			stage.addEventListener(Event.DEACTIVATE, stage_onDeactivate);
		});
		video.onEndReached.add(function()
		{
			stage.removeEventListener(Event.ACTIVATE, stage_onActivate);
			stage.removeEventListener(Event.DEACTIVATE, stage_onDeactivate);

			if (stage.hasEventListener(Event.ENTER_FRAME))
				stage.removeEventListener(Event.ENTER_FRAME, stage_onEnterFrame);

			video.dispose();

			if (contains(video))
				removeChild(video);
		});
		video.onFormatSetup.add(() -> stage.addEventListener(Event.ENTER_FRAME, stage_onEnterFrame));
		addChild(video);

		// These must be called after the child is added (Mostly to have events accuracy).
		video.load(Path.join([Sys.getCwd(), 'assets/video.mp4']));
		video.play();
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

		Log.trace(msg, null);
		Lib.application.window.alert(msg, 'Error!');
		LimeSystem.exit(1);
	}

	private inline function stage_onEnterFrame(event:Event):Void
	{
		final aspectRatio:Float = video.formatWidth / video.formatHeight;

		if (stage.stageWidth / stage.stageHeight > aspectRatio)
		{
			// stage is wider than video
			video.width = stage.stageHeight * aspectRatio;
			video.height = stage.stageHeight;
		}
		else
		{
			// stage is taller than video
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

	#if mobile
	private inline function copyFiles():Void
	{
		try
		{
			final path:String = 'assets/video.mp4';

			if (!FileSystem.exists(Path.directory(path)))
			{
				FileSystem.createDirectory(Path.directory(path));

				File.saveBytes(path, Assets.getBytes(path));
			}
			else if (!FileSystem.exists(path))
				File.saveBytes(path, Assets.getBytes(path));

			OpenFLSystem.gc();
		}
		catch (e:Exception)
		{
			#if android
			Toast.makeText(e.message, Toast.LENGTH_LONG);
			#end
		}
	}
	#end
}
