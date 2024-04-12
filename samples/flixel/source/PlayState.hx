package;

#if android
import android.widget.Toast;
#end
import flixel.util.FlxTimer;
import flixel.FlxG;
import flixel.FlxState;
import haxe.Exception;
import hxvlc.flixel.FlxVideo;
import hxvlc.flixel.FlxVideoBackdrop;
import hxvlc.flixel.FlxVideoSprite;
import hxvlc.util.Handle;
import openfl.system.System;
import openfl.utils.Assets;
import openfl.Lib;
import sys.io.File;
import sys.FileSystem;

using haxe.io.Path;

class PlayState extends FlxState
{
	override function create():Void
	{
		#if mobile
		copyFiles();
		#end

		var video:FlxVideoSprite = new FlxVideoSprite(0, 0);
		video.antialiasing = true;
		video.bitmap.onFormatSetup.add(function():Void
		{
			video.setGraphicSize(FlxG.width, FlxG.height);
			video.updateHitbox();
			video.screenCenter();
		});
		video.bitmap.onEndReached.add(video.destroy);
		video.load('assets/video.mp4', [':input-repeat=2']);
		add(video);

		new FlxTimer().start(0.001, function(tmr:FlxTimer):Void
		{
			video.play();
		});

		super.create();
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

			System.gc();
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
