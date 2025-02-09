package hxvlc.openfl;

import haxe.io.Bytes;
import haxe.io.BytesData;
import haxe.Int64;
import haxe.MainLoop;
import hxvlc.externs.LibVLC;
import hxvlc.externs.Types;
import hxvlc.util.macros.Define;
#if HXVLC_ENABLE_STATS
import hxvlc.util.Stats;
#end
import hxvlc.util.Handle;
import lime.app.Event;
#if lime_openal
import lime.media.openal.AL;
import lime.media.openal.ALBuffer;
import lime.media.openal.ALSource;
#end
import lime.utils.Log;
import lime.utils.UInt8Array;
import openfl.display.BitmapData;
import openfl.display3D.textures.RectangleTexture;
import openfl.display3D.textures.TextureBase;
import openfl.Lib;
import sys.thread.Mutex;

using StringTools;

/**
 * This class is a video player that uses LibVLC for seamless integration with OpenFL display objects.
 */
@:cppNamespaceCode('static int media_open(void *opaque, void **datap, uint64_t *sizep)
{
	(*datap) = opaque;

	hx::SetTopOfStack((int *)99, true);

	int result = reinterpret_cast<Video_obj *>(opaque)->mediaOpen(sizep);

	hx::SetTopOfStack((int *)0, true);

	return result;
}

static ssize_t media_read(void *opaque, unsigned char *buf, size_t len)
{
	hx::SetTopOfStack((int *)99, true);

	ssize_t bytesToRead = reinterpret_cast<Video_obj *>(opaque)->mediaRead(buf, len);

	hx::SetTopOfStack((int *)0, true);

	return bytesToRead;
}

static int media_seek(void *opaque, uint64_t offset)
{
	hx::SetTopOfStack((int *)99, true);

	int success = reinterpret_cast<Video_obj *>(opaque)->mediaSeek(offset);

	hx::SetTopOfStack((int *)0, true);

	return success;
}

static void *video_lock(void *opaque, void **planes)
{
	hx::SetTopOfStack((int *)99, true);

	void *picture = reinterpret_cast<Video_obj *>(opaque)->videoLock(planes);

	hx::SetTopOfStack((int *)0, true);

	return picture;
}

static void video_unlock(void *opaque, void *picture, void *const *planes)
{
	hx::SetTopOfStack((int *)99, true);

	reinterpret_cast<Video_obj *>(opaque)->videoUnlock(planes);

	hx::SetTopOfStack((int *)0, true);
}

static void video_display(void *opaque, void *picture)
{
	hx::SetTopOfStack((int *)99, true);

	reinterpret_cast<Video_obj *>(opaque)->videoDisplay(picture);

	hx::SetTopOfStack((int *)0, true);
}

static unsigned video_format_setup(void **opaque, char *chroma, unsigned *width, unsigned *height, unsigned *pitches, unsigned *lines)
{
	hx::SetTopOfStack((int *)99, true);

	int pictureBuffers = reinterpret_cast<Video_obj *>(*opaque)->videoFormatSetup(chroma, width, height, pitches, lines);

	hx::SetTopOfStack((int *)0, true);

	return pictureBuffers;
}

static void audio_play(void *data, const void *samples, unsigned count, int64_t pts)
{
	hx::SetTopOfStack((int *)99, true);

	reinterpret_cast<Video_obj *>(data)->audioPlay((unsigned char *)samples, count, pts);

	hx::SetTopOfStack((int *)0, true);
}

static void audio_pause(void *data, int64_t pts)
{
	hx::SetTopOfStack((int *)99, true);

	reinterpret_cast<Video_obj *>(data)->audioPause(pts);

	hx::SetTopOfStack((int *)0, true);
}

static void audio_flush(void *data, int64_t pts)
{
	hx::SetTopOfStack((int *)99, true);

	reinterpret_cast<Video_obj *>(data)->audioFlush(pts);

	hx::SetTopOfStack((int *)0, true);
}

static int audio_setup(void **data, char *format, unsigned *rate, unsigned *channels)
{
	hx::SetTopOfStack((int *)99, true);

	int result = reinterpret_cast<Video_obj *>(*data)->audioSetup(format, rate, channels);

	hx::SetTopOfStack((int *)0, true);

	return result;
}

static void audio_set_volume(void *data, float volume, bool mute)
{
	hx::SetTopOfStack((int *)99, true);

	reinterpret_cast<Video_obj *>(data)->audioSetVolume(volume, mute);

	hx::SetTopOfStack((int *)0, true);
}

static void event_manager_callbacks(const libvlc_event_t *p_event, void *p_data)
{
	hx::SetTopOfStack((int *)99, true);

	reinterpret_cast<Video_obj *>(p_data)->eventManagerCallbacks(p_event);

	hx::SetTopOfStack((int *)0, true);
}')
class Video extends openfl.display.Bitmap
{
	#if lime_openal
	/**
	 * The number of buffers that used for the buffer pool.
	 * 
	 * @see https://github.com/videolan/vlc/blob/0ddf69feccd687f0a694aeeefbc31c76074103ec/modules/audio_output/android/opensles.c#L42.
	 */
	@:noCompletion
	private static final MAX_AUDIO_BUFFER_COUNT:Int = Define.getInt('HXVLC_MAX_AUDIO_BUFFER_COUNT', 255);
	#end

	/**
	 * Indicates whether to use GPU texture for rendering.
	 *
	 * If set to true, GPU texture rendering will be used if possible, otherwise, CPU-based image rendering will be used.
	 */
	public static var useTexture:Bool = true;

	/**
	 * Forces on the rendering of the bitmapData within this bitmap.
	 */
	public var forceRendering:Bool = false;

	/**
	 * The media resource locator (MRL).
	 */
	public var mrl(get, never):Null<String>;

	#if HXVLC_ENABLE_STATS
	/**
	 * Statistics related to the media.
	 */
	public var stats(get, never):Null<Stats>;
	#end

	/**
	 * Duration of the media in microseconds.
	 */
	public var duration(get, never):Int64;

	/**
	 * Indicates whether the media is currently playing.
	 */
	public var isPlaying(get, never):Bool;

	/**
	 * Length of the media in microseconds.
	 */
	public var length(get, never):Int64;

	/**
	 * Current time position in the media in microseconds.
	 */
	public var time(get, set):Int64;

	/**
	 * Current playback position as a percentage (0.0 to 1.0).
	 */
	public var position(get, set):Single;

	/**
	 * Current chapter of the video.
	 */
	public var chapter(get, set):Int;

	/**
	 * Total number of chapters in the video.
	 */
	public var chapterCount(get, never):Int;

	/**
	 * Indicates whether playback will start automatically once loaded.
	 */
	public var willPlay(get, never):Bool;

	/**
	 * Playback rate of the video.
	 *
	 * Note: The actual rate may vary depending on the media.
	 */
	public var rate(get, set):Single;

	/**
	 * Indicates whether seeking is supported.
	 */
	public var isSeekable(get, never):Bool;

	/**
	 * Indicates whether pausing is supported.
	 */
	public var canPause(get, never):Bool;

	/**
	 * Volume level (0 to 100).
	 */
	public var volume(get, set):Int;

	/**
	 * Total number of available audio tracks.
	 */
	public var trackCount(get, never):Int;

	/**
	 * Selected audio track.
	 */
	public var track(get, set):Int;

	/**
	 * Selected audio channel.
	 */
	public var channel(get, set):Int;

	/**
	 * Audio delay in microseconds.
	 */
	public var delay(get, set):Int64;

	/**
	 * Role of the media.
	 */
	public var role(get, set):UInt;

	/**
	 * Event triggered when the media is opening.
	 */
	public var onOpening(default, null):Event<Void->Void> = new Event<Void->Void>();

	/**
	 * Event triggered when playback starts.
	 */
	public var onPlaying(default, null):Event<Void->Void> = new Event<Void->Void>();

	/**
	 * Event triggered when playback stops.
	 */
	public var onStopped(default, null):Event<Void->Void> = new Event<Void->Void>();

	/**
	 * Event triggered when playback is paused.
	 */
	public var onPaused(default, null):Event<Void->Void> = new Event<Void->Void>();

	/**
	 * Event triggered when the end of the media is reached.
	 */
	public var onEndReached(default, null):Event<Void->Void> = new Event<Void->Void>();

	/**
	 * Event triggered when an error occurs.
	 */
	public var onEncounteredError(default, null):Event<String->Void> = new Event<String->Void>();

	/**
	 * Event triggered when the media changes.
	 */
	public var onMediaChanged(default, null):Event<Void->Void> = new Event<Void->Void>();

	/**
	 * Event triggered when the media is corked.
	 */
	public var onCorked(default, null):Event<Void->Void> = new Event<Void->Void>();

	/**
	 * Event triggered when the media is uncorked.
	 */
	public var onUncorked(default, null):Event<Void->Void> = new Event<Void->Void>();

	/**
	 * Event triggered when the time changes.
	 */
	public var onTimeChanged(default, null):Event<Int64->Void> = new Event<Int64->Void>();

	/**
	 * Event triggered when the position changes.
	 */
	public var onPositionChanged(default, null):Event<Single->Void> = new Event<Single->Void>();

	/**
	 * Event triggered when the length changes.
	 */
	public var onLengthChanged(default, null):Event<Int64->Void> = new Event<Int64->Void>();

	/**
	 * Event triggered when the chapter changes.
	 */
	public var onChapterChanged(default, null):Event<Int->Void> = new Event<Int->Void>();

	/**
	 * Event triggered when the media metadata changes.
	 */
	public var onMediaMetaChanged(default, null):Event<Void->Void> = new Event<Void->Void>();

	/**
	 * Event triggered when the media is parsed.
	 */
	public var onMediaParsedChanged(default, null):Event<Int->Void> = new Event<Int->Void>();

	/**
	 * Event triggered when the media format setup is initialized.
	 */
	public var onFormatSetup(default, null):Event<Void->Void> = new Event<Void->Void>();

	/**
	 * Event triggered when the media is being rendered.
	 */
	public var onDisplay(default, null):Event<Void->Void> = new Event<Void->Void>();

	@:noCompletion
	private final mediaMutex:Mutex = new Mutex();

	@:noCompletion
	private var mediaData:Null<cpp.RawPointer<cpp.UInt8>>;

	@:noCompletion
	private var mediaSize:cpp.UInt64 = 0;

	@:noCompletion
	private var mediaOffset:cpp.UInt64 = 0;

	@:noCompletion
	private var mediaPlayer:Null<cpp.RawPointer<LibVLC_Media_Player_T>>;

	@:noCompletion
	private final textureMutex:Mutex = new Mutex();

	@:noCompletion
	private var textureWidth:cpp.UInt32 = 0;

	@:noCompletion
	private var textureHeight:cpp.UInt32 = 0;

	@:noCompletion
	private var texturePlanes:Null<cpp.RawPointer<cpp.UInt8>>;

	@:noCompletion
	private var texturePlanesBuffer:Null<BytesData>;

	@:noCompletion
	private var texture:Null<RectangleTexture>;

	#if lime_openal
	@:noCompletion
	private final alMutex:Mutex = new Mutex();

	@:noCompletion
	private var alSampleRate:cpp.UInt32 = 0;

	@:noCompletion
	private var alSource:Null<ALSource>;

	@:noCompletion
	private var alBufferPool:Null<Array<ALBuffer>>;

	@:noCompletion
	private var alFormat:Int = 0;

	@:noCompletion
	private var alFrameSize:cpp.UInt32 = 0;

	@:noCompletion
	private var alSamplesBuffer:Null<BytesData>;

	@:noCompletion
	private var alUseEXTMCFORMATS:Null<Bool>;
	#end

	/**
	 * Initializes a Video object.
	 *
	 * @param smoothing Whether or not the object is smoothed when scaled.
	 */
	public function new(smoothing:Bool = true):Void
	{
		super(null, AUTO, smoothing);

		#if HXVLC_VIDEO_FINALIZER
		cpp.vm.Gc.setFinalizer(this, cpp.Function.fromStaticFunction(finalize));
		#end

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

				if (location.contains('://'))
					mediaItem = LibVLC.media_new_location(Handle.instance, location);
				else if (location.length > 0)
				{
					mediaItem = LibVLC.media_new_path(Handle.instance,
						#if windows haxe.io.Path.normalize(location).split('/').join('\\') #else haxe.io.Path.normalize(location) #end);
				}
				else
					return false;
			}
			else if ((location is Int))
			{
				mediaItem = LibVLC.media_new_fd(Handle.instance, cast(location, Int));
			}
			else if ((location is haxe.io.Bytes))
			{
				final data:BytesData = cast(location, haxe.io.Bytes).getData();

				if (data.length > 0)
				{
					mediaMutex.acquire();

					mediaData = untyped __cpp__('new unsigned char[{0}]', data.length);

					cpp.Stdlib.nativeMemcpy(untyped mediaData, untyped cpp.Pointer.ofArray(data).constRaw, data.length);

					mediaSize = data.length;
					mediaOffset = 0;

					mediaMutex.release();

					data.splice(0, data.length);

					mediaItem = LibVLC.media_new_callbacks(Handle.instance, untyped __cpp__('media_open'), untyped __cpp__('media_read'),
						untyped __cpp__('media_seek'), untyped NULL, untyped __cpp__('this'));
				}
				else
					return false;
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
				final eventManager:cpp.RawPointer<LibVLC_Event_Manager_T> = LibVLC.media_player_event_manager(mediaPlayer);

				if (eventManager != null)
				{
					if (LibVLC.event_attach(eventManager, LibVLC_MediaPlayerOpening, untyped __cpp__('event_manager_callbacks'), untyped __cpp__('this')) != 0)
						Log.warn('Failed to attach event (MediaPlayerOpening)');

					if (LibVLC.event_attach(eventManager, LibVLC_MediaPlayerPlaying, untyped __cpp__('event_manager_callbacks'), untyped __cpp__('this')) != 0)
						Log.warn('Failed to attach event (MediaPlayerPlaying)');

					if (LibVLC.event_attach(eventManager, LibVLC_MediaPlayerStopped, untyped __cpp__('event_manager_callbacks'), untyped __cpp__('this')) != 0)
						Log.warn('Failed to attach event (MediaPlayerStopped)');

					if (LibVLC.event_attach(eventManager, LibVLC_MediaPlayerPaused, untyped __cpp__('event_manager_callbacks'), untyped __cpp__('this')) != 0)
						Log.warn('Failed to attach event (MediaPlayerPaused)');

					if (LibVLC.event_attach(eventManager, LibVLC_MediaPlayerEndReached, untyped __cpp__('event_manager_callbacks'),
						untyped __cpp__('this')) != 0)
						Log.warn('Failed to attach event (MediaPlayerEndReached)');

					if (LibVLC.event_attach(eventManager, LibVLC_MediaPlayerEncounteredError, untyped __cpp__('event_manager_callbacks'),
						untyped __cpp__('this')) != 0)
						Log.warn('Failed to attach event (MediaPlayerEncounteredError)');

					if (LibVLC.event_attach(eventManager, LibVLC_MediaPlayerMediaChanged, untyped __cpp__('event_manager_callbacks'),
						untyped __cpp__('this')) != 0)
						Log.warn('Failed to attach event (MediaPlayerMediaChanged)');

					if (LibVLC.event_attach(eventManager, LibVLC_MediaPlayerCorked, untyped __cpp__('event_manager_callbacks'), untyped __cpp__('this')) != 0)
						Log.warn('Failed to attach event (MediaPlayerCorked)');

					if (LibVLC.event_attach(eventManager, LibVLC_MediaPlayerUncorked, untyped __cpp__('event_manager_callbacks'), untyped __cpp__('this')) != 0)
						Log.warn('Failed to attach event (MediaPlayerUncorked)');

					if (LibVLC.event_attach(eventManager, LibVLC_MediaPlayerTimeChanged, untyped __cpp__('event_manager_callbacks'),
						untyped __cpp__('this')) != 0)
						Log.warn('Failed to attach event (MediaPlayerTimeChanged)');

					if (LibVLC.event_attach(eventManager, LibVLC_MediaPlayerPositionChanged, untyped __cpp__('event_manager_callbacks'),
						untyped __cpp__('this')) != 0)
						Log.warn('Failed to attach event (MediaPlayerPositionChanged)');

					if (LibVLC.event_attach(eventManager, LibVLC_MediaPlayerLengthChanged, untyped __cpp__('event_manager_callbacks'),
						untyped __cpp__('this')) != 0)
						Log.warn('Failed to attach event (MediaPlayerLengthChanged)');

					if (LibVLC.event_attach(eventManager, LibVLC_MediaPlayerChapterChanged, untyped __cpp__('event_manager_callbacks'),
						untyped __cpp__('this')) != 0)
						Log.warn('Failed to attach event (MediaPlayerChapterChanged)');
				}
				else
					Log.warn('Unable to initialize the LibVLC media player event manager.');

				LibVLC.video_set_callbacks(mediaPlayer, untyped __cpp__('video_lock'), untyped __cpp__('video_unlock'), untyped __cpp__('video_display'),
					untyped __cpp__('this'));
				LibVLC.video_set_format_callbacks(mediaPlayer, untyped __cpp__('video_format_setup'), untyped NULL);

				#if lime_openal
				if (alSource == null)
					alSource = AL.createSource();
				#end

				LibVLC.audio_set_callbacks(mediaPlayer, untyped __cpp__('audio_play'), untyped __cpp__('audio_pause'), untyped NULL,
					untyped __cpp__('audio_flush'), untyped NULL, untyped __cpp__('this'));
				LibVLC.audio_set_volume_callback(mediaPlayer, untyped __cpp__('audio_set_volume'));
				LibVLC.audio_set_format_callbacks(mediaPlayer, untyped __cpp__('audio_setup'), untyped NULL);
			}
			else
				Log.warn('Unable to initialize the LibVLC media player.');
		}

		if (mediaItem != null)
		{
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

			return true;
		}
		else
			Log.warn('Unable to initialize the LibVLC media item.');

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
							if (options != null)
							{
								for (option in options)
								{
									if (option != null && option.length > 0)
										LibVLC.media_add_option(mediaSubItem, option);
								}
							}

							LibVLC.media_player_set_media(mediaPlayer, mediaSubItem);

							LibVLC.media_release(mediaSubItem);

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
					if (LibVLC.event_attach(eventManager, LibVLC_MediaParsedChanged, untyped __cpp__('event_manager_callbacks'), untyped __cpp__('this')) != 0)
						Log.warn('Failed to attach event (MediaParsedChanged)');

					if (LibVLC.event_attach(eventManager, LibVLC_MediaMetaChanged, untyped __cpp__('event_manager_callbacks'), untyped __cpp__('this')) != 0)
						Log.warn('Failed to attach event (MediaMetaChanged)');
				}
				else
					Log.warn('Unable to initialize the LibVLC media event manager.');

				return LibVLC.media_parse_with_options(currentMediaItem, parse_flag, timeout) == 0;
			}
		}

		return false;
	}

	/**
	 * Stops parsing the current media item.
	 */
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
	 * Starts playback.
	 *
	 * @return `true` if playback started successfully, `false` otherwise.
	 */
	public function play():Bool
	{
		return mediaPlayer != null && LibVLC.media_player_play(mediaPlayer) == 0;
	}

	/**
	 * Stops playback.
	 */
	public function stop():Void
	{
		if (mediaPlayer != null)
			LibVLC.media_player_stop(mediaPlayer);
	}

	/**
	 * Pauses playback.
	 */
	public function pause():Void
	{
		if (mediaPlayer != null)
			LibVLC.media_player_set_pause(mediaPlayer, 1);
	}

	/**
	 * Resumes playback.
	 */
	public function resume():Void
	{
		if (mediaPlayer != null)
			LibVLC.media_player_set_pause(mediaPlayer, 0);
	}

	/**
	 * Toggles the pause state.
	 */
	public function togglePaused():Void
	{
		if (mediaPlayer != null)
			LibVLC.media_player_pause(mediaPlayer);
	}

	/**
	 * Moves to the previous chapter, if supported.
	 */
	public function previousChapter():Void
	{
		if (mediaPlayer != null)
			LibVLC.media_player_previous_chapter(mediaPlayer);
	}

	/**
	 * Moves to the next chapter, if supported.
	 */
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
	 *
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

	/**
	 * Frees the memory that is used to store the Video object.
	 */
	@:nullSafety(Off)
	public function dispose():Void
	{
		if (mediaPlayer != null)
		{
			LibVLC.media_player_release(mediaPlayer);
			mediaPlayer = null;
		}

		mediaMutex.acquire();

		if (mediaData != null)
		{
			untyped __cpp__('delete[] {0}', mediaData);
			mediaData = null;
		}

		mediaSize = mediaOffset = 0;

		mediaMutex.release();

		textureMutex.acquire();

		if (bitmapData != null)
		{
			bitmapData.dispose();
			bitmapData = null;
		}

		if (texture != null)
		{
			texture.dispose();
			texture = null;
		}

		textureWidth = textureHeight = 0;

		if (texturePlanes != null)
		{
			untyped __cpp__('delete[] {0}', texturePlanes);
			texturePlanes = null;
		}

		texturePlanesBuffer = [];

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

		alSamplesBuffer = [];

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

	#if HXVLC_ENABLE_STATS
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
	#end

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
	private function get_willPlay():Bool
	{
		return mediaPlayer != null && LibVLC.media_player_will_play(mediaPlayer) != 0;
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
	private function get_trackCount():Int
	{
		return mediaPlayer != null ? LibVLC.audio_get_track_count(mediaPlayer) : -1;
	}

	@:noCompletion
	private function get_track():Int
	{
		return mediaPlayer != null ? LibVLC.audio_get_track(mediaPlayer) : -1;
	}

	@:noCompletion
	private function set_track(value:Int):Int
	{
		if (mediaPlayer != null)
			LibVLC.audio_set_track(mediaPlayer, value);

		return value;
	}

	@:noCompletion
	private function get_channel():Int
	{
		return mediaPlayer != null ? LibVLC.audio_get_channel(mediaPlayer) : 0;
	}

	@:noCompletion
	private function set_channel(value:Int):Int
	{
		if (mediaPlayer != null)
			LibVLC.audio_set_channel(mediaPlayer, value);

		return value;
	}

	@:noCompletion
	private function get_delay():Int64
	{
		return mediaPlayer != null ? LibVLC.audio_get_delay(mediaPlayer) : 0;
	}

	@:noCompletion
	private function set_delay(value:Int64):Int64
	{
		if (mediaPlayer != null)
			LibVLC.audio_set_delay(mediaPlayer, value);

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

		sizep[0] = untyped mediaSize;

		mediaMutex.release();

		return 0;
	}

	@:keep
	@:noCompletion
	@:unreflective
	private function mediaRead(buf:cpp.RawPointer<cpp.UInt8>, len:cpp.SizeT):cpp.SSizeT
	{
		mediaMutex.acquire();

		if (untyped __cpp__('{0} >= {1}', mediaOffset, mediaSize))
		{
			mediaMutex.release();
			return 0;
		}

		final toRead:cpp.UInt64 = untyped __cpp__('{0} < ({1} - {2}) ? {0} : ({1} - {2})', len, mediaSize, mediaOffset);

		if (mediaData == null || untyped __cpp__('{0} > {1} - {2}', mediaOffset, mediaSize, toRead))
		{
			mediaMutex.release();
			return -1;
		}

		cpp.Stdlib.nativeMemcpy(untyped buf, untyped cpp.RawPointer.addressOf(mediaData[untyped __cpp__('{0}', mediaOffset)]), untyped __cpp__('{0}', toRead));

		untyped __cpp__('{0} += {1}', mediaOffset, toRead);

		mediaMutex.release();

		return cast toRead;
	}

	@:keep
	@:noCompletion
	@:unreflective
	private function mediaSeek(offset:cpp.UInt64):Int
	{
		mediaMutex.acquire();

		if (untyped __cpp__('{0} > {1}', offset, mediaSize))
		{
			mediaMutex.release();
			return -1;
		}

		mediaOffset = offset;

		mediaMutex.release();

		return 0;
	}

	@:keep
	@:noCompletion
	@:unreflective
	private function videoLock(planes:cpp.RawPointer<cpp.RawPointer<cpp.Void>>):cpp.RawPointer<cpp.Void>
	{
		textureMutex.acquire();

		if (texturePlanes != null)
			planes[0] = untyped texturePlanes;

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
		if ((__renderable || forceRendering) && texturePlanes != null)
		{
			if (texture != null || (bitmapData != null && bitmapData.image != null))
			{
				MainLoop.runInMainThread(function():Void
				{
					textureMutex.acquire();

					if (texturePlanesBuffer == null)
						texturePlanesBuffer = new BytesData();

					cpp.NativeArray.setUnmanagedData(texturePlanesBuffer, cast texturePlanes, textureWidth * textureHeight * 4);

					if (texture != null)
						texture.uploadFromTypedArray(UInt8Array.fromBytes(Bytes.ofData(texturePlanesBuffer)));
					else if (bitmapData != null && bitmapData.image != null)
						bitmapData.setPixels(bitmapData.rect, Bytes.ofData(texturePlanesBuffer));

					if (__renderable)
						__setRenderDirty();

					onDisplay.dispatch();

					textureMutex.release();
				});
			}
		}
	}

	@:access(openfl.display.BitmapData)
	@:access(openfl.display3D.textures.TextureBase)
	@:keep
	@:noCompletion
	@:unreflective
	private function videoFormatSetup(chroma:cpp.CastCharStar, width:cpp.RawPointer<cpp.UInt32>, height:cpp.RawPointer<cpp.UInt32>,
			pitches:cpp.RawPointer<cpp.UInt32>, lines:cpp.RawPointer<cpp.UInt32>):Int
	{
		textureMutex.acquire();

		final currentChroma:String = new String(untyped chroma);

		if (TextureBase.__supportsBGRA == true)
		{
			if (currentChroma != 'BGRA')
				cpp.Stdlib.nativeMemcpy(untyped chroma, untyped cpp.CastCharStar.fromString('BGRA'), 4);
		}
		else
		{
			if (currentChroma != 'RGBA')
				cpp.Stdlib.nativeMemcpy(untyped chroma, untyped cpp.CastCharStar.fromString('RGBA'), 4);
		}

		final originalWidth:cpp.UInt32 = width[0];
		final originalHeight:cpp.UInt32 = height[0];

		if (mediaPlayer != null
			&& LibVLC.video_get_size(mediaPlayer, 0, cpp.RawPointer.addressOf(textureWidth), cpp.RawPointer.addressOf(textureHeight)) == 0)
		{
			width[0] = textureWidth;
			height[0] = textureHeight;

			if (texturePlanes == null || (originalWidth != textureWidth || originalHeight != textureHeight))
			{
				if (texturePlanes != null)
					untyped __cpp__('delete[] {0}', texturePlanes);

				texturePlanes = untyped __cpp__('new unsigned char[{0}]', textureWidth * textureHeight * 4);
			}
		}
		else
		{
			textureWidth = originalWidth;
			textureHeight = originalHeight;

			if (texturePlanes != null)
				untyped __cpp__('delete[] {0}', texturePlanes);

			texturePlanes = untyped __cpp__('new unsigned char[{0}]', textureWidth * textureHeight * 4);
		}

		pitches[0] = textureWidth * 4;
		lines[0] = textureHeight;

		textureMutex.release();

		if (bitmapData == null
			|| (bitmapData.width != textureWidth || bitmapData.height != textureHeight)
			|| ((!useTexture && bitmapData.__texture != null) || (useTexture && bitmapData.image != null)))
		{
			MainLoop.runInMainThread(function():Void
			{
				textureMutex.acquire();

				if (bitmapData != null)
					bitmapData.dispose();

				if (texture != null)
				{
					texture.dispose();
					texture = null;
				}

				if (useTexture && Lib.current.stage != null && Lib.current.stage.context3D != null)
				{
					texture = Lib.current.stage.context3D.createRectangleTexture(textureWidth, textureHeight, openfl.display3D.Context3DTextureFormat.BGRA,
						true);

					bitmapData = BitmapData.fromTexture(texture);
				}
				else
				{
					if (useTexture)
						Log.warn('Unable to utilize GPU texture, resorting to CPU-based image rendering.');

					bitmapData = new BitmapData(textureWidth, textureHeight, true, 0);
				}

				onFormatSetup.dispatch();

				textureMutex.release();
			});
		}

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

			if (alBufferPool.length > MAX_AUDIO_BUFFER_COUNT)
				alBufferPool.splice(MAX_AUDIO_BUFFER_COUNT, alBufferPool.length - MAX_AUDIO_BUFFER_COUNT);

			if (alBufferPool.length > 0)
			{
				final alBuffer:Null<ALBuffer> = alBufferPool.shift();

				if (alBuffer != null)
				{
					if (alSamplesBuffer == null)
						alSamplesBuffer = new BytesData();

					cpp.NativeArray.setUnmanagedData(alSamplesBuffer, cast samples, count);

					AL.bufferData(alBuffer, alFormat, UInt8Array.fromBytes(Bytes.ofData(alSamplesBuffer)), alSamplesBuffer.length * alFrameSize, alSampleRate);

					AL.sourceQueueBuffer(alSource, alBuffer);
				}
			}

			if (AL.getSourcei(alSource, AL.SOURCE_STATE) != AL.PLAYING)
				AL.sourcePlay(alSource);

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
		if (alSource != null && alBufferPool != null)
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
		if (alSource != null && alBufferPool != null)
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

		final currentFormat:String = new String(untyped format);

		if (currentFormat != 'S16N')
			cpp.Stdlib.nativeMemcpy(untyped format, untyped cpp.CastCharStar.fromString('S16N'), 4);

		if (alUseEXTMCFORMATS == null)
			alUseEXTMCFORMATS = AL.isExtensionPresent('AL_EXT_MCFORMATS');

		if (alBufferPool == null)
			alBufferPool = AL.genBuffers(MAX_AUDIO_BUFFER_COUNT);

		alSampleRate = rate[0];

		var alChannelsToUse:cpp.UInt32 = channels[0];

		if (alUseEXTMCFORMATS == true && alChannelsToUse > 8)
			alChannelsToUse = 8;
		else if (alChannelsToUse > 2)
			alChannelsToUse = 2;

		switch (alChannelsToUse)
		{
			case 1:
				alFormat = AL.FORMAT_MONO16;
				alChannelsToUse = 1;
			case 2 | 3:
				alFormat = AL.FORMAT_STEREO16;
				alChannelsToUse = 2;
			case 4:
				alFormat = AL.getEnumValue('AL_FORMAT_QUAD16');
				alChannelsToUse = 4;
			case 5 | 6:
				alFormat = AL.getEnumValue('AL_FORMAT_51CHN16');
				alChannelsToUse = 6;
			case 7 | 8:
				alFormat = AL.getEnumValue('AL_FORMAT_71CHN16');
				alChannelsToUse = 8;
		}

		alFrameSize = cpp.Stdlib.sizeof(cpp.Int16) * alChannelsToUse;

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
	private function audioSetVolume(volume:Single, mute:Bool):Void
	{
		// Leave this blank as we want to handle ourselves.
	}

	@:keep
	@:noCompletion
	@:unreflective
	private function eventManagerCallbacks(p_event:cpp.RawConstPointer<LibVLC_Event_T>):Void
	{
		switch (p_event[0].type)
		{
			case event if (event == LibVLC_MediaPlayerOpening):
				MainLoop.runInMainThread(onOpening.dispatch.bind());
			case event if (event == LibVLC_MediaPlayerPlaying):
				MainLoop.runInMainThread(onPlaying.dispatch.bind());
			case event if (event == LibVLC_MediaPlayerStopped):
				MainLoop.runInMainThread(onStopped.dispatch.bind());
			case event if (event == LibVLC_MediaPlayerPaused):
				MainLoop.runInMainThread(onPaused.dispatch.bind());
			case event if (event == LibVLC_MediaPlayerEndReached):
				MainLoop.runInMainThread(onEndReached.dispatch.bind());
			case event if (event == LibVLC_MediaPlayerEncounteredError):
				final errmsg:String = LibVLC.errmsg();

				MainLoop.runInMainThread(onEncounteredError.dispatch.bind(errmsg));
			case event if (event == LibVLC_MediaPlayerCorked):
				MainLoop.runInMainThread(onCorked.dispatch.bind());
			case event if (event == LibVLC_MediaPlayerUncorked):
				MainLoop.runInMainThread(onUncorked.dispatch.bind());
			case event if (event == LibVLC_MediaPlayerTimeChanged):
				final newTime:Int64 = (untyped __cpp__('{0}.u.media_player_time_changed.new_time', p_event[0]) : cpp.Int64);

				MainLoop.runInMainThread(onTimeChanged.dispatch.bind(newTime));
			case event if (event == LibVLC_MediaPlayerPositionChanged):
				final newPosition:Single = untyped __cpp__('{0}.u.media_player_position_changed.new_position', p_event[0]);

				MainLoop.runInMainThread(onPositionChanged.dispatch.bind(newPosition));
			case event if (event == LibVLC_MediaPlayerLengthChanged):
				final newLength:Int64 = (untyped __cpp__('{0}.u.media_player_length_changed.new_length', p_event[0]) : cpp.Int64);

				MainLoop.runInMainThread(onLengthChanged.dispatch.bind(newLength));
			case event if (event == LibVLC_MediaPlayerChapterChanged):
				final newChapter:Int = untyped __cpp__('{0}.u.media_player_chapter_changed.new_chapter', p_event[0]);

				MainLoop.runInMainThread(onChapterChanged.dispatch.bind(newChapter));
			case event if (event == LibVLC_MediaPlayerMediaChanged):
				MainLoop.runInMainThread(onMediaChanged.dispatch.bind());
			case event if (event == LibVLC_MediaParsedChanged):
				final newStatus:Int = untyped __cpp__('{0}.u.media_parsed_changed.new_status', p_event[0]);

				MainLoop.runInMainThread(onMediaParsedChanged.dispatch.bind(newStatus));
			case event if (event == LibVLC_MediaMetaChanged):
				MainLoop.runInMainThread(onMediaMetaChanged.dispatch.bind());
		}
	}

	#if HXVLC_VIDEO_FINALIZER
	private static function finalize(video:Video):Void
	{
		video.dispose();
	}
	#end
}
