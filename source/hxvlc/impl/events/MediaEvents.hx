package hxvlc.impl.events;

import cpp.Function;
import cpp.Int64;
import cpp.RawConstPointer;
import cpp.RawPointer;

import haxe.Int64 as HaxeInt64;

import hxvlc.impl.externs.LibVLC;

import sys.thread.Mutex;

/** Represents a LibVLC media handler that receives events and thier data through native callbacks. */
class MediaEvents
{
	/** Event triggered when the media is parsed. */
	public var onParsedChanged:Null<Int->Void>;

	/** Event triggered when the media metadata changes. */
	public var onMetaChanged:Null<Int->Void>;

	/** Event triggered when a sub-item is added to the media. */
	public var onSubItemAdded:Null<Media->Void>;

	/** Event triggered when the media duration changes. */
	public var onDurationChanged:Null<HaxeInt64->Void>;

	/** Event triggered when a sub-item tree is added to the media. */
	public var onSubItemTreeAdded:Null<Media->Void>;

	@:noCompletion
	private var mutex:Mutex;

	/**
	 * Creates a new MediaEvents instance for handling media event callbacks.
	 *
	 * @param media The media object to attach event callbacks to.
	 */
	public function new(media:Media):Void
	{
		if (media.nativeMedia == null)
			return;

		mutex = new Mutex();

		final eventManager:RawPointer<LibVLC_Event_Manager_T> = LibVLC.media_event_manager(media.nativeMedia);

		if (eventManager != null)
		{
			LibVLC.event_attach(eventManager, untyped libvlc_MediaParsedChanged, Function.fromStaticFunction(eventManagerCallbacks), untyped __cpp__('this'));
			LibVLC.event_attach(eventManager, untyped libvlc_MediaMetaChanged, Function.fromStaticFunction(eventManagerCallbacks), untyped __cpp__('this'));
			LibVLC.event_attach(eventManager, untyped libvlc_MediaSubItemAdded, Function.fromStaticFunction(eventManagerCallbacks), untyped __cpp__('this'));
			LibVLC.event_attach(eventManager, untyped libvlc_MediaDurationChanged, Function.fromStaticFunction(eventManagerCallbacks), untyped __cpp__('this'));
			LibVLC.event_attach(eventManager, untyped libvlc_MediaSubItemTreeAdded, Function.fromStaticFunction(eventManagerCallbacks),
				untyped __cpp__('this'));
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
				case event if ((event == untyped libvlc_MediaParsedChanged) && mediaEvents.onParsedChanged != null):
					final newStatus:Int = untyped __cpp__('{0}.u.media_parsed_changed.new_status', p_event[0]);

					mediaEvents.onParsedChanged(newStatus);
				case event if ((event == untyped libvlc_MediaMetaChanged) && mediaEvents.onMetaChanged != null):
					final metaType:LibVLC_Meta_T = untyped __cpp__('{0}.u.media_meta_changed.meta_type', p_event[0]);

					mediaEvents.onMetaChanged((metaType : Int));
				case event if ((event == untyped libvlc_MediaSubItemAdded) && mediaEvents.onSubItemAdded != null):
					final newChild:Media = new Media(false);
					newChild.nativeMedia = untyped __cpp__('{0}.u.media_subitem_added.new_child', p_event[0]);
					mediaEvents.onSubItemAdded(newChild);
				case event if ((event == untyped libvlc_MediaDurationChanged) && mediaEvents.onDurationChanged != null):
					final newLength:Int64 = untyped __cpp__('{0}.u.media_duration_changed.new_duration', p_event[0]);

					mediaEvents.onDurationChanged(newLength);
				case event if ((event == untyped libvlc_MediaSubItemTreeAdded) && mediaEvents.onSubItemTreeAdded != null):
					final item:Media = new Media(false);
					item.nativeMedia = untyped __cpp__('{0}.u.media_subitemtree_added.item', p_event[0]);
					mediaEvents.onSubItemTreeAdded(item);
			}

			mediaEvents.mutex.release();

			untyped __cpp__('hx::SetTopOfStack((int *)0, true)');
		}
	}
}
