package;

#if android
import android.widget.Toast;
#end
import flixel.FlxG;
import flixel.FlxState;
import haxe.Exception;
import hxvlc.flixel.FlxVideo;
import hxvlc.flixel.FlxVideoBackdrop;
import hxvlc.flixel.FlxVideoSprite;
import openfl.utils.Assets;
import sys.io.File;
import sys.FileSystem;

using haxe.io.Path;

class PlayState extends FlxState
{
	override function create():Void
	{
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

		var video:FlxVideo = new FlxVideo();
		video.onEndReached.add(video.dispose);
		video.play(path, 2);

		super.create();
	}
}
