package hxvlc.openfl;

#if (!cpp && !(desktop || android))
#error 'The current target platform isn\'t supported by hxvlc.'
#end
import hxvlc.libvlc.LibVLC;
import hxvlc.libvlc.Types;
import lime.app.Event;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display3D.textures.RectangleTexture;
import openfl.Lib;

using haxe.io.Path;

#if android
@:headerInclude('android/log.h')
#end
@:headerInclude('assert.h')
@:headerInclude('stdint.h')
@:headerInclude('stdio.h')
@:cppNamespaceCode('
static unsigned format_setup(void **data, char *chroma, unsigned *width, unsigned *height, unsigned *pitches, unsigned *lines)
{
	Video_obj *self = reinterpret_cast<Video_obj *>(*data);

	unsigned formatWidth = (*width);
	unsigned formatHeight = (*height);

	self->videoWidth = formatWidth;
	self->videoHeight = formatHeight;

	(*pitches) = formatWidth * 4;
	(*lines) = formatHeight;

	strcpy(chroma, "RV32");

	self->events[7] = true;

	if (self->pixels != NULL)
		delete self->pixels;

	self->pixels = new uint8_t[formatWidth * formatHeight * 4];
	return 1;
}

static void *lock(void *data, void **p_pixels)
{
	Video_obj *self = reinterpret_cast<Video_obj *>(data);
	(*p_pixels) = self->pixels;
	return NULL; /* picture identifier, not needed here */
}

static void unlock(void *data, void *id, void *const *p_pixels)
{
	assert(id == NULL); /* picture identifier, not needed here */
}

static void display(void *data, void *id)
{
	assert(id == NULL); /* picture identifier, not needed here */
}

static void callbacks(const libvlc_event_t *event, void *data)
{
	Video_obj *self = reinterpret_cast<Video_obj *>(data);

	switch (event->type)
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
	}
}

static void logging(void *data, int level, const libvlc_log_t *ctx, const char *fmt, va_list args)
{
	#ifdef __ANDROID__
	switch (level)
	{
		case LIBVLC_DEBUG:
			__android_log_vprint(ANDROID_LOG_DEBUG, "HXVLC", fmt, args);
			break;
		case LIBVLC_NOTICE:
			__android_log_vprint(ANDROID_LOG_INFO, "HXVLC", fmt, args);
			break;
		case LIBVLC_WARNING:
			__android_log_vprint(ANDROID_LOG_WARN, "HXVLC", fmt, args);
			break;
		case LIBVLC_ERROR:
			__android_log_vprint(ANDROID_LOG_ERROR, "HXVLC", fmt, args);
			break;
	}
	#else
	vprintf(fmt, args);
	#endif
}')
class Video extends Bitmap
{
	/**
	 * The video format width, in pixels.
	 */
	public var videoWidth(default, null):Int = 0;

	/**
	 * The video format height, in pixels.
	 */
	public var videoHeight(default, null):Int = 0;

	/**
	 * The video's time in milliseconds.
	 */
	public var time(get, set):Int;

	/**
	 * The video's position as percentage between `0.0` and `1.0`.
	 */
	public var position(get, set):Single;

	/**
	 * The video's length in milliseconds.
	 */
	public var length(get, never):Int;

	/**
	 * The video's duration.
	 */
	public var duration(get, never):Int;

	/**
	 * The video's media resource locator.
	 */
	public var mrl(get, never):String;

	/**
	 * The video's audio volume in percents (0 = mute, 100 = nominal / 0dB).
	 */
	public var volume(get, set):Int;

	/**
	 * The video's audio channel.
	 *
	 * - [Stereo] = 1
	 * - [RStereo] = 2
	 * - [Left] = 3
	 * - [Right] = 4
	 * - [Dolbys] = 5
	 */
	public var channel(get, set):Int;

	/**
	 * The video's audio delay in microseconds.
	 */
	public var delay(get, set):Int;

	/**
	 * The video's play rate.
	 */
	public var rate(get, set):Single;

	/**
	 * Whether the video is playing or not.
	 */
	public var isPlaying(get, never):Bool;

	/**
	 * Whether the video is seekable or not.
	 */
	public var isSeekable(get, never):Bool;

	/**
	 * Whether the video can be paused or not.
	 */
	public var canPause(get, never):Bool;

	/**
	 * The video's mute status.
	 */
	public var mute(get, set):Bool;

	/**
	 * An event that is dispatched when the video is opening.
	 */
	public var onOpening(default, null):Event<Void->Void>;

	/**
	 * An event that is dispatched when the video is playing.
	 */
	public var onPlaying(default, null):Event<Void->Void>;

	/**
	 * An event that is dispatched when the video stopped.
	 */
	public var onStopped(default, null):Event<Void->Void>;

	/**
	 * An event that is dispatched when the video is paused.
	 */
	public var onPaused(default, null):Event<Void->Void>;

	/**
	 * An event that is dispatched when the video reached the end.
	 */
	public var onEndReached(default, null):Event<Void->Void>;

	/**
	 * An event that is dispatched when the video encountered an error.
	 */
	public var onEncounteredError(default, null):Event<String->Void>;

	/**
	 * An event that is dispatched when the media is changed.
	 */
	public var onMediaChanged(default, null):Event<Void->Void>;

	/**
	 * An event that is dispatched when the format is being initialized.
	 */
	public var onFormatSetup(default, null):Event<Void->Void>;

	@:noCompletion private var oldTime:Float = 0;
	@:noCompletion private var deltaTime:Float = 0;
	@:noCompletion private var events:Array<Bool> = [];
	@:noCompletion private var texture:RectangleTexture;
	@:noCompletion private var pixels:cpp.RawPointer<cpp.UInt8>;
	@:noCompletion private var instance:cpp.RawPointer<LibVLC_Instance_T>;
	@:noCompletion private var mediaItem:cpp.RawPointer<LibVLC_Media_T>;
	@:noCompletion private var mediaPlayer:cpp.RawPointer<LibVLC_MediaPlayer_T>;
	@:noCompletion private var eventManager:cpp.RawPointer<LibVLC_EventManager_T>;

	/**
	 * Initializes a Video object.
	 *
	 * @param smoothing Whether or not the video is smoothed when scaled.
	 */
	public function new(smoothing:Bool = true):Void
	{
		super(bitmapData, AUTO, smoothing);

		events.resize(7);
		for (i in 0...events.length)
			events[i] = false;

		onOpening = new Event<Void->Void>();
		onPlaying = new Event<Void->Void>();
		onStopped = new Event<Void->Void>();
		onPaused = new Event<Void->Void>();
		onEndReached = new Event<Void->Void>();
		onEncounteredError = new Event<String->Void>();
		onMediaChanged = new Event<Void->Void>();
		onFormatSetup = new Event<Void->Void>();

		#if android
		Sys.putEnv('VLC_DATA_PATH', '/system/usr/share');
		#end

		#if (windows || macos)
		Sys.putEnv('VLC_PLUGIN_PATH', '${Sys.programPath().directory()}/plugins');

		untyped __cpp__('const char *args[] = {
			"--drop-late-frames",
			"--reset-config",
			"--intf=dummy",
			"--text-renderer=dummy",
			"--no-video-title-show",
			"--no-snapshot-preview",
			"--no-stats",
			"--no-spu",
			"--no-interact",
			"--no-osd",
			"--no-lua",
			"--reset-plugins-cache"
		};');
		#else
		untyped __cpp__('const char *args[] = {
			"--drop-late-frames",
			"--intf=dummy",
			"--text-renderer=dummy",
			"--no-video-title-show",
			"--no-snapshot-preview",
			"--no-stats",
			"--no-spu",
			"--no-interact",
			"--no-osd",
			"--no-lua"
		};');
		#end

		instance = LibVLC.create(untyped __cpp__('sizeof(args) / sizeof(*args)'), untyped __cpp__('args'));

		#if HXVLC_LOGGING
		LibVLC.log_set(instance, untyped __cpp__('logging'), untyped __cpp__('NULL'));
		#end
	}

	/**
	 * Call this function to load a video.
	 *
	 * @param location The local filesystem path or the media location url.
	 * @param repeat The number of times the video should repeat itself.
	 */
	public function load(location:String, repeat:Int = 0):Void
	{
		if (location != null && location.indexOf('://') != -1)
			mediaItem = LibVLC.media_new_location(instance, location);
		else if (location != null && location.isAbsolute())
			mediaItem = LibVLC.media_new_path(instance, #if windows location.normalize().split('/').join('\\') #else location.normalize() #end);
		else
			return false;

		// 65535 is the maximum `unsigned short` size.
		LibVLC.media_add_option(mediaItem, repeat > 65535 ? "input-repeat=65535" : "input-repeat=" + repeat);

		if (mediaPlayer == null)
			mediaPlayer = LibVLC.media_player_new_from_media(mediaItem);
		else
			LibVLC.media_player_set_media(mediaPlayer, mediaItem);

		LibVLC.media_release(mediaItem);

		if (eventManager == null && mediaPlayer != null)
		{
			eventManager = LibVLC.media_player_event_manager(mediaPlayer);

			LibVLC.event_attach(eventManager, LibVLC_MediaPlayerOpening, untyped __cpp__('callbacks'), untyped __cpp__('this'));
			LibVLC.event_attach(eventManager, LibVLC_MediaPlayerPlaying, untyped __cpp__('callbacks'), untyped __cpp__('this'));
			LibVLC.event_attach(eventManager, LibVLC_MediaPlayerStopped, untyped __cpp__('callbacks'), untyped __cpp__('this'));
			LibVLC.event_attach(eventManager, LibVLC_MediaPlayerPaused, untyped __cpp__('callbacks'), untyped __cpp__('this'));
			LibVLC.event_attach(eventManager, LibVLC_MediaPlayerEndReached, untyped __cpp__('callbacks'), untyped __cpp__('this'));
			LibVLC.event_attach(eventManager, LibVLC_MediaPlayerEncounteredError, untyped __cpp__('callbacks'), untyped __cpp__('this'));
			LibVLC.event_attach(eventManager, LibVLC_MediaPlayerMediaChanged, untyped __cpp__('callbacks'), untyped __cpp__('this'));
		}

		LibVLC.video_set_format_callbacks(mediaPlayer, untyped __cpp__('format_setup'), untyped __cpp__('NULL'));
		LibVLC.video_set_callbacks(mediaPlayer, untyped __cpp__('lock'), untyped __cpp__('unlock'), untyped __cpp__('display'), untyped __cpp__('this'));
	}

	/**
	 * Call this function to play a video.
	 *
	 * @return `true` if the video started playing or `false` if there's an error.
	 */
	public function play():Bool
	{
		if (mediaPlayer != null)
			return LibVLC.media_player_play(mediaPlayer) == 0;

		return false;
	}

	/**
	 * Call this function to stop the video.
	 */
	public function stop():Void
	{
		if (mediaPlayer != null)
			LibVLC.media_player_stop(mediaPlayer);
	}

	/**
	 * Call this function to pause the video.
	 */
	public function pause():Void
	{
		if (mediaPlayer != null)
			LibVLC.media_player_set_pause(mediaPlayer, 1);
	}

	/**
	 * Call this function to resume the video.
	 */
	public function resume():Void
	{
		if (mediaPlayer != null)
			LibVLC.media_player_set_pause(mediaPlayer, 0);
	}

	/**
	 * Call this function to toggle the pause of the video.
	 */
	public function togglePaused():Void
	{
		if (mediaPlayer != null)
			LibVLC.media_player_pause(mediaPlayer);
	}

	/**
	 * Frees libvlc and the memory that is used to store the Video object.
	 */
	public function dispose():Void
	{
		if (eventManager != null)
		{
			LibVLC.event_detach(eventManager, LibVLC_MediaPlayerOpening, untyped __cpp__('callbacks'), untyped __cpp__('this'));
			LibVLC.event_detach(eventManager, LibVLC_MediaPlayerPlaying, untyped __cpp__('callbacks'), untyped __cpp__('this'));
			LibVLC.event_detach(eventManager, LibVLC_MediaPlayerStopped, untyped __cpp__('callbacks'), untyped __cpp__('this'));
			LibVLC.event_detach(eventManager, LibVLC_MediaPlayerPaused, untyped __cpp__('callbacks'), untyped __cpp__('this'));
			LibVLC.event_detach(eventManager, LibVLC_MediaPlayerEndReached, untyped __cpp__('callbacks'), untyped __cpp__('this'));
			LibVLC.event_detach(eventManager, LibVLC_MediaPlayerEncounteredError, untyped __cpp__('callbacks'), untyped __cpp__('this'));
			LibVLC.event_detach(eventManager, LibVLC_MediaPlayerMediaChanged, untyped __cpp__('callbacks'), untyped __cpp__('this'));
		}

		if (mediaPlayer != null)
		{
			LibVLC.media_player_stop(mediaPlayer);
			LibVLC.media_player_release(mediaPlayer);
		}

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

		videoWidth = 0;
		videoHeight = 0;
		pixels = null;

		events.splice(0, events.length);

		if (instance != null)
		{
			#if HXVLC_LOGGING
			LibVLC.log_unset(instance);
			#end
			LibVLC.release(instance);
		}

		eventManager = null;
		mediaPlayer = null;
		mediaItem = null;
		instance = null;
	}

	// Get & Set Methods
	@:noCompletion private function get_time():Int
	{
		if (mediaPlayer != null)
			return cast(LibVLC.media_player_get_time(mediaPlayer), Int);

		return -1;
	}

	@:noCompletion private function set_time(value:Int):Int
	{
		if (mediaPlayer != null)
			LibVLC.media_player_set_time(mediaPlayer, value);

		return value;
	}

	@:noCompletion private function get_position():Single
	{
		if (mediaPlayer != null)
			return LibVLC.media_player_get_position(mediaPlayer);

		return -1;
	}

	@:noCompletion private function set_position(value:Single):Single
	{
		if (mediaPlayer != null)
			LibVLC.media_player_set_position(mediaPlayer, value);

		return value;
	}

	@:noCompletion private function get_length():Int
	{
		if (mediaPlayer != null)
			return cast(LibVLC.media_player_get_length(mediaPlayer), Int);

		return -1;
	}

	@:noCompletion private function get_duration():Int
	{
		if (mediaItem != null)
			return cast(LibVLC.media_get_duration(mediaItem), Int);

		return -1;
	}

	@:noCompletion private function get_mrl():String
	{
		if (mediaItem != null)
			return cast(LibVLC.media_get_mrl(mediaItem), String);

		return null;
	}

	@:noCompletion private function get_volume():Int
	{
		if (mediaPlayer != null)
			return LibVLC.audio_get_volume(mediaPlayer);

		return 0;
	}

	@:noCompletion private function set_volume(value:Int):Int
	{
		if (mediaPlayer != null)
			LibVLC.audio_set_volume(mediaPlayer, value);

		return value;
	}

	@:noCompletion private function get_channel():Int
	{
		if (mediaPlayer != null)
			return LibVLC.audio_get_channel(mediaPlayer);

		return -1;
	}

	@:noCompletion private function set_channel(value:Int):Int
	{
		if (mediaPlayer != null)
			LibVLC.audio_set_channel(mediaPlayer, value);

		return value;
	}

	@:noCompletion private function get_delay():Int
	{
		if (mediaPlayer != null)
			return cast(LibVLC.audio_get_delay(mediaPlayer), Int);

		return -1;
	}

	@:noCompletion private function set_delay(value:Int):Int
	{
		if (mediaPlayer != null)
			LibVLC.audio_set_delay(mediaPlayer, value);

		return value;
	}

	@:noCompletion private function get_rate():Single
	{
		if (mediaPlayer != null)
			return LibVLC.media_player_get_rate(mediaPlayer);

		return -1;
	}

	@:noCompletion private function set_rate(value:Single):Single
	{
		if (mediaPlayer != null)
			LibVLC.media_player_set_rate(mediaPlayer, value);

		return value;
	}

	@:noCompletion private function get_isPlaying():Bool
	{
		if (mediaPlayer != null)
			return LibVLC.media_player_is_playing(mediaPlayer);

		return false;
	}

	@:noCompletion private function get_isSeekable():Bool
	{
		if (mediaPlayer != null)
			return LibVLC.media_player_is_seekable(mediaPlayer);

		return false;
	}

	@:noCompletion private function get_canPause():Bool
	{
		if (mediaPlayer != null)
			return LibVLC.media_player_can_pause(mediaPlayer);

		return false;
	}

	@:noCompletion private function get_mute():Bool
	{
		if (mediaPlayer != null)
			return LibVLC.audio_get_mute(mediaPlayer) > 0;

		return false;
	}

	@:noCompletion private function set_mute(value:Bool):Bool
	{
		if (mediaPlayer != null)
			LibVLC.audio_set_mute(mediaPlayer, value ? 1 : 0);

		return value;
	}

	// Overrides
	@:noCompletion private override function __enterFrame(elapsed:Int):Void
	{
		checkEvents();

		if (__renderable && isPlaying)
		{
			deltaTime += elapsed;

			if (Math.abs(deltaTime - oldTime) >= 1000 / Lib.application.window.displayMode.refreshRate)
				oldTime = deltaTime;
			else
				return;

			if (texture != null && pixels != null)
				texture.uploadFromByteArray(cpp.Pointer.fromRaw(pixels).toUnmanagedArray(videoWidth * videoHeight * 4), 0);

			__setRenderDirty();
		}
	}

	@:noCompletion private override function set_bitmapData(value:BitmapData):BitmapData
	{
		return __bitmapData = value;
	}

	// Internal Methods
	@:noCompletion private function checkEvents():Void
	{
		if (!events.contains(true))
			return;

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

			onEncounteredError.dispatch(cast(LibVLC.errmsg(), String));
		}

		if (events[6])
		{
			events[6] = false;

			onMediaChanged.dispatch();
		}

		if (events[7])
		{
			events[7] = false;

			if (bitmapData != null && texture != null)
			{
				if (bitmapData.width != videoWidth && bitmapData.height != videoHeight)
				{
					bitmapData.dispose();
					texture.dispose();
				}
				else
					return;
			}

			texture = Lib.current.stage.context3D.createRectangleTexture(videoWidth, videoHeight, BGRA, true);
			bitmapData = BitmapData.fromTexture(texture);

			onFormatSetup.dispatch();
		}
	}
}
