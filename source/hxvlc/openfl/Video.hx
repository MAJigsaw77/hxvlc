package hxvlc.openfl;

import cpp.Char;
import cpp.NativeArray;
import cpp.RawConstPointer;
import cpp.RawPointer;
import cpp.Stdlib;

import haxe.Int64;
import haxe.io.Bytes;
import haxe.io.BytesData;

import hxvlc.impl.Instance;
import hxvlc.impl.Media;
import hxvlc.impl.MediaPlayer;
import hxvlc.impl.Stats;
import hxvlc.impl.TrackDescription;
import hxvlc.impl.events.MediaEvents;
import hxvlc.impl.events.MediaPlayerEvents;
import hxvlc.impl.output.AudioOutput;
import hxvlc.impl.output.VideoOutput;
import hxvlc.util.Handle;
import hxvlc.util.Location;
import hxvlc.util.MainLoop;

import lime.app.Event;
import lime.graphics.Image;
import lime.media.openal.AL;
import lime.media.openal.ALBuffer;
import lime.media.openal.ALSource;
import lime.utils.UInt8Array;

import openfl.display.Bitmap;
import openfl.display.BitmapData;

using StringTools;

class Video extends Bitmap
{
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

	/** The media resource locator (MRL). */
	public var mrl(get, never):Null<String>;

	/** Duration of the media in microseconds. */
	public var duration(get, never):Int64;

	/** Statistics related to the media. */
	public var stats(get, never):Null<Stats>;

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

	/** Volume level (0.0 to 1.0). */
	public var volume(get, set):Float;

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
	public var onMediaMetaChanged(default, null):Event<Int->Void> = new Event<Int->Void>();

	/** Event triggered when the media is parsed. */
	public var onMediaParsedChanged(default, null):Event<Int->Void> = new Event<Int->Void>();

	/** Event triggered when the media format setup is initialized. */
	public var onFormatSetup(default, null):Event<Void->Void> = new Event<Void->Void>();

	/** Event triggered when the media is being rendered. */
	public var onDisplay(default, null):Event<Void->Void> = new Event<Void->Void>();

	@:noCompletion
	private var instance:Null<Instance>;

	@:noCompletion
	private var mediaPlayer:MediaPlayer;

	@:noCompletion
	private var mediaPlayerEvents:MediaPlayerEvents;

	@:noCompletion
	private var mediaEvents:Null<MediaEvents>;

	@:noCompletion
	private var videoOutput:Null<VideoOutput>;

	@:noCompletion
	private var audioOutput:Null<AudioOutput>;

	@:noCompletion
	private var alUseEXTFLOAT32:Null<Bool>;

	@:noCompletion
	private var alUseEXTMCFORMATS:Null<Bool>;

	@:noCompletion
	private var alSource:Null<ALSource>;

	@:noCompletion
	private var alBufferPool:Null<Array<ALBuffer>>;

	@:noCompletion
	private var alSampleRate:Null<Int>;

	@:noCompletion
	private var alFormat:Null<Int>;

	@:noCompletion
	private var alFrameSize:Null<Int>;

	/**
	 * Initializes a Video object.
	 * 
	 * @param smoothing Whether or not the object is smoothed when scaled.
	 */
	@:nullSafety(Off)
	public function new(?instance:Instance, smoothing:Bool = true):Void
	{
		super(new BitmapData(1, 1, true, 0x000000), AUTO, smoothing);

		if (instance == null)
		{
			while (Handle.loading)
				Handle.init();

			instance = Handle.sharedInstance;
		}

		this.instance = instance;

		this.mediaPlayer = new MediaPlayer(instance);

		this.mediaPlayerEvents = new MediaPlayerEvents(mediaPlayer);

		// I know this looks silly but, for some reason trying to null the instance inside one of the callbacks (for example onEndReached)
		// crashes the whole thing, so by dispatching the events inside the main thread we bypass this issue, obviously this isnt the best solution
		// but it is what it is
		this.mediaPlayerEvents.onOpening = () -> MainLoop.runInMainThread(() -> onOpening.dispatch());
		this.mediaPlayerEvents.onPlaying = () -> MainLoop.runInMainThread(() -> onPlaying.dispatch());
		this.mediaPlayerEvents.onStopped = () -> MainLoop.runInMainThread(() -> onStopped.dispatch());
		this.mediaPlayerEvents.onPaused = () -> MainLoop.runInMainThread(() -> onPaused.dispatch());
		this.mediaPlayerEvents.onEndReached = () -> MainLoop.runInMainThread(() -> onEndReached.dispatch());
		this.mediaPlayerEvents.onEncounteredError = () -> MainLoop.runInMainThread(() -> onEncounteredError.dispatch('Unknown Error'));
		this.mediaPlayerEvents.onCorked = () -> MainLoop.runInMainThread(() -> onCorked.dispatch());
		this.mediaPlayerEvents.onUncorked = () -> MainLoop.runInMainThread(() -> onUncorked.dispatch());
		this.mediaPlayerEvents.onESAdded = (type:Int, id:Int) -> MainLoop.runInMainThread(() -> onESAdded.dispatch(type, id));
		this.mediaPlayerEvents.onESDeleted = (type:Int, id:Int) -> MainLoop.runInMainThread(() -> onESDeleted.dispatch(type, id));
		this.mediaPlayerEvents.onESSelected = (type:Int, id:Int) -> MainLoop.runInMainThread(() -> onESSelected.dispatch(type, id));
		this.mediaPlayerEvents.onTimeChanged = (time:Int64) -> MainLoop.runInMainThread(() -> onTimeChanged.dispatch(time));
		this.mediaPlayerEvents.onPositionChanged = (position:Single) -> MainLoop.runInMainThread(() -> onPositionChanged.dispatch(position));
		this.mediaPlayerEvents.onLengthChanged = (length:Int64) -> MainLoop.runInMainThread(() -> onLengthChanged.dispatch(length));
		this.mediaPlayerEvents.onMediaChanged = (media:Media) -> MainLoop.runInMainThread(() -> onMediaChanged.dispatch());

		setupVideo();

		setupAudio();
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
		var media:Null<Media> = null;

		if (location != null)
		{
			@:nullSafety(Off)
			{
				if ((location is String))
				{
					if (URL_VERIFICATION_REGEX.match(location))
						media = Media.fromLocation(instance, location);
					else
					{
						#if windows
						media = Media.fromPath(instance, haxe.io.Path.normalize(location).split('/').join('\\'));
						#else
						media = Media.fromPath(instance, haxe.io.Path.normalize(location));
						#end
					}
				}
				else if ((location is Bytes))
					media = Media.fromBytes(instance, cast(location, Bytes));
			}
		}

		return setMediaToMediaPlayer(media, options);
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
		return setMediaToMediaPlayer(mediaPlayer.media?.subitems()[index], options);
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
		return mediaPlayer.media?.parseWithOptions(parse_flag, timeout) ?? false;
	}

	/** Stops parsing the current media item. */
	public function parseStop():Void
	{
		mediaPlayer.media?.parseStop();
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
		return mediaPlayer.addSlave(type, url, select);
	}

	/**
	 * Gets the description of available audio tracks of the current media player.
	 * 
	 * @return The list containing descriptions of available audio tracks.
	 */
	public function getVideoDescription():Array<TrackDescription>
	{
		return mediaPlayer.getVideoDescription();
	}

	/**
	 * Gets the description of available audio tracks of the current media player.
	 * 
	 * @return The list containing descriptions of available audio tracks.
	 */
	public function getAudioDescription():Array<TrackDescription>
	{
		return mediaPlayer.getAudioDescription();
	}

	/**
	 * Gets the description of available available video subtitles of the current media player.
	 * 
	 * @return The list containing descriptions of available available video subtitles.
	 */
	public function getSpuDescription():Array<TrackDescription>
	{
		return mediaPlayer.getSpuDescription();
	}

	/**
	 * Starts playback.
	 * 
	 * @return `true` if playback started successfully, `false` otherwise.
	 */
	public function play():Bool
	{
		return mediaPlayer.play();
	}

	/** Stops playback. */
	public function stop():Void
	{
		mediaPlayer.stop();
	}

	/** Pauses playback. */
	public function pause():Void
	{
		mediaPlayer.pause();
	}

	/** Resumes playback. */
	public function resume():Void
	{
		mediaPlayer.resume();
	}

	/** Toggles the pause state. */
	public function togglePaused():Void
	{
		mediaPlayer.togglePaused();
	}

	/**
	 * Retrieves metadata for the current media item.
	 * 
	 * @param e_meta The metadata type.
	 * @return The metadata value as a string, or `null` if not available.
	 */
	public function getMeta(e_meta:Int):Null<String>
	{
		return mediaPlayer.media?.getMeta(e_meta);
	}

	/**
	 * Sets metadata for the current media item.
	 * 
	 * @param e_meta The metadata type.
	 * @param value The metadata value.
	 */
	public function setMeta(e_meta:Int, value:String):Void
	{
		mediaPlayer.media?.setMeta(e_meta, value);
	}

	/**
	 * Saves the metadata of the current media item.
	 * 
	 * @return `true` if the metadata was saved successfully, `false` otherwise.
	 */
	public function saveMeta():Bool
	{
		return mediaPlayer.media?.saveMeta() ?? false;
	}

	/** Frees the memory that is used to store the Video object. */
	public function dispose():Void
	{
		mediaPlayer.destroy();

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

	@:noCompletion
	private function get_mrl():Null<String>
	{
		return mediaPlayer.media?.mrl;
	}

	@:noCompletion
	private function get_stats():Null<Stats>
	{
		return mediaPlayer.media?.stats;
	}

	@:noCompletion
	private function get_duration():Int64
	{
		return mediaPlayer.media?.duration ?? -1;
	}

	@:noCompletion
	private function get_isPlaying():Bool
	{
		return mediaPlayer.isPlaying;
	}

	@:noCompletion
	private function get_length():Int64
	{
		return mediaPlayer.length;
	}

	@:noCompletion
	private function get_time():Int64
	{
		return mediaPlayer.time;
	}

	@:noCompletion
	private function set_time(value:Int64):Int64
	{
		return mediaPlayer.time = value;
	}

	@:noCompletion
	private function get_position():Single
	{
		return mediaPlayer.position;
	}

	@:noCompletion
	private function set_position(value:Single):Single
	{
		return mediaPlayer.position = value;
	}

	@:noCompletion
	private function get_rate():Single
	{
		return mediaPlayer.rate;
	}

	@:noCompletion
	private function set_rate(value:Single):Single
	{
		return mediaPlayer.rate = value;
	}

	@:noCompletion
	private function get_volume():Float
	{
		return alSource != null ? AL.getSourcef(alSource, AL.GAIN) : -1;
	}

	@:noCompletion
	private function set_volume(value:Float):Float
	{
		if (alSource != null)
			AL.sourcef(alSource, AL.GAIN, value);

		return value;
	}

	@:noCompletion
	private function get_isSeekable():Bool
	{
		return mediaPlayer.isSeekable;
	}

	@:noCompletion
	private function get_videoTrackCount():Int
	{
		return mediaPlayer.videoTrackCount;
	}

	@:noCompletion
	private function get_videoTrack():Int
	{
		return mediaPlayer.videoTrack;
	}

	@:noCompletion
	private function set_videoTrack(value:Int):Int
	{
		return mediaPlayer.videoTrack = value;
	}

	@:noCompletion
	private function get_audioTrackCount():Int
	{
		return mediaPlayer.audioTrackCount;
	}

	@:noCompletion
	private function get_audioTrack():Int
	{
		return mediaPlayer.audioTrack;
	}

	@:noCompletion
	private function set_audioTrack(value:Int):Int
	{
		return mediaPlayer.audioTrack = value;
	}

	@:noCompletion
	private function get_spuTrackCount():Int
	{
		return mediaPlayer.spuTrackCount;
	}

	@:noCompletion
	private function get_spuTrack():Int
	{
		return mediaPlayer.spuTrack;
	}

	@:noCompletion
	private function set_spuTrack(value:Int):Int
	{
		return mediaPlayer.spuTrack = value;
	}

	@:noCompletion
	private override function set_bitmapData(value:BitmapData):BitmapData
	{
		__bitmapData = value;
		__setRenderDirty();
		__imageVersion = -1;
		return __bitmapData;
	}

	@:noCompletion
	private function setMediaToMediaPlayer(media:Null<Media>, ?options:Array<String>):Bool
	{
		if (media != null)
		{
			if (options != null && options.length > 0)
			{
				for (option in options)
					media.addOption(option);
			}

			// I know this looks silly but, for some reason trying to null the instance inside one of the callbacks (for example onEndReached)
			// crashes the whole thing, so by dispatching the events inside the main thread we bypass this issue, obviously this isnt the best solution
			// but it is what it is
			mediaEvents = new MediaEvents(media);
			mediaEvents.onMediaMetaChanged = (type:Int) -> MainLoop.runInMainThread(() -> onMediaMetaChanged.dispatch(type));
			mediaEvents.onMediaParsedChanged = (status:Int) -> MainLoop.runInMainThread(() -> onMediaParsedChanged.dispatch(status));

			mediaPlayer.media = media;

			media.destroy();

			return true;
		}

		return false;
	}

	@:noCompletion
	private function setupVideo():Void
	{
		videoOutput = new VideoOutput(mediaPlayer, "RV32", 4);
		videoOutput.onFormatSetup = videoOutput_onSetup;
		videoOutput.onDisplay = videoOutput_onDisplay;
	}

	@:noCompletion
	private function videoOutput_onSetup(width:Int, height:Int):Void
	{
		MainLoop.runInMainThread(function():Void
		{
			if (videoOutput != null)
			{
				if (bitmapData == null || (bitmapData.width != width || bitmapData.height != height))
				{
					if (bitmapData != null)
						bitmapData.dispose();

					bitmapData = new BitmapData(width, height, true, 0x000000);

					onFormatSetup.dispatch();
				}
			}
		});
	}

	@:noCompletion
	private function videoOutput_onDisplay(pixels:BytesData):Void
	{
		if (bitmapData?.image?.buffer?.data?.buffer == null)
			return;

		final image:Image = bitmapData.image;

		final dest:RawPointer<Char> = cast NativeArray.getBase(image.buffer.data.buffer.getData()).getBase();

		final src:RawConstPointer<Char> = cast NativeArray.getBase(pixels).getBase();

		Stdlib.nativeMemcpy(untyped dest, untyped src, pixels.length);

		image.dirty = true;

		image.version++;

		onDisplay.dispatch();
	}

	@:noCompletion
	private function setupAudio():Void
	{
		alUseEXTFLOAT32 ??= AL.isExtensionPresent('AL_EXT_FLOAT32');
		alUseEXTMCFORMATS ??= AL.isExtensionPresent('AL_EXT_MCFORMATS');
		alSource ??= AL.createSource();
		alBufferPool ??= AL.genBuffers(255);

		audioOutput = new AudioOutput(mediaPlayer);
		audioOutput.onMapFormat = audioOutput_onMapFormat;
		audioOutput.onMapChannels = audioOutput_onMapChannels;
		audioOutput.onMapRate = audioOutput_onMapRate;
		audioOutput.onFormatSetup = audioOutput_onFormatSetup;
		audioOutput.onPlay = audioOutput_onPlay;
		audioOutput.onPause = audioOutput_onPause;
		audioOutput.onResume = audioOutput_onResume;
		audioOutput.onFlush = audioOutput_onFlush;
	}

	@:noCompletion
	private function audioOutput_onMapFormat(format:String):String
	{
		return format == 'FL32' && alUseEXTFLOAT32 == true ? 'FL32' : 'S16N';
	}

	@:noCompletion
	private function audioOutput_onMapChannels(channels:Int):Int
	{
		if (channels == 1)
			return 1;

		if (channels == 3 || channels == 5 || channels == 7)
			return 2;

		if (alUseEXTMCFORMATS != true)
			return 2;

		return channels;
	}

	@:noCompletion
	private function audioOutput_onMapRate(rate:Int):Int
	{
		return rate;
	}

	@:noCompletion
	private function audioOutput_onFormatSetup(format:String, rate:Int, channels:Int):Void
	{
		alSampleRate = rate;

		switch (format)
		{
			case 'FL32':
				switch (channels)
				{
					case 1:
						alFormat = AL.getEnumValue('AL_FORMAT_MONO_FLOAT32');
					case 2:
						alFormat = AL.getEnumValue('AL_FORMAT_STEREO_FLOAT32');
					case 4:
						alFormat = AL.getEnumValue('AL_FORMAT_QUAD32');
					case 6:
						alFormat = AL.getEnumValue('AL_FORMAT_51CHN32');
					case 8:
						alFormat = AL.getEnumValue('AL_FORMAT_71CHN32');
				}

				alFrameSize = Stdlib.sizeof(cpp.Float32) * channels;
			case 'S16N':
				switch (channels)
				{
					case 1:
						alFormat = AL.getEnumValue('AL_FORMAT_MONO16');
					case 2:
						alFormat = AL.getEnumValue('AL_FORMAT_STEREO16');
					case 4:
						alFormat = AL.getEnumValue('AL_FORMAT_QUAD16');
					case 6:
						alFormat = AL.getEnumValue('AL_FORMAT_51CHN16');
					case 8:
						alFormat = AL.getEnumValue('AL_FORMAT_71CHN16');
				}

				alFrameSize = Stdlib.sizeof(cpp.Int16) * channels;
		}
	}

	@:noCompletion
	private function audioOutput_onPlay(samples:BytesData):Void
	{
		if (alSource != null && alBufferPool != null && alFormat != null && alFrameSize != null && alSampleRate != null)
		{
			for (alBuffer in AL.sourceUnqueueBuffers(alSource, AL.getSourcei(alSource, AL.BUFFERS_PROCESSED)))
				alBufferPool.push(alBuffer);

			final alBuffer:Null<ALBuffer> = alBufferPool.shift();

			if (alBuffer != null)
			{
				AL.bufferData(alBuffer, alFormat, UInt8Array.fromBytes(Bytes.ofData(samples)), samples.length * alFrameSize, alSampleRate);

				AL.sourceQueueBuffer(alSource, alBuffer);

				if (AL.getSourcei(alSource, AL.SOURCE_STATE) != AL.PLAYING)
					AL.sourcePlay(alSource);
			}
		}
	}

	@:noCompletion
	private function audioOutput_onPause():Void
	{
		if (alSource != null && AL.getSourcei(alSource, AL.SOURCE_STATE) != AL.PAUSED)
			AL.sourcePause(alSource);
	}

	@:noCompletion
	private function audioOutput_onResume():Void
	{
		if (alSource != null && AL.getSourcei(alSource, AL.SOURCE_STATE) == AL.PAUSED)
			AL.sourcePlay(alSource);
	}

	@:noCompletion
	private function audioOutput_onFlush():Void
	{
		if (alSource != null && AL.getSourcei(alSource, AL.SOURCE_STATE) != AL.STOPPED)
			AL.sourceStop(alSource);
	}
}
