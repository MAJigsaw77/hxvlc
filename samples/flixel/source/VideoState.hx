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

		Handle.init([
			'--audio-visual=visual',
			'--effect-list=spectrum',
			'--effect-width=1280',
			'--effect-height=720',
			'--effect-fft-window=flattop'
		]);

		video = new FlxVideoSprite(0, 0);
		video.bitmap.onMediaParsedChanged.add(function(status:Int):Void
		{
			switch (status)
			{
				case status if (status == LibVLC_Media_Parsed_Status_Skipped):
					FlxG.log.notice('Media parsing skipped.');

					video.parseStop();
				case status if (status == LibVLC_Media_Parsed_Status_Failed):
					FlxG.log.notice('Media parsing failed.');

					video.parseStop();
				case status if (status == LibVLC_Media_Parsed_Status_Timeout):
					FlxG.log.notice('Media parsing timed out.');

					video.parseStop();
				case status if (status == LibVLC_Media_Parsed_Status_Done):
					FlxG.log.notice('Media parsing done.');

					if (video.loadFromSubItem(0, [':input-repeat=2']))
					{
						FlxG.log.notice('Currently loading "${video.bitmap.mrl}"...');

						FlxTimer.wait(0.001, function():Void
						{
							video.play();
						});
					}
			}
		});
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
		video.load('https://on.soundcloud.com/pK5Q3');
		video.antialiasing = true;
		video.blend = ADD;
		add(video);

		final parseLocal:Int = LibVLC_Media_Parse_Network;
		final fetchLocal:Int = LibVLC_Media_Fetch_Network;

		video.parseWithOptions(parseLocal | fetchLocal, -1);

		var libvlcVersion:FlxText = new FlxText(10, FlxG.height - 30, 0, 'LibVLC ${Handle.version}', 16);
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
