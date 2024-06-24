package hxvlc.flixel;

#if flixel
import hxvlc.util.interfaces.IVideo;

/**
 * `IFlxVideo` is an interface used for any kind of Flixel Video objects.
 */
interface IFlxVideo extends IVideo
{
	/**
	 * Whether the video should automatically pause when focus is lost.
	 *
	 * WARNING: Must be set before loading a video.
	 */
	public var autoPause:Bool;

	/**
	 * The video's volume multiplier.
	 */
	public var volumeMultiplier:Float;

	#if FLX_SOUND_SYSTEM
	/**
	 * Whether Flixel should automatically adjust the volume according to the Flixel sound system's current volume.
	 */
	public var autoVolumeHandle:Bool;
	#end
}
#end
