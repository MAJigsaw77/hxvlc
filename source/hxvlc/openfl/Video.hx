package hxvlc.openfl;

import cpp.CastCharStar;
import cpp.Float32;
import cpp.Int16;
import cpp.Pointer;
import cpp.RawConstPointer;
import cpp.RawPointer;
import cpp.SSizeT;
import cpp.SizeT;
import cpp.Stdlib;
import cpp.UInt32;
import cpp.UInt64;
import cpp.UInt8;
import cpp.VoidStarConstStar;
import cpp.vm.Gc;

import haxe.Int64;
import haxe.io.Bytes;
import haxe.io.BytesData;
import haxe.io.BytesInput;

import hxvlc.externs.LibVLC;
import hxvlc.externs.Types;
import hxvlc.openfl.textures.VideoTexture;
import hxvlc.util.Handle;
import hxvlc.util.MainLoop;
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

static void audio_resume(void *data, int64_t pts)
{
	if (data)
	{
		hx::SetTopOfStack((int *)99, true);

		reinterpret_cast<Video_obj *>(data)->audioResume(pts);

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

	/** Length of the media in miliseconds. */
	public var length(get, never):Int64;

	/** Current time position in the media in miliseconds. */
	public var time(get, set):Int64;

	/** Current playback position as a percentage (0.0 to 1.0). */
	public var position(get, set):Single;

	/** Current chapter of the video. */
	public var chapter(get, set):Int;

	/** Total number of chapters in the video. */
	public var chapterCount(get, never):Int;

	/** Playback rate of the video. */
	public var rate(get, set):Single;

	/** Frame rate of the video. */
	public var fps(get, never):Float;

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

	/** Event triggered when a new Elementary Stream (ES) is added. */
	public var onESAdded(default, null):Event<Int->Int->Void> = new Event<Int->Int->Void>();

	/** Event triggered when an Elementary Stream (ES) is deleted. */
	public var onESDeleted(default, null):Event<Int->Int->Void> = new Event<Int->Int->Void>();

	/** Event triggered when an Elementary Stream (ES) is selected. */
	public var onESSelected(default, null):Event<Int->Int->Void> = new Event<Int->Int->Void>();

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
	private var mediaPlayer:Null<Pointer<LibVLC_Media_Player_T>>;

	@:noCompletion
	private var textureWidth:UInt32 = 0;

	@:noCompletion
	private var textureHeight:UInt32 = 0;

	@:noCompletion
	private var texturePlanes:Null<BytesData>;

	#if lime_openal
	@:noCompletion
	private var alUseEXTFLOAT32:Null<Bool>;

	@:noCompletion
	private var alUseEXTMCFORMATS:Null<Bool>;

	@:noCompletion
	private var alSource:Null<ALSource>;

	@:noCompletion
	private var alBufferPool:Null<Array<ALBuffer>>;

	@:noCompletion
	private var alSamples:Null<BytesData>;

	@:noCompletion
	private var alSampleRate:UInt32 = 0;

	@:noCompletion
	private var alFormat:Int = 0;

	@:noCompletion
	private var alFrameSize:UInt32 = 0;
	#end

	/**
	 * Initializes a Video object.
	 * 
	 * @param smoothing Whether or not the object is smoothed when scaled.
	 */
	public function new(smoothing:Bool = true):Void
	{
		super(null, AUTO, smoothing);

		{
			while (Handle.loading)
				Sys.sleep(0.05);

			Handle.init();
		}

		Gc.doNotKill(this);
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

		var mediaItem:Pointer<LibVLC_Media_T>;

		if (location != null)
		{
			if ((location is String))
			{
				final location:String = cast(location, String);

				if (URL_VERIFICATION_REGEX.match(location))
					mediaItem = Pointer.fromRaw(LibVLC.media_new_location(Handle.instance.raw, location));
				else
					mediaItem = Pointer.fromRaw(LibVLC.media_new_path(Handle.instance.raw, Util.normalizePath(location)));
			}
			else if ((location is Int))
			{
				mediaItem = Pointer.fromRaw(LibVLC.media_new_fd(Handle.instance.raw, cast(location, Int)));
			}
			else if ((location is Bytes))
			{
				mediaMutex.acquire();

				mediaInput = new BytesInput(cast(location, Bytes));

				mediaItem = Pointer.fromRaw(LibVLC.media_new_callbacks(Handle.instance.raw, untyped media_open, untyped media_read, untyped media_seek,
					untyped NULL, untyped __cpp__('this')));

				mediaMutex.release();
			}
			else
				return false;
		}
		else
			return false;

		if (mediaPlayer == null)
		{
			mediaPlayer = Pointer.fromRaw(LibVLC.media_player_new(Handle.instance.raw));

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
			final currentMediaItem:Pointer<LibVLC_Media_T> = Pointer.fromRaw(LibVLC.media_player_get_media(mediaPlayer.raw));

			if (currentMediaItem != null)
			{
				final currentMediaSubItems:Pointer<LibVLC_Media_List_T> = Pointer.fromRaw(LibVLC.media_subitems(currentMediaItem.raw));

				if (currentMediaSubItems != null)
				{
					final count:Int = LibVLC.media_list_count(currentMediaSubItems.raw);

					if (index >= 0 && index < count)
					{
						final mediaSubItem:Pointer<LibVLC_Media_T> = Pointer.fromRaw(LibVLC.media_list_item_at_index(currentMediaSubItems.raw, index));

						if (mediaSubItem != null)
						{
							setMediaToPlayer(mediaSubItem, options);

							LibVLC.media_list_release(currentMediaSubItems.raw);

							return true;
						}
					}

					LibVLC.media_list_release(currentMediaSubItems.raw);
				}

				LibVLC.media_release(currentMediaItem.raw);
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
			final currentMediaItem:Pointer<LibVLC_Media_T> = Pointer.fromRaw(LibVLC.media_player_get_media(mediaPlayer.raw));

			if (currentMediaItem != null)
			{
				final eventManager:Pointer<LibVLC_Event_Manager_T> = Pointer.fromRaw(LibVLC.media_event_manager(currentMediaItem.raw));

				if (eventManager != null)
				{
					addEvent(eventManager, LibVLC_MediaParsedChanged);
					addEvent(eventManager, LibVLC_MediaMetaChanged);
				}
				else
					trace('Unable to initialize the LibVLC media event manager.');

				final result:Bool = LibVLC.media_parse_with_options(currentMediaItem.raw, parse_flag, timeout) == 0;

				LibVLC.media_release(currentMediaItem.raw);

				return result;
			}
		}

		return false;
	}

	/** Stops parsing the current media item. */
	public function parseStop():Void
	{
		if (mediaPlayer != null)
		{
			final currentMediaItem:Pointer<LibVLC_Media_T> = Pointer.fromRaw(LibVLC.media_player_get_media(mediaPlayer.raw));

			if (currentMediaItem != null)
			{
				LibVLC.media_parse_stop(currentMediaItem.raw);
				LibVLC.media_release(currentMediaItem.raw);
			}
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
		return mediaPlayer != null && LibVLC.media_player_add_slave(mediaPlayer.raw, type, url, select) == 0;
	}

	/**
	 * Gets the description of available audio tracks of the current media player.
	 * 
	 * @return The list containing descriptions of available audio tracks.
	 */
	public function getVideoDescription():Array<TrackDescription>
	{
		final description:Array<TrackDescription> = [];

		if (mediaPlayer != null)
		{
			final rawDescription:Pointer<LibVLC_Track_Description_T> = Pointer.fromRaw(LibVLC.video_get_track_description(mediaPlayer.raw));

			if (rawDescription != null)
				getDescription(rawDescription, description);
		}

		return description;
	}

	/**
	 * Gets the description of available audio tracks of the current media player.
	 * 
	 * @return The list containing descriptions of available audio tracks.
	 */
	public function getAudioDescription():Array<TrackDescription>
	{
		final description:Array<TrackDescription> = [];

		if (mediaPlayer != null)
		{
			final rawDescription:Pointer<LibVLC_Track_Description_T> = Pointer.fromRaw(LibVLC.audio_get_track_description(mediaPlayer.raw));

			if (rawDescription != null)
				getDescription(rawDescription, description);
		}

		return description;
	}

	/**
	 * Gets the description of available available video subtitles of the current media player.
	 * 
	 * @return The list containing descriptions of available available video subtitles.
	 */
	public function getSpuDescription():Array<TrackDescription>
	{
		final description:Array<TrackDescription> = [];

		if (mediaPlayer != null)
		{
			final rawDescription:Pointer<LibVLC_Track_Description_T> = Pointer.fromRaw(LibVLC.video_get_spu_description(mediaPlayer.raw));

			if (rawDescription != null)
				getDescription(rawDescription, description);
		}

		return description;
	}

	/**
	 * Starts playback.
	 * 
	 * @return `true` if playback started successfully, `false` otherwise.
	 */
	public function play():Bool
	{
		return mediaPlayer != null && LibVLC.media_player_play(mediaPlayer.raw) == 0;
	}

	/** Stops playback. */
	public function stop():Void
	{
		if (mediaPlayer != null)
			LibVLC.media_player_stop(mediaPlayer.raw);
	}

	/** Pauses playback. */
	public function pause():Void
	{
		if (mediaPlayer != null)
			LibVLC.media_player_set_pause(mediaPlayer.raw, 1);
	}

	/** Resumes playback. */
	public function resume():Void
	{
		if (mediaPlayer != null)
			LibVLC.media_player_set_pause(mediaPlayer.raw, 0);
	}

	/** Toggles the pause state. */
	public function togglePaused():Void
	{
		if (mediaPlayer != null)
			LibVLC.media_player_pause(mediaPlayer.raw);
	}

	/** Moves to the previous chapter, if supported. */
	public function previousChapter():Void
	{
		if (mediaPlayer != null)
			LibVLC.media_player_previous_chapter(mediaPlayer.raw);
	}

	/** Moves to the next chapter, if supported. */
	public function nextChapter():Void
	{
		if (mediaPlayer != null)
			LibVLC.media_player_next_chapter(mediaPlayer.raw);
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
			final currentMediaItem:Pointer<LibVLC_Media_T> = Pointer.fromRaw(LibVLC.media_player_get_media(mediaPlayer.raw));

			if (currentMediaItem != null)
			{
				final rawMeta:CastCharStar = LibVLC.media_get_meta(currentMediaItem.raw, e_meta);

				if (rawMeta != null)
				{
					final meta:String = new String(untyped rawMeta);

					LibVLC.media_release(currentMediaItem.raw);

					return meta;
				}
				else
					LibVLC.media_release(currentMediaItem.raw);
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
			final currentMediaItem:Pointer<LibVLC_Media_T> = Pointer.fromRaw(LibVLC.media_player_get_media(mediaPlayer.raw));

			if (currentMediaItem != null)
			{
				LibVLC.media_set_meta(currentMediaItem.raw, e_meta, value);
				LibVLC.media_release(currentMediaItem.raw);
			}
		}
	}

	/**
	 * Saves the metadata of the current media item.
	 * 
	 * @return `true` if the metadata was saved successfully, `false` otherwise.
	 */
	public function saveMeta():Bool
	{
		if (mediaPlayer != null)
		{
			final currentMediaItem:Pointer<LibVLC_Media_T> = Pointer.fromRaw(LibVLC.media_player_get_media(mediaPlayer.raw));

			if (currentMediaItem != null)
			{
				final result:Bool = LibVLC.media_save_meta(currentMediaItem.raw) != 0;

				LibVLC.media_release(currentMediaItem.raw);

				return result;
			}
		}

		return false;
	}

	/** Frees the memory that is used to store the Video object. */
	public function dispose():Void
	{
		if (mediaPlayer != null)
		{
			LibVLC.media_player_release(mediaPlayer.raw);
			mediaPlayer = null;
		}

		mediaMutex.acquire();

		mediaInput = null;

		{
			mediaMutex.release();
		}

		textureMutex.acquire();

		{
			if (bitmapData != null)
			{
				if (bitmapData.__texture != null)
					bitmapData.__texture.dispose();

				bitmapData.dispose();
			}

			textureWidth = 0;
			textureHeight = 0;
			texturePlanes = null;
		}

		textureMutex.release();

		#if lime_openal
		alMutex.acquire();

		{
			if (alSource != null)
			{
				if (AL.getSourcei(alSource, AL.SOURCE_STATE) != AL.STOPPED)
					AL.sourceStop(alSource);

				for (alBuffer in AL.sourceUnqueueBuffers(alSource, AL.getSourcei(alSource, AL.BUFFERS_QUEUED)))
					AL.deleteBuffer(alBuffer);

				AL.deleteSource(alSource);
				alSource = null;
			}

			if (alBufferPool != null)
			{
				AL.deleteBuffers(alBufferPool);
				alBufferPool = null;
			}
		}

		alMutex.release();
		#end
	}

	@:noCompletion
	private function get_mrl():Null<String>
	{
		if (mediaPlayer != null)
		{
			final currentMediaItem:Pointer<LibVLC_Media_T> = Pointer.fromRaw(LibVLC.media_player_get_media(mediaPlayer.raw));

			if (currentMediaItem != null)
			{
				final rawMrl:CastCharStar = LibVLC.media_get_mrl(currentMediaItem.raw);

				if (rawMrl != null)
				{
					final mrl:String = new String(untyped rawMrl);

					LibVLC.media_release(currentMediaItem.raw);

					return mrl;
				}
				else
					LibVLC.media_release(currentMediaItem.raw);
			}
		}

		return null;
	}

	@:noCompletion
	private function get_stats():Null<Stats>
	{
		if (mediaPlayer != null)
		{
			final currentMediaItem:Pointer<LibVLC_Media_T> = Pointer.fromRaw(LibVLC.media_player_get_media(mediaPlayer.raw));

			if (currentMediaItem != null)
			{
				final currentMediaStats:LibVLC_Media_Stats_T = new LibVLC_Media_Stats_T();

				if (LibVLC.media_get_stats(currentMediaItem.raw, Pointer.addressOf(currentMediaStats).raw) != 0)
				{
					final stats:Stats = Stats.fromMediaStats(currentMediaStats);

					LibVLC.media_release(currentMediaItem.raw);

					return stats;
				}
				else
					LibVLC.media_release(currentMediaItem.raw);
			}
		}

		return null;
	}

	@:noCompletion
	private function get_duration():Int64
	{
		if (mediaPlayer != null)
		{
			final currentMediaItem:Pointer<LibVLC_Media_T> = Pointer.fromRaw(LibVLC.media_player_get_media(mediaPlayer.raw));

			if (currentMediaItem != null)
			{
				final duration:Int64 = LibVLC.media_get_duration(currentMediaItem.raw);

				LibVLC.media_release(currentMediaItem.raw);

				return duration;
			}
		}

		return -1;
	}

	@:noCompletion
	private function get_isPlaying():Bool
	{
		return mediaPlayer != null && LibVLC.media_player_is_playing(mediaPlayer.raw) != 0;
	}

	@:noCompletion
	private function get_length():Int64
	{
		return mediaPlayer != null ? LibVLC.media_player_get_length(mediaPlayer.raw) : -1;
	}

	@:noCompletion
	private function get_time():Int64
	{
		return mediaPlayer != null ? LibVLC.media_player_get_time(mediaPlayer.raw) : -1;
	}

	@:noCompletion
	private function set_time(value:Int64):Int64
	{
		if (mediaPlayer != null)
			LibVLC.media_player_set_time(mediaPlayer.raw, value);

		return value;
	}

	@:noCompletion
	private function get_position():Single
	{
		return mediaPlayer != null ? LibVLC.media_player_get_position(mediaPlayer.raw) : -1.0;
	}

	@:noCompletion
	private function set_position(value:Single):Single
	{
		if (mediaPlayer != null)
			LibVLC.media_player_set_position(mediaPlayer.raw, value);

		return value;
	}

	@:noCompletion
	private function get_chapter():Int
	{
		return mediaPlayer != null ? LibVLC.media_player_get_chapter(mediaPlayer.raw) : -1;
	}

	@:noCompletion
	private function set_chapter(value:Int):Int
	{
		if (mediaPlayer != null)
			LibVLC.media_player_set_chapter(mediaPlayer.raw, value);

		return value;
	}

	@:noCompletion
	private function get_chapterCount():Int
	{
		return mediaPlayer != null ? LibVLC.media_player_get_chapter_count(mediaPlayer.raw) : -1;
	}

	@:noCompletion
	private function get_rate():Single
	{
		return mediaPlayer != null ? LibVLC.media_player_get_rate(mediaPlayer.raw) : 1;
	}

	@:noCompletion
	private function set_rate(value:Single):Single
	{
		if (mediaPlayer != null)
			LibVLC.media_player_set_rate(mediaPlayer.raw, value);

		return value;
	}

	@:noCompletion
	private function get_fps():Float
	{
		if (mediaPlayer != null)
		{
			final currentMediaItem:Pointer<LibVLC_Media_T> = Pointer.fromRaw(LibVLC.media_player_get_media(mediaPlayer.raw));

			if (currentMediaItem != null)
			{
				final tracks:RawPointer<RawPointer<LibVLC_Media_Track_T>> = untyped nullptr;

				final count:UInt32 = LibVLC.media_tracks_get(currentMediaItem.raw, Pointer.addressOf(tracks).raw);

				for (i in 0...count)
				{
					final track:RawPointer<LibVLC_Media_Track_T> = tracks[i];

					if (track[0].i_type != LibVLC_Track_Video || LibVLC.video_get_track(mediaPlayer.raw) != track[0].i_id)
						continue;

					if (track[0].video[0].i_frame_rate_num > 0 && track[0].video[0].i_frame_rate_den > 0)
					{
						final fps:Float = track[0].video[0].i_frame_rate_num / track[0].video[0].i_frame_rate_den;

						LibVLC.media_tracks_release(tracks, count);

						LibVLC.media_release(currentMediaItem.raw);

						return fps;
					}

					break;
				}

				LibVLC.media_tracks_release(tracks, count);

				LibVLC.media_release(currentMediaItem.raw);
			}
		}

		return 0.0;
	}

	@:noCompletion
	private function get_isSeekable():Bool
	{
		return mediaPlayer != null && LibVLC.media_player_is_seekable(mediaPlayer.raw) != 0;
	}

	@:noCompletion
	private function get_canPause():Bool
	{
		return mediaPlayer != null && LibVLC.media_player_can_pause(mediaPlayer.raw) != 0;
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
		return mediaPlayer != null ? LibVLC.media_player_get_role(mediaPlayer.raw) : 0;
	}

	@:noCompletion
	private function set_role(value:UInt):UInt
	{
		if (mediaPlayer != null)
			LibVLC.media_player_set_role(mediaPlayer.raw, value);

		return value;
	}

	@:noCompletion
	private function get_videoTrackCount():Int
	{
		return mediaPlayer != null ? LibVLC.video_get_track_count(mediaPlayer.raw) : -1;
	}

	@:noCompletion
	private function get_videoTrack():Int
	{
		return mediaPlayer != null ? LibVLC.video_get_track(mediaPlayer.raw) : -1;
	}

	@:noCompletion
	private function set_videoTrack(value:Int):Int
	{
		if (mediaPlayer != null)
			LibVLC.video_set_track(mediaPlayer.raw, value);

		return value;
	}

	@:noCompletion
	private function get_audioTrackCount():Int
	{
		return mediaPlayer != null ? LibVLC.audio_get_track_count(mediaPlayer.raw) : -1;
	}

	@:noCompletion
	private function get_audioTrack():Int
	{
		return mediaPlayer != null ? LibVLC.audio_get_track(mediaPlayer.raw) : -1;
	}

	@:noCompletion
	private function set_audioTrack(value:Int):Int
	{
		if (mediaPlayer != null)
			LibVLC.audio_set_track(mediaPlayer.raw, value);

		return value;
	}

	@:noCompletion
	private function get_audioDelay():Int64
	{
		return mediaPlayer != null ? LibVLC.audio_get_delay(mediaPlayer.raw) : 0;
	}

	@:noCompletion
	private function set_audioDelay(value:Int64):Int64
	{
		if (mediaPlayer != null)
			LibVLC.audio_set_delay(mediaPlayer.raw, value);

		return value;
	}

	@:noCompletion
	private function get_spuTrackCount():Int
	{
		return mediaPlayer != null ? LibVLC.video_get_spu_count(mediaPlayer.raw) : -1;
	}

	@:noCompletion
	private function get_spuTrack():Int
	{
		return mediaPlayer != null ? LibVLC.video_get_spu(mediaPlayer.raw) : -1;
	}

	@:noCompletion
	private function set_spuTrack(value:Int):Int
	{
		if (mediaPlayer != null)
			LibVLC.video_set_spu(mediaPlayer.raw, value);

		return value;
	}

	@:noCompletion
	private function get_spuDelay():Int64
	{
		return mediaPlayer != null ? LibVLC.video_get_spu_delay(mediaPlayer.raw) : 0;
	}

	@:noCompletion
	private function set_spuDelay(value:Int64):Int64
	{
		if (mediaPlayer != null)
			LibVLC.video_set_spu_delay(mediaPlayer.raw, value);

		return value;
	}

	@:noCompletion
	private override function set_bitmapData(value:BitmapData):BitmapData
	{
		__bitmapData = value;

		__setRenderDirty();

		__imageVersion = -1;

		return __bitmapData;
	}

	@:keep
	@:noCompletion
	@:noDebug
	@:unreflective
	private function mediaOpen(sizep:RawPointer<UInt64>):Int
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
	@:noDebug
	@:unreflective
	private function mediaRead(buf:RawPointer<UInt8>, len:SizeT):SSizeT
	{
		mediaMutex.acquire();

		final bytesRead:Int = mediaInput != null ? Util.readFromInput(mediaInput, Pointer.fromRaw(buf), cast len) : -1;

		mediaMutex.release();

		return bytesRead;
	}

	@:keep
	@:noCompletion
	@:noDebug
	@:unreflective
	private function mediaSeek(offset:UInt64):Int
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
	@:noDebug
	@:unreflective
	private function videoLock(planes:RawPointer<RawPointer<cpp.Void>>):RawPointer<cpp.Void>
	{
		textureMutex.acquire();

		if (texturePlanes != null)
			planes[0] = untyped texturePlanes.getBase().getBase();

		return untyped nullptr;
	}

	@:keep
	@:noCompletion
	@:noDebug
	@:unreflective
	private function videoUnlock(planes:VoidStarConstStar):Void
	{
		textureMutex.release();
	}

	@:keep
	@:noCompletion
	@:noDebug
	@:unreflective
	private function videoDisplay(picture:RawPointer<cpp.Void>):Void
	{
		if ((__renderable || forceRendering) && bitmapData != null)
		{
			if (bitmapData.image != null && bitmapData.readable)
				updateImage();
			else
				updateTexture();
		}
	}

	@:keep
	@:noCompletion
	@:noDebug
	@:unreflective
	private function videoFormatSetup(chroma:CastCharStar, width:RawPointer<UInt32>, height:RawPointer<UInt32>, pitches:RawPointer<UInt32>,
			lines:RawPointer<UInt32>):Int
	{
		textureMutex.acquire();

		Stdlib.nativeMemcpy(untyped chroma, untyped cpp.CastCharStar.fromString('RV32'), 4);

		final originalWidth:UInt32 = width[0];
		final originalHeight:UInt32 = height[0];

		// The width and height passed from VLC are the buffer size rather than
		// the correct video display size, and may be the next multiple of 32
		// up from the original dimension, e.g. 1080 would become 1088. VLC 4.0
		// will pass the correct display size in *(width+1) and *(height+1) but
		// for now we need to calculate it ourselves.
		if (!calculateVideoSize(Pointer.fromRaw(width), Pointer.fromRaw(height)))
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
			if (!isValid())
				return;

			textureMutex.acquire();

			final sizeMismatch:Bool = bitmapData != null && (bitmapData.width != textureWidth || bitmapData.height != textureHeight);
			final textureMismatch:Bool = bitmapData != null && bitmapData.__texture != null && !useTexture;
			final imageMismatch:Bool = bitmapData != null && bitmapData.image != null && useTexture;

			if (bitmapData == null || sizeMismatch || textureMismatch || imageMismatch)
			{
				if (bitmapData != null)
				{
					if (bitmapData.__texture != null)
						bitmapData.__texture.dispose();

					bitmapData.dispose();
				}

				bitmapData = new BitmapData(textureWidth, textureHeight, true, 0);

				{
					@:privateAccess
					if (useTexture)
					{
						@:nullSafety(Off)
						if (Lib.current.stage?.context3D != null)
						{
							bitmapData.disposeImage();

							{
								bitmapData.__texture = new VideoTexture(Lib.current.stage.context3D, bitmapData, textureWidth * textureHeight * 4);
								bitmapData.__textureContext = bitmapData.__texture.__textureContext;
								bitmapData.__surface = null;
							}

							bitmapData.image = null;
						}
						else
							trace('Unable to utilize GPU texture, resorting to CPU-based image rendering.');
					}
				}

				if (onFormatSetup != null)
					onFormatSetup.dispatch();
			}

			textureMutex.release();
		});

		return 1;
	}

	@:keep
	@:noCompletion
	@:noDebug
	@:unreflective
	private function audioPlay(samples:RawPointer<UInt8>, count:UInt32, pts:Int64):Void
	{
		#if lime_openal
		if (alSource != null && alBufferPool != null)
		{
			alMutex.acquire();

			for (alBuffer in AL.sourceUnqueueBuffers(alSource, AL.getSourcei(alSource, AL.BUFFERS_PROCESSED)))
				alBufferPool.push(alBuffer);

			final alBuffer:Null<ALBuffer> = alBufferPool.shift();

			if (alBuffer == null)
			{
				alMutex.release();
				return;
			}

			if (alSamples == null)
				alSamples = new BytesData();

			alSamples.setUnmanagedData(cast samples, count);

			alMutex.release();

			AL.bufferData(alBuffer, alFormat, UInt8Array.fromBytes(Bytes.ofData(alSamples)), alSamples.length * alFrameSize, alSampleRate);

			AL.sourceQueueBuffer(alSource, alBuffer);

			if (AL.getSourcei(alSource, AL.SOURCE_STATE) != AL.PLAYING)
				AL.sourcePlay(alSource);
		}
		#end
	}

	@:keep
	@:noCompletion
	@:noDebug
	@:unreflective
	private function audioResume(pts:Int64):Void
	{
		#if lime_openal
		if (alSource != null)
		{
			alMutex.acquire();

			if (AL.getSourcei(alSource, AL.SOURCE_STATE) == AL.PAUSED)
				AL.sourcePlay(alSource);

			alMutex.release();
		}
		#end
	}

	@:keep
	@:noCompletion
	@:noDebug
	@:unreflective
	private function audioPause(pts:Int64):Void
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
	@:noDebug
	@:unreflective
	private function audioFlush(pts:Int64):Void
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
	@:noDebug
	@:unreflective
	private function audioSetup(format:CastCharStar, rate:RawPointer<UInt32>, channels:RawPointer<UInt32>):Int
	{
		#if lime_openal
		alMutex.acquire();

		alSampleRate = rate[0];

		if (alSamples == null)
			alSamples = new BytesData();

		if (alUseEXTFLOAT32 == null)
			alUseEXTFLOAT32 = AL.isExtensionPresent('AL_EXT_FLOAT32');

		if (alUseEXTMCFORMATS == null)
			alUseEXTMCFORMATS = AL.isExtensionPresent('AL_EXT_MCFORMATS');

		var alChannelsToUse:Int = channels[0];

		if (alUseEXTMCFORMATS == true && alChannelsToUse > 8)
			alChannelsToUse = 8;
		else if (alChannelsToUse > 2)
			alChannelsToUse = 2;

		{
			final useFloat32:Bool = alUseEXTFLOAT32 == true && (new String(untyped format) == 'FL32');

			Stdlib.nativeMemcpy(untyped format, untyped cpp.CastCharStar.fromString(useFloat32 ? 'FL32' : 'S16N'), 4);

			switch (alChannelsToUse)
			{
				case 1:
					alFormat = AL.getEnumValue(useFloat32 ? 'AL_FORMAT_MONO_FLOAT32' : 'AL_FORMAT_MONO16');
					alChannelsToUse = 1;
				case 2 | 3:
					alFormat = AL.getEnumValue(useFloat32 ? 'AL_FORMAT_STEREO_FLOAT32' : 'AL_FORMAT_STEREO16');
					alChannelsToUse = 2;
				case 4:
					alFormat = AL.getEnumValue(useFloat32 ? 'AL_FORMAT_QUAD32' : 'AL_FORMAT_QUAD16');
					alChannelsToUse = 4;
				case 5 | 6:
					alFormat = AL.getEnumValue(useFloat32 ? 'AL_FORMAT_51CHN32' : 'AL_FORMAT_51CHN16');
					alChannelsToUse = 6;
				case 7 | 8:
					alFormat = AL.getEnumValue(useFloat32 ? 'AL_FORMAT_71CHN32' : 'AL_FORMAT_71CHN16');
					alChannelsToUse = 8;
			}

			alFrameSize = (useFloat32 ? Stdlib.sizeof(Float32) : Stdlib.sizeof(Int16)) * alChannelsToUse;
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
	@:noDebug
	@:unreflective
	private function audioSetVolume(volume:Single, mute:Bool):Void {}

	@:keep
	@:noCompletion
	@:noDebug
	@:unreflective
	private function eventManagerCallbacks(p_event:RawConstPointer<LibVLC_Event_T>):Void
	{
		switch (p_event[0].type)
		{
			case event if (event == LibVLC_MediaPlayerOpening):
				MainLoop.runInMainThread(function():Void
				{
					if (isValid() && onOpening != null)
						onOpening.dispatch();
				});
			case event if (event == LibVLC_MediaPlayerPlaying):
				MainLoop.runInMainThread(function():Void
				{
					if (isValid() && onPlaying != null)
						onPlaying.dispatch();
				});
			case event if (event == LibVLC_MediaPlayerStopped):
				MainLoop.runInMainThread(function():Void
				{
					if (isValid() && onStopped != null)
						onStopped.dispatch();
				});
			case event if (event == LibVLC_MediaPlayerPaused):
				MainLoop.runInMainThread(function():Void
				{
					if (isValid() && onPaused != null)
						onPaused.dispatch();
				});
			case event if (event == LibVLC_MediaPlayerEndReached):
				MainLoop.runInMainThread(function():Void
				{
					if (isValid() && onEndReached != null)
						onEndReached.dispatch();
				});
			case event if (event == LibVLC_MediaPlayerEncounteredError):
				final errmsg:String = LibVLC.errmsg();

				MainLoop.runInMainThread(function():Void
				{
					if (isValid() && onEncounteredError != null)
					{
						if (errmsg != null && errmsg.length > 0)
							onEncounteredError.dispatch(errmsg);
						else
							onEncounteredError.dispatch('Unknown error');
					}
				});
			case event if (event == LibVLC_MediaPlayerESAdded):
				final iType:LibVLC_Track_Type = untyped __cpp__('{0}.u.media_player_es_changed.i_type', p_event[0]);
				final iID:Int = untyped __cpp__('{0}.u.media_player_es_changed.i_id', p_event[0]);

				MainLoop.runInMainThread(function():Void
				{
					if (isValid() && onESAdded != null)
						onESAdded.dispatch((iType : Int), iID);
				});
			case event if (event == LibVLC_MediaPlayerESDeleted):
				final iType:LibVLC_Track_Type = untyped __cpp__('{0}.u.media_player_es_changed.i_type', p_event[0]);
				final iID:Int = untyped __cpp__('{0}.u.media_player_es_changed.i_id', p_event[0]);

				MainLoop.runInMainThread(function():Void
				{
					if (isValid() && onESDeleted != null)
						onESDeleted.dispatch((iType : Int), iID);
				});
			case event if (event == LibVLC_MediaPlayerESSelected):
				final iType:LibVLC_Track_Type = untyped __cpp__('{0}.u.media_player_es_changed.i_type', p_event[0]);
				final iID:Int = untyped __cpp__('{0}.u.media_player_es_changed.i_id', p_event[0]);

				MainLoop.runInMainThread(function():Void
				{
					if (isValid() && onESSelected != null)
						onESSelected.dispatch((iType : Int), iID);
				});
			case event if (event == LibVLC_MediaPlayerCorked):
				MainLoop.runInMainThread(function():Void
				{
					if (isValid() && onCorked != null)
						onCorked.dispatch();
				});
			case event if (event == LibVLC_MediaPlayerUncorked):
				MainLoop.runInMainThread(function():Void
				{
					if (isValid() && onUncorked != null)
						onUncorked.dispatch();
				});
			case event if (event == LibVLC_MediaPlayerTimeChanged):
				final newTime:Int64 = untyped __cpp__('{0}.u.media_player_time_changed.new_time', p_event[0]);

				MainLoop.runInMainThread(function():Void
				{
					if (isValid() && onTimeChanged != null)
						onTimeChanged.dispatch(newTime);
				});
			case event if (event == LibVLC_MediaPlayerPositionChanged):
				final newPosition:Single = untyped __cpp__('{0}.u.media_player_position_changed.new_position', p_event[0]);

				MainLoop.runInMainThread(function():Void
				{
					if (isValid() && onPositionChanged != null)
						onPositionChanged.dispatch(newPosition);
				});
			case event if (event == LibVLC_MediaPlayerLengthChanged):
				final newLength:Int64 = untyped __cpp__('{0}.u.media_player_length_changed.new_length', p_event[0]);

				MainLoop.runInMainThread(function():Void
				{
					if (isValid() && onLengthChanged != null)
						onLengthChanged.dispatch(newLength);
				});
			case event if (event == LibVLC_MediaPlayerChapterChanged):
				final newChapter:Int = untyped __cpp__('{0}.u.media_player_chapter_changed.new_chapter', p_event[0]);

				MainLoop.runInMainThread(function():Void
				{
					if (isValid() && onChapterChanged != null)
						onChapterChanged.dispatch(newChapter);
				});
			case event if (event == LibVLC_MediaPlayerMediaChanged):
				MainLoop.runInMainThread(function():Void
				{
					if (isValid() && onMediaChanged != null)
						onMediaChanged.dispatch();
				});
			case event if (event == LibVLC_MediaParsedChanged):
				final newStatus:Int = untyped __cpp__('{0}.u.media_parsed_changed.new_status', p_event[0]);

				MainLoop.runInMainThread(function():Void
				{
					if (isValid() && onMediaParsedChanged != null)
						onMediaParsedChanged.dispatch(newStatus);
				});
			case event if (event == LibVLC_MediaMetaChanged):
				MainLoop.runInMainThread(function():Void
				{
					if (isValid() && onMediaMetaChanged != null)
						onMediaMetaChanged.dispatch();
				});
		}
	}

	@:noCompletion
	@:noDebug
	@:unreflective
	private inline function isValid():Bool
	{
		return mediaPlayer != null;
	}

	@:noCompletion
	@:noDebug
	@:unreflective
	private function updateImage():Void
	{
		textureMutex.acquire();

		if (texturePlanes != null)
		{
			bitmapData.image.buffer.data = UInt8Array.fromBytes(Bytes.ofData(texturePlanes));
			bitmapData.image.dirty = true;
			bitmapData.image.version++;
		}

		if (onDisplay != null)
			onDisplay.dispatch();

		textureMutex.release();
	}

	@:noCompletion
	@:noDebug
	@:unreflective
	private function updateTexture():Void
	{
		MainLoop.runInMainThread(function():Void
		{
			if (!isValid() || bitmapData == null || texturePlanes == null)
				return;

			textureMutex.acquire();

			final texture:Null<VideoTexture> = cast(bitmapData.__texture, VideoTexture);

			if (texture != null)
			{
				texture.uploadFromTypedArray(UInt8Array.fromBytes(Bytes.ofData(texturePlanes)));

				if (__renderable)
					__setRenderDirty();
			}

			if (onDisplay != null)
				onDisplay.dispatch();

			textureMutex.release();
		});
	}

	@:noCompletion
	@:noDebug
	@:unreflective
	private function getDescription(rawDescription:Pointer<LibVLC_Track_Description_T>, description:Array<TrackDescription>):Void
	{
		var nextDescription:Pointer<LibVLC_Track_Description_T> = rawDescription;

		while (nextDescription != null)
		{
			description.push(TrackDescription.fromTrackDescription(nextDescription[0]));

			nextDescription = Pointer.fromRaw(nextDescription[0].p_next);
		}

		LibVLC.track_description_list_release(rawDescription.raw);
	}

	@:noCompletion
	@:noDebug
	@:unreflective
	private function setMediaToPlayer(mediaItem:Pointer<LibVLC_Media_T>, ?options:Array<String>):Void
	{
		if (mediaPlayer == null)
			return;

		if (options != null)
		{
			for (option in options)
			{
				if (option != null && option.length > 0)
					LibVLC.media_add_option(mediaItem.raw, option);
			}
		}

		LibVLC.media_player_set_media(mediaPlayer.raw, mediaItem.raw);

		LibVLC.media_release(mediaItem.raw);
	}

	@:noCompletion
	@:noDebug
	@:unreflective
	private function setupVideo():Void
	{
		if (mediaPlayer == null)
			return;

		LibVLC.video_set_callbacks(mediaPlayer.raw, untyped video_lock, untyped video_unlock, untyped video_display, untyped __cpp__('this'));
		LibVLC.video_set_format_callbacks(mediaPlayer.raw, untyped video_format_setup, untyped NULL);
	}

	@:noCompletion
	@:noDebug
	@:unreflective
	private function setupAudio():Void
	{
		if (mediaPlayer == null)
			return;

		#if lime_openal
		if (alSource == null)
			alSource = AL.createSource();

		if (alBufferPool == null)
			alBufferPool = AL.genBuffers(MAX_AUDIO_BUFFER_COUNT);
		#end

		LibVLC.audio_set_callbacks(mediaPlayer.raw, untyped audio_play, untyped audio_pause, untyped audio_resume, untyped audio_flush, untyped NULL,
			untyped __cpp__('this'));
		LibVLC.audio_set_volume_callback(mediaPlayer.raw, untyped audio_set_volume);
		LibVLC.audio_set_format_callbacks(mediaPlayer.raw, untyped audio_setup, untyped NULL);
	}

	@:noCompletion
	@:noDebug
	@:unreflective
	private function setupEvents():Void
	{
		if (mediaPlayer != null)
		{
			final eventManager:Pointer<LibVLC_Event_Manager_T> = Pointer.fromRaw(LibVLC.media_player_event_manager(mediaPlayer.raw));

			if (eventManager != null)
			{
				addEvent(eventManager, LibVLC_MediaPlayerOpening);
				addEvent(eventManager, LibVLC_MediaPlayerPlaying);
				addEvent(eventManager, LibVLC_MediaPlayerStopped);
				addEvent(eventManager, LibVLC_MediaPlayerPaused);
				addEvent(eventManager, LibVLC_MediaPlayerEndReached);
				addEvent(eventManager, LibVLC_MediaPlayerEncounteredError);
				addEvent(eventManager, LibVLC_MediaPlayerMediaChanged);
				addEvent(eventManager, LibVLC_MediaPlayerESAdded);
				addEvent(eventManager, LibVLC_MediaPlayerESDeleted);
				addEvent(eventManager, LibVLC_MediaPlayerESSelected);
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
	@:noDebug
	@:unreflective
	private function addEvent(eventManager:Pointer<LibVLC_Event_Manager_T>, type:Int):Void
	{
		if (LibVLC.event_attach(eventManager.raw, type, untyped event_manager_callbacks, untyped __cpp__('this')) != 0)
			trace('Failed to attach event (${LibVLC.event_type_name(type)})');
	}

	/**
	 * @see https://github.com/obsproject/obs-studio/blob/5d1f0efc43c64c25f5edd4101bc1f0013bcacb60/plugins/vlc-video/vlc-video-source.c#L385
	 */
	@:noCompletion
	@:noDebug
	@:unreflective
	private function calculateVideoSize(width:Pointer<UInt32>, height:Pointer<UInt32>):Bool
	{
		if (mediaPlayer != null)
		{
			final currentMediaItem:Pointer<LibVLC_Media_T> = Pointer.fromRaw(LibVLC.media_player_get_media(mediaPlayer.raw));

			if (currentMediaItem != null)
			{
				final tracks:RawPointer<RawPointer<LibVLC_Media_Track_T>> = untyped nullptr;

				final count:UInt32 = LibVLC.media_tracks_get(currentMediaItem.raw, Pointer.addressOf(tracks).raw);

				for (i in 0...count)
				{
					final track:RawPointer<LibVLC_Media_Track_T> = tracks[i];

					if (track[0].i_type != LibVLC_Track_Video || LibVLC.video_get_track(mediaPlayer.raw) != track[0].i_id)
						continue;

					var trackWidth:UInt32 = track[0].video[0].i_width;
					var trackHeight:UInt32 = track[0].video[0].i_height;

					if (trackWidth == 0 || trackHeight == 0)
						break;

					final trackSarNum:UInt32 = track[0].video[0].i_sar_num;
					final trackSarDen:UInt32 = track[0].video[0].i_sar_den;

					if (trackSarNum > 0 && trackSarDen > 0)
					{
						trackWidth = Math.floor(trackWidth / trackSarDen) * trackSarNum + Math.floor((trackWidth % trackSarDen) * trackSarNum / trackSarDen);
					}

					if (track[0].video[0].i_orientation == LibVLC_Video_Orient_Right_Bottom)
					{
						width[0] = trackHeight;
						height[0] = trackWidth;
					}
					else
					{
						width[0] = trackWidth;
						height[0] = trackHeight;
					}

					LibVLC.media_tracks_release(tracks, count);

					LibVLC.media_release(currentMediaItem.raw);

					return true;
				}

				LibVLC.media_tracks_release(tracks, count);

				LibVLC.media_release(currentMediaItem.raw);
			}
		}

		return false;
	}
}
