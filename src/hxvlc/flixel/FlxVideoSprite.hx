package hxvlc.flixel;

import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;
import hxvlc.openfl.Video;
import sys.FileSystem;

/**
 * This class allows you to play videos using sprites (FlxSprite).
 */
class FlxVideoSprite extends FlxSprite
{
	public var bitmap(default, null):Video;

	public function new(x = 0, y = 0):Void
	{
		super(x, y);

		makeGraphic(1, 1, FlxColor.TRANSPARENT);

		bitmap = new Video();
		bitmap.alpha = 0;
		bitmap.onOpening.add(function()
		{
			#if FLX_SOUND_SYSTEM
			bitmap.volume = Math.floor((FlxG.sound.muted ? 0 : 1) * (FlxG.sound.volume * 100));
			#end
		});
		bitmap.onFormatSetup.add(() -> loadGraphic(bitmap.bitmapData));

		FlxG.game.addChild(bitmap);
	}

	public function play(location:String, shouldLoop:Bool = false):Bool
	{
		if (FlxG.autoPause)
		{
			if (!FlxG.signals.focusGained.has(resume))
				FlxG.signals.focusGained.add(resume);

			if (!FlxG.signals.focusLost.has(pause))
				FlxG.signals.focusLost.add(pause);
		}

		if (bitmap != null)
		{
			if (FileSystem.exists(Sys.getCwd() + location))
				return bitmap.play(Sys.getCwd() + location, shouldLoop);

			return bitmap.play(location, shouldLoop);
		}

		return false;
	}

	public function stop():Void
	{
		if (bitmap != null)
			bitmap.stop();
	}

	public function pause():Void
	{
		if (bitmap != null)
			bitmap.pause();
	}

	public function resume():Void
	{
		if (bitmap != null)
			bitmap.resume();
	}

	public function togglePaused():Void
	{
		if (bitmap != null)
			bitmap.togglePaused();
	}

	// Overrides
	public override function update(elapsed:Float):Void
	{
		#if FLX_SOUND_SYSTEM
		bitmap.volume = Math.floor((FlxG.sound.muted ? 0 : 1) * (FlxG.sound.volume * 100));
		#end

		super.update(elapsed);
	}

	public override function kill():Void
	{
		if (bitmap != null)
			bitmap.pause();

		super.kill();
	}

	public override function revive():Void
	{
		super.revive();

		if (bitmap != null)
			bitmap.resume();
	}

	public override function destroy():Void
	{
		if (FlxG.autoPause)
		{
			if (FlxG.signals.focusGained.has(resume))
				FlxG.signals.focusGained.remove(resume);

			if (FlxG.signals.focusLost.has(pause))
				FlxG.signals.focusLost.remove(pause);
		}

		super.destroy();

		if (bitmap != null)
		{
			bitmap.dispose();

			if (FlxG.game.contains(bitmap))
				FlxG.game.removeChild(bitmap);

			bitmap = null;
		}
	}
}
