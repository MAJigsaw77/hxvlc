package;

import flixel.system.FlxAssets;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.FlxG;
import flixel.FlxState;
import hxvlc.flixel.FlxVideoSprite;
import hxvlc.util.Handle;
import openfl.display.FPS;
import sys.FileSystem;

@:nullSafety
class VideoState extends FlxState
{
	static final bigBuckBunny:String = 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4';

	var video:Null<FlxVideoSprite>;
	var versionInfo:Null<FlxText>;
	var fpsInfo:Null<FlxText>;
	var fps:Null<FPS>;

	override function create():Void
	{
		FlxG.autoPause = false;

		setupVideoAsync();

		setupUI();

		super.create();
	}

	override function update(elapsed:Float):Void
	{
		if (fps != null && fpsInfo != null)
		{
			#if HXVLC_ENABLE_STATS
			@:nullSafety(Off)
			if (video != null && video.bitmap != null && video.bitmap.stats != null)
				fpsInfo.text = 'FPS ${fps.currentFPS}\n${video.bitmap.stats.toString()}';
			else
				fpsInfo.text = 'FPS ${fps.currentFPS}';
			#else
			fpsInfo.text = 'FPS ${fps.currentFPS}';
			#end
		}

		if (video != null && video.bitmap != null)
		{
			if (FlxG.keys.justPressed.SPACE)
				video.bitmap.togglePaused();

			if (FlxG.keys.justPressed.LEFT)
				video.bitmap.position -= 0.1;
			else if (FlxG.keys.justPressed.RIGHT)
				video.bitmap.position += 0.1;

			if (FlxG.keys.justPressed.A)
				video.bitmap.rate -= 0.01;
			else if (FlxG.keys.justPressed.D)
				video.bitmap.rate += 0.01;
		}

		super.update(elapsed);
	}

	private function setupUI():Void
	{
		versionInfo = new FlxText(10, FlxG.height - 10, 0, 'LibVLC ${Handle.version}', 17);
		versionInfo.setBorderStyle(OUTLINE, FlxColor.BLACK, 2);
		versionInfo.font = FlxAssets.FONT_DEBUGGER;
		versionInfo.active = false;
		versionInfo.alignment = JUSTIFY;
		versionInfo.antialiasing = true;
		versionInfo.y -= versionInfo.height;
		add(versionInfo);

		fpsInfo = new FlxText(10, 10, 0, 'FPS 0', 17);
		fpsInfo.setBorderStyle(OUTLINE, FlxColor.BLACK, 2);
		fpsInfo.font = FlxAssets.FONT_DEBUGGER;
		fpsInfo.active = false;
		fpsInfo.alignment = JUSTIFY;
		fpsInfo.antialiasing = true;
		add(fpsInfo);

		fps = new FPS();
		fps.visible = false;
		FlxG.stage.addChild(fps);
	}

	private function setupVideoAsync():Void
	{
		Handle.initAsync(function(success:Bool):Void
		{
			if (!success)
				return;

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
				final file:String = haxe.io.Path.join(['videos', FileSystem.readDirectory('videos')[0]]);

				if (file != null && file.length > 0)
					video.load(file);
				else
					video.load(bigBuckBunny);
			}
			catch (e:Dynamic)
				video.load(bigBuckBunny);

			if (versionInfo != null)
				insert(members.indexOf(versionInfo), video);

			FlxTimer.wait(0.001, function():Void
			{
				video.play();
			});
		});
	}
}
