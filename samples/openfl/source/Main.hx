package;

import hxvlc.openfl.Video;

import openfl.events.Event;

class Main extends openfl.display.Sprite
{
	private var video:Video;

	public static function main():Void
	{
		#if android
		Sys.setCwd(haxe.io.Path.addTrailingSlash(extension.androidtools.os.Build.VERSION.SDK_INT > 30 ? extension.androidtools.content.Context.getObbDir() : extension.androidtools.content.Context.getExternalFilesDir()));
		#elseif ios
		Sys.setCwd(lime.system.System.documentsDirectory);
		#end

		openfl.Lib.current.addChild(new Main());
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

		openfl.Lib.current.stage.frameRate = 999;

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

			if (video != null)
			{
				removeChild(video);
				video.dispose();
				video = null;
			}
		});
		video.onFormatSetup.add(function():Void
		{
			stage.addEventListener(Event.ENTER_FRAME, stage_onEnterFrame);
		});
		addChild(video);

		try
		{
			final file:String = haxe.io.Path.join(['videos', sys.FileSystem.readDirectory('videos')[0]]);

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
