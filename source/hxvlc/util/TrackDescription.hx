package hxvlc.util;

import hxvlc.externs.Types;

/**
 * Represents a description for video, audio tracks, and subtitles.
 */
class TrackDescription
{
	/**
	 * The unique identifier for the track.
	 */
	public var i_id:Int;

	/**
	 * The name of the track as a string.
	 */
	public var psz_name:String;

	/**
	 * Creates a new instance of `TrackDescription` with default values.
	 */
	public function new():Void
	{
		this.i_id = 0;
		this.psz_name = '';
	}

	/**
	 * Returns a string representation of the `TrackDescription` object.
	 * @return A string containing all the properties of the TrackDescription object.
	 */
	@:keep
	public function toString():String
	{
		final parts:Array<String> = [];
		parts.push('Track ID: $i_id');
		parts.push('Track Name: $psz_name');
		return parts.join(', ');
	}

	/**
	 * Constructs a `TrackDescription` object from raw LibVLC track description data.
	 * 
	 * @param track_description The LibVLC track description data.
	 * 
	 * @return A `TrackDescription` object populated with the provided data.
	 */
	@:unreflective
	public static function fromTrackDescription(track_description:cpp.Struct<LibVLC_Track_Description_T>):TrackDescription
	{
		final description:TrackDescription = new TrackDescription();

		if (track_description != null)
		{
			description.i_id = track_description.i_id;
			description.psz_name = track_description.psz_name;
		}

		return description;
	}
}
