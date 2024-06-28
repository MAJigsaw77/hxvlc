package hxvlc.openfl;

import haxe.Int64;
import hxvlc.openfl.Stats;
import hxvlc.util.Location;
import lime.app.Event;

/**
 * Interface representing a video object with various media player functionalities.
 */
interface IVideo
{
	/**
	 * The media resource locator (MRL).
	 */
	public var mrl(get, never):String;

	/**
	 * Statistics related to the media resource.
	 */
	public var stats(get, never):Null<Stats>;

	/**
	 * The duration of the media in microseconds.
	 */
	public var duration(get, never):Int64;

	/**
	 * Indicates whether the media player is currently playing.
	 */
	public var isPlaying(get, never):Bool;

	/**
	 * The length of the media in microseconds.
	 */
	public var length(get, never):Int64;

	/**
	 * The current time position in the media in microseconds.
	 */
	public var time(get, set):Int64;

	/**
	 * The current playback position in the media as a percentage (0.0 to 1.0).
	 */
	public var position(get, set):Single;

	/**
	 * The current chapter of the media player.
	 */
	public var chapter(get, set):Int;

	/**
	 * The total number of chapters in the media.
	 */
	public var chapterCount(get, never):Int;

	/**
	 * Indicates whether the media player will play once loaded.
	 */
	public var willPlay(get, never):Bool;

	/**
	 * The playback rate of the media player.
	 *
	 * Note: The actual rate may differ depending on the underlying media.
	 */
	public var rate(get, set):Single;

	/**
	 * Indicates whether seeking is supported by the media player.
	 */
	public var isSeekable(get, never):Bool;

	/**
	 * Indicates whether pausing is supported by the media player.
	 */
	public var canPause(get, never):Bool;

	/**
	 * Available audio output modules for the media player.
	 */
	public var outputModules(get, never):Array<{name:String, description:String}>;

	/**
	 * The selected audio output module for the media player.
	 *
	 * Note: Changes take effect only after restarting playback.
	 */
	public var output(never, set):String;

	/**
	 * Mute status of the media player audio.
	 *
	 * Note: May not be supported under certain conditions (e.g., digital pass-through).
	 */
	public var mute(get, set):Bool;

	/**
	 * Volume level of the media player audio (0 to 100).
	 */
	public var volume(get, set):Int;

	/**
	 * Total number of available audio tracks in the media.
	 */
	public var trackCount(get, never):Int;

	/**
	 * The selected audio track for the media player.
	 */
	public var track(get, set):Int;

	/**
	 * The selected audio channel for the media player.
	 */
	public var channel(get, set):Int;

	/**
	 * Audio delay in microseconds for the media player.
	 */
	public var delay(get, set):Int64;

	/**
	 * Role of the media player.
	 */
	public var role(get, set):UInt;

	/**
	 * Event triggered when the media player is opening.
	 */
	public var onOpening(get, null):Event<Void->Void>;

	/**
	 * Event triggered when the media player starts playing.
	 */
	public var onPlaying(get, null):Event<Void->Void>;

	/**
	 * Event triggered when the media player stops.
	 */
	public var onStopped(get, null):Event<Void->Void>;

	/**
	 * Event triggered when the media player is paused.
	 */
	public var onPaused(get, null):Event<Void->Void>;

	/**
	 * Event triggered when the media player reaches the end.
	 */
	public var onEndReached(get, null):Event<Void->Void>;

	/**
	 * Event triggered when the media player encounters an error.
	 */
	public var onEncounteredError(get, null):Event<String->Void>;

	/**
	 * Event triggered when the media changes.
	 */
	public var onMediaChanged(get, null):Event<Void->Void>;

	/**
	 * Event triggered when the media player is corked.
	 */
	public var onCorked(get, null):Event<Void->Void>;

	/**
	 * Event triggered when the media player is uncorked.
	 */
	public var onUncorked(get, null):Event<Void->Void>;

	/**
	 * Event triggered when the time of the media player changes.
	 */
	public var onTimeChanged(get, null):Event<Int64->Void>;

	/**
	 * Event triggered when the position of the media player changes.
	 */
	public var onPositionChanged(get, null):Event<Single->Void>;

	/**
	 * Event triggered when the length of the media player changes.
	 */
	public var onLengthChanged(get, null):Event<Int64->Void>;

	/**
	 * Event triggered when the chapter of the media player changes.
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
	 * Event triggered when the format setup of the media player is initialized.
	 */
	public var onFormatSetup(get, null):Event<Void->Void>;

	/**
	 * Loads a video from the specified location.
	 *
	 * @param location The location of the video file or stream.
	 * @param options Additional options to configure the media.
	 * @return `true` if the video was loaded successfully, `false` otherwise.
	 */
	public function load(location:Location, ?options:Array<String>):Bool;

	/**
	 * Parses the current media item with the specified parsing option and timeout.
	 *
	 * @param parse_flag The parsing option indicating how to parse the media item.
	 * @param timeout The timeout value in milliseconds for parsing.
	 * @return `true` if parsing succeeded, `false` otherwise.
	 */
	public function parseWithOptions(parse_flag:Int, timeout:Int):Bool;

	/**
	 * Stops parsing of the current media item.
	 */
	public function parseStop():Void;

	/**
	 * Starts playing the loaded video.
	 *
	 * @return `true` if playback started successfully, `false` otherwise.
	 */
	public function play():Bool;

	/**
	 * Stops playback of the video.
	 */
	public function stop():Void;

	/**
	 * Pauses the currently playing video.
	 */
	public function pause():Void;

	/**
	 * Resumes playback of a paused video.
	 */
	public function resume():Void;

	/**
	 * Toggles the pause state of the video.
	 */
	public function togglePaused():Void;

	/**
	 * Sets the media player to the previous chapter, if supported.
	 */
	public function previousChapter():Void;

	/**
	 * Sets the media player to the next chapter, if supported.
	 */
	public function nextChapter():Void;

	/**
	 * Retrieves metadata for the current media item.
	 *
	 * @param e_meta The metadata type to retrieve.
	 * @return The metadata value as a string, or `null` if not available.
	 */
	public function getMeta(e_meta:Int):String;

	/**
	 * Sets metadata for the current media item.
	 *
	 * @param e_meta The metadata type to set.
	 * @param value The metadata value to set.
	 */
	public function setMeta(e_meta:Int, value:String):Void;

	/**
	 * Saves the metadata of the current media item.
	 *
	 * @return `true` if the metadata was saved successfully, `false` otherwise.
	 */
	public function saveMeta():Bool;

	/**
	 * Frees the memory used by the media player object.
	 */
	public function dispose():Void;
}
