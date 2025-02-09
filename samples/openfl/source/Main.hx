package;

#if android
import android.content.Context;
import android.os.Build;
#end
import haxe.io.Path;
import lime.system.System;
import hxvlc.openfl.Video;
import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.Lib;
import sys.FileSystem;

using StringTools;

class Main extends Sprite
{
	private var video:Video;
	private var fps:FPS;

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

		Lib.current.stage.frameRate = 999;

		video = new Video();
		video.onOpening.add(function():Void
		{
			stage.nativeWindow.addEventListener(Event.ACTIVATE, stage_onActivate);
			stage.nativeWindow.addEventListener(Event.DEACTIVATE, stage_onDeactivate);
		});
		video.onEndReached.add(function():Void
		{
			stage.nativeWindow.removeEventListener(Event.ACTIVATE, stage_onActivate);
			stage.nativeWindow.removeEventListener(Event.DEACTIVATE, stage_onDeactivate);

			if (stage.hasEventListener(Event.ENTER_FRAME))
				stage.removeEventListener(Event.ENTER_FRAME, stage_onEnterFrame);

			video.dispose();

			removeChild(video);

			video = null;
		});
		video.onFormatSetup.add(function():Void
		{
			stage.addEventListener(Event.ENTER_FRAME, stage_onEnterFrame);
		});
		addChild(video);

		fps = new FPS(0, 0, 0xFFFFFF);
		fps.defaultTextFormat.align = JUSTIFY;
		fps.defaultTextFormat.size = 16;
		addChild(fps);

		try
		{
			final file:String = Path.join(['videos', FileSystem.readDirectory('videos')[0]]);

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
		if (video != null && video.bitmapData != null)
		{
			final aspectRatio:Float = video.bitmapData.width / video.bitmapData.height;

			video.width = stage.stageWidth / stage.stageHeight > aspectRatio ? stage.stageHeight * aspectRatio : stage.stageWidth;
			video.height = stage.stageWidth / stage.stageHeight > aspectRatio ? stage.stageHeight : stage.stageWidth / aspectRatio;

			video.x = (stage.stageWidth - video.width) / 2;
			video.y = (stage.stageHeight - video.height) / 2;

			fps.x = video.x + 10;
			fps.y = video.y + 10;
		}
	}

	private inline function stage_onActivate(event:Event):Void
	{
		video?.resume();
	}

	private inline function stage_onDeactivate(event:Event):Void
	{
		video?.pause();
	}
}
