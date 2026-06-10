package hxvlc.impl.events;

import cpp.Function;
import cpp.RawConstPointer;
import cpp.RawPointer;

import hxvlc.impl.externs.LibVLC;

import sys.thread.Mutex;

class MediaEvents
{
	/** Event triggered when the media is parsed. */
	public var onMediaParsedChanged:Null<Int->Void>;

	/** Event triggered when the media metadata changes. */
	public var onMediaMetaChanged:Null<Int->Void>;

	@:noCompletion
	private var mutex:Mutex;

	public function new(media:Media):Void
	{
		if (media.nativeMedia == null)
			return;

		mutex = new Mutex();

		final eventManager:RawPointer<LibVLC_Event_Manager_T> = LibVLC.media_event_manager(media.nativeMedia);

		if (eventManager != null)
		{
			LibVLC.event_attach(eventManager, LibVLC_MediaParsedChanged, Function.fromStaticFunction(eventManagerCallbacks), untyped __cpp__('this'));
			LibVLC.event_attach(eventManager, LibVLC_MediaMetaChanged, Function.fromStaticFunction(eventManagerCallbacks), untyped __cpp__('this'));
		}
	}

	@:noCompletion
	@:noDebug
	@:unreflective
	private static function eventManagerCallbacks(p_event:RawConstPointer<LibVLC_Event_T>, p_data:RawPointer<cpp.Void>):Void
	{
		final mediaEvents:MediaEvents = untyped __cpp__('reinterpret_cast<MediaEvents_obj *>({0})', p_data);

		if (mediaEvents != null)
		{
			untyped __cpp__('int stackBase');

			untyped __cpp__('hx::SetTopOfStack(&stackBase, true)');

			mediaEvents.mutex.acquire();

			switch (p_event[0].type)
			{
				case event if (event == LibVLC_MediaParsedChanged && mediaEvents.onMediaParsedChanged != null):
					final newStatus:Int = untyped __cpp__('{0}.u.media_parsed_changed.new_status', p_event[0]);

					mediaEvents.onMediaParsedChanged(newStatus);
				case event if (event == LibVLC_MediaMetaChanged && mediaEvents.onMediaMetaChanged != null):
					final metaType:LibVLC_Meta_T = untyped __cpp__('{0}.u.media_meta_changed.meta_type', p_event[0]);

					mediaEvents.onMediaMetaChanged((metaType : Int));
			}

			mediaEvents.mutex.release();

			untyped __cpp__('hx::SetTopOfStack((int *)0, true)');
		}
	}
}
