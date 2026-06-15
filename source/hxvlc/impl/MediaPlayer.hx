package hxvlc.impl;

import cpp.RawPointer;

import haxe.Int64;

import hxvlc.impl.externs.LibVLC;

/** Represents a implementation or wrapper for the native LibVLC media player instance */
class MediaPlayer extends Finalizeable
{
	/** The media of the media player */
	public var media(get, set):Null<Media>;

	/** Indicates whether the media is currently playing. */
	public var isPlaying(get, never):Bool;

	/** Length of the media in miliseconds. */
	public var length(get, never):Int64;

	/** Current time position in the media in miliseconds. */
	public var time(get, set):Int64;

	/** Current playback position as a percentage (0.0 to 1.0). */
	public var position(get, set):Single;

	/** Playback rate of the video. */
	public var rate(get, set):Single;

	/** Indicates whether seeking is supported. */
	public var isSeekable(get, never):Bool;

	/** Total number of available video tracks. */
	public var videoTrackCount(get, never):Int;

	/** Selected video track. */
	public var videoTrack(get, set):Int;

	/** Total number of available audio tracks. */
	public var audioTrackCount(get, never):Int;

	/** Selected audio track. */
	public var audioTrack(get, set):Int;

	/** Total number of available subtitle tracks. */
	public var spuTrackCount(get, never):Int;

	/** Selected subtitle track. */
	public var spuTrack(get, set):Int;

	/** The raw media player of LibVLC. */
	@:noCompletion
	public var nativeMediaPlayer:Null<RawPointer<LibVLC_Media_Player_T>>;

	/**
	 * Initializes the LibVLC media player
	 * 
	 * @param instance The instance to be used for the media player.
	 */
	public function new(instance:Instance):Void
	{
		super();

		if (instance.nativeInstance != null)
			nativeMediaPlayer = LibVLC.media_player_new(instance.nativeInstance);
	}

	/**
	 * Starts playback.
	 * 
	 * @return `true` if playback started successfully, `false` otherwise.
	 */
	public function play():Bool
	{
		return nativeMediaPlayer != null && LibVLC.media_player_play(nativeMediaPlayer) == 0;
	}

	/** Stops playback. */
	public function stop():Void
	{
		if (nativeMediaPlayer != null)
			LibVLC.media_player_stop(nativeMediaPlayer);
	}

	/** Pauses playback. */
	public function pause():Void
	{
		if (nativeMediaPlayer != null)
			LibVLC.media_player_set_pause(nativeMediaPlayer, 1);
	}

	/** Resumes playback. */
	public function resume():Void
	{
		if (nativeMediaPlayer != null)
			LibVLC.media_player_set_pause(nativeMediaPlayer, 0);
	}

	/** Toggles the pause state. */
	public function togglePaused():Void
	{
		if (nativeMediaPlayer != null)
			LibVLC.media_player_pause(nativeMediaPlayer);
	}

	/**
	 * Adds a slave to the LibVLC media player.
	 * 
	 * @param type The slave type.
	 * @param uri URI of the slave (should contain a valid scheme).
	 * @param select `true` if this slave should be selected when it's loaded.
	 * @return `true` on success, `false` otherwise.
	 */
	public function addSlave(type:Int, url:String, select:Bool):Bool
	{
		return nativeMediaPlayer != null && LibVLC.media_player_add_slave(nativeMediaPlayer, type, url, select) == 0;
	}

	/**
	 * Gets the description of available audio tracks of the LibVLC media player.
	 * 
	 * @return The list containing descriptions of available audio tracks.
	 */
	public function getVideoDescription():Array<TrackDescription>
	{
		final description:Array<TrackDescription> = [];

		if (nativeMediaPlayer != null)
		{
			final rawDescription:RawPointer<LibVLC_Track_Description_T> = LibVLC.video_get_track_description(nativeMediaPlayer);

			if (rawDescription != null)
			{
				var nextDescription:RawPointer<LibVLC_Track_Description_T> = rawDescription;

				while (nextDescription != null)
				{
					description.push(TrackDescription.fromTrackDescription(nextDescription[0]));

					nextDescription = nextDescription[0].p_next;
				}

				LibVLC.track_description_list_release(rawDescription);
			}
		}

		return description;
	}

	/**
	 * Gets the description of available audio tracks of the LibVLC media player.
	 * 
	 * @return The list containing descriptions of available audio tracks.
	 */
	public function getAudioDescription():Array<TrackDescription>
	{
		final description:Array<TrackDescription> = [];

		if (nativeMediaPlayer != null)
		{
			final rawDescription:RawPointer<LibVLC_Track_Description_T> = LibVLC.audio_get_track_description(nativeMediaPlayer);

			if (rawDescription != null)
			{
				var nextDescription:RawPointer<LibVLC_Track_Description_T> = rawDescription;

				while (nextDescription != null)
				{
					description.push(TrackDescription.fromTrackDescription(nextDescription[0]));

					nextDescription = nextDescription[0].p_next;
				}

				LibVLC.track_description_list_release(rawDescription);
			}
		}

		return description;
	}

	/**
	 * Gets the description of available available video subtitles of the LibVLC media player.
	 * 
	 * @return The list containing descriptions of available available video subtitles.
	 */
	public function getSpuDescription():Array<TrackDescription>
	{
		final description:Array<TrackDescription> = [];

		if (nativeMediaPlayer != null)
		{
			final rawDescription:RawPointer<LibVLC_Track_Description_T> = LibVLC.video_get_spu_description(nativeMediaPlayer);

			if (rawDescription != null)
			{
				var nextDescription:RawPointer<LibVLC_Track_Description_T> = rawDescription;

				while (nextDescription != null)
				{
					description.push(TrackDescription.fromTrackDescription(nextDescription[0]));

					nextDescription = nextDescription[0].p_next;
				}

				LibVLC.track_description_list_release(rawDescription);
			}
		}

		return description;
	}

	/** Destroys the native LibVLC media (even if not called, the GC will be picking it up if unused) */
	public override function destroy():Void
	{
		if (nativeMediaPlayer != null)
		{
			LibVLC.media_player_release(nativeMediaPlayer);

			nativeMediaPlayer = null;
		}
	}

	@:noCompletion
	private function get_media():Null<Media>
	{
		if (nativeMediaPlayer != null)
		{
			final nativeMedia:RawPointer<LibVLC_Media_T> = LibVLC.media_player_get_media(nativeMediaPlayer);

			if (nativeMedia != null)
			{
				final media:Media = new Media(false);
				media.nativeMedia = nativeMedia;
				return media;
			}
		}

		return null;
	}

	@:noCompletion
	private function set_media(value:Null<Media>):Null<Media>
	{
		if (nativeMediaPlayer != null && (value != null && value.nativeMedia != null))
			LibVLC.media_player_set_media(nativeMediaPlayer, value.nativeMedia);

		return value;
	}

	@:noCompletion
	private function get_isPlaying():Bool
	{
		return nativeMediaPlayer != null && LibVLC.media_player_is_playing(nativeMediaPlayer) != 0;
	}

	@:noCompletion
	private function get_length():Int64
	{
		return nativeMediaPlayer != null ? LibVLC.media_player_get_length(nativeMediaPlayer) : -1;
	}

	@:noCompletion
	private function get_time():Int64
	{
		return nativeMediaPlayer != null ? LibVLC.media_player_get_time(nativeMediaPlayer) : -1;
	}

	@:noCompletion
	private function set_time(value:Int64):Int64
	{
		if (nativeMediaPlayer != null)
			LibVLC.media_player_set_time(nativeMediaPlayer, value);

		return value;
	}

	@:noCompletion
	private function get_position():Single
	{
		return nativeMediaPlayer != null ? LibVLC.media_player_get_position(nativeMediaPlayer) : -1.0;
	}

	@:noCompletion
	private function set_position(value:Single):Single
	{
		if (nativeMediaPlayer != null)
			LibVLC.media_player_set_position(nativeMediaPlayer, value);

		return value;
	}

	@:noCompletion
	private function get_rate():Single
	{
		return nativeMediaPlayer != null ? LibVLC.media_player_get_rate(nativeMediaPlayer) : 1;
	}

	@:noCompletion
	private function set_rate(value:Single):Single
	{
		if (nativeMediaPlayer != null)
			LibVLC.media_player_set_rate(nativeMediaPlayer, value);

		return value;
	}

	@:noCompletion
	private function get_isSeekable():Bool
	{
		return nativeMediaPlayer != null && LibVLC.media_player_is_seekable(nativeMediaPlayer) != 0;
	}

	@:noCompletion
	private function get_videoTrackCount():Int
	{
		return nativeMediaPlayer != null ? LibVLC.video_get_track_count(nativeMediaPlayer) : -1;
	}

	@:noCompletion
	private function get_videoTrack():Int
	{
		return nativeMediaPlayer != null ? LibVLC.video_get_track(nativeMediaPlayer) : -1;
	}

	@:noCompletion
	private function set_videoTrack(value:Int):Int
	{
		if (nativeMediaPlayer != null)
			LibVLC.video_set_track(nativeMediaPlayer, value);

		return value;
	}

	@:noCompletion
	private function get_audioTrackCount():Int
	{
		return nativeMediaPlayer != null ? LibVLC.audio_get_track_count(nativeMediaPlayer) : -1;
	}

	@:noCompletion
	private function get_audioTrack():Int
	{
		return nativeMediaPlayer != null ? LibVLC.audio_get_track(nativeMediaPlayer) : -1;
	}

	@:noCompletion
	private function set_audioTrack(value:Int):Int
	{
		if (nativeMediaPlayer != null)
			LibVLC.audio_set_track(nativeMediaPlayer, value);

		return value;
	}

	@:noCompletion
	private function get_spuTrackCount():Int
	{
		return nativeMediaPlayer != null ? LibVLC.video_get_spu_count(nativeMediaPlayer) : -1;
	}

	@:noCompletion
	private function get_spuTrack():Int
	{
		return nativeMediaPlayer != null ? LibVLC.video_get_spu(nativeMediaPlayer) : -1;
	}

	@:noCompletion
	private function set_spuTrack(value:Int):Int
	{
		if (nativeMediaPlayer != null)
			LibVLC.video_set_spu(nativeMediaPlayer, value);

		return value;
	}
}
