package;

#if android
import android.content.Context;
import android.os.Build;
#end
import haxe.io.Path;
import lime.system.System;
import hxvlc.openfl.Video;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.Lib;
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

		try
		{
			#if mobile
			final file:String = FileSystem.readDirectory('./')[0];
			#else
			final file:String = Path.join(['videos', FileSystem.readDirectory('videos')[0]]);
			#end

			if (file != null && file.length > 0)
				video.load(file);
			else
				video.load('https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4');
		}
		catch (e:Dynamic)
			video.load('https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4');

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
}
