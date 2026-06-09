package hxvlc.impl;

import cpp.NativeArray;
import cpp.Stdlib;
import cpp.RawConstPointer;
import cpp.Function;

import haxe.io.BytesInput;

import sys.thread.Mutex;

import cpp.CastCharStar;
import cpp.Int64;
import cpp.RawPointer;
import cpp.SSizeT;
import cpp.SizeT;
import cpp.UInt64;
import cpp.UInt8;

import haxe.io.Bytes;

import hxvlc.impl.externs.LibVLC;

import sys.FileSystem;

@:access(haxe.io.BytesInput)
class Media extends Finalizeable
{
	/**
	 * Intializes a LibVLC media instance from an absolute path.
	 * 
	 * @param instance The LibVLC instance to use for the media.
	 * @param path The absolute path to use.
	 * @return The media instance created or null if failed.
	 */
	public static function fromPath(instance:Instance, path:String):Null<Media>
	{
		if (instance == null || instance.nativeInstance == null)
			return null;

		if (path == null || path.length == 0 || !FileSystem.exists(path))
			return null;

		final media:Media = new Media();
		#if windows
		media.nativeMedia = LibVLC.media_new_path(instance.nativeInstance, haxe.io.Path.normalize(path).split('/').join('\\'));
		#else
		media.nativeMedia = LibVLC.media_new_path(instance.nativeInstance, haxe.io.Path.normalize(path));
		#end
		return media;
	}

	/**
	 * Intializes a LibVLC media instance from an location.
	 * 
	 * @param instance The LibVLC instance to use for the media.
	 * @param location The location to use.
	 * @return The media instance created or null if failed.
	 */
	public static function fromLocation(instance:Instance, location:String):Null<Media>
	{
		if (instance == null || instance.nativeInstance == null)
			return null;

		final media:Media = new Media();
		media.nativeMedia = LibVLC.media_new_location(instance.nativeInstance, location);
		return media;
	}

	/**
	 * Intializes a LibVLC media instance from a bytes instance.
	 * 
	 * @param instance The LibVLC instance to use for the media.
	 * @param bytes The bytes instance to use.
	 * @return The media instance created or null if failed.
	 */
	public static function fromBytes(instance:Instance, bytes:Bytes):Null<Media>
	{
		if (instance == null || instance.nativeInstance == null)
			return null;

		if (bytes == null || bytes.length == 0)
			return null;

		final media:Media = new Media();

		media.mutex = new Mutex();

		media.input = new BytesInput(bytes);

		@:nullSafety(Off)
		media.nativeMedia = LibVLC.media_new_callbacks(instance.nativeInstance, Function.fromStaticFunction(mediaOpen),
			Function.fromStaticFunction(mediaRead), Function.fromStaticFunction(mediaSeek), null, untyped __cpp__('{0}.mPtr', media));

		return media;
	}

	/** The media resource locator (MRL). */
	public var mrl(get, never):Null<String>;

	/** Duration of the media in microseconds. */
	public var duration(get, never):Int64;

	/** Statistics related to the media. */
	public var stats(get, never):Null<Stats>;

	/** The raw media of LibVLC. */
	@:noCompletion
	public var nativeMedia:Null<RawPointer<LibVLC_Media_T>>;

	@:noCompletion
	private var owned:Bool = true;

	@:noCompletion
	private var mutex:Null<Mutex>;

	@:noCompletion
	private var input:Null<BytesInput>;

	/**
	 * Initializes the LibVLC media
	 */
	public function new(owned:Bool = true):Void
	{
		super('Media');

		this.owned = owned;
	}

	/**
	 * Adds an option to the LibVLC media instance.
	 * 
	 * @param option The option to be added.
	 */
	public function addOption(option:String):Void
	{
		if (nativeMedia != null && (option != null && option.length > 0))
			LibVLC.media_add_option(nativeMedia, option);
	}

	/**
	 * Retrivews the subitems of the LibVLC media instance.
	 * 
	 * @return The subitems as an array.
	 */
	public function subitems():Array<Media>
	{
		final subitems:Array<Media> = [];

		if (nativeMedia != null)
		{
			final nativeMediaSubItems:RawPointer<LibVLC_Media_List_T> = LibVLC.media_subitems(nativeMedia);

			if (nativeMediaSubItems != null)
			{
				for (i in 0...LibVLC.media_list_count(nativeMediaSubItems))
				{
					final mediaSubItem:Media = new Media();
					mediaSubItem.nativeMedia = LibVLC.media_list_item_at_index(nativeMediaSubItems, i);
					subitems.push(mediaSubItem);
				}

				LibVLC.media_list_release(nativeMediaSubItems);
			}
		}

		return subitems;
	}

	/**
	 * Parses the LibVLC media instance with the specified options.
	 * 
	 * @param parse_flag The parsing option.
	 * @param timeout The timeout in milliseconds.
	 * @return `true` if parsing succeeded, `false` otherwise.
	 */
	public function parseWithOptions(parse_flag:Int, timeout:Int):Bool
	{
		return nativeMedia != null ? LibVLC.media_parse_with_options(nativeMedia, parse_flag, timeout) == 0 : false;
	}

	/** Stops parsing the LibVLC media instance. */
	public function parseStop():Void
	{
		if (nativeMedia != null)
			LibVLC.media_parse_stop(nativeMedia);
	}

	/**
	 * Retrieves metadata with the LibVLC media instance.
	 * 
	 * @param e_meta The metadata type.
	 * @return The metadata value as a string, or `null` if not available.
	 */
	public function getMeta(e_meta:Int):Null<String>
	{
		if (nativeMedia != null)
		{
			final rawMeta:CastCharStar = LibVLC.media_get_meta(nativeMedia, e_meta);

			if (rawMeta != null)
				return new String(untyped rawMeta);
		}

		return null;
	}

	/**
	 * Sets metadata for the LibVLC media instance.
	 * 
	 * @param e_meta The metadata type.
	 * @param value The metadata value.
	 */
	public function setMeta(e_meta:Int, value:String):Void
	{
		if (nativeMedia != null)
			LibVLC.media_set_meta(nativeMedia, e_meta, value);
	}

	/**
	 * Saves the metadata of the LibVLC media instance.
	 * 
	 * @return `true` if the metadata was saved successfully, `false` otherwise.
	 */
	public function saveMeta():Bool
	{
		return nativeMedia != null ? LibVLC.media_save_meta(nativeMedia) != 0 : false;
	}

	/** Destroys the native LibVLC media (even if not called, the GC will be picking it up if unused) */
	public override function destroy():Bool
	{
		if (nativeMedia != null && owned)
		{
			LibVLC.media_release(nativeMedia);

			nativeMedia = null;

			return true;
		}

		return false;
	}

	@:noCompletion
	private function get_mrl():Null<String>
	{
		if (nativeMedia != null)
		{
			final rawMrl:CastCharStar = LibVLC.media_get_mrl(nativeMedia);

			if (rawMrl != null)
				return new String(untyped rawMrl);
		}

		return null;
	}

	@:noCompletion
	private function get_duration():Int64
	{
		return nativeMedia != null ? LibVLC.media_get_duration(nativeMedia) : -1;
	}

	@:noCompletion
	private function get_stats():Null<Stats>
	{
		if (nativeMedia != null)
		{
			final nativeMediaStats:LibVLC_Media_Stats_T = new LibVLC_Media_Stats_T();

			if (LibVLC.media_get_stats(nativeMedia, RawPointer.addressOf(nativeMediaStats)) != 0)
				return Stats.fromMediaStats(nativeMediaStats);
		}

		return null;
	}

	@:noCompletion
	@:noDebug
	@:unreflective
	private static function mediaOpen(opaque:RawPointer<cpp.Void>, datap:RawPointer<RawPointer<cpp.Void>>, sizep:RawPointer<UInt64>):Int
	{
		final media:Media = untyped __cpp__('reinterpret_cast<Media_obj *>({0})', opaque);

		if (media != null && media.mutex != null && (media.input != null && media.input.length > 0))
		{
			datap[0] = opaque;

			untyped __cpp__('int stackBase');

			untyped __cpp__('hx::SetTopOfStack(&stackBase, true)');

			sizep[0] = media.input.length;

			untyped __cpp__('hx::SetTopOfStack((int *)0, true)');

			return 0;
		}

		return 1;
	}

	@:noCompletion
	@:noDebug
	@:unreflective
	private static function mediaRead(opaque:RawPointer<cpp.Void>, buf:RawPointer<UInt8>, len:SizeT):SSizeT
	{
		final media:Media = untyped __cpp__('reinterpret_cast<Media_obj *>({0})', opaque);

		if (media != null && media.mutex != null && (media.input != null && media.input.length > 0))
		{
			untyped __cpp__('int stackBase');

			untyped __cpp__('hx::SetTopOfStack(&stackBase, true)');

			media.mutex.acquire();

			final remaining:Int = media.input.length - media.input.position;

			if (remaining <= 0)
			{
				media.mutex.release();

				untyped __cpp__('hx::SetTopOfStack((int *)0, true)');

				return 0;
			}

			final read:Int = len < remaining ? len : remaining;

			Stdlib.nativeMemcpy(cast buf, cast RawConstPointer.addressOf(NativeArray.getBase(media.input.b).getBase()[media.input.position]), read);

			media.input.position += read;

			media.mutex.release();

			untyped __cpp__('hx::SetTopOfStack((int *)0, true)');

			return read;
		}

		return -1;
	}

	@:noCompletion
	@:noDebug
	@:unreflective
	private static function mediaSeek(opaque:RawPointer<cpp.Void>, offset:UInt64):Int
	{
		final media:Media = untyped __cpp__('reinterpret_cast<Media_obj *>({0})', opaque);

		if (media != null && media.mutex != null && (media.input != null && media.input.length > 0))
		{
			untyped __cpp__('int stackBase');

			untyped __cpp__('hx::SetTopOfStack(&stackBase, true)');

			media.mutex.acquire();

			final offset:Int = cast offset;

			if (offset > media.input.length)
			{
				media.mutex.release();

				untyped __cpp__('hx::SetTopOfStack((int *)0, true)');

				return -1;
			}

			media.input.position = offset;

			media.mutex.release();

			untyped __cpp__('hx::SetTopOfStack((int *)0, true)');

			return 0;
		}

		return -1;
	}
}
