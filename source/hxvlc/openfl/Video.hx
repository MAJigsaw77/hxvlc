package hxvlc.openfl;

#if (!cpp && !(desktop || mobile))
#error 'The current target platform isn\'t supported by hxvlc.'
#end
import haxe.io.Bytes;
import haxe.io.BytesData;
import haxe.io.Path;
import haxe.Exception;
import haxe.Int64;
import hxvlc.externs.LibVLC;
import hxvlc.externs.Types;
import hxvlc.util.Handle;
import hxvlc.util.OneOfThree;
import lime.app.Application;
import lime.app.Event;
#if lime_openal
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
import openfl.Lib;

using StringTools;

/**
 * This class represents a video player that utilizes LibVLC to play videos.
 *
 * It extends a Bitmap object to provide a seamless integration with existing display objects.
 */
@:cppNamespaceCode('
#ifndef _MSC_VER
static int media_open(void *opaque, void **datap, uint64_t *sizep)
{
	hx::SetTopOfStack((int *)99, true);

	Video_obj *self = reinterpret_cast<Video_obj *>(opaque);

	(*datap) = opaque;

	(*sizep) = self->mediaSize;

	hx::SetTopOfStack((int *)0, true);

	return 0;
}

static ssize_t media_read(void *opaque, unsigned char *buf, size_t len)
{
	hx::SetTopOfStack((int *)99, true);

	Video_obj *self = reinterpret_cast<Video_obj *>(opaque);

	if (self->mediaOffset >= self->mediaSize)
	{
		hx::SetTopOfStack((int *)0, true);

		return 0;
	}

	uint64_t toRead = len < (self->mediaSize - self->mediaOffset) ? len : (self->mediaSize - self->mediaOffset);

	if (self->mediaData == NULL || (self->mediaOffset > self->mediaSize - toRead))
	{
		hx::SetTopOfStack((int *)0, true);

		return -1;
	}

	memcpy(buf, &self->mediaData[self->mediaOffset], (size_t) toRead);

	self->mediaOffset += toRead;

	hx::SetTopOfStack((int *)0, true);

	return (ssize_t) toRead;
}

static int media_seek(void *opaque, uint64_t offset)
{
	hx::SetTopOfStack((int *)99, true);

	Video_obj *self = reinterpret_cast<Video_obj *>(opaque);

	if (offset > self->mediaSize)
	{
		hx::SetTopOfStack((int *)0, true);

		return -1;
	}

	self->mediaOffset = offset;

	hx::SetTopOfStack((int *)0, true);

	return 0;
}
#endif

static void *video_lock(void *opaque, void **planes)
{
	hx::SetTopOfStack((int *)99, true);

	Video_obj *self = reinterpret_cast<Video_obj *>(opaque);

	if (self->planes != NULL)
		(*planes) = self->planes;

	hx::SetTopOfStack((int *)0, true);

	return NULL;
}

static void video_display(void *opaque, void *picture)
{
	hx::SetTopOfStack((int *)99, true);

	reinterpret_cast<Video_obj *>(opaque)->events[1] = true;

	hx::SetTopOfStack((int *)0, true);
}

static unsigned video_format_setup(void **opaque, char *chroma, unsigned *width, unsigned *height, unsigned *pitches, unsigned *lines)
{
	hx::SetTopOfStack((int *)99, true);

	Video_obj *self = reinterpret_cast<Video_obj *>(*opaque);

	strcpy(chroma, "RV32");

	self->formatWidth = (*width);
	self->formatHeight = (*height);

	(*pitches) = self->formatWidth * 4;
	(*lines) = self->formatHeight;

	self->events[0] = true;

	if (self->planes != NULL)
		delete[] self->planes;

	self->planes = new unsigned char[self->formatWidth * self->formatHeight * 4];

	hx::SetTopOfStack((int *)0, true);

	return 1;
}

static void audio_play(void *data, const void *samples, unsigned count, int64_t pts)
{
	hx::SetTopOfStack((int *)99, true);

	unsigned byteCount = count * 4;

	unsigned char *soundSamples = new unsigned char[byteCount];
	memcpy(soundSamples, samples, byteCount);
	reinterpret_cast<Video_obj *>(data)->updateSound(soundSamples, byteCount);

	delete[] soundSamples;

	hx::SetTopOfStack((int *)0, true);
}

static void audio_set_volume(void *data, float volume, bool mute)
{
	hx::SetTopOfStack((int *)99, true);

	reinterpret_cast<Video_obj *>(data)->updateSoundVolume(volume, mute);

	hx::SetTopOfStack((int *)0, true);
}

static void media_player_callbacks(const libvlc_event_t *p_event, void *p_data)
{
	hx::SetTopOfStack((int *)99, true);

	Video_obj *self = reinterpret_cast<Video_obj *>(p_data);

	switch (p_event->type)
	{
		case libvlc_MediaPlayerOpening:
			self->updateCallbacks(0);
			break;
		case libvlc_MediaPlayerPlaying:
			self->updateCallbacks(1);
			break;
		case libvlc_MediaPlayerStopped:
			self->updateCallbacks(2);
			break;
		case libvlc_MediaPlayerPaused:
			self->updateCallbacks(3);
			break;
		case libvlc_MediaPlayerEndReached:
			self->updateCallbacks(4);
			break;
		case libvlc_MediaPlayerEncounteredError:
			self->updateCallbacks(5);
			break;
		case libvlc_MediaPlayerMediaChanged:
			self->updateCallbacks(6);
			break;
		case libvlc_MediaPlayerCorked:
			self->updateCallbacks(7);
			break;
		case libvlc_MediaPlayerUncorked:
			self->updateCallbacks(8);
			break;
	}

	hx::SetTopOfStack((int *)0, true);
}')
@:keep
class Video extends Bitmap
{
	/**
	 * Indicates whether to use GPU texture for rendering.
	 *
	 * If set to true, GPU texture rendering will be used if possible, otherwise, CPU-based image rendering will be used.
	 */
	public static var useTexture:Bool = true;

	/**
	 * The format width, in pixels.
	 */
	public var formatWidth(default, null):Int = 0;

	/**
	 * The format height, in pixels.
	 */
	public var formatHeight(default, null):Int = 0;

	/**
	 * The media resource locator.
	 */
	public var mrl(get, never):String;

	/**
	 * The media's duration.
	 */
	public var duration(get, never):Int64;

	/**
	 * Whether the media player is playing or not.
	 */
	public var isPlaying(get, never):Bool;

	/**
	 * The media player's length in milliseconds.
	 */
	public var length(get, never):Int64;

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
	 * Whether the media player is able to play.
	 */
	public var willPlay(get, never):Bool;

	/**
	 * The media player's play rate.
	 *
	 * @warning Depending on the underlying media, the requested rate may be different from the real playback rate.
	 */
	public var rate(get, set):Single;

	/**
	 * Whether the media player is seekable or not.
	 */
	public var isSeekable(get, never):Bool;

	/**
	 * Whether the media player can be paused or not.
	 */
	public var canPause(get, never):Bool;

	/**
	 * Gets the list of available audio output modules.
	 */
	public var outputModules(get, never):Array<String>;

	/**
	 * Selects an audio output module.
	 *
	 * @note Any change will take be effect only after playback is stopped and restarted.
	 *
	 * Audio output cannot be changed while playing.
	 */
	public var output(never, set):String;

	/**
	 * The audio's mute status.
	 *
	 * @warning This does not always work.
	 * If there is no active audio playback stream, the mute status might not be available.
	 * If digital pass-through (S/PDIF, HDMI...) is in use, muting may be unapplicable.
	 * Also some audio output plugins do not support muting at all.
	 *
	 * @note To force silent playback, disable all audio tracks. This is more efficient and reliable than mute.
	 */
	public var mute(get, set):Bool;

	/**
	 * The audio volume in percents (0 = mute, 100 = nominal / 0dB).
	 */
	public var volume(get, set):Int;

	/**
	 * Get the number of available audio tracks.
	 */
	public var trackCount(get, never):Int;

	/**
	 * The media player's audio track.
	 */
	public var track(get, set):Int;

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
	 * The media player's role.
	 */
	public var role(get, set):UInt;

	/**
	 * An event that is dispatched when the media player is opening.
	 */
	public var onOpening(default, null):Event<Void->Void> = new Event<Void->Void>();

	/**
	 * An event that is dispatched when the media player is playing.
	 */
	public var onPlaying(default, null):Event<Void->Void> = new Event<Void->Void>();

	/**
	 * An event that is dispatched when the media player stopped.
	 */
	public var onStopped(default, null):Event<Void->Void> = new Event<Void->Void>();

	/**
	 * An event that is dispatched when the media player is paused.
	 */
	public var onPaused(default, null):Event<Void->Void> = new Event<Void->Void>();

	/**
	 * An event that is dispatched when the media player reached the end.
	 */
	public var onEndReached(default, null):Event<Void->Void> = new Event<Void->Void>();

	/**
	 * An event that is dispatched when the media player encountered an error.
	 */
	public var onEncounteredError(default, null):Event<String->Void> = new Event<String->Void>();

	/**
	 * An event that is dispatched when the media is changed.
	 */
	public var onMediaChanged(default, null):Event<Void->Void> = new Event<Void->Void>();

	/**
	 * An event that is dispatched when the media player is corked.
	 */
	public var onCorked(default, null):Event<Void->Void> = new Event<Void->Void>();

	/**
	 * An event that is dispatched when the media player is uncorked.
	 */
	public var onUncorked(default, null):Event<Void->Void> = new Event<Void->Void>();

	/**
	 * An event that is dispatched when the format is being initialized.
	 */
	public var onFormatSetup(default, null):Event<Void->Void> = new Event<Void->Void>();

	/**
	 * An event that is dispatched when the media is being displayed.
	 */
	public var onDisplay(default, null):Event<Void->Void> = new Event<Void->Void>();

	@:noCompletion
	private var audioOutput:cpp.RawPointer<LibVLC_Audio_Output_T>;

	#if lime_openal
	@:noCompletion
	private var alAudioContext:OpenALAudioContext;

	@:noCompletion
	private var alSource:ALSource;

	@:noCompletion
	private var alBuffers:Array<ALBuffer> = [];
	#end

	#if (mingw || HXCPP_MINGW || !windows)
	@:noCompletion
	private var mediaData:cpp.RawPointer<cpp.UInt8>;

	@:noCompletion
	private var mediaOffset:cpp.UInt64;

	@:noCompletion
	private var mediaSize:cpp.UInt64;
	#end

	@:noCompletion
	private var mediaItem:cpp.RawPointer<LibVLC_Media_T>;

	@:noCompletion
	private var mediaPlayer:cpp.RawPointer<LibVLC_Media_Player_T>;

	@:noCompletion
	private var eventManager:cpp.RawPointer<LibVLC_Event_Manager_T>;

	@:noCompletion
	private var events:Array<Bool> = [false, false];

	@:noCompletion
	private var planes:cpp.RawPointer<cpp.UInt8>;

	@:noCompletion
	private var texture:RectangleTexture;

	/**
	 * Initializes a Video object.
	 *
	 * @param smoothing Whether or not the object is smoothed when scaled.
	 */
	public function new(smoothing:Bool = true):Void
	{
		super(null, AUTO, smoothing);

		#if lime_openal
		if (AudioManager.context != null)
		{
			switch (AudioManager.context.type)
			{
				case OPENAL:
					alAudioContext = AudioManager.context.openal;
				default:
			}
		}
		#end

		while (Handle.loading)
			Sys.sleep(0.05);

		Handle.init();

		audioOutput = LibVLC.audio_output_list_get(Handle.instance);
	}

	/**
	 * Call this function to load a media.
	 *
	 * @param location The local filesystem path or the media location url or the id of a open file descriptor or the bitstream input.
	 * @param options The additional options you can add to the LibVLC Media instance.
	 *
	 * @return `true` if the media loaded successfully or `false` if there's an error.
	 */
	public function load(location:OneOfThree<String, Int, Bytes>, ?options:Array<String>):Bool
	{
		if (Handle.instance == null)
			return false;

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
				#if (mingw || HXCPP_MINGW || !windows)
				final data:BytesData = cast(location, Bytes).getData();

				mediaData = untyped __cpp__('new unsigned char[{0}]', data.length);

				cpp.Stdlib.nativeMemcpy(cast mediaData, cast cpp.Pointer.ofArray(data).constRaw, data.length);

				mediaOffset = 0;
				mediaSize = data.length;
				mediaItem = LibVLC.media_new_callbacks(Handle.instance, untyped __cpp__('media_open'), untyped __cpp__('media_read'),
					untyped __cpp__('media_seek'), null, untyped __cpp__('this'));
				#else
				Log.warn('Failed to use bitstream input, this doesn\'t work when compiling on Windows with MSVC compiler, use MinGW compiler instead.');

				return false;
				#end
			}
			else
				return false;
		}
		else
			return false;

		if (mediaPlayer == null)
		{
			mediaPlayer = LibVLC.media_player_new(Handle.instance);

			if (Application.current != null && !Application.current.onUpdate.has(update))
				Application.current.onUpdate.add(update);

			if (eventManager == null)
			{
				eventManager = LibVLC.media_player_event_manager(mediaPlayer);

				if (LibVLC.event_attach(eventManager, LibVLC_MediaPlayerOpening, untyped __cpp__('media_player_callbacks'), untyped __cpp__('this')) != 0)
					Log.warn('Failed to attach event (MediaPlayerOpening)');

				if (LibVLC.event_attach(eventManager, LibVLC_MediaPlayerPlaying, untyped __cpp__('media_player_callbacks'), untyped __cpp__('this')) != 0)
					Log.warn('Failed to attach event (MediaPlayerPlaying)');

				if (LibVLC.event_attach(eventManager, LibVLC_MediaPlayerStopped, untyped __cpp__('media_player_callbacks'), untyped __cpp__('this')) != 0)
					Log.warn('Failed to attach event (MediaPlayerStopped)');

				if (LibVLC.event_attach(eventManager, LibVLC_MediaPlayerPaused, untyped __cpp__('media_player_callbacks'), untyped __cpp__('this')) != 0)
					Log.warn('Failed to attach event (MediaPlayerPaused)');

				if (LibVLC.event_attach(eventManager, LibVLC_MediaPlayerEndReached, untyped __cpp__('media_player_callbacks'), untyped __cpp__('this')) != 0)
					Log.warn('Failed to attach event (MediaPlayerEndReached)');

				if (LibVLC.event_attach(eventManager, LibVLC_MediaPlayerEncounteredError, untyped __cpp__('media_player_callbacks'),
					untyped __cpp__('this')) != 0)
					Log.warn('Failed to attach event (MediaPlayerEncounteredError)');

				if (LibVLC.event_attach(eventManager, LibVLC_MediaPlayerMediaChanged, untyped __cpp__('media_player_callbacks'), untyped __cpp__('this')) != 0)
					Log.warn('Failed to attach event (MediaPlayerMediaChanged)');

				if (LibVLC.event_attach(eventManager, LibVLC_MediaPlayerCorked, untyped __cpp__('media_player_callbacks'), untyped __cpp__('this')) != 0)
					Log.warn('Failed to attach event (MediaPlayerCorked)');

				if (LibVLC.event_attach(eventManager, LibVLC_MediaPlayerUncorked, untyped __cpp__('media_player_callbacks'), untyped __cpp__('this')) != 0)
					Log.warn('Failed to attach event (MediaPlayerUncorked)');
			}

			LibVLC.video_set_callbacks(mediaPlayer, untyped __cpp__('video_lock'), null, untyped __cpp__('video_display'), untyped __cpp__('this'));
			LibVLC.video_set_format_callbacks(mediaPlayer, untyped __cpp__('video_format_setup'), null);

			#if lime_openal
			if (alAudioContext != null)
			{
				alSource = alAudioContext.createSource();

				alAudioContext.sourcei(alSource, alAudioContext.SOURCE_RELATIVE, alAudioContext.TRUE);
				alAudioContext.sourcef(alSource, alAudioContext.GAIN, 1);
				alAudioContext.source3f(alSource, alAudioContext.POSITION, 0, 0, 0);
				alAudioContext.source3f(alSource, alAudioContext.VELOCITY, 0, 0, 0);
				alAudioContext.sourcef(alSource, alAudioContext.PITCH, 1);
				alAudioContext.sourcef(alSource, alAudioContext.ROLLOFF_FACTOR, 2);

				alBuffers = new Array<ALBuffer>();

				for (i in 0...6)
					alBuffers.push(alAudioContext.createBuffer());

				LibVLC.audio_set_callbacks(mediaPlayer, untyped __cpp__('audio_play'), null, null, null, null, untyped __cpp__('this'));
				LibVLC.audio_set_volume_callback(mediaPlayer, untyped __cpp__('audio_set_volume'));
				LibVLC.audio_set_format(mediaPlayer, "S16N", 44100, 2);
			}
			#end
		}

		if (options == null)
			options = new Array<String>();

		for (option in options)
		{
			if (option != null && option.length > 0)
				LibVLC.media_add_option(mediaItem, option);
		}

		LibVLC.media_player_set_media(mediaPlayer, mediaItem);

		return true;
	}

	/**
	 * Call this function to initiate playback with the media player.
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
	 * Call this function to set the previous chapter (if applicable).
	 */
	public function previousChapter():Void
	{
		if (mediaPlayer != null)
			LibVLC.media_player_previous_chapter(mediaPlayer);
	}

	/**
	 * Call this function to set the next chapter (if applicable).
	 */
	public function nextChapter():Void
	{
		if (mediaPlayer != null)
			LibVLC.media_player_next_chapter(mediaPlayer);
	}

	/**
	 * Frees the memory that is used to store the Video object.
	 */
	public function dispose():Void
	{
		if (eventManager != null)
		{
			LibVLC.event_detach(eventManager, LibVLC_MediaPlayerOpening, untyped __cpp__('media_player_callbacks'), untyped __cpp__('this'));
			LibVLC.event_detach(eventManager, LibVLC_MediaPlayerPlaying, untyped __cpp__('media_player_callbacks'), untyped __cpp__('this'));
			LibVLC.event_detach(eventManager, LibVLC_MediaPlayerStopped, untyped __cpp__('media_player_callbacks'), untyped __cpp__('this'));
			LibVLC.event_detach(eventManager, LibVLC_MediaPlayerPaused, untyped __cpp__('media_player_callbacks'), untyped __cpp__('this'));
			LibVLC.event_detach(eventManager, LibVLC_MediaPlayerEndReached, untyped __cpp__('media_player_callbacks'), untyped __cpp__('this'));
			LibVLC.event_detach(eventManager, LibVLC_MediaPlayerEncounteredError, untyped __cpp__('media_player_callbacks'), untyped __cpp__('this'));
			LibVLC.event_detach(eventManager, LibVLC_MediaPlayerMediaChanged, untyped __cpp__('media_player_callbacks'), untyped __cpp__('this'));
			LibVLC.event_detach(eventManager, LibVLC_MediaPlayerCorked, untyped __cpp__('media_player_callbacks'), untyped __cpp__('this'));
			LibVLC.event_detach(eventManager, LibVLC_MediaPlayerUncorked, untyped __cpp__('media_player_callbacks'), untyped __cpp__('this'));
		}

		if (mediaPlayer != null)
		{
			LibVLC.media_player_stop(mediaPlayer);
			LibVLC.media_player_release(mediaPlayer);
		}

		eventManager = null;
		mediaPlayer = null;

		if (Application.current != null && Application.current.onUpdate.has(update))
			Application.current.onUpdate.remove(update);

		if (mediaItem != null)
		{
			LibVLC.media_release(mediaItem);

			#if (mingw || HXCPP_MINGW || !windows)
			if (mediaData != null)
			{
				untyped __cpp__('delete[] {0}', mediaData);
				mediaData = null;
			}

			mediaOffset = 0;
			mediaSize = 0;
			#end

			mediaItem = null;
		}

		if (audioOutput != null)
		{
			LibVLC.audio_output_list_release(audioOutput);
			audioOutput = null;
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

		formatWidth = formatHeight = 0;

		if (planes != null)
		{
			untyped __cpp__('delete[] {0}', planes);
			planes = null;
		}
	}

	@:noCompletion
	private function update(deltaTime:Int):Void
	{
		if (!events.contains(true))
			return;

		if (events[0])
		{
			events[0] = false;

			var mustRecreate:Bool = false;

			if (bitmapData != null)
			{
				@:privateAccess
				if ((bitmapData.width != formatWidth && bitmapData.height != formatHeight)
					|| ((!useTexture && bitmapData.__texture != null) || (useTexture && bitmapData.image != null)))
				{
					bitmapData.dispose();

					if (texture != null)
					{
						texture.dispose();
						texture = null;
					}

					mustRecreate = true;
				}
			}
			else
				mustRecreate = true;

			if (mustRecreate)
			{
				try
				{
					if (useTexture && Lib.current.stage != null && Lib.current.stage.context3D != null)
					{
						texture = Lib.current.stage.context3D.createRectangleTexture(formatWidth, formatHeight, BGRA, true);

						bitmapData = BitmapData.fromTexture(texture);
					}
					else
					{
						if (useTexture)
							Log.warn('Unable to utilize GPU texture, resorting to CPU-based image rendering.');

						bitmapData = new BitmapData(formatWidth, formatHeight, true, 0);
					}
				}
				catch (e:Exception)
					Log.error('Failed to create video\'s texture: ${e.message}');

				onFormatSetup.dispatch();
			}
		}

		if (events[1])
		{
			events[1] = false;

			if (__renderable && planes != null)
			{
				try
				{
					final planesData:BytesData = cpp.Pointer.fromRaw(planes).toUnmanagedArray(formatWidth * formatHeight * 4);

					if (texture != null)
					{
						texture.uploadFromTypedArray(UInt8Array.fromBytes(Bytes.ofData(planesData)));

						__setRenderDirty();
					}
					else if (bitmapData != null && bitmapData.image != null)
						bitmapData.setPixels(bitmapData.rect, planesData);
				}
				catch (e:Exception)
					Log.error('An error occurred while attempting to render the video: ${e.message}');
			}

			onDisplay.dispatch();
		}
	}

	@:noCompletion
	private function updateCallbacks(type:Int):Void
	{
		switch (type)
		{
			case 0:
				onOpening.dispatch();
			case 1:
				onPlaying.dispatch();
			case 2:
				onStopped.dispatch();
			case 3:
				onPaused.dispatch();
			case 4:
				onEndReached.dispatch();
			case 5:
				final errmsg:String = cast(LibVLC.errmsg(), String);

				if (errmsg != null && errmsg.length > 0)
					onEncounteredError.dispatch(errmsg);
				else
					onEncounteredError.dispatch('Unknown error');
			case 6:
				onMediaChanged.dispatch();
			case 7:
				onCorked.dispatch();
			case 8:
				onUncorked.dispatch();
		}
	}

	@:noCompletion
	private function updateSound(samples:cpp.RawPointer<cpp.UInt8>, count:cpp.UInt32):Void
	{		
		#if lime_openal
		if (alAudioContext != null && alSource != null && alBuffers != null)
		{
			final processed:Int = alAudioContext.getSourcei(alSource, alAudioContext.BUFFERS_PROCESSED);

			if (processed > 0)
			{
				for (buffer in alAudioContext.sourceUnqueueBuffers(alSource, processed))
					alBuffers.push(buffer);
			}

			final samplesData:BytesData = cpp.Pointer.fromRaw(samples).toUnmanagedArray(count);

			if (alBuffers.length > 0)
			{
				final newBuffer:ALBuffer = alBuffers.pop();

				alAudioContext.bufferData(newBuffer, alAudioContext.FORMAT_STEREO16, UInt8Array.fromBytes(Bytes.ofData(samplesData)), samplesData.length, 44100);
				alAudioContext.sourceQueueBuffer(alSource, newBuffer);

				if (alAudioContext.getSourcei(alSource, alAudioContext.SOURCE_STATE) != alAudioContext.PLAYING)
					alAudioContext.sourcePlay(alSource);
			}
		}
		#end
	}

	@:noCompletion
	private function updateSoundVolume(volume:Single, mute:Bool):Void
	{
		#if lime_openal
		Log.info('Volume callback triggered: Volume = $volume, Mute = $mute');

		if (alAudioContext != null && alSource != null)
			alAudioContext.sourcef(alSource, alAudioContext.GAIN, mute ? 0 : volume);
		#end
	}

	@:noCompletion
	private function get_mrl():String
	{
		if (mediaPlayer != null)
		{
			final curMediaItem:cpp.RawPointer<LibVLC_Media_T> = LibVLC.media_player_get_media(mediaPlayer);

			if (curMediaItem != null)
				return cast(LibVLC.media_get_mrl(curMediaItem), String);
		}

		return null;
	}

	@:noCompletion
	private function get_duration():Int64
	{
		if (mediaPlayer != null)
		{
			final curMediaItem:cpp.RawPointer<LibVLC_Media_T> = LibVLC.media_player_get_media(mediaPlayer);

			if (curMediaItem != null)
				return LibVLC.media_get_duration(curMediaItem);
		}

		return -1;
	}

	@:noCompletion
	private function get_isPlaying():Bool
	{
		if (mediaPlayer != null)
			return LibVLC.media_player_is_playing(mediaPlayer) != 0;

		return false;
	}

	@:noCompletion
	private function get_length():Int64
	{
		if (mediaPlayer != null)
			return LibVLC.media_player_get_length(mediaPlayer);

		return -1;
	}

	@:noCompletion
	private function get_time():Int64
	{
		if (mediaPlayer != null)
			return LibVLC.media_player_get_time(mediaPlayer);

		return -1;
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
		if (mediaPlayer != null)
			return LibVLC.media_player_get_position(mediaPlayer);

		return -1;
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
		if (mediaPlayer != null)
			return LibVLC.media_player_get_chapter(mediaPlayer);

		return -1;
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
		if (mediaItem != null)
			return LibVLC.media_player_get_chapter_count(mediaPlayer);

		return -1;
	}

	@:noCompletion
	private function get_willPlay():Bool
	{
		if (mediaPlayer != null)
			return LibVLC.media_player_will_play(mediaPlayer) != 0;

		return false;
	}

	@:noCompletion
	private function get_rate():Single
	{
		if (mediaPlayer != null)
			return LibVLC.media_player_get_rate(mediaPlayer);

		return -1;
	}

	@:noCompletion
	private function set_rate(value:Single):Single
	{
		if (mediaPlayer != null)
		{
			if (LibVLC.media_player_set_rate(mediaPlayer, value) == -1)
				Log.warn('Failed to set play rate');
		}

		return value;
	}

	@:noCompletion
	private function get_isSeekable():Bool
	{
		if (mediaPlayer != null)
			return LibVLC.media_player_is_seekable(mediaPlayer) != 0;

		return false;
	}

	@:noCompletion
	private function get_canPause():Bool
	{
		if (mediaPlayer != null)
			return LibVLC.media_player_can_pause(mediaPlayer) != 0;

		return false;
	}

	@:noCompletion
	private function get_outputModules():Array<String>
	{
		var modules:Array<String> = null;

		if (audioOutput != null)
		{
			modules = [];

			var temp:cpp.RawPointer<LibVLC_Audio_Output_T> = audioOutput;

			while (temp != null)
			{
				modules.push(temp[0].psz_name);

				temp = temp[0].p_next;
			}
		}

		return modules;
	}

	@:noCompletion
	private function set_output(value:String):String
	{
		if (mediaPlayer != null)
		{
			if (LibVLC.audio_output_set(mediaPlayer, value) != 0)
				Log.warn('Failed to set audio output module');
		}

		return value;
	}

	@:noCompletion
	private function get_mute():Bool
	{
		if (mediaPlayer != null)
			return LibVLC.audio_get_mute(mediaPlayer) > 0;

		return false;
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
		if (mediaPlayer != null)
			return LibVLC.audio_get_volume(mediaPlayer);

		return 0;
	}

	@:noCompletion
	private function set_volume(value:Int):Int
	{
		if (mediaPlayer != null)
		{
			if (LibVLC.audio_set_volume(mediaPlayer, value) == -1)
				Log.warn('The volume is out of range');
		}

		return value;
	}

	@:noCompletion
	private function get_trackCount():Int
	{
		if (mediaItem != null)
			return LibVLC.audio_get_track_count(mediaPlayer);

		return -1;
	}

	@:noCompletion
	private function get_track():Int
	{
		if (mediaPlayer != null)
			return LibVLC.audio_get_track(mediaPlayer);

		return -1;
	}

	@:noCompletion
	private function set_track(value:Int):Int
	{
		if (mediaPlayer != null)
		{
			if (LibVLC.audio_set_track(mediaPlayer, value) == -1)
				Log.warn('Failed to set audio track');
		}

		return value;
	}

	@:noCompletion
	private function get_channel():Int
	{
		if (mediaPlayer != null)
			return LibVLC.audio_get_channel(mediaPlayer);

		return -1;
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
		if (mediaPlayer != null)
			return LibVLC.audio_get_delay(mediaPlayer);

		return -1;
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
		if (mediaPlayer != null)
			return LibVLC.media_player_get_role(mediaPlayer);

		return 0;
	}

	@:noCompletion
	private function set_role(value:UInt):UInt
	{
		if (mediaPlayer != null)
		{
			if (LibVLC.media_player_set_role(mediaPlayer, value) == -1)
				Log.warn('Failed to media player\'s role');
		}

		return value;
	}

	@:noCompletion
	private override function set_bitmapData(value:BitmapData):BitmapData
	{
		return __bitmapData = value;
	}
}
