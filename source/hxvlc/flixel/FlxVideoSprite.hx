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
 * var video:FlxVideoSprite = new FlxVideoSprite(0, 0);
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
class FlxVideoSprite extends FlxSprite
{
	/**
	 * Indicates whether the video should automatically pause when focus is lost.
	 *
	 * Must be set before loading a video.
	 */
	public var autoPause:Bool = FlxG.autoPause;

	#if FLX_SOUND_SYSTEM
	/**
	 * Determines if Flixel automatically adjusts the volume based on the Flixel sound system's current volume.
	 */
	public var autoVolumeHandle:Bool = true;
	#end

	/**
	 * The video bitmap object.
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
		bitmap.forceRendering = true;
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
		bitmap.visible = false;
		FlxG.game.addChild(bitmap);
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
	public function loadFromSubItem(index:Int, ?options:Array<String>):Bool
	{
		return bitmap == null ? false : bitmap.loadFromSubItem(index, options);
	}

	/**
	 * Parses the current media item with the specified options.
	 *
	 * @param parse_flag The parsing option.
	 * @param timeout The timeout in milliseconds.
	 * @return `true` if parsing succeeded, `false` otherwise.
	 */
	public function parseWithOptions(parse_flag:Int, timeout:Int):Bool
	{
		return bitmap == null ? false : bitmap.parseWithOptions(parse_flag, timeout);
	}

	/**
	 * Stops parsing the current media item.
	 */
	public function parseStop():Void
	{
		if (bitmap != null)
			bitmap.parseStop();
	}

	/**
	 * Starts video playback.
	 *
	 * @return `true` if playback started successfully, `false` otherwise.
	 */
	public function play():Bool
	{
		return bitmap == null ? false : bitmap.play();
	}

	/**
	 * Stops video playback.
	 */
	public function stop():Void
	{
		if (bitmap != null)
			bitmap.stop();
	}

	/**
	 * Pauses video playback.
	 */
	public function pause():Void
	{
		if (bitmap != null)
			bitmap.pause();
	}

	/**
	 * Resumes playback of a paused video.
	 */
	public function resume():Void
	{
		if (bitmap != null)
			bitmap.resume();
	}

	/**
	 * Toggles between play and pause states of the video.
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
