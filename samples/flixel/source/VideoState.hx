package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.system.FlxAssets;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

import hxvlc.flixel.FlxVideoSprite;
import hxvlc.util.Handle;

import sys.FileSystem;

@:nullSafety
class VideoState extends FlxState
{
	static final bigBuckBunny:String = 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4';
	static final elephantsDream:String = 'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4';

	var video:Null<FlxVideoSprite>;
	var versionInfo:Null<FlxText>;

	override function create():Void
	{
		FlxG.autoPause = false;

		setupUI();

		setupVideo();

		super.create();
	}

	override function update(elapsed:Float):Void
	{
		if (video != null)
		{
			if (FlxG.keys.justPressed.SPACE)
				video.togglePaused();

			if (video.bitmap != null)
			{
				if (FlxG.keys.justPressed.LEFT)
					video.bitmap.position -= 0.1;
				else if (FlxG.keys.justPressed.RIGHT)
					video.bitmap.position += 0.1;

				if (FlxG.keys.justPressed.A)
					video.bitmap.rate -= 0.01;
				else if (FlxG.keys.justPressed.D)
					video.bitmap.rate += 0.01;
			}

			if (FlxG.keys.justPressed.ESCAPE)
				video.stop();
		}

		super.update(elapsed);
	}

	private function setupUI():Void
	{
		FlxG.camera.bgColor = FlxColor.MAGENTA;

		versionInfo = new FlxText(10, FlxG.height - 10, 0, 'Version: ${Handle.version}\nCompiler: ${Handle.compiler}\nChangeset: ${Handle.changeset}', 17);
		versionInfo.setBorderStyle(OUTLINE, FlxColor.BLACK, 2);
		versionInfo.font = FlxAssets.FONT_DEBUGGER;
		versionInfo.active = false;
		versionInfo.alignment = JUSTIFY;
		versionInfo.antialiasing = true;
		versionInfo.y -= versionInfo.height;
		add(versionInfo);
	}

	@:nullSafety(Off)
	private function setupVideo():Void
	{
		Handle.initAsync(function(success:Bool):Void
		{
			if (!success)
				return;

			function finishVideo():Void
			{
				if (video != null)
				{
					remove(video);
					video.destroy();
					video = null;
				}
			}

			video = new FlxVideoSprite(0, 0);
			video.active = false;
			video.antialiasing = true;
			video.bitmap.onStopped.add(finishVideo);
			video.bitmap.onEndReached.add(finishVideo);
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

			try
			{
				final file:String = haxe.io.Path.join(['assets', FileSystem.readDirectory('assets')[0]]);

				if (file != null && file.length > 0)
					video.load(file);
				else
					video.load(FlxG.random.getObject([bigBuckBunny, elephantsDream]));
			}
			catch (e:Dynamic)
				video.load(FlxG.random.getObject([bigBuckBunny, elephantsDream]));

			if (versionInfo != null)
				insert(members.indexOf(versionInfo), video);

			FlxTimer.wait(0.001, function():Void
			{
				video.play();
			});
		});
	}
}
