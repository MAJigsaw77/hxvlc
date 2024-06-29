package hxvlc.flixel;

#if flixel
import hxvlc.openfl.Video;
import hxvlc.util.Location;

/**
 * Interface representing a video sprite object in Flixel.
 */
interface IFlxVideoSprite
{
	/**
	 * Indicates whether the video should automatically pause when focus is lost.
	 *
	 * Must be set before loading a video.
	 */
	public var autoPause:Bool;

	#if FLX_SOUND_SYSTEM
	/**
	 * Determines if Flixel automatically adjusts the volume based on the Flixel sound system's current volume.
	 */
	public var autoVolumeHandle:Bool;
	#end

	/**
	 * The video bitmap object.
	 */
	public var bitmap(default, null):Video;

	/**
	 * Loads a video from a specified location.
	 *
	 * @param location The path, URL, file descriptor ID, or bitstream input of the media.
	 * @param options Additional options for LibVLC Media.
	 * @return `true` if the video loads successfully, `false` otherwise.
	 */
	public function load(location:Location, ?options:Array<String>):Bool;

	/**
	 * Parses the current media item with the specified options.
	 *
	 * @param parse_flag The parsing option.
	 * @param timeout The timeout duration in milliseconds.
	 * @return `true` if parsing succeeds, `false` otherwise.
	 */
	public function parseWithOptions(parse_flag:Int, timeout:Int):Bool;

	/**
	 * Stops the parsing of the current media item.
	 */
	public function parseStop():Void;

	/**
	 * Begins playback of the video.
	 *
	 * @return `true` if the video starts playing successfully, `false` otherwise.
	 */
	public function play():Bool;

	/**
	 * Stops video playback.
	 */
	public function stop():Void;

	/**
	 * Pauses video playback.
	 */
	public function pause():Void;

	/**
	 * Resumes playback of a paused video.
	 */
	public function resume():Void;

	/**
	 * Toggles between play and pause states of the video.
	 */
	public function togglePaused():Void;

	/**
	 * Moves to the previous chapter or position in the video, if supported.
	 */
	public function previousChapter():Void;

	/**
	 * Moves to the next chapter or position in the video, if supported.
	 */
	public function nextChapter():Void;

	/**
	 * Retrieves metadata for the current media item.
	 *
	 * @param e_meta The type of metadata to retrieve.
	 * @return The metadata value as a string, or `null` if unavailable.
	 */
	public function getMeta(e_meta:Int):String;

	/**
	 * Sets metadata for the current media item.
	 *
	 * @param e_meta The type of metadata to set.
	 * @param value The value of the metadata.
	 */
	public function setMeta(e_meta:Int, value:String):Void;

	/**
	 * Saves the metadata of the current media item.
	 *
	 * @return `true` if the metadata saves successfully, `false` otherwise.
	 */
	public function saveMeta():Bool;
}
#end
