package hxvlc.flixel;

#if flixel
import flixel.graphics.FlxGraphic;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;
import haxe.io.Bytes;
import hxvlc.externs.Types;
import hxvlc.util.macros.Define;
import hxvlc.util.Location;
import hxvlc.openfl.Video;
import sys.FileSystem;

using StringTools;

/**
 * This class is used for displaying video files in HaxeFlixel as sprites.
 */
class FlxVideoSprite extends FlxSprite implements IFlxVideoSprite
{
	/**
	 * Whether the video should automatically pause when focus is lost.
	 *
	 * WARNING: Must be set before loading a video.
	 */
	public var autoPause:Bool = FlxG.autoPause;

	#if FLX_SOUND_SYSTEM
	/**
	 * Whether Flixel should automatically adjust the volume according to the Flixel sound system's current volume.
	 */
	public var autoVolumeHandle:Bool = true;
	#end

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
		bitmap.onOpening.add(function():Void
		{
			bitmap.role = LibVLC_Role_Game;

			#if FLX_SOUND_SYSTEM
			if (bitmap != null && autoVolumeHandle)
				bitmap.volume = Math.floor((FlxG.sound.muted ? 0 : 1) * FlxG.sound.volume * Define.getFloat('HXVLC_FLIXEL_VOLUME_MULTIPLIER', 100));
			#end
		});
		bitmap.onFormatSetup.add(function():Void
		{
			if (bitmap != null && bitmap.bitmapData != null)
				loadGraphic(FlxGraphic.fromBitmapData(bitmap.bitmapData, false, null, false));
		});
		bitmap.alpha = 0;
		FlxG.game.addChild(bitmap);
	}

	/**
	 * Loads a video.
	 *
	 * @param location The local filesystem path, the media location URL, the ID of an open file descriptor, or the bitstream input.
	 * @param options Additional options to add to the LibVLC Media.
	 *
	 * @return `true` if the video loaded successfully, `false` otherwise.
	 */
	public function load(location:Location, ?options:Array<String>):Bool
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
	 * Parses the current media item with the specified options.
	 *
	 * @param parse_flag The parsing option.
	 * @param timeout The timeout duration in milliseconds.
	 * @return `true` if parsing succeeds, `false` otherwise.
	 */
	public function parseWithOptions(parse_flag:Int, timeout:Int):Bool
	{
		return bitmap == null ? false : bitmap.parseWithOptions(parse_flag, timeout);
	}

	/**
	 * Stops the parsing of the current media item.
	 */
	public function parseStop():Void
	{
		if (bitmap != null)
			bitmap.parseStop();
	}

	/**
	 * Plays the video.
	 *
	 * @return `true` if the video started playing, `false` otherwise.
	 */
	public function play():Bool
	{
		return bitmap == null ? false : bitmap.play();
	}

	/**
	 * Stops the video.
	 */
	public function stop():Void
	{
		if (bitmap != null)
			bitmap.stop();
	}

	/**
	 * Pauses the video.
	 */
	public function pause():Void
	{
		if (bitmap != null)
			bitmap.pause();
	}

	/**
	 * Resumes the video.
	 */
	public function resume():Void
	{
		if (bitmap != null)
			bitmap.resume();
	}

	/**
	 * Toggles the pause state of the video.
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

			FlxG.removeChild(bitmap);

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
		if (bitmap != null && autoVolumeHandle)
			bitmap.volume = Math.floor((FlxG.sound.muted ? 0 : 1) * FlxG.sound.volume * Define.getFloat('HXVLC_FLIXEL_VOLUME_MULTIPLIER', 100));
		#end

		super.update(elapsed);
	}

	@:noCompletion
	private override function set_antialiasing(value:Bool):Bool
	{
		return antialiasing = (bitmap == null ? value : (bitmap.smoothing = value));
	}
}
#end
