package hxvlc.flixel;

#if flixel
import flixel.math.FlxMath;
import flixel.util.FlxAxes;
import flixel.FlxG;
import haxe.io.Bytes;
import haxe.io.Path;
import hxvlc.externs.Types;
import hxvlc.util.macros.Define;
import hxvlc.util.Location;
import hxvlc.openfl.Video;
import openfl.utils.Assets;
import sys.FileSystem;

using StringTools;

/**
 * This class extends Video to display video files in HaxeFlixel.
 *
 * ```haxe
 * var video:FlxVideo = new FlxVideo();
 * video.onEndReached.add(function():Void
 * {
 * 	video.dispose();
 *
 * 	FlxG.removeChild(video);
 * });
 * FlxG.addChildBelowMouse(video);
 *
 * if (video.load('assets/videos/video.mp4'))
 * 	FlxTimer.wait(0.001, () -> video.play());
 * ```
 */
class FlxVideo extends Video
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
	 * WARNING: Must be set before loading a video.
	 */
	public var autoResizeMode:FlxAxes = FlxAxes.XY;

	#if FLX_SOUND_SYSTEM
	/**
	 * Whether Flixel should automatically adjust the volume according to the Flixel sound system's current volume.
	 */
	public var autoVolumeHandle:Bool = true;
	#end

	/**
	 * Internal tracker for whether the video is paused or not.
	 */
	@:noCompletion
	private var resumeOnFocus:Bool = false;

	/**
	 * Internal tracker for the resize mode so it doesn't get changed while the video is running.
	 */
	@:noCompletion
	private var currentResizeMode:Null<FlxAxes>;

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

			#if (FLX_SOUND_SYSTEM && flixel >= "5.9.0")
			if (!FlxG.sound.onVolumeChange.has(onVolumeChange))
				FlxG.sound.onVolumeChange.add(onVolumeChange);
			#elseif (FLX_SOUND_SYSTEM && flixel < "5.9.0")
			if (!FlxG.signals.postUpdate.has(onVolumeUpdate))
				FlxG.signals.postUpdate.add(onVolumeUpdate);
			#end

			onVolumeChange((FlxG.sound.muted ? 0 : 1) * FlxG.sound.volume);
		});
		onFormatSetup.add(function():Void
		{
			if (!FlxG.signals.gameResized.has(onGameResized))
				FlxG.signals.gameResized.add(onGameResized);

			onGameResized(0, 0);
		});
	}

	/**
	 * Loads a video.
	 *
	 * @param location The local filesystem path, the media location URL, the ID of an open file descriptor, or the bitstream input.
	 * @param options Additional options to add to the LibVLC Media.
	 * @return `true` if the video loaded successfully, `false` otherwise.
	 */
	public override function load(location:Location, ?options:Array<String>):Bool
	{
		if (autoPause)
		{
			if (!FlxG.signals.focusGained.has(onFocusGained))
				FlxG.signals.focusGained.add(onFocusGained);

			if (!FlxG.signals.focusLost.has(onFocusLost))
				FlxG.signals.focusLost.add(onFocusLost);
		}

		currentResizeMode = autoResizeMode;

		if (location != null && !(location is Int) && !(location is Bytes) && (location is String))
		{
			final location:String = cast(location, String);

			if (!location.contains('://'))
			{
				final absolutePath:String = FileSystem.absolutePath(location);

				if (FileSystem.exists(absolutePath))
					return super.load(absolutePath, options);
				else if (Assets.exists(location))
				{
					final assetPath:String = Assets.getPath(location);

					if (assetPath != null)
					{
						if (FileSystem.exists(assetPath) && Path.isAbsolute(assetPath))
							return super.load(assetPath, options);
						else if (!Path.isAbsolute(assetPath))
						{
							try
							{
								final assetBytes:Bytes = Assets.getBytes(location);

								if (assetBytes != null)
									return super.load(assetBytes, options);
							}
							catch (e:Dynamic)
							{
								FlxG.log.error('Error loading asset bytes from location "$location": $e');

								return false;
							}
						}
					}

					return false;
				}
				else
				{
					FlxG.log.warn('Unable to find the video file at location "$location".');

					return false;
				}
			}
		}

		return super.load(location, options);
	}

	public override function dispose():Void
	{
		if (FlxG.signals.focusGained.has(onFocusGained))
			FlxG.signals.focusGained.remove(onFocusGained);

		if (FlxG.signals.focusLost.has(onFocusLost))
			FlxG.signals.focusLost.remove(onFocusLost);

		if (FlxG.signals.gameResized.has(onGameResized))
			FlxG.signals.gameResized.remove(onGameResized);

		#if (FLX_SOUND_SYSTEM && flixel >= "5.9.0")
		if (FlxG.sound.onVolumeChange.has(onVolumeChange))
			FlxG.sound.onVolumeChange.remove(onVolumeChange);
		#elseif (FLX_SOUND_SYSTEM && flixel < "5.9.0")
		if (FlxG.signals.postUpdate.has(onVolumeUpdate))
			FlxG.signals.postUpdate.remove(onVolumeUpdate);
		#end

		super.dispose();
	}

	@:noCompletion
	private function onGameResized(width:Int, height:Int):Void
	{
		if (currentResizeMode != null)
		{
			if ((currentResizeMode.x || currentResizeMode.y) && bitmapData != null)
			{
				this.width = currentResizeMode.x ? FlxG.scaleMode.gameSize.x : bitmapData.width;
				this.height = currentResizeMode.y ? FlxG.scaleMode.gameSize.y : bitmapData.height;
			}
		}
	}

	@:noCompletion
	private function onFocusGained():Void
	{
		if (resumeOnFocus)
		{
			resumeOnFocus = false;

			resume();
		}
	}

	@:noCompletion
	private function onFocusLost():Void
	{
		resumeOnFocus = isPlaying;

		pause();
	}

	#if FLX_SOUND_SYSTEM
	@:noCompletion
	private function onVolumeUpdate():Void
	{
		onVolumeChange((FlxG.sound.muted ? 0 : 1) * FlxG.sound.volume);
	}

	@:noCompletion
	private function onVolumeChange(vol:Float):Void
	{
		if (autoVolumeHandle)
			volume = Math.floor(vol * Define.getFloat('HXVLC_FLIXEL_VOLUME_MULTIPLIER', 100));
	}
	#end
}
#end
