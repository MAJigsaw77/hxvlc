package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.system.FlxAssets;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

import hxvlc.flixel.FlxVideoSprite;
import hxvlc.impl.Instance;

class VideoState extends FlxState
{
	var video:FlxVideoSprite;
	var versionInfo:FlxText;

	override function create():Void
	{
		FlxG.autoPause = false;


		video = new FlxVideoSprite(0, 0);

		video.bitmap.onEndReached.add(function():Void
		{
			if (video != null)
			{
				remove(video);
				video.destroy();
				video = null;
			}
		});
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
		video.precache('assets/video.mp4');
		add(video);

		versionInfo = new FlxText(10, FlxG.height - 10, 0, 'Version: ${Instance.version} | Changeset: ${Instance.changeset}', 17);
		versionInfo.setBorderStyle(OUTLINE, FlxColor.BLACK, 2);
		versionInfo.font = FlxAssets.FONT_DEBUGGER;
		versionInfo.active = false;
		versionInfo.alignment = JUSTIFY;
		versionInfo.antialiasing = true;
		versionInfo.y -= versionInfo.height;
		add(versionInfo);

		super.create();

		FlxTimer.wait(0.001, function():Void
		{
			video.play();
		});
	}

	override function update(elapsed:Float):Void
	{
		if (video != null)
		{
			if (FlxG.keys.justPressed.SPACE)
				video.togglePaused();

			if (video.bitmap != null)
			{
				if (FlxG.keys.justPressed.R)
				{
					video.pause();
					video.bitmap.position = 0.0;
					video.resume();
				}

				if (FlxG.keys.justPressed.LEFT)
					video.bitmap.position -= 0.1;
				else if (FlxG.keys.justPressed.RIGHT)
					video.bitmap.position += 0.1;

				if (FlxG.keys.justPressed.A)
					video.bitmap.rate -= 0.1;
				else if (FlxG.keys.justPressed.D)
					video.bitmap.rate += 0.1;
			}
		}

		super.update(elapsed);
	}
}
