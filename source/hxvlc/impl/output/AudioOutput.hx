package hxvlc.impl.output;

import cpp.CastCharStar;
import cpp.Function;
import cpp.Int64;
import cpp.NativeArray;
import cpp.RawConstPointer;
import cpp.RawPointer;
import cpp.Stdlib;
import cpp.UInt32;

import haxe.io.BytesData;

import hxvlc.impl.externs.LibVLC;

import sys.thread.Mutex;

class AudioOutput
{
	/** Maps the audio format to a supported format. */
	public var onMapFormat:Null<String->String>;

	/** Maps the audio channel count to a supported layout. */
	public var onMapChannels:Null<Int->Int>;

	/** Maps the audio sample rate to a supported value. */
	public var onMapRate:Null<Int->Int>;

	/** Called when audio samples are ready to be played. */
	public var onPlay:Null<Null<BytesData>->Void>;

	/** Called when audio playback is paused. */
	public var onPause:Null<Void->Void>;

	/** Called when audio playback is resumed. */
	public var onResume:Null<Void->Void>;

	/** Called when the audio buffer is flushed (e.g., during seeking). */
	public var onFlush:Null<Void->Void>;

	/** Called when the audio buffer is drained (e.g., at the end of playback). */
	public var onDrain:Null<Void->Void>;

	/** Called when the audio format is set up with format string, sample rate, and channel count. */
	public var onFormatSetup:Null<(format:String, rate:Int, channels:Int) -> Void>;

	@:noCompletion
	private var mutex:Mutex;

	@:noCompletion
	private var samples:Null<BytesData>;

	/**
	 * Creates a new AudioOutput instance for handling audio output.
	 * 
	 * @param mediaPlayer The media player to attach audio callbacks to.
	 */
	public function new(mediaPlayer:MediaPlayer):Void
	{
		if (mediaPlayer.nativeMediaPlayer == null)
			return;

		this.mutex = new Mutex();

		LibVLC.audio_set_callbacks(mediaPlayer.nativeMediaPlayer, Function.fromStaticFunction(audioPlay), Function.fromStaticFunction(audioPause),
			Function.fromStaticFunction(audioResume), Function.fromStaticFunction(audioFlush), Function.fromStaticFunction(audioDrain),
			untyped __cpp__('this'));

		LibVLC.audio_set_volume_callback(mediaPlayer.nativeMediaPlayer, Function.fromStaticFunction(audioSetVolume));

		@:nullSafety(Off)
		LibVLC.audio_set_format_callbacks(mediaPlayer.nativeMediaPlayer, Function.fromStaticFunction(audioFormatSetup), null);
	}

	@:noCompletion
	@:noDebug
	@:unreflective
	private static function audioPlay(data:RawPointer<cpp.Void>, samples:RawConstPointer<cpp.Void>, count:UInt32, pts:Int64):Void
	{
		final audioOutput:AudioOutput = untyped __cpp__('reinterpret_cast<AudioOutput_obj *>({0})', data);

		if (audioOutput != null && audioOutput.onPlay != null)
		{
			untyped __cpp__('int stackBase');

			untyped __cpp__('hx::SetTopOfStack(&stackBase, true)');

			audioOutput.mutex.acquire();

			if (audioOutput.samples == null)
				audioOutput.samples = new BytesData();

			NativeArray.setUnmanagedData(audioOutput.samples, cast samples, count);

			audioOutput.onPlay(audioOutput.samples);

			audioOutput.mutex.release();

			untyped __cpp__('hx::SetTopOfStack((int *)0, true)');
		}
	}

	@:noCompletion
	@:noDebug
	@:unreflective
	private static function audioPause(data:RawPointer<cpp.Void>, pts:Int64):Void
	{
		final audioOutput:AudioOutput = untyped __cpp__('reinterpret_cast<AudioOutput_obj *>({0})', data);

		if (audioOutput != null && audioOutput.onPause != null)
		{
			untyped __cpp__('int stackBase');

			untyped __cpp__('hx::SetTopOfStack(&stackBase, true)');

			audioOutput.mutex.acquire();

			audioOutput.onPause();

			audioOutput.mutex.release();

			untyped __cpp__('hx::SetTopOfStack((int *)0, true)');
		}
	}

	@:noCompletion
	@:noDebug
	@:unreflective
	private static function audioResume(data:RawPointer<cpp.Void>, pts:Int64):Void
	{
		final audioOutput:AudioOutput = untyped __cpp__('reinterpret_cast<AudioOutput_obj *>({0})', data);

		if (audioOutput != null && audioOutput.onResume != null)
		{
			untyped __cpp__('int stackBase');

			untyped __cpp__('hx::SetTopOfStack(&stackBase, true)');

			audioOutput.mutex.acquire();

			audioOutput.onResume();

			audioOutput.mutex.release();

			untyped __cpp__('hx::SetTopOfStack((int *)0, true)');
		}
	}

	@:noCompletion
	@:noDebug
	@:unreflective
	private static function audioFlush(data:RawPointer<cpp.Void>, pts:Int64):Void
	{
		final audioOutput:AudioOutput = untyped __cpp__('reinterpret_cast<AudioOutput_obj *>({0})', data);

		if (audioOutput != null && audioOutput.onFlush != null)
		{
			untyped __cpp__('int stackBase');

			untyped __cpp__('hx::SetTopOfStack(&stackBase, true)');

			audioOutput.mutex.acquire();

			audioOutput.onFlush();

			audioOutput.mutex.release();

			untyped __cpp__('hx::SetTopOfStack((int *)0, true)');
		}
	}

	@:noCompletion
	@:noDebug
	@:unreflective
	private static function audioDrain(data:RawPointer<cpp.Void>):Void
	{
		final audioOutput:AudioOutput = untyped __cpp__('reinterpret_cast<AudioOutput_obj *>({0})', data);

		if (audioOutput != null && audioOutput.onDrain != null)
		{
			untyped __cpp__('int stackBase');

			untyped __cpp__('hx::SetTopOfStack(&stackBase, true)');

			audioOutput.mutex.acquire();

			audioOutput.onDrain();

			audioOutput.mutex.release();

			untyped __cpp__('hx::SetTopOfStack((int *)0, true)');
		}
	}

	@:noCompletion
	@:noDebug
	@:unreflective
	private static function audioSetVolume(data:RawPointer<cpp.Void>, volume:Single, mute:Bool):Void
	{
		// Empty because the way LibVLC handles the audio volume's isnt really nice,
		// and this callback cant be removed as if removed,
		// LibVLC will make the samples volume be changed which is really bad.
	}

	@:noCompletion
	@:noDebug
	@:unreflective
	private static function audioFormatSetup(opaque:RawPointer<RawPointer<cpp.Void>>, format:CastCharStar, rate:RawPointer<UInt32>,
			channels:RawPointer<UInt32>):Int
	{
		final audioOutput:AudioOutput = untyped __cpp__('reinterpret_cast<AudioOutput_obj *>(*{0})', opaque);

		if (audioOutput != null)
		{
			untyped __cpp__('int stackBase');

			untyped __cpp__('hx::SetTopOfStack(&stackBase, true)');

			final inFormat:String = new String(untyped format);
			final inRate:Int = rate[0];
			final inChannels:Int = channels[0];

			final outFormat:String = audioOutput.onMapFormat != null ? audioOutput.onMapFormat(inFormat) : inFormat;
			final outRate:Int = audioOutput.onMapRate != null ? audioOutput.onMapRate(inRate) : inRate;
			final outChannels:Int = audioOutput.onMapChannels != null ? audioOutput.onMapChannels(inChannels) : inChannels;

			Stdlib.nativeMemcpy(untyped format, untyped cpp.CastCharStar.fromString(outFormat), outFormat.length);

			if (outRate > 0)
				rate[0] = outRate;

			if (outChannels > 0)
				channels[0] = outChannels;

			if (audioOutput.onFormatSetup != null)
			{
				audioOutput.mutex.acquire();

				audioOutput.onFormatSetup(new String(untyped format), rate[0], channels[0]);

				audioOutput.mutex.release();
			}

			untyped __cpp__('hx::SetTopOfStack((int *)0, true)');

			return 0;
		}

		return 1;
	}
}
