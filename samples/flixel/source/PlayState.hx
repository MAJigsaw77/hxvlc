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
import hxvlc.externs.Types;
import hxvlc.flixel.FlxVideo;
import hxvlc.flixel.FlxVideoSprite;
import hxvlc.util.Handle;
import openfl.system.System;
import openfl.utils.Assets;
import openfl.Lib;
import sys.io.File;
import sys.FileSystem;

class PlayState extends FlxState
{
	var video:FlxVideoSprite;
	var videoPositionBar:FlxBar;

	override function create():Void
	{
		/*#if mobile
		copyFiles();
		#end*/

		if (!FileSystem.exists('assets'))
			FileSystem.createDirectory('assets');

		FlxG.cameras.bgColor = 0xFF131C1B;

		var metadataInfo:FlxText = new FlxText(0, 40, 0, 'Unknown\nUnknown', 32);
		metadataInfo.setBorderStyle(OUTLINE, FlxColor.BLACK);
		metadataInfo.alignment = CENTER;
		metadataInfo.antialiasing = true;

		video = new FlxVideoSprite(0, 0);
		video.bitmap.onMediaParsedChanged.add(function(status:Int):Void
		{
			switch (status)
			{
				case status if (status == LibVLC_Media_Parsed_Status_Skipped):
					FlxG.log.notice('Media parsing skipped.');

					video.bitmap.parseStop();

					FlxTimer.wait(0.001, function():Void
					{
						video.play();
					});
				case status if (status == LibVLC_Media_Parsed_Status_Failed):
					FlxG.log.notice('Media parsing failed. Stopping further processing.');

					video.bitmap.parseStop();
				case status if (status == LibVLC_Media_Parsed_Status_Timeout):
					FlxG.log.notice('Media parsing timed out. Stopping further processing.');

					video.bitmap.parseStop();
				case status if (status == LibVLC_Media_Parsed_Status_Done):
					FlxG.log.notice('Media parsing done. Starting playback.');

					metadataInfo.text = '${video.bitmap.getMeta(LibVLC_Meta_Title) ?? 'Unknown'}\n${video.bitmap.getMeta(LibVLC_Meta_Artist) ?? 'Unknown'}';
					metadataInfo.screenCenter(X);

					FlxTimer.wait(0.001, function():Void
					{
						video.play();
					});
			}
		});
		video.bitmap.onFormatSetup.add(function():Void
		{
			video.setGraphicSize(FlxG.width * 0.7, FlxG.height * 0.7);
			video.updateHitbox();
			video.screenCenter();
		});
		video.bitmap.onPositionChanged.add(function(position:Single):Void
		{
			if (videoPositionBar != null)
				videoPositionBar.value = position;
		});
		video.bitmap.onEndReached.add(video.destroy);
		video.load(Path.join(['assets', FileSystem.readDirectory('assets')[0]]), [':input-repeat=2']);
		video.bitmap.parseWithOptions(LibVLC_Media_Parse_Local, -1);
		video.antialiasing = true;
		add(video);

		add(metadataInfo);

		var libvlcVersion:FlxText = new FlxText(10, FlxG.height - 30, 0, 'LibVLC Version: ${Handle.version}', 16);
		libvlcVersion.setBorderStyle(OUTLINE, FlxColor.BLACK);
		libvlcVersion.active = false;
		libvlcVersion.antialiasing = true;
		add(libvlcVersion);

		videoPositionBar = new FlxBar(10, FlxG.height - 50, LEFT_TO_RIGHT, FlxG.width - 20, 10, null, '', 0, 1);
		videoPositionBar.createFilledBar(FlxColor.GRAY, FlxColor.CYAN, true, FlxColor.BLACK);
		add(videoPositionBar);

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
