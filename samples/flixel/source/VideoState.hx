package;

#if android
import android.widget.Toast;
#end
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.ui.FlxBar;
import flixel.FlxG;
import flixel.FlxState;
import haxe.io.Path;
import haxe.Exception;
import hxvlc.flixel.FlxVideo;
import hxvlc.flixel.FlxVideoSprite;
import hxvlc.util.Handle;
import openfl.system.System;
import openfl.utils.Assets;
import openfl.Lib;
import sys.io.File;
import sys.FileSystem;

class VideoState extends FlxState
{
	var video:FlxVideoSprite;
	var videoPositionBar:FlxBar;

	override function create():Void
	{
		#if mobile
		copyFiles();
		#end

		FlxG.cameras.bgColor = 0xFF131C1B;

		video = new FlxVideoSprite(0, 0);
		video.bitmap.onFormatSetup.add(function():Void
		{
			if (video.bitmap != null && video.bitmap.bitmapData != null)
			{
				final scale:Float = Math.min(FlxG.width / video.bitmap.bitmapData.width, FlxG.height / video.bitmap.bitmapData.height) * 0.8;

				video.setGraphicSize(video.bitmap.bitmapData.width * scale, video.bitmap.bitmapData.height * scale);
				video.updateHitbox();
				video.screenCenter();
			}
		});
		video.bitmap.onPositionChanged.add(function(position:Single):Void
		{
			if (videoPositionBar != null)
				videoPositionBar.value = position;
		});
		video.bitmap.onEndReached.add(video.destroy);
		video.load('assets/video.mp4', [':input-repeat=2']);
		video.antialiasing = true;
		add(video);

		var libvlcVersion:FlxText = new FlxText(10, FlxG.height - 30, 0, 'LibVLC ${Handle.version}', 16);
		libvlcVersion.setBorderStyle(OUTLINE, FlxColor.BLACK);
		libvlcVersion.active = false;
		libvlcVersion.antialiasing = true;
		add(libvlcVersion);

		videoPositionBar = new FlxBar(10, FlxG.height - 50, LEFT_TO_RIGHT, FlxG.width - 20, 10, null, '', 0, 1);
		videoPositionBar.createFilledBar(FlxColor.GRAY, FlxColor.CYAN, true, FlxColor.BLACK);
		videoPositionBar.antialiasing = true;
		videoPositionBar.numDivisions = 10000;
		add(videoPositionBar);

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
