package;

import flixel.system.FlxAssets;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.FlxG;
import flixel.FlxState;
import hxvlc.flixel.FlxVideo;
import hxvlc.flixel.FlxVideoSprite;
import hxvlc.util.Handle;
import sys.FileSystem;

class VideoState extends FlxState
{
	var video:FlxVideoSprite;

	override function create():Void
	{
		video = new FlxVideoSprite(0, 0);
		video.active = false;
		video.antialiasing = true;
		video.bitmap.onFormatSetup.add(function():Void
		{
			if (video.bitmap != null && video.bitmap.bitmapData != null)
			{
				final scale:Float = Math.min(FlxG.width / video.bitmap.bitmapData.width, FlxG.height / video.bitmap.bitmapData.height);

				video.setGraphicSize(video.bitmap.bitmapData.width * scale, video.bitmap.bitmapData.height * scale);
				video.updateHitbox();
				video.screenCenter();
			}
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

		final libvlcVersion:FlxText = new FlxText(10, FlxG.height - 10, 0, 'LibVLC ${Handle.version}', 16);
		libvlcVersion.font = FlxAssets.FONT_DEBUGGER;
		libvlcVersion.active = false;
		libvlcVersion.antialiasing = true;
		libvlcVersion.y -= libvlcVersion.height;
		add(libvlcVersion);

		FlxTimer.wait(0.001, function():Void
		{
			video.play();
		});

		super.create();
	}
}
