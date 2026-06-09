package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.system.FlxAssets;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

import hxvlc.flixel.FlxVideoSprite;
import hxvlc.impl.Instance;

import sys.FileSystem;

@:nullSafety
class VideoState extends FlxState
{
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
					video.bitmap.rate -= 0.01;
				else if (FlxG.keys.justPressed.D)
					video.bitmap.rate += 0.01;
			}
		}

		super.update(elapsed);
	}

	private function setupUI():Void
	{
		final versionInfoArray:Array<String> = [];

		versionInfoArray.push('Version: ${Instance.version}');
		versionInfoArray.push('Compiler: ${Instance.compiler}');
		versionInfoArray.push('Changeset: ${Instance.changeset}');

		versionInfo = new FlxText(10, FlxG.height - 10, 0, versionInfoArray.join('\n'), 17);
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

		video.load('assets/video.mp4');

		if (versionInfo != null)
			insert(members.indexOf(versionInfo), video);

		FlxTimer.wait(0.001, function():Void
		{
			video.play();
		});
	}
}
