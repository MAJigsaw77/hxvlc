package hxvlc.openfl;

import haxe.Int64;
import haxe.MainLoop;
import haxe.io.Bytes;
import haxe.io.BytesData;
import haxe.io.BytesInput;
import hxvlc.externs.LibVLC;
import hxvlc.externs.Types;
import hxvlc.util.Handle;
import hxvlc.util.Stats;
import hxvlc.util.TrackDescription;
import hxvlc.util.Util;
import hxvlc.util.macros.DefineMacro;
import lime.app.Event;
import lime.utils.UInt8Array;
import openfl.Lib;
import openfl.display.BitmapData;
import sys.thread.Mutex;

using cpp.NativeArray;

#if lime_openal
import lime.media.openal.AL;
import lime.media.openal.ALBuffer;
import lime.media.openal.ALSource;
#end

/** This class is a video player that uses LibVLC for seamless integration with OpenFL display objects. */
@:access(openfl.display.BitmapData)
@:cppNamespaceCode('
static int media_open(void *opaque, void **datap, uint64_t *sizep)
{
	if (opaque)
	{
		(*datap) = opaque;

		hx::SetTopOfStack((int *)99, true);

		int result = reinterpret_cast<Video_obj *>(opaque)->mediaOpen(sizep);

		hx::SetTopOfStack((int *)0, true);

		return result;
	}

	return -1;
}

static ssize_t media_read(void *opaque, unsigned char *buf, size_t len)
{
	if (opaque)
	{
		hx::SetTopOfStack((int *)99, true);

		ssize_t bytesToRead = reinterpret_cast<Video_obj *>(opaque)->mediaRead(buf, len);

		hx::SetTopOfStack((int *)0, true);

		return bytesToRead;
	}

	return -1;
}

static int media_seek(void *opaque, uint64_t offset)
{
	if (opaque)
	{
		hx::SetTopOfStack((int *)99, true);

		int success = reinterpret_cast<Video_obj *>(opaque)->mediaSeek(offset);

		hx::SetTopOfStack((int *)0, true);

		return success;
	}

	return -1;
}

static void *video_lock(void *opaque, void **planes)
{
	if (opaque)
	{
		hx::SetTopOfStack((int *)99, true);

		void *picture = reinterpret_cast<Video_obj *>(opaque)->videoLock(planes);

		hx::SetTopOfStack((int *)0, true);

		return picture;
	}

	return nullptr;
}

static void video_unlock(void *opaque, void *picture, void *const *planes)
{
	if (opaque)
	{
		hx::SetTopOfStack((int *)99, true);

		reinterpret_cast<Video_obj *>(opaque)->videoUnlock(planes);

		hx::SetTopOfStack((int *)0, true);
	}
}

static void video_display(void *opaque, void *picture)
{
	if (opaque)
	{
		hx::SetTopOfStack((int *)99, true);

		reinterpret_cast<Video_obj *>(opaque)->videoDisplay(picture);

		hx::SetTopOfStack((int *)0, true);
	}
}

static unsigned video_format_setup(void **opaque, char *chroma, unsigned *width, unsigned *height, unsigned *pitches, unsigned *lines)
{
	if (opaque && (*opaque))
	{
		hx::SetTopOfStack((int *)99, true);

		int pictureBuffers = reinterpret_cast<Video_obj *>(*opaque)->videoFormatSetup(chroma, width, height, pitches, lines);

		hx::SetTopOfStack((int *)0, true);

		return pictureBuffers;
	}

	return 0;
}

static void audio_play(void *data, const void *samples, unsigned count, int64_t pts)
{
	if (data)
	{
		hx::SetTopOfStack((int *)99, true);

		reinterpret_cast<Video_obj *>(data)->audioPlay((unsigned char *)samples, count, pts);

		hx::SetTopOfStack((int *)0, true);
	}
}

static void audio_pause(void *data, int64_t pts)
{
	if (data)
	{
		hx::SetTopOfStack((int *)99, true);

		reinterpret_cast<Video_obj *>(data)->audioPause(pts);

		hx::SetTopOfStack((int *)0, true);
	}
}

static void audio_flush(void *data, int64_t pts)
{
	if (data)
	{
		hx::SetTopOfStack((int *)99, true);

		reinterpret_cast<Video_obj *>(data)->audioFlush(pts);

		hx::SetTopOfStack((int *)0, true);
	}
}

static int audio_setup(void **data, char *format, unsigned *rate, unsigned *channels)
{
	if (data && *data)
	{
		hx::SetTopOfStack((int *)99, true);

		int result = reinterpret_cast<Video_obj *>(*data)->audioSetup(format, rate, channels);

		hx::SetTopOfStack((int *)0, true);

		return result;
	}

	return 1;
}

static void audio_set_volume(void *data, float volume, bool mute)
{
	if (data)
	{
		hx::SetTopOfStack((int *)99, true);

		reinterpret_cast<Video_obj *>(data)->audioSetVolume(volume, mute);

		hx::SetTopOfStack((int *)0, true);
	}
}

static void event_manager_callbacks(const libvlc_event_t *p_event, void *p_data)
{
	if (p_data)
	{
		hx::SetTopOfStack((int *)99, true);

		reinterpret_cast<Video_obj *>(p_data)->eventManagerCallbacks(p_event);

		hx::SetTopOfStack((int *)0, true);
	}
}')
class Video extends openfl.display.Bitmap
{
	#if lime_openal
	/** The number of buffers used for the buffer pool. */
	@:noCompletion
	private static final MAX_AUDIO_BUFFER_COUNT:Int = DefineMacro.getInt('HXVLC_MAX_AUDIO_BUFFER_COUNT', 255);
	#end

	/**
	 * Regular expression used to validate the structure of a URL.
	 * 
	 * This regex checks that the URL:
	 * 
	 * 1. Starts with a valid protocol (letters, digits, or special characters like '+', '.', or '-').
	 * 2. Contains "://" after the protocol.
	 * 3. Does not contain spaces after the "://".
	 * 
	 * This validation does not restrict specific protocols, so it allows any protocol
	 * that follows the general URL format (e.g., https://, ftp://, file://).
	 * 
	 * Example:
	 * - "https://example.com" -> valid
	 * - "ftp://files.server" -> valid
	 * - "invalid_url://something" -> invalid
	 * - "https:// example.com" -> invalid (space after '://')
	 */
	@:noCompletion
	private static final URL_VERIFICATION_REGEX:EReg = ~/^[a-zA-Z][a-zA-Z\d+\-.]*:\/\/[^\s]*$/;

	/** Enables hardware rendering (GPU textures) if supported; otherwise, falls back to software rendering (CPU). */
	public static var useTexture:Bool = true;

	/** Forces rendering of the bitmapData within this bitmap. */
	public var forceRendering:Bool = false;

	/** The media resource locator (MRL). */
	public var mrl(get, never):Null<String>;

	/** Statistics related to the media. */
	public var stats(get, never):Null<Stats>;

	/** Duration of the media in microseconds. */
	public var duration(get, never):Int64;

	/** Indicates whether the media is currently playing. */
	public var isPlaying(get, never):Bool;

	/** Length of the media in microseconds. */
	public var length(get, never):Int64;

	/** Current time position in the media in microseconds. */
	public var time(get, set):Int64;

	/** Current playback position as a percentage (0.0 to 1.0). */
	public var position(get, set):Single;

	/** Current chapter of the video. */
	public var chapter(get, set):Int;

	/** Total number of chapters in the video. */
	public var chapterCount(get, never):Int;

	/** Playback rate of the video. */
	public var rate(get, set):Single;

	/** Indicates whether seeking is supported. */
	public var isSeekable(get, never):Bool;

	/** Indicates whether pausing is supported. */
	public var canPause(get, never):Bool;

	/** Volume level (0 to 100). */
	public var volume(get, set):Int;

	/** Role of the media. */
	public var role(get, set):UInt;

	/** Total number of available video tracks. */
	public var videoTrackCount(get, never):Int;

	/** Selected video track. */
	public var videoTrack(get, set):Int;

	/** Total number of available audio tracks. */
	public var audioTrackCount(get, never):Int;

	/** Selected audio track. */
	public var audioTrack(get, set):Int;

	/** Audio delay in microseconds. */
	public var audioDelay(get, set):Int64;

	/** Total number of available subtitle tracks. */
	public var spuTrackCount(get, never):Int;

	/** Selected subtitle track. */
	public var spuTrack(get, set):Int;

	/** Subtitle delay in microseconds. */
	public var spuDelay(get, set):Int64;

	/** Event triggered when the media is opening. */
	public var onOpening(default, null):Event<Void->Void> = new Event<Void->Void>();

	/** Event triggered when playback starts. */
	public var onPlaying(default, null):Event<Void->Void> = new Event<Void->Void>();

	/** Event triggered when playback stops. */
	public var onStopped(default, null):Event<Void->Void> = new Event<Void->Void>();

	/** Event triggered when playback is paused. */
	public var onPaused(default, null):Event<Void->Void> = new Event<Void->Void>();

	/** Event triggered when the end of the media is reached. */
	public var onEndReached(default, null):Event<Void->Void> = new Event<Void->Void>();

	/** Event triggered when an error occurs. */
	public var onEncounteredError(default, null):Event<String->Void> = new Event<String->Void>();

	/** Event triggered when the media changes. */
	public var onMediaChanged(default, null):Event<Void->Void> = new Event<Void->Void>();

	/** Event triggered when the media is corked. */
	public var onCorked(default, null):Event<Void->Void> = new Event<Void->Void>();

	/** Event triggered when the media is uncorked. */
	public var onUncorked(default, null):Event<Void->Void> = new Event<Void->Void>();

	/** Event triggered when the time changes. */
	public var onTimeChanged(default, null):Event<Int64->Void> = new Event<Int64->Void>();

	/** Event triggered when the position changes. */
	public var onPositionChanged(default, null):Event<Single->Void> = new Event<Single->Void>();

	/** Event triggered when the length changes. */
	public var onLengthChanged(default, null):Event<Int64->Void> = new Event<Int64->Void>();

	/** Event triggered when the chapter changes. */
	public var onChapterChanged(default, null):Event<Int->Void> = new Event<Int->Void>();

	/** Event triggered when the media metadata changes. */
	public var onMediaMetaChanged(default, null):Event<Void->Void> = new Event<Void->Void>();

	/** Event triggered when the media is parsed. */
	public var onMediaParsedChanged(default, null):Event<Int->Void> = new Event<Int->Void>();

	/** Event triggered when the media format setup is initialized. */
	public var onFormatSetup(default, null):Event<Void->Void> = new Event<Void->Void>();

	/** Event triggered when the media is being rendered. */
	public var onDisplay(default, null):Event<Void->Void> = new Event<Void->Void>();

	@:noCompletion
	private final mediaMutex:Mutex = new Mutex();

	@:noCompletion
	private final textureMutex:Mutex = new Mutex();

	#if lime_openal
	@:noCompletion
	private final alMutex:Mutex = new Mutex();
	#end

	@:noCompletion
	private var mediaInput:Null<BytesInput>;

	@:noCompletion
	private var mediaPlayer:Null<cpp.RawPointer<LibVLC_Media_Player_T>>;

	@:noCompletion
	private var textureWidth:cpp.UInt32 = 0;

	@:noCompletion
	private var textureHeight:cpp.UInt32 = 0;

	@:noCompletion
	private var texturePlanes:Null<BytesData>;

	#if lime_openal
	@:noCompletion
	private var alUseEXTMCFORMATS:Null<Bool>;

	@:noCompletion
	private var alSource:Null<ALSource>;

	@:noCompletion
	private var alBufferPool:Null<Array<ALBuffer>>;

	@:noCompletion
	private var alSampleRate:cpp.UInt32 = 0;

	@:noCompletion
	private var alFormat:Int = 0;

	@:noCompletion
	private var alFrameSize:cpp.UInt32 = 0;
	#end

	/**
	 * Initializes a Video object.
	 * 
	 * @param smoothing Whether or not the object is smoothed when scaled.
	 */
	public function new(smoothing:Bool = true):Void
	{
		super(null, AUTO, smoothing);

		while (Handle.loading)
			Sys.sleep(0.05);

		Handle.init();
	}

	/**
	 * Loads media from the specified location.
	 * 
	 * @param location The location of the media file or stream.
	 * @param options Additional options to configure the media.
	 * @return `true` if the media was loaded successfully, `false` otherwise.
	 */
	public function load(location:hxvlc.util.Location, ?options:Array<String>):Bool
	{
		if (Handle.instance == null)
			return false;

		var mediaItem:cpp.RawPointer<LibVLC_Media_T>;

		if (location != null)
		{
			if ((location is String))
			{
				final location:String = cast(location, String);

				if (URL_VERIFICATION_REGEX.match(location))
					mediaItem = LibVLC.media_new_location(Handle.instance, location);
				else
					mediaItem = LibVLC.media_new_path(Handle.instance, Util.normalizePath(location));
			}
			else if ((location is Int))
			{
				mediaItem = LibVLC.media_new_fd(Handle.instance, cast(location, Int));
			}
			else if ((location is Bytes))
			{
				mediaMutex.acquire();

				mediaInput = new BytesInput(cast(location, Bytes));

				mediaItem = LibVLC.media_new_callbacks(Handle.instance, untyped __cpp__('media_open'), untyped __cpp__('media_read'),
					untyped __cpp__('media_seek'), untyped NULL, untyped __cpp__('this'));

				mediaMutex.release();
			}
			else
				return false;
		}
		else
			return false;

		if (mediaPlayer == null)
		{
			mediaPlayer = LibVLC.media_player_new(Handle.instance);

			if (mediaPlayer != null)
			{
				setupAudio();
				setupVideo();
				setupEvents();
			}
			else
				trace('Unable to initialize the LibVLC media player.');
		}

		if (mediaItem != null)
		{
			setMediaToPlayer(mediaItem, options);

			return true;
		}
		else
			trace('Unable to initialize the LibVLC media item.');

		return false;
	}

	/**
	 * Loads a media subitem from the current media's subitems list at the specified index.
	 * 
	 * @param index The index of the subitem to load.
	 * @param options Additional options to configure the loaded subitem.
	 * @return `true` if the subitem was loaded successfully, `false` otherwise.
	 */
	public function loadFromSubItem(index:Int, ?options:Array<String>):Bool
	{
		if (mediaPlayer != null)
		{
			final currentMediaItem:cpp.RawPointer<LibVLC_Media_T> = LibVLC.media_player_get_media(mediaPlayer);

			if (currentMediaItem != null)
			{
				final currentMediaSubItems:cpp.RawPointer<LibVLC_Media_List_T> = LibVLC.media_subitems(currentMediaItem);

				if (currentMediaSubItems != null)
				{
					final count:Int = LibVLC.media_list_count(currentMediaSubItems);

					if (index >= 0 && index < count)
					{
						final mediaSubItem:cpp.RawPointer<LibVLC_Media_T> = LibVLC.media_list_item_at_index(currentMediaSubItems, index);

						if (mediaSubItem != null)
						{
							setMediaToPlayer(mediaSubItem, options);

							LibVLC.media_list_release(currentMediaSubItems);

							return true;
						}
					}

					LibVLC.media_list_release(currentMediaSubItems);
				}
			}
		}

		return false;
	}

	/**
	 * Parses the current media item with the specified options.
	 * 
	 * @param parse_flag The parsing option.
	 * @param timeout The timeout in milliseconds.
	 * @return `true` if parsing succeeded, `false` otherwise.
	 */
	public function parseWithOptions(parse_flag:Int, timeout:Int):Bool
	{
		if (mediaPlayer != null)
		{
			final currentMediaItem:cpp.RawPointer<LibVLC_Media_T> = LibVLC.media_player_get_media(mediaPlayer);

			if (currentMediaItem != null)
			{
				final eventManager:cpp.RawPointer<LibVLC_Event_Manager_T> = LibVLC.media_event_manager(currentMediaItem);

				if (eventManager != null)
				{
					addEvent(eventManager, LibVLC_MediaParsedChanged);
					addEvent(eventManager, LibVLC_MediaMetaChanged);
				}
				else
					trace('Unable to initialize the LibVLC media event manager.');

				return LibVLC.media_parse_with_options(currentMediaItem, parse_flag, timeout) == 0;
			}
		}

		return false;
	}

	/** Stops parsing the current media item. */
	public function parseStop():Void
	{
		if (mediaPlayer != null)
		{
			final currentMediaItem:cpp.RawPointer<LibVLC_Media_T> = LibVLC.media_player_get_media(mediaPlayer);

			if (currentMediaItem != null)
				LibVLC.media_parse_stop(currentMediaItem);
		}
	}

	/**
	 * Adds a slave to the current media player.
	 * 
	 * @param type The slave type.
	 * @param uri URI of the slave (should contain a valid scheme).
	 * @param select `true` if this slave should be selected when it's loaded.
	 * @return `true` on success, `false` otherwise.
	 */
	public function addSlave(type:Int, url:String, select:Bool):Bool
	{
		return mediaPlayer != null && LibVLC.media_player_add_slave(mediaPlayer, type, url, select) == 0;
	}

	/**
	 * Gets the description of available audio tracks of the current media player.
	 * @return The list containing descriptions of available audio tracks.
	 */
	public function getVideoDescription():Array<TrackDescription>
	{
		final description:Array<TrackDescription> = [];

		if (mediaPlayer != null)
		{
			final rawDescription:cpp.RawPointer<LibVLC_Track_Description_T> = LibVLC.video_get_track_description(mediaPlayer);

			if (rawDescription != null)
				getDescription(rawDescription, description);
		}

		return description;
	}

	/**
	 * Gets the description of available audio tracks of the current media player.
	 * @return The list containing descriptions of available audio tracks.
	 */
	public function getAudioDescription():Array<TrackDescription>
	{
		final description:Array<TrackDescription> = [];

		if (mediaPlayer != null)
		{
			final rawDescription:cpp.RawPointer<LibVLC_Track_Description_T> = LibVLC.audio_get_track_description(mediaPlayer);

			if (rawDescription != null)
				getDescription(rawDescription, description);
		}

		return description;
	}

	/**
	 * Gets the description of available available video subtitles of the current media player.
	 * @return The list containing descriptions of available available video subtitles.
	 */
	public function getSpuDescription():Array<TrackDescription>
	{
		final description:Array<TrackDescription> = [];

		if (mediaPlayer != null)
		{
			final rawDescription:cpp.RawPointer<LibVLC_Track_Description_T> = LibVLC.video_get_spu_description(mediaPlayer);

			if (rawDescription != null)
				getDescription(rawDescription, description);
		}

		return description;
	}

	/**
	 * Starts playback.
	 * @return `true` if playback started successfully, `false` otherwise.
	 */
	public function play():Bool
	{
		return mediaPlayer != null && LibVLC.media_player_play(mediaPlayer) == 0;
	}

	/** Stops playback. */
	public function stop():Void
	{
		if (mediaPlayer != null)
			LibVLC.media_player_stop(mediaPlayer);
	}

	/** Pauses playback. */
	public function pause():Void
	{
		if (mediaPlayer != null)
			LibVLC.media_player_set_pause(mediaPlayer, 1);
	}

	/** Resumes playback. */
	public function resume():Void
	{
		if (mediaPlayer != null)
			LibVLC.media_player_set_pause(mediaPlayer, 0);
	}

	/** Toggles the pause state. */
	public function togglePaused():Void
	{
		if (mediaPlayer != null)
			LibVLC.media_player_pause(mediaPlayer);
	}

	/** Moves to the previous chapter, if supported. */
	public function previousChapter():Void
	{
		if (mediaPlayer != null)
			LibVLC.media_player_previous_chapter(mediaPlayer);
	}

	/** Moves to the next chapter, if supported. */
	public function nextChapter():Void
	{
		if (mediaPlayer != null)
			LibVLC.media_player_next_chapter(mediaPlayer);
	}

	/**
	 * Retrieves metadata for the current media item.
	 * 
	 * @param e_meta The metadata type.
	 * @return The metadata value as a string, or `null` if not available.
	 */
	public function getMeta(e_meta:Int):Null<String>
	{
		if (mediaPlayer != null)
		{
			final currentMediaItem:cpp.RawPointer<LibVLC_Media_T> = LibVLC.media_player_get_media(mediaPlayer);

			if (currentMediaItem != null)
			{
				final rawMeta:cpp.CastCharStar = LibVLC.media_get_meta(currentMediaItem, e_meta);

				if (rawMeta != null)
					return new String(untyped rawMeta);
			}
		}

		return null;
	}

	/**
	 * Sets metadata for the current media item.
	 * 
	 * @param e_meta The metadata type.
	 * @param value The metadata value.
	 */
	public function setMeta(e_meta:Int, value:String):Void
	{
		if (mediaPlayer != null && value != null)
		{
			final currentMediaItem:cpp.RawPointer<LibVLC_Media_T> = LibVLC.media_player_get_media(mediaPlayer);

			if (currentMediaItem != null)
				LibVLC.media_set_meta(currentMediaItem, e_meta, value);
		}
	}

	/**
	 * Saves the metadata of the current media item.
	 * @return `true` if the metadata was saved successfully, `false` otherwise.
	 */
	public function saveMeta():Bool
	{
		if (mediaPlayer != null)
		{
			final currentMediaItem:cpp.RawPointer<LibVLC_Media_T> = LibVLC.media_player_get_media(mediaPlayer);

			if (currentMediaItem != null)
				return LibVLC.media_save_meta(currentMediaItem) != 0;
		}

		return false;
	}

	/** Frees the memory that is used to store the Video object. */
	public function dispose():Void
	{
		if (mediaPlayer != null)
		{
			LibVLC.media_player_release(mediaPlayer);
			mediaPlayer = null;
		}

		mediaMutex.acquire();

		mediaInput = null;

		mediaMutex.release();

		textureMutex.acquire();

		if (bitmapData != null)
		{
			if (bitmapData.__texture != null)
				bitmapData.__texture.dispose();

			bitmapData.dispose();
		}

		textureWidth = 0;
		textureHeight = 0;
		texturePlanes = null;

		textureMutex.release();

		#if lime_openal
		alMutex.acquire();

		if (alSource != null)
		{
			if (AL.getSourcei(alSource, AL.SOURCE_STATE) != AL.STOPPED)
				AL.sourceStop(alSource);

			final queuedBuffers:Int = AL.getSourcei(alSource, AL.BUFFERS_QUEUED);

			if (queuedBuffers > 0)
			{
				for (alBuffer in AL.sourceUnqueueBuffers(alSource, queuedBuffers))
					AL.deleteBuffer(alBuffer);
			}

			AL.deleteSource(alSource);
			alSource = null;
		}

		if (alBufferPool != null)
		{
			AL.deleteBuffers(alBufferPool);
			alBufferPool = null;
		}

		alMutex.release();
		#end
	}

	@:noCompletion
	private function get_mrl():Null<String>
	{
		if (mediaPlayer != null)
		{
			final currentMediaItem:cpp.RawPointer<LibVLC_Media_T> = LibVLC.media_player_get_media(mediaPlayer);

			if (currentMediaItem != null)
			{
				final rawMrl:cpp.CastCharStar = LibVLC.media_get_mrl(currentMediaItem);

				if (rawMrl != null)
					return new String(untyped rawMrl);
			}
		}

		return null;
	}

	@:noCompletion
	private function get_stats():Null<Stats>
	{
		if (mediaPlayer != null)
		{
			final currentMediaItem:cpp.RawPointer<LibVLC_Media_T> = LibVLC.media_player_get_media(mediaPlayer);

			if (currentMediaItem != null)
			{
				final currentMediaStats:LibVLC_Media_Stats_T = new LibVLC_Media_Stats_T();

				if (LibVLC.media_get_stats(currentMediaItem, cpp.RawPointer.addressOf(currentMediaStats)) != 0)
					return Stats.fromMediaStats(currentMediaStats);
			}
		}

		return null;
	}

	@:noCompletion
	private function get_duration():Int64
	{
		if (mediaPlayer != null)
		{
			final currentMediaItem:cpp.RawPointer<LibVLC_Media_T> = LibVLC.media_player_get_media(mediaPlayer);

			if (currentMediaItem != null)
				return LibVLC.media_get_duration(currentMediaItem);
		}

		return -1;
	}

	@:noCompletion
	private function get_isPlaying():Bool
	{
		return mediaPlayer != null && LibVLC.media_player_is_playing(mediaPlayer) != 0;
	}

	@:noCompletion
	private function get_length():Int64
	{
		return mediaPlayer != null ? LibVLC.media_player_get_length(mediaPlayer) : -1;
	}

	@:noCompletion
	private function get_time():Int64
	{
		return mediaPlayer != null ? LibVLC.media_player_get_time(mediaPlayer) : -1;
	}

	@:noCompletion
	private function set_time(value:Int64):Int64
	{
		if (mediaPlayer != null)
			LibVLC.media_player_set_time(mediaPlayer, value);

		return value;
	}

	@:noCompletion
	private function get_position():Single
	{
		return mediaPlayer != null ? LibVLC.media_player_get_position(mediaPlayer) : -1.0;
	}

	@:noCompletion
	private function set_position(value:Single):Single
	{
		if (mediaPlayer != null)
			LibVLC.media_player_set_position(mediaPlayer, value);

		return value;
	}

	@:noCompletion
	private function get_chapter():Int
	{
		return mediaPlayer != null ? LibVLC.media_player_get_chapter(mediaPlayer) : -1;
	}

	@:noCompletion
	private function set_chapter(value:Int):Int
	{
		if (mediaPlayer != null)
			LibVLC.media_player_set_chapter(mediaPlayer, value);

		return value;
	}

	@:noCompletion
	private function get_chapterCount():Int
	{
		return mediaPlayer != null ? LibVLC.media_player_get_chapter_count(mediaPlayer) : -1;
	}

	@:noCompletion
	private function get_rate():Single
	{
		return mediaPlayer != null ? LibVLC.media_player_get_rate(mediaPlayer) : 1;
	}

	@:noCompletion
	private function set_rate(value:Single):Single
	{
		if (mediaPlayer != null)
			LibVLC.media_player_set_rate(mediaPlayer, value);

		return value;
	}

	@:noCompletion
	private function get_isSeekable():Bool
	{
		return mediaPlayer != null && LibVLC.media_player_is_seekable(mediaPlayer) != 0;
	}

	@:noCompletion
	private function get_canPause():Bool
	{
		return mediaPlayer != null && LibVLC.media_player_can_pause(mediaPlayer) != 0;
	}

	@:noCompletion
	private function get_volume():Int
	{
		#if lime_openal
		return alSource != null ? Math.floor(AL.getSourcef(alSource, AL.GAIN) * 100) : -1;
		#else
		return -1;
		#end
	}

	@:noCompletion
	private function set_volume(value:Int):Int
	{
		#if lime_openal
		if (alSource != null)
			AL.sourcef(alSource, AL.GAIN, Math.abs(value / 100));
		#end

		return value;
	}

	@:noCompletion
	private function get_role():UInt
	{
		return mediaPlayer != null ? LibVLC.media_player_get_role(mediaPlayer) : 0;
	}

	@:noCompletion
	private function set_role(value:UInt):UInt
	{
		if (mediaPlayer != null)
			LibVLC.media_player_set_role(mediaPlayer, value);

		return value;
	}

	@:noCompletion
	private function get_videoTrackCount():Int
	{
		return mediaPlayer != null ? LibVLC.video_get_track_count(mediaPlayer) : -1;
	}

	@:noCompletion
	private function get_videoTrack():Int
	{
		return mediaPlayer != null ? LibVLC.video_get_track(mediaPlayer) : -1;
	}

	@:noCompletion
	private function set_videoTrack(value:Int):Int
	{
		if (mediaPlayer != null)
			LibVLC.video_set_track(mediaPlayer, value);

		return value;
	}

	@:noCompletion
	private function get_audioTrackCount():Int
	{
		return mediaPlayer != null ? LibVLC.audio_get_track_count(mediaPlayer) : -1;
	}

	@:noCompletion
	private function get_audioTrack():Int
	{
		return mediaPlayer != null ? LibVLC.audio_get_track(mediaPlayer) : -1;
	}

	@:noCompletion
	private function set_audioTrack(value:Int):Int
	{
		if (mediaPlayer != null)
			LibVLC.audio_set_track(mediaPlayer, value);

		return value;
	}

	@:noCompletion
	private function get_audioDelay():Int64
	{
		return mediaPlayer != null ? LibVLC.audio_get_delay(mediaPlayer) : 0;
	}

	@:noCompletion
	private function set_audioDelay(value:Int64):Int64
	{
		if (mediaPlayer != null)
			LibVLC.audio_set_delay(mediaPlayer, value);

		return value;
	}

	@:noCompletion
	private function get_spuTrackCount():Int
	{
		return mediaPlayer != null ? LibVLC.video_get_spu_count(mediaPlayer) : -1;
	}

	@:noCompletion
	private function get_spuTrack():Int
	{
		return mediaPlayer != null ? LibVLC.video_get_spu(mediaPlayer) : -1;
	}

	@:noCompletion
	private function set_spuTrack(value:Int):Int
	{
		if (mediaPlayer != null)
			LibVLC.video_set_spu(mediaPlayer, value);

		return value;
	}

	@:noCompletion
	private function get_spuDelay():Int64
	{
		return mediaPlayer != null ? LibVLC.video_get_spu_delay(mediaPlayer) : 0;
	}

	@:noCompletion
	private function set_spuDelay(value:Int64):Int64
	{
		if (mediaPlayer != null)
			LibVLC.video_set_spu_delay(mediaPlayer, value);

		return value;
	}

	@:noCompletion
	private override function __enterFrame(deltaTime:Int):Void {}

	@:noCompletion
	private override function set_bitmapData(value:BitmapData):BitmapData
	{
		__bitmapData = value;

		__setRenderDirty();

		return __bitmapData;
	}

	@:keep
	@:noCompletion
	@:unreflective
	private function mediaOpen(sizep:cpp.RawPointer<cpp.UInt64>):Int
	{
		mediaMutex.acquire();

		if (mediaInput != null)
		{
			sizep[0] = cast mediaInput.length;

			mediaMutex.release();

			return 0;
		}

		mediaMutex.release();

		return -1;
	}

	@:keep
	@:noCompletion
	@:unreflective
	private function mediaRead(buf:cpp.RawPointer<cpp.UInt8>, len:cpp.SizeT):cpp.SSizeT
	{
		mediaMutex.acquire();

		final bytesRead:Int = mediaInput != null ? Util.readFromInput(mediaInput, untyped buf, cast len) : -1;

		mediaMutex.release();

		return bytesRead;
	}

	@:keep
	@:noCompletion
	@:unreflective
	private function mediaSeek(offset:cpp.UInt64):Int
	{
		mediaMutex.acquire();

		if (mediaInput != null)
		{
			mediaInput.position = cast offset;

			final result:Int = mediaInput.position >= mediaInput.length ? -1 : 0;

			mediaMutex.release();

			return result;
		}

		mediaMutex.release();

		return -1;
	}

	@:keep
	@:noCompletion
	@:unreflective
	private function videoLock(planes:cpp.RawPointer<cpp.RawPointer<cpp.Void>>):cpp.RawPointer<cpp.Void>
	{
		textureMutex.acquire();

		if (texturePlanes != null)
			planes[0] = untyped texturePlanes.getBase().getBase();

		return untyped nullptr;
	}

	@:keep
	@:noCompletion
	@:unreflective
	private function videoUnlock(planes:cpp.VoidStarConstStar):Void
	{
		textureMutex.release();
	}

	@:keep
	@:noCompletion
	@:unreflective
	private function videoDisplay(picture:cpp.RawPointer<cpp.Void>):Void
	{
		if (__renderable || forceRendering)
		{
			MainLoop.runInMainThread(function():Void
			{
				if (texturePlanes != null)
				{
					textureMutex.acquire();

					if (bitmapData != null && bitmapData.__texture != null)
						cast(bitmapData.__texture, openfl.display3D.textures.RectangleTexture)
							.uploadFromTypedArray(UInt8Array.fromBytes(Bytes.ofData(texturePlanes)));
					else if (bitmapData != null && bitmapData.image != null)
						bitmapData.setPixels(bitmapData.rect, Bytes.ofData(texturePlanes));

					if (__renderable)
						__setRenderDirty();

					if (onDisplay != null)
						onDisplay.dispatch();

					textureMutex.release();
				}
			});
		}
	}

	@:keep
	@:noCompletion
	@:unreflective
	private function videoFormatSetup(chroma:cpp.CastCharStar, width:cpp.RawPointer<cpp.UInt32>, height:cpp.RawPointer<cpp.UInt32>,
			pitches:cpp.RawPointer<cpp.UInt32>, lines:cpp.RawPointer<cpp.UInt32>):Int
	{
		textureMutex.acquire();

		cpp.Stdlib.nativeMemcpy(untyped chroma, untyped cpp.CastCharStar.fromString('RV32'), 4);

		final originalWidth:cpp.UInt32 = width[0];
		final originalHeight:cpp.UInt32 = height[0];

		if (mediaPlayer == null || LibVLC.video_get_size(mediaPlayer, 0, width, height) != 0)
		{
			width[0] = originalWidth;
			height[0] = originalHeight;
		}

		textureWidth = width[0];
		textureHeight = height[0];

		if (texturePlanes == null)
			texturePlanes = new BytesData();

		texturePlanes.resize(textureWidth * textureHeight * 4);

		pitches[0] = textureWidth * 4;
		lines[0] = textureHeight;

		textureMutex.release();

		MainLoop.runInMainThread(function():Void
		{
			final sizeMismatch:Bool = bitmapData != null && (bitmapData.width != textureWidth || bitmapData.height != textureHeight);
			final textureMismatch:Bool = bitmapData != null && bitmapData.__texture != null && !useTexture;
			final imageMismatch:Bool = bitmapData != null && bitmapData.image != null && useTexture;

			if (bitmapData == null || sizeMismatch || textureMismatch || imageMismatch)
			{
				textureMutex.acquire();

				if (bitmapData != null)
				{
					if (bitmapData.__texture != null)
						bitmapData.__texture.dispose();

					bitmapData.dispose();
				}

				bitmapData = new BitmapData(textureWidth, textureHeight, true, 0);

				if (useTexture)
				{
					@:nullSafety(Off)
					if (Lib.current.stage != null && Lib.current.stage.context3D != null)
					{
						bitmapData.disposeImage();
						bitmapData.__texture = Lib.current.stage.context3D.createRectangleTexture(bitmapData.width, bitmapData.height, BGRA, true);
						bitmapData.__textureContext = bitmapData.__texture.__textureContext;
						bitmapData.__surface = null;
						bitmapData.image = null;
					}
					else
						trace('Unable to utilize GPU texture, resorting to CPU-based image rendering.');
				}

				if (onFormatSetup != null)
					onFormatSetup.dispatch();

				textureMutex.release();
			}
		});

		return 1;
	}

	@:keep
	@:noCompletion
	@:unreflective
	private function audioPlay(samples:cpp.RawPointer<cpp.UInt8>, count:cpp.UInt32, pts:cpp.Int64):Void
	{
		#if lime_openal
		if (alSource != null && alBufferPool != null)
		{
			alMutex.acquire();

			final processedBuffers:Int = AL.getSourcei(alSource, AL.BUFFERS_PROCESSED);

			if (processedBuffers > 0)
			{
				for (alBuffer in AL.sourceUnqueueBuffers(alSource, processedBuffers))
					alBufferPool.push(alBuffer);
			}

			if (alBufferPool.length > 0)
			{
				final alBuffer:Null<ALBuffer> = alBufferPool.shift();

				if (alBuffer != null)
				{
					final alSamples:BytesData = new BytesData();

					alSamples.setUnmanagedData(cast samples, count);

					AL.bufferData(alBuffer, alFormat, UInt8Array.fromBytes(Bytes.ofData(alSamples)), alSamples.length * alFrameSize, alSampleRate);

					AL.sourceQueueBuffer(alSource, alBuffer);

					if (AL.getSourcei(alSource, AL.SOURCE_STATE) != AL.PLAYING)
						AL.sourcePlay(alSource);
				}
			}

			alMutex.release();
		}
		#end
	}

	@:keep
	@:noCompletion
	@:unreflective
	private function audioPause(pts:cpp.Int64):Void
	{
		#if lime_openal
		if (alSource != null)
		{
			alMutex.acquire();

			if (AL.getSourcei(alSource, AL.SOURCE_STATE) != AL.PAUSED)
				AL.sourcePause(alSource);

			alMutex.release();
		}
		#end
	}

	@:keep
	@:noCompletion
	@:unreflective
	private function audioFlush(pts:cpp.Int64):Void
	{
		#if lime_openal
		if (alSource != null)
		{
			alMutex.acquire();

			if (AL.getSourcei(alSource, AL.SOURCE_STATE) != AL.STOPPED)
				AL.sourceStop(alSource);

			alMutex.release();
		}
		#end
	}

	@:keep
	@:noCompletion
	@:unreflective
	private function audioSetup(format:cpp.CastCharStar, rate:cpp.RawPointer<cpp.UInt32>, channels:cpp.RawPointer<cpp.UInt32>):Int
	{
		#if lime_openal
		alMutex.acquire();

		cpp.Stdlib.nativeMemcpy(untyped format, untyped cpp.CastCharStar.fromString('S16N'), 4);

		alSampleRate = rate[0];

		var alChannelsToUse:cpp.UInt32 = channels[0];

		{
			if (alUseEXTMCFORMATS == true && alChannelsToUse > 8)
				alChannelsToUse = 8;
			else if (alChannelsToUse > 2)
				alChannelsToUse = 2;

			switch (alChannelsToUse)
			{
				case 1:
					alFormat = AL.FORMAT_MONO16;
					alChannelsToUse = 1;
					alFrameSize = cpp.Stdlib.sizeof(cpp.Int16) * alChannelsToUse;
				case 2 | 3:
					alFormat = AL.FORMAT_STEREO16;
					alChannelsToUse = 2;
					alFrameSize = cpp.Stdlib.sizeof(cpp.Int16) * alChannelsToUse;
				case 4:
					alFormat = AL.getEnumValue('AL_FORMAT_QUAD16');
					alChannelsToUse = 4;
					alFrameSize = cpp.Stdlib.sizeof(cpp.Int16) * alChannelsToUse;
				case 5 | 6:
					alFormat = AL.getEnumValue('AL_FORMAT_51CHN16');
					alChannelsToUse = 6;
					alFrameSize = cpp.Stdlib.sizeof(cpp.Int16) * alChannelsToUse;
				case 7 | 8:
					alFormat = AL.getEnumValue('AL_FORMAT_71CHN16');
					alChannelsToUse = 8;
					alFrameSize = cpp.Stdlib.sizeof(cpp.Int16) * alChannelsToUse;
			}
		}

		channels[0] = alChannelsToUse;

		alMutex.release();

		return 0;
		#else
		return 1;
		#end
	}

	@:keep
	@:noCompletion
	@:unreflective
	private function audioSetVolume(volume:Single, mute:Bool):Void {}

	@:keep
	@:noCompletion
	@:unreflective
	private function eventManagerCallbacks(p_event:cpp.RawConstPointer<LibVLC_Event_T>):Void
	{
		switch (p_event[0].type)
		{
			case event if (event == LibVLC_MediaPlayerOpening):
				MainLoop.runInMainThread(function():Void
				{
					if (onOpening != null)
						onOpening.dispatch();
				});
			case event if (event == LibVLC_MediaPlayerPlaying):
				MainLoop.runInMainThread(function():Void
				{
					if (onPlaying != null)
						onPlaying.dispatch();
				});
			case event if (event == LibVLC_MediaPlayerStopped):
				MainLoop.runInMainThread(function():Void
				{
					if (onStopped != null)
						onStopped.dispatch();
				});
			case event if (event == LibVLC_MediaPlayerPaused):
				MainLoop.runInMainThread(function():Void
				{
					if (onPaused != null)
						onPaused.dispatch();
				});
			case event if (event == LibVLC_MediaPlayerEndReached):
				MainLoop.runInMainThread(function():Void
				{
					if (onEndReached != null)
						onEndReached.dispatch();
				});
			case event if (event == LibVLC_MediaPlayerEncounteredError):
				final errmsg:String = LibVLC.errmsg();

				MainLoop.runInMainThread(function():Void
				{
					if (onEncounteredError != null)
					{
						if (errmsg != null && errmsg.length > 0)
							onEncounteredError.dispatch(errmsg);
						else
							onEncounteredError.dispatch('Unknown error');
					}
				});
			case event if (event == LibVLC_MediaPlayerCorked):
				MainLoop.runInMainThread(function():Void
				{
					if (onCorked != null)
						onCorked.dispatch();
				});
			case event if (event == LibVLC_MediaPlayerUncorked):
				MainLoop.runInMainThread(function():Void
				{
					if (onUncorked != null)
						onUncorked.dispatch();
				});
			case event if (event == LibVLC_MediaPlayerTimeChanged):
				final newTime:Int64 = untyped __cpp__('{0}.u.media_player_time_changed.new_time', p_event[0]);

				MainLoop.runInMainThread(function():Void
				{
					if (onTimeChanged != null)
						onTimeChanged.dispatch(newTime);
				});
			case event if (event == LibVLC_MediaPlayerPositionChanged):
				final newPosition:Single = untyped __cpp__('{0}.u.media_player_position_changed.new_position', p_event[0]);

				MainLoop.runInMainThread(function():Void
				{
					if (onPositionChanged != null)
						onPositionChanged.dispatch(newPosition);
				});
			case event if (event == LibVLC_MediaPlayerLengthChanged):
				final newLength:Int64 = untyped __cpp__('{0}.u.media_player_length_changed.new_length', p_event[0]);

				MainLoop.runInMainThread(function():Void
				{
					if (onLengthChanged != null)
						onLengthChanged.dispatch(newLength);
				});
			case event if (event == LibVLC_MediaPlayerChapterChanged):
				final newChapter:Int = untyped __cpp__('{0}.u.media_player_chapter_changed.new_chapter', p_event[0]);

				MainLoop.runInMainThread(function():Void
				{
					if (onChapterChanged != null)
						onChapterChanged.dispatch(newChapter);
				});
			case event if (event == LibVLC_MediaPlayerMediaChanged):
				MainLoop.runInMainThread(function():Void
				{
					if (onMediaChanged != null)
						onMediaChanged.dispatch();
				});
			case event if (event == LibVLC_MediaParsedChanged):
				final newStatus:Int = untyped __cpp__('{0}.u.media_parsed_changed.new_status', p_event[0]);

				MainLoop.runInMainThread(function():Void
				{
					if (onMediaParsedChanged != null)
						onMediaParsedChanged.dispatch(newStatus);
				});
			case event if (event == LibVLC_MediaMetaChanged):
				MainLoop.runInMainThread(function():Void
				{
					if (onMediaMetaChanged != null)
						onMediaMetaChanged.dispatch();
				});
		}
	}

	@:noCompletion
	@:unreflective
	private function getDescription(rawDescription:cpp.RawPointer<LibVLC_Track_Description_T>, description:Array<TrackDescription>):Void
	{
		var nextDescription:cpp.RawPointer<LibVLC_Track_Description_T> = rawDescription;

		while (nextDescription != null)
		{
			description.push(TrackDescription.fromTrackDescription(nextDescription[0]));

			nextDescription = nextDescription[0].p_next;
		}

		LibVLC.track_description_list_release(rawDescription);
	}

	@:noCompletion
	@:unreflective
	private function setMediaToPlayer(mediaItem:cpp.RawPointer<LibVLC_Media_T>, ?options:Array<String>):Void
	{
		if (mediaPlayer == null)
			return;

		if (options != null)
		{
			for (option in options)
			{
				if (option != null && option.length > 0)
					LibVLC.media_add_option(mediaItem, option);
			}
		}

		LibVLC.media_player_set_media(mediaPlayer, mediaItem);

		LibVLC.media_release(mediaItem);
	}

	@:noCompletion
	@:unreflective
	private function setupVideo():Void
	{
		if (mediaPlayer == null)
			return;

		LibVLC.video_set_callbacks(mediaPlayer, untyped __cpp__('video_lock'), untyped __cpp__('video_unlock'), untyped __cpp__('video_display'),
			untyped __cpp__('this'));
		LibVLC.video_set_format_callbacks(mediaPlayer, untyped __cpp__('video_format_setup'), untyped NULL);
	}

	@:noCompletion
	@:unreflective
	private function setupAudio():Void
	{
		if (mediaPlayer == null)
			return;

		#if lime_openal
		if (alUseEXTMCFORMATS == null)
			alUseEXTMCFORMATS = AL.isExtensionPresent('AL_EXT_MCFORMATS');

		if (alSource == null)
			alSource = AL.createSource();

		if (alBufferPool == null)
			alBufferPool = AL.genBuffers(MAX_AUDIO_BUFFER_COUNT);
		#end

		LibVLC.audio_set_callbacks(mediaPlayer, untyped __cpp__('audio_play'), untyped __cpp__('audio_pause'), untyped NULL, untyped __cpp__('audio_flush'),
			untyped NULL, untyped __cpp__('this'));
		LibVLC.audio_set_volume_callback(mediaPlayer, untyped __cpp__('audio_set_volume'));
		LibVLC.audio_set_format_callbacks(mediaPlayer, untyped __cpp__('audio_setup'), untyped NULL);
	}

	@:noCompletion
	@:unreflective
	private function setupEvents():Void
	{
		if (mediaPlayer != null)
		{
			final eventManager:cpp.RawPointer<LibVLC_Event_Manager_T> = LibVLC.media_player_event_manager(mediaPlayer);

			if (eventManager != null)
			{
				addEvent(eventManager, LibVLC_MediaPlayerOpening);
				addEvent(eventManager, LibVLC_MediaPlayerPlaying);
				addEvent(eventManager, LibVLC_MediaPlayerStopped);
				addEvent(eventManager, LibVLC_MediaPlayerPaused);
				addEvent(eventManager, LibVLC_MediaPlayerEndReached);
				addEvent(eventManager, LibVLC_MediaPlayerEncounteredError);
				addEvent(eventManager, LibVLC_MediaPlayerMediaChanged);
				addEvent(eventManager, LibVLC_MediaPlayerCorked);
				addEvent(eventManager, LibVLC_MediaPlayerUncorked);
				addEvent(eventManager, LibVLC_MediaPlayerTimeChanged);
				addEvent(eventManager, LibVLC_MediaPlayerPositionChanged);
				addEvent(eventManager, LibVLC_MediaPlayerLengthChanged);
				addEvent(eventManager, LibVLC_MediaPlayerChapterChanged);
			}
			else
				trace('Unable to initialize the LibVLC media player event manager.');
		}
	}

	@:noCompletion
	@:unreflective
	private function addEvent(eventManager:cpp.RawPointer<LibVLC_Event_Manager_T>, type:LibVLC_Event_E):Void
	{
		if (LibVLC.event_attach(eventManager, type, untyped __cpp__('event_manager_callbacks'), untyped __cpp__('this')) != 0)
			trace('Failed to attach event (${LibVLC.event_type_name(type)})');
	}
}
