package hxvlc.openfl;

import haxe.Int64;
import hxvlc.openfl.Stats;
import hxvlc.util.Location;
import lime.app.Event;

/**
 * Interface representing a video object with playback and media management functionalities.
 */
interface IVideo
{
	/**
	 * The media resource locator (MRL).
	 */
	public var mrl(get, never):String;

	/**
	 * Statistics related to the media.
	 */
	public var stats(get, never):Null<Stats>;

	/**
	 * Duration of the media in microseconds.
	 */
	public var duration(get, never):Int64;

	/**
	 * Indicates whether the media is currently playing.
	 */
	public var isPlaying(get, never):Bool;

	/**
	 * Length of the media in microseconds.
	 */
	public var length(get, never):Int64;

	/**
	 * Current time position in the media in microseconds.
	 */
	public var time(get, set):Int64;

	/**
	 * Current playback position as a percentage (0.0 to 1.0).
	 */
	public var position(get, set):Single;

	/**
	 * Current chapter of the video.
	 */
	public var chapter(get, set):Int;

	/**
	 * Total number of chapters in the video.
	 */
	public var chapterCount(get, never):Int;

	/**
	 * Indicates whether playback will start automatically once loaded.
	 */
	public var willPlay(get, never):Bool;

	/**
	 * Playback rate of the video.
	 *
	 * Note: The actual rate may vary depending on the media.
	 */
	public var rate(get, set):Single;

	/**
	 * Indicates whether seeking is supported.
	 */
	public var isSeekable(get, never):Bool;

	/**
	 * Indicates whether pausing is supported.
	 */
	public var canPause(get, never):Bool;

	/**
	 * Available audio output modules.
	 */
	public var outputModules(get, never):Array<{name:String, description:String}>;

	/**
	 * Selected audio output module.
	 *
	 * Note: Changes take effect only after restarting playback.
	 */
	public var output(never, set):String;

	/**
	 * Mute status of the audio.
	 *
	 * Note: May not be supported under certain conditions (e.g., digital pass-through).
	 */
	public var mute(get, set):Bool;

	/**
	 * Volume level (0 to 100).
	 */
	public var volume(get, set):Int;

	/**
	 * Total number of available audio tracks.
	 */
	public var trackCount(get, never):Int;

	/**
	 * Selected audio track.
	 */
	public var track(get, set):Int;

	/**
	 * Selected audio channel.
	 */
	public var channel(get, set):Int;

	/**
	 * Audio delay in microseconds.
	 */
	public var delay(get, set):Int64;

	/**
	 * Role of the media.
	 */
	public var role(get, set):UInt;

	/**
	 * Event triggered when the media is opening.
	 */
	public var onOpening(get, null):Event<Void->Void>;

	/**
	 * Event triggered when playback starts.
	 */
	public var onPlaying(get, null):Event<Void->Void>;

	/**
	 * Event triggered when playback stops.
	 */
	public var onStopped(get, null):Event<Void->Void>;

	/**
	 * Event triggered when playback is paused.
	 */
	public var onPaused(get, null):Event<Void->Void>;

	/**
	 * Event triggered when the end of the media is reached.
	 */
	public var onEndReached(get, null):Event<Void->Void>;

	/**
	 * Event triggered when an error occurs.
	 */
	public var onEncounteredError(get, null):Event<String->Void>;

	/**
	 * Event triggered when the media changes.
	 */
	public var onMediaChanged(get, null):Event<Void->Void>;

	/**
	 * Event triggered when the media is corked.
	 */
	public var onCorked(get, null):Event<Void->Void>;

	/**
	 * Event triggered when the media is uncorked.
	 */
	public var onUncorked(get, null):Event<Void->Void>;

	/**
	 * Event triggered when the time changes.
	 */
	public var onTimeChanged(get, null):Event<Int64->Void>;

	/**
	 * Event triggered when the position changes.
	 */
	public var onPositionChanged(get, null):Event<Single->Void>;

	/**
	 * Event triggered when the length changes.
	 */
	public var onLengthChanged(get, null):Event<Int64->Void>;

	/**
	 * Event triggered when the chapter changes.
	 */
	public var onChapterChanged(get, null):Event<Int->Void>;

	/**
	 * Event triggered when the media metadata changes.
	 */
	public var onMediaMetaChanged(get, null):Event<Void->Void>;

	/**
	 * Event triggered when the media is parsed.
	 */
	public var onMediaParsedChanged(get, null):Event<Int->Void>;

	/**
	 * Event triggered when the format setup is initialized.
	 */
	public var onFormatSetup(get, null):Event<Void->Void>;

	/**
	 * Loads media from the specified location.
	 *
	 * @param location The location of the media file or stream.
	 * @param options Additional options to configure the media.
	 * @return `true` if the media was loaded successfully, `false` otherwise.
	 */
	public function load(location:Location, ?options:Array<String>):Bool;

	/**
	 * Parses the current media item with the specified options.
	 *
	 * @param parse_flag The parsing option.
	 * @param timeout The timeout in milliseconds.
	 * @return `true` if parsing succeeded, `false` otherwise.
	 */
	public function parseWithOptions(parse_flag:Int, timeout:Int):Bool;

	/**
	 * Stops parsing the current media item.
	 */
	public function parseStop():Void;

	/**
	 * Starts playback.
	 *
	 * @return `true` if playback started successfully, `false` otherwise.
	 */
	public function play():Bool;

	/**
	 * Stops playback.
	 */
	public function stop():Void;

	/**
	 * Pauses playback.
	 */
	public function pause():Void;

	/**
	 * Resumes playback.
	 */
	public function resume():Void;

	/**
	 * Toggles the pause state.
	 */
	public function togglePaused():Void;

	/**
	 * Moves to the previous chapter, if supported.
	 */
	public function previousChapter():Void;

	/**
	 * Moves to the next chapter, if supported.
	 */
	public function nextChapter():Void;

	/**
	 * Retrieves metadata for the current media item.
	 *
	 * @param e_meta The metadata type.
	 * @return The metadata value as a string, or `null` if not available.
	 */
	public function getMeta(e_meta:Int):String;

	/**
	 * Sets metadata for the current media item.
	 *
	 * @param e_meta The metadata type.
	 * @param value The metadata value.
	 */
	public function setMeta(e_meta:Int, value:String):Void;

	/**
	 * Saves the metadata of the current media item.
	 *
	 * @return `true` if the metadata was saved successfully, `false` otherwise.
	 */
	public function saveMeta():Bool;

	/**
	 * Frees the memory used by the media object.
	 */
	public function dispose():Void;
}
