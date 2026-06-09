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
	/** Called when audio samples are ready to be played. */
	public var onPlay:Null<(samples:Null<BytesData>) -> Void>;

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
	private var format:String;

	@:noCompletion
	private var rate:Null<Int>;

	@:noCompletion
	private var channels:Null<Int>;

	@:noCompletion
	private var samples:Null<BytesData>;

	/**
	 * Creates a new AudioOutput instance for handling audio output.
	 * 
	 * @param mediaPlayer The media player to attach audio callbacks to.
	 * @param format The audio format string (e.g., "S16N").
	 * @param rate (Optional) The sample rate. If not provided, it will use the default coming from LibVLC.
	 * @param channels (Optional) The number of audio channels. If not provided, it will use the default coming from LibVLC.
	 */
	public function new(mediaPlayer:MediaPlayer, format:String, ?rate:Int, ?channels:Int):Void
	{
		if (mediaPlayer.nativeMediaPlayer == null)
			return;

		this.mutex = new Mutex();
		this.format = format;
		this.rate = rate;
		this.channels = channels;

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
		// and this callback cant be removed as if removed, LibVLC will make the samples volume be changed which is really bad.
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

			Stdlib.nativeMemcpy(untyped format, untyped cpp.CastCharStar.fromString(audioOutput.format), audioOutput.format.length);

			if (audioOutput.rate != null && audioOutput.rate > 0)
				rate[0] = audioOutput.rate;

			if (audioOutput.channels != null && audioOutput.channels > 0)
				channels[0] = audioOutput.channels;

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
