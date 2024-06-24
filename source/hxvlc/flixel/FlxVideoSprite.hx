package hxvlc.flixel;

#if flixel
import flixel.graphics.FlxGraphic;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;
import haxe.io.Bytes;
import haxe.Int64;
import hxvlc.externs.Types;
import hxvlc.util.macros.Define;
import hxvlc.util.Location;
import hxvlc.openfl.Stats;
import hxvlc.openfl.Video;
import lime.app.Event;
import sys.FileSystem;

using StringTools;

/**
 * `FlxVideoSprite` is used for displaying video files in HaxeFlixel as sprites.
 */
class FlxVideoSprite extends FlxSprite implements IFlxVideo
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
	 * The format width, in pixels.
	 */
	public var formatWidth(get, null):cpp.UInt32;

	/**
	 * The format height, in pixels.
	 */
	public var formatHeight(get, null):cpp.UInt32;

	/**
	 * Statistics related to the media resource.
	 */
	public var stats(get, never):Null<Stats>;

	/**
	 * The media resource locator.
	 */
	public var mrl(get, never):String;

	/**
	 * The media's duration.
	 */
	public var duration(get, never):Int64;

	/**
	 * Whether the media player is playing or not.
	 */
	public var isPlaying(get, never):Bool;

	/**
	 * The media player's length in milliseconds.
	 */
	public var length(get, never):Int64;

	/**
	 * The media player's time in milliseconds.
	 */
	public var time(get, set):Int64;

	/**
	 * The media player's position as percentage between `0.0` and `1.0`.
	 */
	public var position(get, set):Single;

	/**
	 * The media player's chapter.
	 */
	public var chapter(get, set):Int;

	/**
	 * The media player's chapter count.
	 */
	public var chapterCount(get, never):Int;

	/**
	 * Whether the media player is able to play.
	 */
	public var willPlay(get, never):Bool;

	/**
	 * The media player's play rate.
	 *
	 * WARNING: Depending on the underlying media, the requested rate may be different from the real playback rate.
	 */
	public var rate(get, set):Single;

	/**
	 * Whether the media player is seekable or not.
	 */
	public var isSeekable(get, never):Bool;

	/**
	 * Whether the media player can be paused or not.
	 */
	public var canPause(get, never):Bool;

	/**
	 * Gets the list of available audio output modules.
	 */
	public var outputModules(get, never):Array<{name:String, description:String}>;

	/**
	 * Selects an audio output module.
	 *
	 * Note: Any change will take effect only after playback is stopped and restarted.
	 *
	 * Audio output cannot be changed while playing.
	 */
	public var output(never, set):String;

	/**
	 * The audio's mute status.
	 *
	 * WARNING: This does not always work.
	 * If there is no active audio playback stream, the mute status might not be available.
	 * If digital pass-through (S/PDIF, HDMI...) is in use, muting may be inapplicable.
	 * Also some audio output plugins do not support muting at all.
	 *
	 * Note: To force silent playback, disable all audio tracks. This is more efficient and reliable than mute.
	 */
	public var mute(get, set):Bool;

	/**
	 * The audio volume in percents (0 = mute, 100 = nominal / 0dB).
	 */
	public var volume(get, set):Int;

	/**
	 * Get the number of available audio tracks.
	 */
	public var trackCount(get, never):Int;

	/**
	 * The media player's audio track.
	 */
	public var track(get, set):Int;

	/**
	 * The audio channel.
	 */
	public var channel(get, set):Int;

	/**
	 * The audio delay in microseconds.
	 */
	public var delay(get, set):Int64;

	/**
	 * The media player's role.
	 */
	public var role(get, set):UInt;

	/**
	 * An event that is dispatched when the media player is opening.
	 */
	public var onOpening(get, null):Event<Void->Void> = new Event<Void->Void>();

	/**
	 * An event that is dispatched when the media player is playing.
	 */
	public var onPlaying(get, null):Event<Void->Void> = new Event<Void->Void>();

	/**
	 * An event that is dispatched when the media player stops.
	 */
	public var onStopped(get, null):Event<Void->Void> = new Event<Void->Void>();

	/**
	 * An event that is dispatched when the media player is paused.
	 */
	public var onPaused(get, null):Event<Void->Void> = new Event<Void->Void>();

	/**
	 * An event that is dispatched when the media player reaches the end.
	 */
	public var onEndReached(get, null):Event<Void->Void> = new Event<Void->Void>();

	/**
	 * An event that is dispatched when the media player encounters an error.
	 */
	public var onEncounteredError(get, null):Event<String->Void> = new Event<String->Void>();

	/**
	 * An event that is dispatched when the media changes.
	 */
	public var onMediaChanged(get, null):Event<Void->Void> = new Event<Void->Void>();

	/**
	 * An event that is dispatched when the media player is corked.
	 */
	public var onCorked(get, null):Event<Void->Void> = new Event<Void->Void>();

	/**
	 * An event that is dispatched when the media player is uncorked.
	 */
	public var onUncorked(get, null):Event<Void->Void> = new Event<Void->Void>();

	/**
	 * An event that is dispatched when the media player changes time.
	 */
	public var onTimeChanged(get, null):Event<Int64->Void> = new Event<Int64->Void>();

	/**
	 * An event that is dispatched when the media player changes position.
	 */
	public var onPositionChanged(get, null):Event<Single->Void> = new Event<Single->Void>();

	/**
	 * An event that is dispatched when the media player changes the length.
	 */
	public var onLengthChanged(get, null):Event<Int64->Void> = new Event<Int64->Void>();

	/**
	 * An event that is dispatched when the media player changes the chapter.
	 */
	public var onChapterChanged(get, null):Event<Int->Void> = new Event<Int->Void>();

	/**
	 * An event that is dispatched when the format is being initialized.
	 */
	public var onFormatSetup(get, null):Event<Void->Void> = new Event<Void->Void>();

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
		onOpening.add(function():Void
		{
			role = LibVLC_Role_Game;

			#if FLX_SOUND_SYSTEM
			if (autoVolumeHandle)
				volume = (FlxG.sound.muted ? 0 : 1) * FlxG.sound.volume;
			#end
		});
		onFormatSetup.add(function():Void
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
	 * Plays the video.
	 *
	 * @return `true` if the video started playing, `false` otherwise.
	 */
	public function play():Bool
	{
		if (bitmap == null)
			return false;

		return bitmap.play();
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
		if (autoVolumeHandle)
			volume = Math.floor((FlxG.sound.muted ? 0 : 1) * FlxG.sound.volume * Define.getFloat("HXVLC_VOLUME_MULTIPLIER", 100));
		#end

		super.update(elapsed);
	}

	@:noCompletion
	private override function set_antialiasing(value:Bool):Bool
	{
		return antialiasing = (bitmap == null ? value : (bitmap.smoothing = value));
	}

	@:noCompletion
	private function get_formatWidth():cpp.UInt32
	{
		return bitmap == null ? 0 : bitmap.formatWidth;
	}

	@:noCompletion
	private function get_formatHeight():cpp.UInt32
	{
		return bitmap == null ? 0 : bitmap.formatHeight;
	}

	@:noCompletion
	private function get_stats():Null<Stats>
	{
		return bitmap == null ? null : bitmap.stats;
	}

	@:noCompletion
	private function get_mrl():String
	{
		return bitmap == null ? null : bitmap.mrl;
	}

	@:noCompletion
	private function get_duration():Int64
	{
		return bitmap == null ? -1 : bitmap.duration;
	}

	@:noCompletion
	private function get_isPlaying():Bool
	{
		return bitmap != null && bitmap.isPlaying;
	}

	@:noCompletion
	private function get_length():Int64
	{
		return bitmap == null ? -1 : bitmap.length;
	}

	@:noCompletion
	private function get_time():Int64
	{
		return bitmap == null ? -1 : bitmap.time;
	}

	@:noCompletion
	private function set_time(value:Int64):Int64
	{
		// Returning the bitmap.time value instead of directly value just in case the setter edits the return (the same logic gets applided under)  - Nex
		return bitmap == null ? value : (bitmap.time = value);
	}

	@:noCompletion
	private function get_position():Single
	{
		return bitmap == null ? -1.0 : bitmap.position;
	}

	@:noCompletion
	private function set_position(value:Single):Single
	{
		return bitmap == null ? value : (bitmap.position = value);
	}

	@:noCompletion
	private function get_chapter():Int
	{
		return bitmap == null ? -1 : bitmap.chapter;
	}

	@:noCompletion
	private function set_chapter(value:Int):Int
	{
		return bitmap == null ? value : (bitmap.chapter = value);
	}

	@:noCompletion
	private function get_chapterCount():Int
	{
		return bitmap == null ? -1 : bitmap.chapterCount;
	}

	@:noCompletion
	private function get_willPlay():Bool
	{
		return bitmap != null && bitmap.willPlay;
	}

	@:noCompletion
	private function get_rate():Single
	{
		return bitmap == null ? 1 : bitmap.rate;
	}

	@:noCompletion
	private function set_rate(value:Single):Single
	{
		return bitmap == null ? value : (bitmap.rate = value);
	}

	@:noCompletion
	private function get_isSeekable():Bool
	{
		return bitmap != null && bitmap.isSeekable;
	}

	@:noCompletion
	private function get_canPause():Bool
	{
		return bitmap != null && bitmap.canPause;
	}

	@:noCompletion
	private function get_outputModules():Array<{name:String, description:String}>
	{
		return bitmap == null ? null : bitmap.outputModules;
	}

	@:noCompletion
	private function set_output(value:String):String
	{
		return bitmap == null ? value : (bitmap.output = value);
	}

	@:noCompletion
	private function get_mute():Bool
	{
		return bitmap != null && bitmap.mute;
	}

	@:noCompletion
	private function set_mute(value:Bool):Bool
	{
		return bitmap == null ? value : (bitmap.mute = value);
	}

	@:noCompletion
	private function get_volume():Int
	{
		return bitmap == null ? -1 : bitmap.volume;
	}

	@:noCompletion
	private function set_volume(value:Float):Int
	{
		return bitmap == null ? Math.floor(value * Define.getFloat("HXVLC_VOLUME_MULTIPLIER", 100)) : (bitmap.volume = value);
	}

	@:noCompletion
	private function get_trackCount():Int
	{
		return bitmap == null ? -1 : bitmap.trackCount;
	}

	@:noCompletion
	private function get_track():Int
	{
		return bitmap == null ? -1 : bitmap.track;
	}

	@:noCompletion
	private function set_track(value:Int):Int
	{
		return bitmap == null ? value : (bitmap.track = value);
	}

	@:noCompletion
	private function get_channel():Int
	{
		return bitmap == null ? 0 : bitmap.channel;
	}

	@:noCompletion
	private function set_channel(value:Int):Int
	{
		return bitmap == null ? value : (bitmap.channel = value);
	}

	@:noCompletion
	private function get_delay():Int64
	{
		return bitmap == null ? 0 : bitmap.delay;
	}

	@:noCompletion
	private function set_delay(value:Int64):Int64
	{
		return bitmap == null ? value : (bitmap.delay = value);
	}

	@:noCompletion
	private function get_role():UInt
	{
		return bitmap == null ? 0 : bitmap.role;
	}

	@:noCompletion
	private function set_role(value:UInt):UInt
	{
		return bitmap == null ? value : (bitmap.role = value);
	}

	@:noCompletion
	private function get_onOpening():Event<Void->Void>
	{
		return bitmap == null ? null : bitmap.onOpening;
	}

	@:noCompletion
	private function get_onPlaying():Event<Void->Void>
	{
		return bitmap == null ? null : bitmap.onPlaying;
	}

	@:noCompletion
	private function get_onStopped():Event<Void->Void>
	{
		return bitmap == null ? null : bitmap.onStopped;
	}

	@:noCompletion
	private function get_onPaused():Event<Void->Void>
	{
		return bitmap == null ? null : bitmap.onPaused;
	}

	@:noCompletion
	private function get_onEndReached():Event<Void->Void>
	{
		return bitmap == null ? null : bitmap.onEndReached;
	}

	@:noCompletion
	private function get_onEncounteredError():Event<String->Void>
	{
		return bitmap == null ? null : bitmap.onEncounteredError;
	}

	@:noCompletion
	private function get_onMediaChanged():Event<Void->Void>
	{
		return bitmap == null ? null : bitmap.onMediaChanged;
	}

	@:noCompletion
	private function get_onCorked():Event<Void->Void>
	{
		return bitmap == null ? null : bitmap.onCorked;
	}

	@:noCompletion
	private function get_onUncorked():Event<Void->Void>
	{
		return bitmap == null ? null : bitmap.onUncorked;
	}

	@:noCompletion
	private function get_onTimeChanged():Event<Int64->Void>
	{
		return bitmap == null ? null : bitmap.onTimeChanged;
	}

	@:noCompletion
	private function get_onPositionChanged():Event<Single->Void>
	{
		return bitmap == null ? null : bitmap.onPositionChanged;
	}

	@:noCompletion
	private function get_onLengthChanged():Event<Int64->Void>
	{
		return bitmap == null ? null : bitmap.onLengthChanged;
	}

	@:noCompletion
	private function get_onChapterChanged():Event<Int->Void>
	{
		return bitmap == null ? null : bitmap.onChapterChanged;
	}

	@:noCompletion
	private function get_onFormatSetup():Event<Void->Void>
	{
		return bitmap == null ? null : bitmap.onFormatSetup;
	}
}
#end
