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
import sys.io.File;
import sys.FileSystem;

class Main extends Sprite
{
	private var video:Video;

	public function new():Void
	{
		super();

		#if android
		Sys.setCwd(Path.addTrailingSlash(Context.getExternalFilesDir()));
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
		});
		video.onFormatSetup.add(() -> stage.addEventListener(Event.ENTER_FRAME, stage_onEnterFrame));
		addChild(video);

		final path:String = 'assets/video.mp4';

		#if android
		try
		{
			if (!FileSystem.exists(Path.directory(path)))
			{
				FileSystem.createDirectory(Path.directory(path));

				File.saveBytes(path, Assets.getBytes(path));
			}
			else if (!FileSystem.exists(path))
				File.saveBytes(path, Assets.getBytes(path));
				
		}
		catch (e:Exception)
			Toast.makeText(e.message, Toast.LENGTH_LONG);
		#end

		addChild(new FPS(10, 10, 0xFFFFFFFF));
		
		video.play(Sys.getCwd() + path, 2);
	}

	private inline function stage_onEnterFrame(event:Event):Void
	{
		final aspectRatio:Float = video.videoWidth / video.videoHeight;

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
