package hxvlc.openfl;

#if (!cpp && !(desktop || mobile))
#error 'The current target platform isn\'t supported by hxvlc.'
#end
import haxe.io.Bytes;
import haxe.io.BytesData;
import haxe.io.Path;
import haxe.Exception;
import haxe.Int64;
import haxe.MainLoop;
import hxvlc.externs.LibVLC;
import hxvlc.externs.Types;
import hxvlc.openfl.Stats;
import hxvlc.util.Location;
import hxvlc.util.Handle;
import lime.app.Event;
#if (HXVLC_OPENAL && lime_openal)
import lime.media.openal.AL;
import lime.media.openal.ALBuffer;
import lime.media.openal.ALSource;
import lime.media.AudioManager;
import lime.media.OpenALAudioContext;
#end
import lime.utils.Log;
import lime.utils.UInt8Array;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display3D.textures.RectangleTexture;
import openfl.display3D.Context3DTextureFormat;
import openfl.Lib;
import sys.thread.Mutex;

using StringTools;

/**
 * This class is a video player that uses LibVLC for seamless integration with OpenFL display objects.
 */
@:nullSafety
@:cppNamespaceCode('static int media_open(void *opaque, void **datap, uint64_t *sizep)
{
	hx::SetTopOfStack((int *)99, true);

	Video_obj *self = reinterpret_cast<Video_obj *>(opaque);

	self->mediaMutex->acquire();

	(*datap) = opaque;
	(*sizep) = self->mediaSize;

	self->mediaMutex->release();

	hx::SetTopOfStack((int *)0, true);

	return 0;
}

static ssize_t media_read(void *opaque, unsigned char *buf, size_t len)
{
	hx::SetTopOfStack((int *)99, true);

	Video_obj *self = reinterpret_cast<Video_obj *>(opaque);

	self->mediaMutex->acquire();

	if (self->mediaOffset >= self->mediaSize)
	{
		self->mediaMutex->release();

		hx::SetTopOfStack((int *)0, true);

		return 0;
	}

	uint64_t toRead = len < (self->mediaSize - self->mediaOffset) ? len : (self->mediaSize - self->mediaOffset);

	if (self->mediaData == NULL || (self->mediaOffset > self->mediaSize - toRead))
	{
		self->mediaMutex->release();

		hx::SetTopOfStack((int *)0, true);

		return -1;
	}

	memcpy(buf, &self->mediaData[self->mediaOffset], (size_t)toRead);

	self->mediaOffset += toRead;

	self->mediaMutex->release();

	hx::SetTopOfStack((int *)0, true);

	return (ssize_t)toRead;
}

static int media_seek(void *opaque, uint64_t offset)
{
	hx::SetTopOfStack((int *)99, true);

	Video_obj *self = reinterpret_cast<Video_obj *>(opaque);

	self->mediaMutex->acquire();

	if (offset > self->mediaSize)
	{
		self->mediaMutex->release();

		hx::SetTopOfStack((int *)0, true);

		return -1;
	}

	self->mediaOffset = offset;

	self->mediaMutex->release();

	hx::SetTopOfStack((int *)0, true);

	return 0;
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

static void audio_resume(void *data, int64_t pts)
{
	hx::SetTopOfStack((int *)99, true);

	reinterpret_cast<Video_obj *>(data)->audioResume(pts);

	hx::SetTopOfStack((int *)0, true);
}

static int audio_setup(void **data, char *format, unsigned *rate, unsigned *channels)
{
	hx::SetTopOfStack((int *)99, true);

	int success = reinterpret_cast<Video_obj *>(*data)->audioSetup(format, rate, channels);

	hx::SetTopOfStack((int *)0, true);

	return success;
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

	Video_obj *self = reinterpret_cast<Video_obj *>(p_data);

	self->eventsMutex->acquire();

	switch (p_event->type)
	{
	case libvlc_MediaPlayerOpening:
		self->events[0] = true;
		break;
	case libvlc_MediaPlayerPlaying:
		self->events[1] = true;
		break;
	case libvlc_MediaPlayerStopped:
		self->events[2] = true;
		break;
	case libvlc_MediaPlayerPaused:
		self->events[3] = true;
		break;
	case libvlc_MediaPlayerEndReached:
		self->events[4] = true;
		break;
	case libvlc_MediaPlayerEncounteredError:
		self->events[5] = true;
		break;
	case libvlc_MediaPlayerMediaChanged:
		self->events[6] = true;
		break;
	case libvlc_MediaPlayerCorked:
		self->events[7] = true;
		break;
	case libvlc_MediaPlayerUncorked:
		self->events[8] = true;
		break;
	case libvlc_MediaPlayerTimeChanged:
		self->events[9] = true;
		break;
	case libvlc_MediaPlayerPositionChanged:
		self->events[10] = true;
		break;
	case libvlc_MediaPlayerLengthChanged:
		self->events[11] = true;
		break;
	case libvlc_MediaPlayerChapterChanged:
		self->events[12] = true;
		break;
	case libvlc_MediaMetaChanged:
		self->events[13] = true;
		break;
	case libvlc_MediaParsedChanged:
		self->events[14] = true;
		break;
	}

	self->eventsMutex->release();

	hx::SetTopOfStack((int *)0, true);
}')
class Video extends Bitmap
{
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

	/**
	 * Statistics related to the media.
	 */
	public var stats(get, never):Null<Stats>;

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
	 * Available audio output modules.
	 */
	public var outputModules(get, never):Null<Array<{name:String, description:String}>>;

	/**
	 * Selected audio output module.
	 *
	 * Note: Changes take effect only after restarting playback.
	 */
	public var output(never, set):String;

	/**
	 * Mute status of the audio.
	 *
	 * Note: May not be supported under certain conditions (e.g., digital pass-through).
	 */
	public var mute(get, set):Bool;

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
	 * Event triggered when the format setup is initialized.
	 */
	public var onFormatSetup(default, null):Event<Void->Void> = new Event<Void->Void>();

	@:noCompletion
	private final mediaMutex:Mutex = new Mutex();

	#if (HXVLC_OPENAL && lime_openal)
	@:noCompletion
	private final alMutex:Mutex = new Mutex();
	#end

	@:noCompletion
	private final eventsMutex:Mutex = new Mutex();

	@:noCompletion
	private final textureMutex:Mutex = new Mutex();

	@:noCompletion
	private final events:Array<Bool> = [for (i in 0...15) false];

	@:noCompletion
	private var mediaData:Null<cpp.RawPointer<cpp.UInt8>>;

	@:noCompletion
	private var mediaSize:cpp.UInt64 = 0;

	@:noCompletion
	private var mediaOffset:cpp.UInt64 = 0;

	@:noCompletion
	private var mediaPlayer:Null<cpp.RawPointer<LibVLC_Media_Player_T>>;

	@:noCompletion
	private var texture:Null<RectangleTexture>;

	@:noCompletion
	private var textureWidth:cpp.UInt32 = 0;

	@:noCompletion
	private var textureHeight:cpp.UInt32 = 0;

	@:noCompletion
	private var texturePlanes:Null<cpp.RawPointer<cpp.UInt8>>;

	@:noCompletion
	private var texturePlanesBuffer:Null<BytesData>;

	#if (HXVLC_OPENAL && lime_openal)
	@:noCompletion
	private var alAudioContext:Null<OpenALAudioContext>;

	@:noCompletion
	private var alBuffers:Null<Array<ALBuffer>> = [];

	@:noCompletion
	private var alSource:Null<ALSource>;

	@:noCompletion
	private var alSampleRate:cpp.UInt32 = 0;

	@:noCompletion
	private var alChannels:cpp.UInt32 = 0;

	@:noCompletion
	private var alSamplesBuffer:Null<BytesData>;
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
	public function load(location:Location, ?options:Array<String>):Bool
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
						#if windows Path.normalize(location).split('/').join('\\') #else Path.normalize(location) #end);
				}
				else
					return false;
			}
			else if ((location is Int))
			{
				mediaItem = LibVLC.media_new_fd(Handle.instance, cast(location, Int));
			}
			else if ((location is Bytes))
			{
				final data:BytesData = cast(location, Bytes).getData();

				if (data.length > 0)
				{
					mediaMutex.acquire();

					mediaData = untyped __cpp__('new unsigned char[{0}]', data.length);

					cpp.Stdlib.nativeMemcpy(cast mediaData, cast cpp.Pointer.ofArray(data).constRaw, data.length);

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

		if (Lib.application != null)
		{
			if (!Lib.application.onUpdate.has(update))
				Lib.application.onUpdate.add(update);

			if (Lib.application.window != null)
			{
				if (!Lib.application.window.onActivate.has(resume))
					Lib.application.window.onActivate.add(resume);

				if (!Lib.application.window.onDeactivate.has(pause))
					Lib.application.window.onDeactivate.add(pause);
			}
		}

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

					if (LibVLC.event_attach(eventManager, LibVLC_MediaPlayerUncorked, untyped __cpp__('event_manager_callbacks'),
						untyped __cpp__('this')) != 0)
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

				#if (HXVLC_OPENAL && lime_openal)
				if (AudioManager.context != null)
				{
					switch (AudioManager.context.type)
					{
						case OPENAL:
							alMutex.acquire();

							alAudioContext = AudioManager.context.openal;
							alBuffers = alAudioContext.genBuffers(128);
							alSource = alAudioContext.createSource();

							alAudioContext.sourcef(alSource, AL.GAIN, 1);
							alAudioContext.source3f(alSource, AL.POSITION, 0, 0, 0);
							alAudioContext.sourcef(alSource, AL.PITCH, 1);

							alMutex.release();

							LibVLC.audio_set_callbacks(mediaPlayer, untyped __cpp__('audio_play'), untyped __cpp__('audio_pause'),
								untyped __cpp__('audio_resume'), untyped NULL, untyped NULL, untyped __cpp__('this'));

							LibVLC.audio_set_volume_callback(mediaPlayer, untyped __cpp__('audio_set_volume'));

							LibVLC.audio_set_format_callbacks(mediaPlayer, untyped __cpp__('audio_setup'), untyped NULL);
						default:
							Log.warn('Unable to use a sound output.');
					}
				}
				else
					Log.warn('AudioManager\'s context isn\'t available.');
				#end
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
				{
					final metaString:String = new String(untyped rawMeta);

					cpp.Stdlib.nativeFree(untyped rawMeta);

					return metaString;
				}
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
	public function dispose():Void
	{
		if (mediaPlayer != null)
		{
			LibVLC.media_player_stop(mediaPlayer);
			LibVLC.media_player_release(mediaPlayer);
			mediaPlayer = null;
		}

		if (Lib.application != null)
		{
			if (Lib.application.onUpdate.has(update))
				Lib.application.onUpdate.remove(update);

			if (Lib.application.window != null)
			{
				if (Lib.application.window.onActivate.has(resume))
					Lib.application.window.onActivate.remove(resume);

				if (Lib.application.window.onDeactivate.has(pause))
					Lib.application.window.onDeactivate.remove(pause);
			}
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

		@:nullSafety(Off)
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

		#if (HXVLC_OPENAL && lime_openal)
		alMutex.acquire();

		if (alAudioContext != null)
		{
			if (alSource != null)
			{
				alAudioContext.sourceStop(alSource);
				alAudioContext.deleteSource(alSource);
				alSource = null;
			}

			if (alBuffers != null)
			{
				alAudioContext.deleteBuffers(alBuffers);
				alBuffers = null;
			}

			alAudioContext = null;
		}

		alSamplesBuffer = [];

		alMutex.release();
		#end
	}

	@:noCompletion
	private function update(deltaTime:Int):Void
	{
		eventsMutex.acquire();

		if (!events.contains(true))
		{
			eventsMutex.release();
			return;
		}

		if (events[0])
		{
			events[0] = false;

			onOpening.dispatch();
		}

		if (events[1])
		{
			events[1] = false;

			onPlaying.dispatch();
		}

		if (events[2])
		{
			events[2] = false;

			onStopped.dispatch();
		}

		if (events[3])
		{
			events[3] = false;

			onPaused.dispatch();
		}

		if (events[4])
		{
			events[4] = false;

			onEndReached.dispatch();
		}

		if (events[5])
		{
			events[5] = false;

			final errmsg:String = LibVLC.errmsg();

			if (errmsg != null && errmsg.length > 0)
				onEncounteredError.dispatch(errmsg);
			else
				onEncounteredError.dispatch('Unknown error');
		}

		if (events[6])
		{
			events[6] = false;

			onMediaChanged.dispatch();
		}

		if (events[7])
		{
			events[7] = false;

			onCorked.dispatch();
		}

		if (events[8])
		{
			events[8] = false;

			onUncorked.dispatch();
		}

		if (events[9])
		{
			events[9] = false;

			onTimeChanged.dispatch(time);
		}

		if (events[10])
		{
			events[10] = false;

			onPositionChanged.dispatch(position);
		}

		if (events[11])
		{
			events[11] = false;

			onLengthChanged.dispatch(length);
		}

		if (events[12])
		{
			events[12] = false;

			onChapterChanged.dispatch(chapter);
		}

		if (events[13])
		{
			events[13] = false;

			onMediaMetaChanged.dispatch();
		}

		if (events[14])
		{
			events[14] = false;

			if (mediaPlayer != null)
			{
				final currentMediaItem:cpp.RawPointer<LibVLC_Media_T> = LibVLC.media_player_get_media(mediaPlayer);

				if (currentMediaItem != null)
					onMediaParsedChanged.dispatch(LibVLC.media_get_parsed_status(currentMediaItem));
			}
		}

		eventsMutex.release();
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
				{
					final mrlString:String = new String(untyped rawMrl);

					cpp.Stdlib.nativeFree(untyped rawMrl);

					return mrlString;
				}
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
				final currentMediaStats:LibVLC_Media_Stats_T = LibVLC_Media_Stats_T.alloc();

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
			LibVLC.media_player_set_time(mediaPlayer, #if (haxe <= "4.2.5") cast #end value);

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
	private function get_outputModules():Null<Array<{name:String, description:String}>>
	{
		if (Handle.instance != null)
		{
			final audioOutput:cpp.RawPointer<LibVLC_Audio_Output_T> = LibVLC.audio_output_list_get(Handle.instance);

			if (audioOutput != null)
			{
				final outputs:Array<{name:String, description:String}> = [];

				var temp:cpp.RawPointer<LibVLC_Audio_Output_T> = audioOutput;

				while (temp != null)
				{
					outputs.push({name: new String(untyped temp[0].psz_name), description: new String(untyped temp[0].psz_description)});

					temp = temp[0].p_next;
				}

				LibVLC.audio_output_list_release(audioOutput);

				return outputs;
			}
		}

		return null;
	}

	@:noCompletion
	private function set_output(value:String):String
	{
		if (mediaPlayer != null)
			LibVLC.audio_output_set(mediaPlayer, value);

		return value;
	}

	@:noCompletion
	private function get_mute():Bool
	{
		return mediaPlayer != null && LibVLC.audio_get_mute(mediaPlayer) > 0;
	}

	@:noCompletion
	private function set_mute(value:Bool):Bool
	{
		if (mediaPlayer != null)
			LibVLC.audio_set_mute(mediaPlayer, value ? 1 : 0);

		return value;
	}

	@:noCompletion
	private function get_volume():Int
	{
		return mediaPlayer != null ? LibVLC.audio_get_volume(mediaPlayer) : -1;
	}

	@:noCompletion
	private function set_volume(value:Int):Int
	{
		if (mediaPlayer != null)
			LibVLC.audio_set_volume(mediaPlayer, value);

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

	// These functions act as Haxe interop methods that are called from the C++ glue code.
	// They handle critical operations for video and audio playback, including locking/unlocking
	// textures, managing memory for video planes, synchronizing with GPU or CPU-based rendering,
	// and interfacing with the audio subsystem for playback, pause, and volume control.
	//
	// The functions interact with raw pointers from the C++ layer, handling tasks such as
	// memory allocation, pointer manipulation, and format setup for video and audio streams.
	// Mutexes are used to ensure thread-safe access to shared resources like textures and audio buffers.
	// The functions also coordinate between the Haxe main loop and the underlying C++ systems,
	// ensuring operations that need to run on the main thread (e.g., rendering) are properly synchronized.

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

					textureMutex.release();
				});
			}
		}
	}

	@:access(openfl.display.BitmapData)
	@:keep
	@:noCompletion
	@:unreflective
	private function videoFormatSetup(chroma:cpp.CastCharStar, width:cpp.RawPointer<cpp.UInt32>, height:cpp.RawPointer<cpp.UInt32>,
			pitches:cpp.RawPointer<cpp.UInt32>, lines:cpp.RawPointer<cpp.UInt32>):Int
	{
		cpp.Stdlib.nativeMemcpy(cast chroma, cast cpp.CastCharStar.fromString("RV32"), 4);

		final originalWidth:cpp.UInt32 = width[0];
		final originalHeight:cpp.UInt32 = height[0];

		textureMutex.acquire();

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
					texture = Lib.current.stage.context3D.createRectangleTexture(textureWidth, textureHeight, Context3DTextureFormat.BGRA, true);
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

		pitches[0] = textureWidth * 4;
		lines[0] = textureHeight;

		return 1;
	}

	@:keep
	@:noCompletion
	@:unreflective
	private function audioPlay(samples:cpp.RawPointer<cpp.UInt8>, count:cpp.UInt32, pts:cpp.Int64):Void
	{
		// TODO: Audio synchronisation in case of a sudden desync using pts.
		#if (HXVLC_OPENAL && lime_openal)
		if (alAudioContext != null && alSource != null && alBuffers != null)
		{
			alMutex.acquire();

			if (alSamplesBuffer == null)
				alSamplesBuffer = new BytesData();

			cpp.NativeArray.setUnmanagedData(alSamplesBuffer, cast samples, count);

			final processedBuffers:Int = alAudioContext.getSourcei(alSource, AL.BUFFERS_PROCESSED);

			if (processedBuffers > 0)
			{
				for (alBuffer in alAudioContext.sourceUnqueueBuffers(alSource, processedBuffers))
					alBuffers.push(alBuffer);
			}

			if (alBuffers.length > 0)
			{
				final alBuffer:Null<ALBuffer> = alBuffers.shift();

				if (alBuffer != null)
				{
					alAudioContext.bufferData(alBuffer, alChannels == 2 ? AL.FORMAT_STEREO16 : AL.FORMAT_MONO16,
						UInt8Array.fromBytes(Bytes.ofData(alSamplesBuffer)), alSamplesBuffer.length * 2 * alChannels, alSampleRate);
					alAudioContext.sourceQueueBuffer(alSource, alBuffer);
				}

				if (alAudioContext.getSourcei(alSource, AL.SOURCE_STATE) != AL.PLAYING)
					alAudioContext.sourcePlay(alSource);
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
		#if (HXVLC_OPENAL && lime_openal)
		if (alAudioContext != null && alSource != null)
		{
			alMutex.acquire();

			if (alAudioContext.getSourcei(alSource, AL.SOURCE_STATE) == AL.PLAYING)
				alAudioContext.sourcePause(alSource);

			alMutex.release();
		}
		#end
	}

	@:keep
	@:noCompletion
	@:unreflective
	private function audioResume(pts:cpp.Int64):Void
	{
		#if (HXVLC_OPENAL && lime_openal)
		if (alAudioContext != null && alSource != null)
		{
			alMutex.acquire();

			if (alAudioContext.getSourcei(alSource, AL.SOURCE_STATE) != AL.PLAYING)
				alAudioContext.sourcePlay(alSource);

			alMutex.release();
		}
		#end
	}

	@:keep
	@:noCompletion
	@:unreflective
	private function audioSetup(format:cpp.CastCharStar, rate:cpp.RawPointer<cpp.UInt32>, channels:cpp.RawPointer<cpp.UInt32>):Int
	{
		#if (HXVLC_OPENAL && lime_openal)
		cpp.Stdlib.nativeMemcpy(cast format, cast cpp.CastCharStar.fromString("S16N"), 4);

		alMutex.acquire();

		alSampleRate = rate[0];

		final originalChannels:cpp.UInt32 = channels[0];

		if (originalChannels > 2)
			channels[0] = 2;

		alChannels = channels[0];

		alMutex.release();
		#end

		return 0;
	}

	@:keep
	@:noCompletion
	@:unreflective
	private function audioSetVolume(volume:Single, mute:Bool):Void
	{
		#if (HXVLC_OPENAL && lime_openal)
		if (alAudioContext != null && alSource != null)
		{
			alMutex.acquire();

			alAudioContext.sourcef(alSource, AL.GAIN, mute ? 0 : volume);

			alMutex.release();
		}
		#end
	}
}
