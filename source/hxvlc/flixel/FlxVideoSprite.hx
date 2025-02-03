package hxvlc.flixel;

#if flixel
import flixel.graphics.FlxGraphic;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;
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
 * This class extends FlxSprite to display video files in HaxeFlixel.
 *
 * ```haxe
 * final video:FlxVideoSprite = new FlxVideoSprite(0, 0);
 * video.antialiasing = true;
 * video.bitmap.onFormatSetup.add(function():Void
 * {
 * 	if (video.bitmap != null && video.bitmap.bitmapData != null)
 * 	{
 * 		final scale:Float = Math.min(FlxG.width / video.bitmap.bitmapData.width, FlxG.height / video.bitmap.bitmapData.height);
 *
 * 		video.setGraphicSize(video.bitmap.bitmapData.width * scale, video.bitmap.bitmapData.height * scale);
 * 		video.updateHitbox();
 * 		video.screenCenter();
 * 	}
 * });
 * video.bitmap.onEndReached.add(video.destroy);
 * add(video);
 *
 * if (video.load('assets/videos/video.mp4'))
 * 	FlxTimer.wait(0.001, () -> video.play());
 * ```
 */
@:nullSafety
class FlxVideoSprite extends FlxSprite
{
	/**
	 * The volume adjustment.
	 */
	public var volumeAdjust(default, set):Float = 1.0;

	/**
	 * The video bitmap object.
	 */
	public final bitmap:Video;

	/**
	 * Internal tracker for whether the video is paused or not.
	 */
	@:noCompletion
	private var resumeOnFocus:Bool = false;

	/**
	 * Creates a `FlxVideoSprite` at a specified position.
	 *
	 * @param x The initial X position of the sprite.
	 * @param y The initial Y position of the sprite.
	 */
	public function new(?x:Float = 0, ?y:Float = 0):Void
	{
		super(x, y);

		bitmap = new Video(antialiasing);
		bitmap.forceRendering = true;
		bitmap.onOpening.add(function():Void
		{
			bitmap.role = LibVLC_Role_Game;

			#if (FLX_SOUND_SYSTEM && flixel >= version("5.9.0"))
			if (!FlxG.sound.onVolumeChange.has(onVolumeChange))
				FlxG.sound.onVolumeChange.add(onVolumeChange);
			#elseif (FLX_SOUND_SYSTEM && flixel < version("5.9.0"))
			if (!FlxG.signals.postUpdate.has(onVolumeUpdate))
				FlxG.signals.postUpdate.add(onVolumeUpdate);
			#end

			#if FLX_SOUND_SYSTEM
			onVolumeChange((FlxG.sound.muted ? 0 : 1) * FlxG.sound.volume);
			#else
			onVolumeChange(1);
			#end
		});
		bitmap.onFormatSetup.add(function():Void
		{
			if (bitmap.bitmapData != null)
				loadGraphic(FlxGraphic.fromBitmapData(bitmap.bitmapData, false, null, false));
		});
		bitmap.visible = false;
		FlxG.game.addChild(bitmap);

		makeGraphic(1, 1, FlxColor.TRANSPARENT);
	}

	/**
	 * Loads a video from the specified location.
	 *
	 * @param location The location of the media file or stream.
	 * @param options Additional options to configure the media.
	 * @return `true` if the media was loaded successfully, `false` otherwise.
	 */
	public function load(location:Location, ?options:Array<String>):Bool
	{
		if (!FlxG.signals.focusGained.has(onFocusGained))
			FlxG.signals.focusGained.add(onFocusGained);

		if (!FlxG.signals.focusLost.has(onFocusLost))
			FlxG.signals.focusLost.add(onFocusLost);

		if (location != null && !(location is Int) && !(location is Bytes) && (location is String))
		{
			final location:String = cast(location, String);

			if (!location.contains('://'))
			{
				final absolutePath:String = FileSystem.absolutePath(location);

				if (FileSystem.exists(absolutePath))
					return bitmap.load(absolutePath, options);
				else if (Assets.exists(location))
				{
					final assetPath:String = Assets.getPath(location);

					if (assetPath != null)
					{
						if (FileSystem.exists(assetPath) && Path.isAbsolute(assetPath))
							return bitmap.load(assetPath, options);
						else if (!Path.isAbsolute(assetPath))
						{
							try
							{
								final assetBytes:Bytes = Assets.getBytes(location);

								if (assetBytes != null)
									return bitmap.load(assetBytes, options);
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

		return bitmap.load(location, options);
	}

	/**
	 * Loads a media subitem from the current media's subitems list at the specified index.
	 *
	 * @param index The index of the subitem to load.
	 * @param options Additional options to configure the loaded subitem.
	 * @return `true` if the subitem was loaded successfully, `false` otherwise.
	 */
	public inline function loadFromSubItem(index:Int, ?options:Array<String>):Bool
	{
		return bitmap.loadFromSubItem(index, options);
	}

	/**
	 * Parses the current media item with the specified options.
	 *
	 * @param parse_flag The parsing option.
	 * @param timeout The timeout in milliseconds.
	 * @return `true` if parsing succeeded, `false` otherwise.
	 */
	public inline function parseWithOptions(parse_flag:Int, timeout:Int):Bool
	{
		return bitmap.parseWithOptions(parse_flag, timeout);
	}

	/**
	 * Stops parsing the current media item.
	 */
	public inline function parseStop():Void
	{
		bitmap.parseStop();
	}

	/**
	 * Starts video playback.
	 *
	 * @return `true` if playback started successfully, `false` otherwise.
	 */
	public inline function play():Bool
	{
		return bitmap.play();
	}

	/**
	 * Stops video playback.
	 */
	public inline function stop():Void
	{
		bitmap.stop();
	}

	/**
	 * Pauses video playback.
	 */
	public inline function pause():Void
	{
		bitmap.pause();
	}

	/**
	 * Resumes playback of a paused video.
	 */
	public inline function resume():Void
	{
		bitmap.resume();
	}

	/**
	 * Toggles between play and pause states of the video.
	 */
	public inline function togglePaused():Void
	{
		bitmap.togglePaused();
	}

	public override function destroy():Void
	{
		#if (FLX_SOUND_SYSTEM && flixel >= version("5.9.0"))
		if (FlxG.sound.onVolumeChange.has(onVolumeChange))
			FlxG.sound.onVolumeChange.remove(onVolumeChange);
		#elseif (FLX_SOUND_SYSTEM && flixel < version("5.9.0"))
		if (FlxG.signals.postUpdate.has(onVolumeUpdate))
			FlxG.signals.postUpdate.remove(onVolumeUpdate);
		#end

		super.destroy();

		FlxG.removeChild(bitmap);

		bitmap.dispose();
	}

	public override function kill():Void
	{
		bitmap.pause();

		super.kill();
	}

	public override function revive():Void
	{
		super.revive();

		bitmap.resume();
	}

	@:noCompletion
	private function onFocusGained():Void
	{
		#if !mobile
		if (!FlxG.autoPause)
			return;
		#end

		if (resumeOnFocus)
		{
			resumeOnFocus = false;

			resume();
		}
	}

	@:noCompletion
	private function onFocusLost():Void
	{
		#if !mobile
		if (!FlxG.autoPause)
			return;
		#end

		resumeOnFocus = bitmap.isPlaying;

		pause();
	}

	#if (FLX_SOUND_SYSTEM && flixel < version("5.9.0"))
	@:noCompletion
	private function onVolumeUpdate():Void
	{
		onVolumeChange((FlxG.sound.muted ? 0 : 1) * FlxG.sound.volume);
	}
	#end

	@:noCompletion
	private function onVolumeChange(vol:Float):Void
	{
		final currentVolume:Int = Math.floor((vol * Define.getFloat('HXVLC_FLIXEL_VOLUME_MULTIPLIER', 125)) * volumeAdjust);

		if (bitmap.volume != currentVolume)
			bitmap.volume = currentVolume;
	}

	@:noCompletion
	private override function set_antialiasing(value:Bool):Bool
	{
		return antialiasing = (bitmap == null ? value : (bitmap.smoothing = value));
	}

	@:noCompletion
	private function set_volumeAdjust(value:Float):Float
	{
		#if FLX_SOUND_SYSTEM
		onVolumeChange((FlxG.sound.muted ? 0 : 1) * FlxG.sound.volume);
		#else
		onVolumeChange(1);
		#end

		return volumeAdjust = value;
	}
}
#end
