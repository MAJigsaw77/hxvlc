package hxvlc.util.igenerals;

import lime.app.Event;
import hxvlc.openfl.Stats;
import hxvlc.util.Location;
import haxe.Int64;
import cpp.UInt32;

// IMPORTANT NOTE: This Interface for now it's just used for the openfl video class (and extended by the flixel video interface) but I specifically made this just in case in the future hxvlc will work for more libs!  - Nex

/**
 * `IVideo` is an interface used for certain kind of Video objects.
 */
interface IVideo
{
	/**
	 * The format width, in pixels.
	 */
	public var formatWidth(get, null):UInt32;

	/**
	 * The format height, in pixels.
	 */
	public var formatHeight(get, null):UInt32;

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
	public var onOpening(get, null):Event<Void->Void>;

	/**
	 * An event that is dispatched when the media player is playing.
	 */
	public var onPlaying(get, null):Event<Void->Void>;

	/**
	 * An event that is dispatched when the media player stops.
	 */
	public var onStopped(get, null):Event<Void->Void>;

	/**
	 * An event that is dispatched when the media player is paused.
	 */
	public var onPaused(get, null):Event<Void->Void>;

	/**
	 * An event that is dispatched when the media player reaches the end.
	 */
	public var onEndReached(get, null):Event<Void->Void>;

	/**
	 * An event that is dispatched when the media player encounters an error.
	 */
	public var onEncounteredError(get, null):Event<String->Void>;

	/**
	 * An event that is dispatched when the media changes.
	 */
	public var onMediaChanged(get, null):Event<Void->Void>;

	/**
	 * An event that is dispatched when the media player is corked.
	 */
	public var onCorked(get, null):Event<Void->Void>;

	/**
	 * An event that is dispatched when the media player is uncorked.
	 */
	public var onUncorked(get, null):Event<Void->Void>;

	/**
	 * An event that is dispatched when the media player changes time.
	 */
	public var onTimeChanged(get, null):Event<Int64->Void>;

	/**
	 * An event that is dispatched when the media player changes position.
	 */
	public var onPositionChanged(get, null):Event<Single->Void>;

	/**
	 * An event that is dispatched when the media player changes the length.
	 */
	public var onLengthChanged(get, null):Event<Int64->Void>;

	/**
	 * An event that is dispatched when the media player changes the chapter.
	 */
	public var onChapterChanged(get, null):Event<Int->Void>;
	/**
	 * An event that is dispatched when the format is being initialized.
	 */
	public var onFormatSetup(get, null):Event<Void->Void>;

    /**
	 * Loads a video.
	 *
	 * @param location The local filesystem path, the media location URL, the ID of an open file descriptor, or the bitstream input.
	 * @param options Additional options to add to the LibVLC Media.
	 *
	 * @return `true` if the video loaded successfully, `false` otherwise.
	 */
    public function load(location:Location, ?options:Array<String>):Bool;

    /**
	 * Plays the video.
	 *
	 * @return `true` if the video started playing, `false` otherwise.
	 */
	public function play():Bool;

    /**
	 * Stops the video.
	 */
	public function stop():Void;

    /**
	 * Pauses the video.
	 */
	public function pause():Void;

	/**
	 * Toggles the pause state of the video.
	 */
	public function togglePaused():Void;

    /**
	 * Resumes the video.
	 */
	public function resume():Void;
}