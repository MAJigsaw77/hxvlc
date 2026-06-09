package hxvlc.impl.output;

import cpp.CastCharStar;
import cpp.Function;
import cpp.NativeArray;
import cpp.RawPointer;
import cpp.Stdlib;
import cpp.UInt32;
import cpp.VoidStarConstStar;

import haxe.io.BytesData;

import hxvlc.impl.externs.LibVLC;

import sys.thread.Mutex;

class VideoOutput
{
	/** Called when video frame data is ready to be displayed. */
	public var onDisplay:Null<(pixels:Null<BytesData>) -> Void>;

	/** Called when the video format is set up with dimensions. */
	public var onFormatSetup:Null<(width:Int, height:Int) -> Void>;

	@:noCompletion
	private var mutex:Mutex;

	@:noCompletion
	private var width:Null<Int>;

	@:noCompletion
	private var height:Null<Int>;

	@:noCompletion
	private var format:Null<String>;

	@:noCompletion
	private var bytesPerPixel:Int;

	@:noCompletion
	private var pixels:Null<BytesData>;

	@:noCompletion
	private var nativeMediaPlayer:RawPointer<LibVLC_Media_Player_T>;

	/**
	 * Creates a new VideoOutput instance for rendering video frames.
	 * 
	 * @param mediaPlayer The media player to attach video callbacks to.
	 * @param format The pixel format string (e.g., "RV32").
	 * @param bytesPerPixel The number of bytes per pixel for the specified format.
	 */
	public function new(mediaPlayer:MediaPlayer, format:String, bytesPerPixel:Int):Void
	{
		if (mediaPlayer.nativeMediaPlayer == null)
			return;

		this.mutex = new Mutex();
		this.format = format;
		this.bytesPerPixel = bytesPerPixel;
		this.nativeMediaPlayer = mediaPlayer.nativeMediaPlayer;

		LibVLC.video_set_callbacks(nativeMediaPlayer, Function.fromStaticFunction(videoLock), Function.fromStaticFunction(videoUnlock),
			Function.fromStaticFunction(videoDisplay), untyped __cpp__('this'));

		@:nullSafety(Off)
		LibVLC.video_set_format_callbacks(nativeMediaPlayer, Function.fromStaticFunction(videoFormatSetup), null);
	}

	@:noCompletion
	@:noDebug
	@:unreflective
	private static function videoLock(data:RawPointer<cpp.Void>, p_pixels:RawPointer<RawPointer<cpp.Void>>):cpp.RawPointer<cpp.Void>
	{
		final videoOutput:VideoOutput = untyped __cpp__('reinterpret_cast<VideoOutput_obj *>({0})', data);

		if (videoOutput != null)
		{
			untyped __cpp__('int stackBase');

			untyped __cpp__('hx::SetTopOfStack(&stackBase, true)');

			videoOutput.mutex.acquire();

			if (videoOutput.pixels != null)
				p_pixels[0] = untyped NativeArray.getBase(videoOutput.pixels).getBase();

			untyped __cpp__('hx::SetTopOfStack((int *)0, true)');
		}

		@:nullSafety(Off)
		return null;
	}

	@:noCompletion
	@:noDebug
	@:unreflective
	private static function videoUnlock(data:RawPointer<cpp.Void>, id:RawPointer<cpp.Void>, p_pixels:VoidStarConstStar):Void
	{
		final videoOutput:VideoOutput = untyped __cpp__('reinterpret_cast<VideoOutput_obj *>({0})', data);

		if (videoOutput != null)
		{
			untyped __cpp__('int stackBase');

			untyped __cpp__('hx::SetTopOfStack(&stackBase, true)');

			videoOutput.mutex.release();

			untyped __cpp__('hx::SetTopOfStack((int *)0, true)');
		}
	}

	@:noCompletion
	@:noDebug
	@:unreflective
	private static function videoDisplay(opaque:RawPointer<cpp.Void>, picture:RawPointer<cpp.Void>):Void
	{
		final videoOutput:VideoOutput = untyped __cpp__('reinterpret_cast<VideoOutput_obj *>({0})', opaque);

		if (videoOutput != null && videoOutput.onDisplay != null)
		{
			untyped __cpp__('int stackBase');

			untyped __cpp__('hx::SetTopOfStack(&stackBase, true)');

			videoOutput.mutex.acquire();

			videoOutput.onDisplay(videoOutput.pixels);

			videoOutput.mutex.release();

			untyped __cpp__('hx::SetTopOfStack((int *)0, true)');
		}
	}

	@:noCompletion
	@:noDebug
	@:nullSafety(Off)
	@:unreflective
	private static function videoFormatSetup(opaque:RawPointer<RawPointer<cpp.Void>>, chroma:CastCharStar, width:RawPointer<UInt32>,
			height:RawPointer<UInt32>, pitches:RawPointer<UInt32>, lines:RawPointer<UInt32>):UInt32
	{
		final videoOutput:VideoOutput = untyped __cpp__('reinterpret_cast<VideoOutput_obj *>(*{0})', opaque);

		if (videoOutput != null && videoOutput.onFormatSetup != null && videoOutput.format != null && videoOutput.bytesPerPixel > 0)
		{
			untyped __cpp__('int stackBase');

			untyped __cpp__('hx::SetTopOfStack(&stackBase, true)');

			Stdlib.nativeMemcpy(untyped chroma, untyped cpp.CastCharStar.fromString(videoOutput.format), videoOutput.format.length);

			videoOutput.mutex.acquire();

			final originalWidth:UInt32 = width[0];
			final originalHeight:UInt32 = height[0];

			if (!calculateVideoSize(videoOutput.nativeMediaPlayer, width, height))
			{
				width[0] = originalWidth;
				height[0] = originalHeight;
			}

			videoOutput.width = width[0];
			videoOutput.height = height[0];

			pitches[0] = videoOutput.width * videoOutput.bytesPerPixel;
			lines[0] = videoOutput.height;

			if (videoOutput.pixels == null)
				videoOutput.pixels = new BytesData();

			NativeArray.setSize(videoOutput.pixels, videoOutput.width * videoOutput.height * videoOutput.bytesPerPixel);

			videoOutput.onFormatSetup(videoOutput.width, videoOutput.height);

			videoOutput.mutex.release();

			untyped __cpp__('hx::SetTopOfStack((int *)0, true)');

			return 1;
		}

		return 0;
	}

	/**
	 * @see https://github.com/obsproject/obs-studio/blob/5d1f0efc43c64c25f5edd4101bc1f0013bcacb60/plugins/vlc-video/vlc-video-source.c#L385
	 */
	@:noCompletion
	@:noDebug
	@:unreflective
	private static function calculateVideoSize(mediaPlayer:RawPointer<LibVLC_Media_Player_T>, width:RawPointer<UInt32>, height:RawPointer<UInt32>):Bool
	{
		if (mediaPlayer != null)
		{
			final currentMediaItem:RawPointer<LibVLC_Media_T> = LibVLC.media_player_get_media(mediaPlayer);

			if (currentMediaItem != null)
			{
				final tracks:RawPointer<RawPointer<LibVLC_Media_Track_T>> = untyped NULL;

				final count:UInt32 = LibVLC.media_tracks_get(currentMediaItem, RawPointer.addressOf(tracks));

				for (i in 0...count)
				{
					final track:RawPointer<LibVLC_Media_Track_T> = tracks[i];

					if (track[0].i_type != LibVLC_Track_Video || LibVLC.video_get_track(mediaPlayer) != track[0].i_id)
						continue;

					var trackWidth:UInt32 = track[0].video[0].i_width;
					var trackHeight:UInt32 = track[0].video[0].i_height;

					if (trackWidth == 0 || trackHeight == 0)
						break;

					var trackSarNum:UInt32 = track[0].video[0].i_sar_num;
					var trackSarDen:UInt32 = track[0].video[0].i_sar_den;

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

					return true;
				}

				LibVLC.media_tracks_release(tracks, count);
			}
		}

		return false;
	}
}
