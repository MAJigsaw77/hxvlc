package hxvlc.impl.events;

import cpp.Function;
import cpp.Int64;
import cpp.RawConstPointer;
import cpp.RawPointer;

import haxe.Int64 as HaxeInt64;

import hxvlc.impl.externs.LibVLC;

import sys.thread.Mutex;

/** Represents a LibVLC media player handler that receives events and thier data through native callbacks. */
class MediaPlayerEvents
{
	/** Event triggered when the media is opening. */
	public var onOpening:Null<Void->Void>;

	/** Event triggered when playback starts. */
	public var onPlaying:Null<Void->Void>;

	/** Event triggered when playback stops. */
	public var onStopped:Null<Void->Void>;

	/** Event triggered when playback is paused. */
	public var onPaused:Null<Void->Void>;

	/** Event triggered when the end of the media is reached. */
	public var onEndReached:Null<Void->Void>;

	/** Event triggered when an error occurs. */
	public var onEncounteredError:Null<Void->Void>;

	/** Event triggered when the media is corked. */
	public var onCorked:Null<Void->Void>;

	/** Event triggered when the media is uncorked. */
	public var onUncorked:Null<Void->Void>;

	/** Event triggered when a new Elementary Stream (ES) is added. */
	public var onESAdded:Null<Int->Int->Void>;

	/** Event triggered when an Elementary Stream (ES) is deleted. */
	public var onESDeleted:Null<Int->Int->Void>;

	/** Event triggered when an Elementary Stream (ES) is selected. */
	public var onESSelected:Null<Int->Int->Void>;

	/** Event triggered when the time changes. */
	public var onTimeChanged:Null<HaxeInt64->Void>;

	/** Event triggered when the position changes. */
	public var onPositionChanged:Null<Single->Void>;

	/** Event triggered when the length changes. */
	public var onLengthChanged:Null<HaxeInt64->Void>;

	/** Event triggered when the media changes. */
	public var onMediaChanged:Null<Media->Void>;

	@:noCompletion
	private var mutex:Mutex;

	/**
	 * Creates a new MediaPlayerEvents instance for handling media player event callbacks.
	 *
	 * @param mediaPlayer The media player to attach event callbacks to.
	 */
	public function new(mediaPlayer:MediaPlayer):Void
	{
		if (mediaPlayer.nativeMediaPlayer == null)
			return;

		mutex = new Mutex();

		final eventManager:RawPointer<LibVLC_Event_Manager_T> = LibVLC.media_player_event_manager(mediaPlayer.nativeMediaPlayer);

		if (eventManager != null)
		{
			LibVLC.event_attach(eventManager, untyped libvlc_MediaPlayerOpening, Function.fromStaticFunction(eventManagerCallbacks), untyped __cpp__('this'));
			LibVLC.event_attach(eventManager, untyped libvlc_MediaPlayerPlaying, Function.fromStaticFunction(eventManagerCallbacks), untyped __cpp__('this'));
			LibVLC.event_attach(eventManager, untyped libvlc_MediaPlayerStopped, Function.fromStaticFunction(eventManagerCallbacks), untyped __cpp__('this'));
			LibVLC.event_attach(eventManager, untyped libvlc_MediaPlayerPaused, Function.fromStaticFunction(eventManagerCallbacks), untyped __cpp__('this'));
			LibVLC.event_attach(eventManager, untyped libvlc_MediaPlayerEndReached, Function.fromStaticFunction(eventManagerCallbacks),
				untyped __cpp__('this'));
			LibVLC.event_attach(eventManager, untyped libvlc_MediaPlayerEncounteredError, Function.fromStaticFunction(eventManagerCallbacks),
				untyped __cpp__('this'));
			LibVLC.event_attach(eventManager, untyped libvlc_MediaPlayerCorked, Function.fromStaticFunction(eventManagerCallbacks), untyped __cpp__('this'));
			LibVLC.event_attach(eventManager, untyped libvlc_MediaPlayerUncorked, Function.fromStaticFunction(eventManagerCallbacks), untyped __cpp__('this'));
			LibVLC.event_attach(eventManager, untyped libvlc_MediaPlayerESAdded, Function.fromStaticFunction(eventManagerCallbacks), untyped __cpp__('this'));
			LibVLC.event_attach(eventManager, untyped libvlc_MediaPlayerESDeleted, Function.fromStaticFunction(eventManagerCallbacks), untyped __cpp__('this'));
			LibVLC.event_attach(eventManager, untyped libvlc_MediaPlayerESSelected, Function.fromStaticFunction(eventManagerCallbacks),
				untyped __cpp__('this'));
			LibVLC.event_attach(eventManager, untyped libvlc_MediaPlayerTimeChanged, Function.fromStaticFunction(eventManagerCallbacks),
				untyped __cpp__('this'));
			LibVLC.event_attach(eventManager, untyped libvlc_MediaPlayerPositionChanged, Function.fromStaticFunction(eventManagerCallbacks),
				untyped __cpp__('this'));
			LibVLC.event_attach(eventManager, untyped libvlc_MediaPlayerLengthChanged, Function.fromStaticFunction(eventManagerCallbacks),
				untyped __cpp__('this'));
			LibVLC.event_attach(eventManager, untyped libvlc_MediaPlayerMediaChanged, Function.fromStaticFunction(eventManagerCallbacks),
				untyped __cpp__('this'));
		}
	}

	@:noCompletion
	@:noDebug
	@:unreflective
	private static function eventManagerCallbacks(p_event:RawConstPointer<LibVLC_Event_T>, p_data:RawPointer<cpp.Void>):Void
	{
		final mediaPlayerEvents:MediaPlayerEvents = untyped __cpp__('reinterpret_cast<MediaPlayerEvents_obj *>({0})', p_data);

		if (mediaPlayerEvents != null)
		{
			untyped __cpp__('int stackBase');

			untyped __cpp__('hx::SetTopOfStack(&stackBase, true)');

			mediaPlayerEvents.mutex.acquire();

			switch (p_event[0].type)
			{
				case event if ((event == untyped libvlc_MediaPlayerOpening) && mediaPlayerEvents.onOpening != null):
					mediaPlayerEvents.onOpening();
				case event if ((event == untyped libvlc_MediaPlayerPlaying) && mediaPlayerEvents.onPlaying != null):
					mediaPlayerEvents.onPlaying();
				case event if ((event == untyped libvlc_MediaPlayerStopped) && mediaPlayerEvents.onStopped != null):
					mediaPlayerEvents.onStopped();
				case event if ((event == untyped libvlc_MediaPlayerPaused) && mediaPlayerEvents.onPaused != null):
					mediaPlayerEvents.onPaused();
				case event if ((event == untyped libvlc_MediaPlayerEndReached) && mediaPlayerEvents.onEndReached != null):
					mediaPlayerEvents.onEndReached();
				case event if ((event == untyped libvlc_MediaPlayerEncounteredError) && mediaPlayerEvents.onEncounteredError != null):
					mediaPlayerEvents.onEncounteredError();
				case event if ((event == untyped libvlc_MediaPlayerCorked) && mediaPlayerEvents.onCorked != null):
					mediaPlayerEvents.onCorked();
				case event if ((event == untyped libvlc_MediaPlayerUncorked) && mediaPlayerEvents.onUncorked != null):
					mediaPlayerEvents.onUncorked();
				case event if ((event == untyped libvlc_MediaPlayerESAdded) && mediaPlayerEvents.onESAdded != null):
					final iType:LibVLC_Track_Type = untyped __cpp__('{0}.u.media_player_es_changed.i_type', p_event[0]);
					final iID:Int = untyped __cpp__('{0}.u.media_player_es_changed.i_id', p_event[0]);

					mediaPlayerEvents.onESAdded((iType : Int), iID);
				case event if ((event == untyped libvlc_MediaPlayerESDeleted) && mediaPlayerEvents.onESDeleted != null):
					final iType:LibVLC_Track_Type = untyped __cpp__('{0}.u.media_player_es_changed.i_type', p_event[0]);
					final iID:Int = untyped __cpp__('{0}.u.media_player_es_changed.i_id', p_event[0]);

					mediaPlayerEvents.onESDeleted((iType : Int), iID);
				case event if ((event == untyped libvlc_MediaPlayerESSelected) && mediaPlayerEvents.onESSelected != null):
					final iType:LibVLC_Track_Type = untyped __cpp__('{0}.u.media_player_es_changed.i_type', p_event[0]);
					final iID:Int = untyped __cpp__('{0}.u.media_player_es_changed.i_id', p_event[0]);

					mediaPlayerEvents.onESSelected((iType : Int), iID);
				case event if ((event == untyped libvlc_MediaPlayerTimeChanged) && mediaPlayerEvents.onTimeChanged != null):
					final newTime:Int64 = untyped __cpp__('{0}.u.media_player_time_changed.new_time', p_event[0]);

					mediaPlayerEvents.onTimeChanged(newTime);
				case event if ((event == untyped libvlc_MediaPlayerPositionChanged) && mediaPlayerEvents.onPositionChanged != null):
					final newPosition:Single = untyped __cpp__('{0}.u.media_player_position_changed.new_position', p_event[0]);

					mediaPlayerEvents.onPositionChanged(newPosition);
				case event if ((event == untyped libvlc_MediaPlayerLengthChanged) && mediaPlayerEvents.onLengthChanged != null):
					final newLength:Int64 = untyped __cpp__('{0}.u.media_player_length_changed.new_length', p_event[0]);

					mediaPlayerEvents.onLengthChanged(newLength);
				case event if ((event == untyped libvlc_MediaPlayerMediaChanged) && mediaPlayerEvents.onMediaChanged != null):
					final newMedia:Media = new Media(false);
					newMedia.nativeMedia = untyped __cpp__('{0}.u.media_player_media_changed.new_media', p_event[0]);
					mediaPlayerEvents.onMediaChanged(newMedia);
			}

			mediaPlayerEvents.mutex.release();

			untyped __cpp__('hx::SetTopOfStack((int *)0, true)');
		}
	}
}
