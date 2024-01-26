package hxvlc.openfl;

#if (!cpp && !(desktop || mobile))
#error 'The current target platform isn\'t supported by hxvlc.'
#end
import haxe.io.BytesData;
import haxe.io.Path;
import haxe.Exception;
import haxe.Int64;
import hxvlc.libvlc.Handle;
import hxvlc.libvlc.LibVLC;
import hxvlc.libvlc.Types;
import lime.app.Event;
import lime.utils.Log;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display3D.textures.Texture;
import openfl.Lib;

using StringTools;

@:headerInclude('assert.h')
@:headerInclude('stdio.h')
@:cppNamespaceCode('
static void *lock(void *opaque, void **planes)
{
	Video_obj *self = reinterpret_cast<Video_obj *>(opaque);

	if (self->planes != NULL)
		(*planes) = self->planes;

	return NULL; /* picture identifier, not needed here */
}

static void unlock(void *opaque, void *picture, void *const *planes)
{
	#ifdef assert
	assert(picture == NULL); /* picture identifier, not needed here */
	#endif
}

static void display(void *opaque, void *picture)
{
	Video_obj *self = reinterpret_cast<Video_obj *>(opaque);

	self->events[8] = true;

	#ifdef assert
	assert(picture == NULL); /* picture identifier, not needed here */
	#endif
}

static unsigned format_setup(void **opaque, char *chroma, unsigned *width, unsigned *height, unsigned *pitches, unsigned *lines)
{
	Video_obj *self = reinterpret_cast<Video_obj *>(*opaque);

	strcpy(chroma, "RV32");

	self->formatWidth = (*width);
	self->formatHeight = (*height);

	(*pitches) = self->formatWidth * 4;
	(*lines) = self->formatHeight;

	self->events[7] = true;

	if (self->planes != NULL)
		delete[] self->planes;

	self->planes = new unsigned char[self->formatWidth * self->formatHeight * 4];

	return 1;
}

static void callbacks(const libvlc_event_t *p_event, void *p_data)
{
	Video_obj *self = reinterpret_cast<Video_obj *>(p_data);

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
	}
}')
@:access(hxvlc.libvlc.Handle)
class Video extends Bitmap
{
	/**
	 * The format width, in pixels.
	 */
	public var formatWidth(default, null):Int = 0;

	/**
	 * The format height, in pixels.
	 */
	public var formatHeight(default, null):Int = 0;

	/**
	 * The media player's time in milliseconds.
	 */
	public var time(get, set):Int64;

	/**
	 * The media player's position as percentage between `0.0` and `1.0`.
	 */
	public var position(get, set):Single;

	/**
	 * The media player's chapter.
	 */
	public var chapter(get, set):Int;

	/**
	 * The media player's chapter count.
	 */
	public var chapterCount(get, never):Int;

	/**
	 * The media player's length in milliseconds.
	 */
	public var length(get, never):Int64;

	/**
	 * The media's duration.
	 */
	public var duration(get, never):Int64;

	/**
	 * The media resource locator.
	 */
	public var mrl(get, never):String;

	/**
	 * The audio volume in percents (0 = mute, 100 = nominal / 0dB).
	 */
	public var volume(get, set):Int;

	/**
	 * The audio channel.
	 *
	 * - [Stereo] = 1
	 * - [RStereo] = 2
	 * - [Left] = 3
	 * - [Right] = 4
	 * - [Dolbys] = 5
	 */
	public var channel(get, set):Int;

	/**
	 * The audio delay in microseconds.
	 */
	public var delay(get, set):Int64;

	/**
	 * The media player's play rate.
	 */
	public var rate(get, set):Single;

	/**
	 * Whether the media player is playing or not.
	 */
	public var isPlaying(get, never):Bool;

	/**
	 * Whether the media player is seekable or not.
	 */
	public var isSeekable(get, never):Bool;

	/**
	 * Whether the media player can be paused or not.
	 */
	public var canPause(get, never):Bool;

	/**
	 * Whether the media player is able to play.
	 */
	public var willPlay(get, never):Bool;

	/**
	 * The audio's mute status.
	 */
	public var mute(get, set):Bool;

	/**
	 * The media player's role.
	 */
	public var role(get, set):UInt;

	/**
	 * An event that is dispatched when the media player is opening.
	 */
	public var onOpening(default, null):Event<Void->Void>;

	/**
	 * An event that is dispatched when the media player is playing.
	 */
	public var onPlaying(default, null):Event<Void->Void>;

	/**
	 * An event that is dispatched when the media player stopped.
	 */
	public var onStopped(default, null):Event<Void->Void>;

	/**
	 * An event that is dispatched when the media player is paused.
	 */
	public var onPaused(default, null):Event<Void->Void>;

	/**
	 * An event that is dispatched when the media player reached the end.
	 */
	public var onEndReached(default, null):Event<Void->Void>;

	/**
	 * An event that is dispatched when the media player encountered an error.
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

	/**
	 * An event that is dispatched when the media is being displayed.
	 */
	public var onDisplay(default, null):Event<Void->Void>;

	@:noCompletion private var mediaItem:cpp.RawPointer<LibVLC_Media_T>;
	@:noCompletion private var mediaPlayer:cpp.RawPointer<LibVLC_MediaPlayer_T>;
	@:noCompletion private var eventManager:cpp.RawPointer<LibVLC_EventManager_T>;

	@:noCompletion private var events:Array<Bool> = [false, false, false, false, false, false, false, false, false];
	@:noCompletion private var planes:cpp.RawPointer<cpp.UInt8>;
	@:noCompletion private var texture:Texture;

	/**
	 * Initializes a Video object.
	 *
	 * @param smoothing Whether or not the object is smoothed when scaled.
	 */
	public function new(smoothing:Bool = true):Void
	{
		super(bitmapData, AUTO, smoothing);

		onOpening = new Event<Void->Void>();
		onPlaying = new Event<Void->Void>();
		onStopped = new Event<Void->Void>();
		onPaused = new Event<Void->Void>();
		onEndReached = new Event<Void->Void>();
		onEncounteredError = new Event<String->Void>();
		onMediaChanged = new Event<Void->Void>();
		onFormatSetup = new Event<Void->Void>();
		onDisplay = new Event<Void->Void>();

		while (Handle.loadingInstance)
			Sys.sleep(0.05);

		Handle.init();
	}

	/**
	 * Call this function to load a media.
	 *
	 * @param location The local filesystem path or the media location url.
	 * @param options The additional options you can add to the LibVLC Media instance.
	 *
	 * @return `true` if the media loaded successfully or `false` if there's an error.
	 */
	public function load(location:String, ?options:Array<String>):Bool
	{
		if (Handle.instance == null)
			return false;

		if (options == null)
			options = new Array<String>();

		if (location != null && location.length > 0)
		{
			if (location.contains('://'))
				mediaItem = LibVLC.media_new_location(Handle.instance, location);
			else
			{
				#if windows
				mediaItem = LibVLC.media_new_path(Handle.instance, Path.normalize(location).split('/').join('\\'));
				#else
				mediaItem = LibVLC.media_new_path(Handle.instance, Path.normalize(location));
				#end
			}
		}
		else
			return false;

		if (mediaPlayer == null)
		{
			mediaPlayer = LibVLC.media_player_new(Handle.instance);

			if (eventManager == null)
			{
				eventManager = LibVLC.media_player_event_manager(mediaPlayer);

				Lib.current.addEventListener(openfl.events.Event.ENTER_FRAME, this_onEnterFrame);

				if (LibVLC.event_attach(eventManager, LibVLC_MediaPlayerOpening, untyped __cpp__('callbacks'), untyped __cpp__('this')) != 0)
					Log.warn('Failed to attach event (MediaPlayerOpening)');

				if (LibVLC.event_attach(eventManager, LibVLC_MediaPlayerPlaying, untyped __cpp__('callbacks'), untyped __cpp__('this')) != 0)
					Log.warn('Failed to attach event (MediaPlayerPlaying)');

				if (LibVLC.event_attach(eventManager, LibVLC_MediaPlayerStopped, untyped __cpp__('callbacks'), untyped __cpp__('this')) != 0)
					Log.warn('Failed to attach event (MediaPlayerStopped)');

				if (LibVLC.event_attach(eventManager, LibVLC_MediaPlayerPaused, untyped __cpp__('callbacks'), untyped __cpp__('this')) != 0)
					Log.warn('Failed to attach event (MediaPlayerPaused)');

				if (LibVLC.event_attach(eventManager, LibVLC_MediaPlayerEndReached, untyped __cpp__('callbacks'), untyped __cpp__('this')) != 0)
					Log.warn('Failed to attach event (MediaPlayerEndReached)');

				if (LibVLC.event_attach(eventManager, LibVLC_MediaPlayerEncounteredError, untyped __cpp__('callbacks'), untyped __cpp__('this')) != 0)
					Log.warn('Failed to attach event (MediaPlayerEncounteredError)');

				if (LibVLC.event_attach(eventManager, LibVLC_MediaPlayerMediaChanged, untyped __cpp__('callbacks'), untyped __cpp__('this')) != 0)
					Log.warn('Failed to attach event (MediaPlayerMediaChanged)');
			}

			LibVLC.video_set_callbacks(mediaPlayer, untyped __cpp__('lock'), untyped __cpp__('unlock'), untyped __cpp__('display'), untyped __cpp__('this'));
			LibVLC.video_set_format_callbacks(mediaPlayer, untyped __cpp__('format_setup'), untyped __cpp__('NULL'));
		}

		for (option in options)
			LibVLC.media_add_option(mediaItem, option);

		LibVLC.media_player_set_media(mediaPlayer, mediaItem);

		return true;
	}

	/**
	 * Call this function to play a media player.
	 *
	 * @return `true` if the media player started playing or `false` if there's an error.
	 */
	public function play():Bool
	{
		if (mediaPlayer != null)
			return LibVLC.media_player_play(mediaPlayer) == 0;

		return false;
	}

	/**
	 * Call this function to stop the media player.
	 */
	public function stop():Void
	{
		if (mediaPlayer != null)
			LibVLC.media_player_stop(mediaPlayer);
	}

	/**
	 * Call this function to pause the media player.
	 */
	public function pause():Void
	{
		if (mediaPlayer != null)
			LibVLC.media_player_set_pause(mediaPlayer, 1);
	}

	/**
	 * Call this function to resume the media player.
	 */
	public function resume():Void
	{
		if (mediaPlayer != null)
			LibVLC.media_player_set_pause(mediaPlayer, 0);
	}

	/**
	 * Call this function to toggle the pause of the media player.
	 */
	public function togglePaused():Void
	{
		if (mediaPlayer != null)
			LibVLC.media_player_pause(mediaPlayer);
	}

	/**
	 * Frees the memory that is used to store the Video object.
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

			Lib.current.removeEventListener(openfl.events.Event.ENTER_FRAME, this_onEnterFrame);
		}

		if (mediaPlayer != null)
		{
			LibVLC.media_player_stop(mediaPlayer);
			LibVLC.media_player_release(mediaPlayer);
		}

		if (mediaItem != null)
			LibVLC.media_release(mediaItem);

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

		formatWidth = formatHeight = 0;

		if (planes != null)
			untyped __cpp__('delete[] {0}', planes);

		eventManager = null;
		mediaPlayer = null;
		mediaItem = null;
	}

	// Get & Set Methods
	@:noCompletion private function get_time():Int64
	{
		if (mediaPlayer != null)
			return LibVLC.media_player_get_time(mediaPlayer);

		return -1;
	}

	@:noCompletion private function set_time(value:Int64):Int64
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

	@:noCompletion private function get_chapter():Int
	{
		if (mediaPlayer != null)
			return LibVLC.media_player_get_chapter(mediaPlayer);

		return -1;
	}

	@:noCompletion private function set_chapter(value:Int):Int
	{
		if (mediaPlayer != null)
			LibVLC.media_player_set_chapter(mediaPlayer, value);

		return value;
	}

	@:noCompletion private function get_chapterCount():Int
	{
		if (mediaItem != null)
			return LibVLC.media_player_get_chapter_count(mediaPlayer);

		return -1;
	}

	@:noCompletion private function get_length():Int64
	{
		if (mediaPlayer != null)
			return LibVLC.media_player_get_length(mediaPlayer);

		return -1;
	}

	@:noCompletion private function get_duration():Int64
	{
		if (mediaItem != null)
			return LibVLC.media_get_duration(mediaItem);

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

	@:noCompletion private function get_delay():Int64
	{
		if (mediaPlayer != null)
			return LibVLC.audio_get_delay(mediaPlayer);

		return -1;
	}

	@:noCompletion private function set_delay(value:Int64):Int64
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
			return LibVLC.media_player_is_playing(mediaPlayer) != 0;

		return false;
	}

	@:noCompletion private function get_isSeekable():Bool
	{
		if (mediaPlayer != null)
			return LibVLC.media_player_is_seekable(mediaPlayer) != 0;

		return false;
	}

	@:noCompletion private function get_canPause():Bool
	{
		if (mediaPlayer != null)
			return LibVLC.media_player_can_pause(mediaPlayer) != 0;

		return false;
	}

	@:noCompletion private function get_willPlay():Bool
	{
		if (mediaPlayer != null)
			return LibVLC.media_player_will_play(mediaPlayer) != 0;

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

	@:noCompletion private function get_role():UInt
	{
		if (mediaPlayer != null)
			return LibVLC.media_player_get_role(mediaPlayer);

		return 0;
	}

	@:noCompletion private function set_role(value:UInt):UInt
	{
		if (mediaPlayer != null)
			LibVLC.media_player_set_role(mediaPlayer, value);

		return value;
	}

	// Private Methods
	@:noCompletion private function this_onEnterFrame(event:openfl.events.Event):Void
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

			final errmsg:String = cast(LibVLC.errmsg(), String);

			onEncounteredError.dispatch(errmsg != null && errmsg.length > 0 ? errmsg : 'Could not specify the error');
		}

		if (events[6])
		{
			events[6] = false;

			onMediaChanged.dispatch();
		}

		if (events[7])
		{
			events[7] = false;

			var mustRecreate:Bool = false;

			if (bitmapData != null)
			{
				if (bitmapData.width != formatWidth && bitmapData.height != formatHeight)
				{
					bitmapData.dispose();

					if (texture != null)
						texture.dispose();

					mustRecreate = true;
				}
			}
			else
				mustRecreate = true;

			if (mustRecreate)
			{
				try
				{
					if (stage != null && stage.context3D != null)
						texture = stage.context3D.createTexture(formatWidth, formatHeight, BGRA, true);
					else
					{
						Log.warn('Failed to use texture, resorting to CPU based image');

						bitmapData = new BitmapData(formatWidth, formatHeight, true, 0);
					}
				}
				catch (e:Exception)
					Log.error('Failed to create video\'s texture');

				if (texture != null)
					bitmapData = BitmapData.fromTexture(texture);

				onFormatSetup.dispatch();
			}
		}

		if (events[8])
		{
			events[8] = false;

			if (__renderable)
			{
				if (planes != null)
				{
					final planesData:BytesData = cpp.Pointer.fromRaw(planes).toUnmanagedArray(formatWidth * formatHeight * 4);

					if (texture != null)
						texture.uploadFromByteArray(planesData, 0);
					else if (bitmapData != null)
						bitmapData.setPixels(bitmapData.rect, planesData);
				}

				__setRenderDirty();
			}

			onDisplay.dispatch();
		}
	}

	// Overrides
	@:noCompletion private override function set_bitmapData(value:BitmapData):BitmapData
	{
		return __bitmapData = value;
	}
}
