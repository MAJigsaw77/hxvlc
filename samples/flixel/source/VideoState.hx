package;

import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.ui.FlxBar;
import flixel.FlxG;
import flixel.FlxState;
import hxvlc.flixel.FlxVideo;
import hxvlc.flixel.FlxVideoSprite;
import hxvlc.util.Handle;
import sys.FileSystem;

class VideoState extends FlxState
{
	var video:FlxVideoSprite;
	var videoPositionBar:FlxBar;

	override function create():Void
	{
		FlxG.cameras.bgColor = 0xFF131C1B;

		video = new FlxVideoSprite(0, 0);
		video.antialiasing = true;
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

		try
		{
			#if mobile
			final file:String = FileSystem.readDirectory('./')[0];
			#else
			final file:String = haxe.io.Path.join(['videos', FileSystem.readDirectory('videos')[0]]);
			#end

			if (file != null && file.length > 0)
				video.load(file);
			else
				video.load('https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4');
		}
		catch (e:Dynamic)
			video.load('https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4');

		add(video);

		final libvlcVersion:FlxText = new FlxText(10, FlxG.height - 30, 0, 'LibVLC ${Handle.version}', 16);
		libvlcVersion.setBorderStyle(OUTLINE, FlxColor.BLACK);
		libvlcVersion.active = false;
		libvlcVersion.antialiasing = true;
		add(libvlcVersion);

		videoPositionBar = new FlxBar(10, FlxG.height - 50, LEFT_TO_RIGHT, FlxG.width - 20, 10, null, '', 0, 1);
		videoPositionBar.createFilledBar(FlxColor.GRAY, FlxColor.CYAN, true, FlxColor.BLACK);
		videoPositionBar.antialiasing = true;
		videoPositionBar.numDivisions = 999999;
		add(videoPositionBar);

		FlxTimer.wait(0.001, function():Void
		{
			video.play();
		});

		super.create();
	}
}
