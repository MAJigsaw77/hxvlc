package;

#if android
import android.content.Context;
import android.widget.Toast;
#end
import haxe.io.Path;
import haxe.Exception;
import hxvlc.openfl.Video;
import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.utils.Assets;
import openfl.Lib;
import sys.io.File;
import sys.FileSystem;

using haxe.io.Path;

class Main extends Sprite
{
	private var video:Video;

	public function new():Void
	{
		super();

		Lib.current.stage.frameRate = Lib.application.window?.displayMode.refreshRate;

		#if android
		Sys.setCwd(Path.addTrailingSlash(Context.getObbDir()));
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
			stage.removeEventListener(Event.ENTER_FRAME, stage_onEnterFrame);

			video.dispose();

			if (contains(video))
				removeChild(video);
		});
		video.onFormatSetup.add(() -> stage.addEventListener(Event.ENTER_FRAME, stage_onEnterFrame));

		final path:String = 'assets/video.mp4';

		#if android
		try
		{
			if (!FileSystem.exists(path.directory()))
			{
				FileSystem.createDirectory(path.directory());

				File.saveBytes(path, Assets.getBytes(path));
			}
			else if (!FileSystem.exists(path))
				File.saveBytes(path, Assets.getBytes(path));
				
		}
		catch (e:Exception)
			Toast.makeText(e.message, Toast.LENGTH_LONG);
		#end
		
		video.load(Sys.getCwd() + path, 2);

		addChild(video);

		video.play();
	}

	private inline function stage_onEnterFrame(event:Event):Void
	{
		final aspectRatio:Float = video.size.x / video.size.y;

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
			video.height = stage.stageWidth * (1 / aspectRatio);
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
