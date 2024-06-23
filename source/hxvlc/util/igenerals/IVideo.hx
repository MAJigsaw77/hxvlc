package hxvlc.util.igenerals;

import hxvlc.util.Location;

// IMPORTANT NOTE: This Interface for now it's just used for the openfl video class (and extended by the flixel video interface) but I specifically made this just in case in the future hxvlc will work for more libs!  - Nex

/**
 * `IVideo` is an interface used for certain kind of Video objects.
 */
interface IVideo
{
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
}