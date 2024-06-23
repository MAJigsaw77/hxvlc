package hxvlc.flixel;

#if flixel
import hxvlc.util.igenerals.IVideo;

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
	 * Update the video's current volume.
     *
     * @param volume The volume to apply to the video.
     * @param multiplier The volume's multiplier (if it's `null` or by default it equals to `volumeMultiplier`).
     *
     * @return The final volume.
	 */
    public function updateVolume(volume:Float = 0, ?multiplier:Float):Int;

    /**
	 * The video's volume multiplier used in `updateVolume` BY DEFAULT.
	 */
    public var volumeMultiplier:Float;

    #if FLX_SOUND_SYSTEM
    /**
	 * Whether `updateVolume` should be atomatically called and used according to the Flixel sound system's current volume.
	 */
	public var autoVolumeHandle:Bool;
	#end
}
#end