package;

#if android
import android.widget.Toast;
#end
import flixel.util.FlxTimer;
import flixel.FlxState;
import haxe.Exception;
import hxvlc.flixel.FlxVideo;
import hxvlc.flixel.FlxVideoBackdrop;
import hxvlc.flixel.FlxVideoSprite;
import hxvlc.libvlc.Handle;
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
		final path:String = 'assets/video.mp4';

		/*#if mobile
		try
		{
			if (!FileSystem.exists(path.directory()))
			{
				FileSystem.createDirectory(path.directory());

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
		#end*/

		// Handle.initAsync(['--video-filter=sepia', '--sepia-intensity=153'], function(success:Bool):Void
		// {
			// if (!success)
				// return;

			var video:FlxVideo = new FlxVideo();
			video.onEndReached.add(video.dispose);
			video.load(Assets.getBytes(path));

			new FlxTimer().start(0.001, function(tmr:FlxTimer):Void
			{
				video.play();
			});
		// });

		super.create();
	}
}
