package hxvlc.flixel;

#if flixel
/**
 * Interface representing a video sprite object in Flixel.
 */
interface IFlxVideoSprite
{
	/**
	 * Whether the video should automatically pause when focus is lost.
	 *
	 * WARNING: Must be set before loading a video.
	 */
	public var autoPause:Bool;

	#if FLX_SOUND_SYSTEM
	/**
	 * Whether Flixel should automatically adjust the volume according to the Flixel sound system's current volume.
	 */
	public var autoVolumeHandle:Bool;
	#end

	/**
	 * The video bitmap.
	 */
	public var bitmap(get, never):Video;

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
	 * Resumes the video.
	 */
	public function resume():Void;

	/**
	 * Toggles the pause state of the video.
	 */
	public function togglePaused():Void;
}
#end
