package hxvlc.flixel;

#if flixel
import flixel.graphics.FlxGraphic;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;
import haxe.io.Bytes;
import hxvlc.externs.Types;
import hxvlc.openfl.Video;
import hxvlc.util.OneOfThree;
import sys.FileSystem;

using StringTools;

/**
 * `FlxVideoSprite` is made for displaying video files in HaxeFlixel as sprites.
 */
class FlxVideoSprite extends FlxSprite
{
	/**
	 * Whether the video should automatically be paused when focus is lost or not.
	 *
	 * @warning Must be set before loading a video.
	 */
	public var autoPause:Bool = FlxG.autoPause;

	/**
	 * Whether flixel should automatically change the volume according to the flixel sound system current volume.
	 */
	public var autoVolumeHandle:Bool = true;

	/**
	 * The video bitmap.
	 */
	public var bitmap(default, null):Video;

	/**
	 * Creates a `FlxVideoSprite` at a specified position.
	 *
	 * @param x The initial X position of the sprite.
	 * @param y The initial Y position of the sprite.
	 */
	public function new(?x:Float = 0, ?y:Float = 0):Void
	{
		super(x, y);

		makeGraphic(1, 1, FlxColor.TRANSPARENT);

		bitmap = new Video(antialiasing);
		bitmap.onOpening.add(() -> bitmap.role = LibVLC_Role_Game);
		bitmap.onFormatSetup.add(() -> loadGraphic(FlxGraphic.fromBitmapData(bitmap.bitmapData, false, null, false)));
		bitmap.alpha = 0;
		FlxG.game.addChild(bitmap);
	}

	/**
	 * Call this function to load a video.
	 *
	 * @param location The local filesystem path or the media location url or the id of a open file descriptor or the bitstream input.
	 * @param options The additional options you can add to the LibVLC Media.
	 *
	 * @return `true` if the video loaded successfully or `false` if there's an error.
	 */
	public function load(location:OneOfThree<String, Int, Bytes>, ?options:Array<String>):Bool
	{
		if (bitmap == null)
			return false;

		if (autoPause)
		{
			if (!FlxG.signals.focusGained.has(resume))
				FlxG.signals.focusGained.add(resume);

			if (!FlxG.signals.focusLost.has(pause))
				FlxG.signals.focusLost.add(pause);
		}

		if (location != null && !(location is Int) && !(location is Bytes) && (location is String))
		{
			final location:String = cast(location, String);

			if (!location.contains('://'))
			{
				final absolutePath:String = FileSystem.absolutePath(location);

				if (FileSystem.exists(absolutePath))
					return bitmap.load(absolutePath, options);
				else
				{
					FlxG.log.warn('Unable to find the video file at location "$absolutePath".');

					return false;
				}
			}
		}

		return bitmap.load(location, options);
	}

	/**
	 * Call this function to play a video.
	 *
	 * @return `true` if the video started playing or `false` if there's an error.
	 */
	public function play():Bool
	{
		if (bitmap == null)
			return false;

		return bitmap.play();
	}

	/**
	 * Call this function to stop the video.
	 */
	public function stop():Void
	{
		if (bitmap != null)
			bitmap.stop();
	}

	/**
	 * Call this function to pause the video.
	 */
	public function pause():Void
	{
		if (bitmap != null)
			bitmap.pause();
	}

	/**
	 * Call this function to resume the video.
	 */
	public function resume():Void
	{
		if (bitmap != null)
			bitmap.resume();
	}

	/**
	 * Call this function to toggle the pause of the video.
	 */
	public function togglePaused():Void
	{
		if (bitmap != null)
			bitmap.togglePaused();
	}

	public override function destroy():Void
	{
		if (FlxG.signals.focusGained.has(resume))
			FlxG.signals.focusGained.remove(resume);

		if (FlxG.signals.focusLost.has(pause))
			FlxG.signals.focusLost.remove(pause);

		super.destroy();

		if (bitmap != null)
		{
			bitmap.dispose();

			if (FlxG.game.contains(bitmap))
				FlxG.game.removeChild(bitmap);

			bitmap = null;
		}
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

	public override function update(elapsed:Float):Void
	{
		#if FLX_SOUND_SYSTEM
		if (autoVolumeHandle)
		{
			final curVolume:Int = Math.floor((FlxG.sound.muted ? 0 : 1) * FlxG.sound.volume * 100);

			if (bitmap.volume != curVolume)
				bitmap.volume = curVolume;
		}
		#end

		super.update(elapsed);
	}

	@:noCompletion
	private override function set_antialiasing(value:Bool):Bool
	{
		if (bitmap != null)
			bitmap.smoothing = value;

		return antialiasing = value;
	}
}
#end
