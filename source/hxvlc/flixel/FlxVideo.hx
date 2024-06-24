package hxvlc.flixel;

#if flixel
import flixel.util.FlxAxes;
import flixel.FlxG;
import haxe.io.Bytes;
import hxvlc.externs.Types;
import hxvlc.util.Location;
import hxvlc.openfl.Video;
import sys.FileSystem;

using StringTools;

class FlxVideo extends Video implements IFlxVideo
{
	/**
	 * Whether the video should automatically pause when focus is lost.
	 *
	 * WARNING: Must be set before loading a video.
	 */
	public var autoPause:Bool = FlxG.autoPause;

	/**
	 * Determines the automatic resizing behavior for the video.
	 *
	 * WARNING: Must be set before loading a video if you want to set it to `NONE`.
	 */
	public var autoResizeMode:FlxAxes = FlxAxes.XY;

	/**
	 * The video's volume multiplier.
	 */
    public var volumeMultiplier:Float = 100;

	#if FLX_SOUND_SYSTEM
	/**
	 * Whether Flixel should automatically adjust the volume according to the Flixel sound system's current volume.
	 */
	public var autoVolumeHandle:Bool = true;
	#end

	/**
	 * Initializes a FlxVideo object.
	 *
	 * @param smoothing Whether or not the video is smoothed when scaled.
	 */
	public function new(smoothing:Bool = true):Void
	{
		super(smoothing);

		onOpening.add(function():Void
		{
			role = LibVLC_Role_Game;

			if (!FlxG.signals.postUpdate.has(postUpdate))
				FlxG.signals.postUpdate.add(postUpdate);
		});

		FlxG.addChildBelowMouse(this);
	}

	/**
	 * Loads a video.
	 *
	 * @param location The local filesystem path, the media location URL, the ID of an open file descriptor, or the bitstream input.
	 * @param options Additional options to add to the LibVLC Media.
	 *
	 * @return `true` if the video loaded successfully, `false` otherwise.
	 */
	public override function load(location:Location, ?options:Array<String>):Bool
	{
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
					return super.load(absolutePath, options);
				else
				{
					FlxG.log.warn('Unable to find the video file at location "$absolutePath".');

					return false;
				}
			}
		}

		return super.load(location, options);
	}

	public override function dispose():Void
	{
		if (FlxG.signals.focusGained.has(resume))
			FlxG.signals.focusGained.remove(resume);

		if (FlxG.signals.focusLost.has(pause))
			FlxG.signals.focusLost.remove(pause);

		if (FlxG.signals.postUpdate.has(postUpdate))
			FlxG.signals.postUpdate.remove(postUpdate);

		super.dispose();

		FlxG.removeChild(this);
	}

	@:noCompletion
	private function postUpdate():Void
	{
		if (autoResizeMode.x || autoResizeMode.y)
		{
			width = autoResizeMode.x ? FlxG.scaleMode.gameSize.x : formatWidth;
			height = autoResizeMode.y ? FlxG.scaleMode.gameSize.y : formatHeight;
		}

		#if FLX_SOUND_SYSTEM
		if (autoVolumeHandle)
			volume = (FlxG.sound.muted ? 0 : 1) * FlxG.sound.volume;
		#end
	}

	@:noCompletion
	override private function set_volume(value:Float):Int
	{
		final finalVolume:Int = Math.floor(value * volumeMultiplier);
		return finalVolume != volume ? finalVolume : super.set_volume(finalVolume);
	}
}
#end
