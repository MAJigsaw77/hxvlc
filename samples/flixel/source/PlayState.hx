package;

#if android
import android.widget.Toast;
#end
import flixel.text.FlxText;
import flixel.util.FlxColor;
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

		FlxG.cameras.bgColor = 0xFF131C1B;

		var video:FlxVideoSprite = new FlxVideoSprite(0, 0);
		video.antialiasing = true;
		video.bitmap.onFormatSetup.add(function():Void
		{
			video.setGraphicSize(FlxG.width * 0.7, FlxG.height * 0.7);
			video.updateHitbox();
			video.screenCenter();
		});
		video.bitmap.onEndReached.add(video.destroy);
		video.load('assets/video.mp4', [':input-repeat=2']);
		add(video);

		var infoText:FlxText = new FlxText(10, FlxG.height - 50, FlxG.width - 20, 'LibVLC Version: ${Handle.version}\nLibVLC Change-Set: ${Handle.changeset}', 16);
		infoText.setBorderStyle(OUTLINE, FlxColor.BLACK);
		infoText.active = false;
		infoText.antialiasing = true;
		add(infoText);

		FlxTimer.wait(0.001, function():Void
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
