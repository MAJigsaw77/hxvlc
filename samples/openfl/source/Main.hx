package;

import openfl.display.FPS;

import hxvlc.openfl.Video;

import openfl.display.Sprite;
import openfl.events.Event;
import openfl.utils.Assets;

class Main extends Sprite
{
	var video:Video;
	var fps:FPS;

	public function new():Void
	{
		super();

		video = new Video();
		video.onOpening.add(function():Void
		{
			if (!stage.nativeWindow.hasEventListener(Event.ACTIVATE))
				stage.nativeWindow.addEventListener(Event.ACTIVATE, stage_onActivate);

			if (!stage.nativeWindow.hasEventListener(Event.DEACTIVATE))
				stage.nativeWindow.addEventListener(Event.DEACTIVATE, stage_onDeactivate);
		});
		video.onEndReached.add(function():Void
		{
			if (stage.nativeWindow.hasEventListener(Event.ACTIVATE))
				stage.nativeWindow.removeEventListener(Event.ACTIVATE, stage_onActivate);

			if (stage.nativeWindow.hasEventListener(Event.DEACTIVATE))
				stage.nativeWindow.removeEventListener(Event.DEACTIVATE, stage_onDeactivate);

			if (stage.hasEventListener(Event.ENTER_FRAME))
				stage.removeEventListener(Event.ENTER_FRAME, stage_onEnterFrame);

			if (video != null)
			{
				removeChild(video);

				if (video.bitmapData != null)
				{
					video.bitmapData.dispose();
					video.bitmapData = null;
				}

				video.dispose();

				video = null;
			}
		});
		video.onFormatSetup.add(function():Void
		{
			if (!stage.hasEventListener(Event.ENTER_FRAME))
				stage.addEventListener(Event.ENTER_FRAME, stage_onEnterFrame);
		});

		addChild(video);

		if (video.load('assets/video.mp4'))
			video.play();

		fps = new FPS(10, 10, 0xFF0000);
		addChild(fps);
	}

	@:noCompletion
	private function stage_onEnterFrame(_):Void
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

	@:noCompletion
	private function stage_onActivate(event:Event):Void
	{
		video.resume();
	}

	@:noCompletion
	private function stage_onDeactivate(event:Event):Void
	{
		video.pause();
	}
}
