package hxvlc.impl;

import cpp.CastCharStar;
import cpp.ConstCharStar;
import cpp.Function;
import cpp.RawConstPointer;
import cpp.RawPointer;
import cpp.StdVector;
import cpp.Stdlib;
import cpp.UInt32;
import cpp.VarList;

import haxe.PosInfos;
import haxe.extern.AsVar;
import haxe.io.Path;

import hxvlc.impl.externs.LibVLC;

import sys.thread.Mutex;

/** Represents a implementation or wrapper for the native LibVLC instance */
@:cppInclude('stdarg.h')
@:cppNamespaceCode('static int vsnprintf_safe(char* buffer, size_t size, const char* fmt, va_list args)
{
    va_list copy;
    va_copy(copy, args);
    int len = vsnprintf(buffer, size, fmt, copy);
    va_end(copy);
    return len;
}')
class Instance extends Finalizeable
{
	#if (windows || macos)
	@:noCompletion
	private static function __init__():Void
	{
		final pluginPath:String = haxe.io.Path.join([haxe.io.Path.directory(Sys.programPath()), 'plugins']);

		if (sys.FileSystem.exists(pluginPath))
			Sys.putEnv('VLC_PLUGIN_PATH', pluginPath);
	}
	#end

	/** The possible source paths that the LibVLC logs can come from */
	@:noCompletion
	private static final POSSIBLE_LIBVLC_LOG_PATHS:Array<String> = ['src', 'modules'];

	/** Retrieves the LibVLC version. */
	public static var version(get, never):String;

	/** Retrieves the LibVLC compiler version. */
	public static var compiler(get, never):String;

	/** Retrieves the LibVLC changeset. */
	public static var changeset(get, never):String;

	/** @return The default arguments for a LibVLC instance on `hxvlc`. */
	public static function defaultArgs():Array<String>
	{
		final args:Array<String> = [];

		#if (android || ios)
		args.push("--audio-resampler=soxr"); // High-quality audio resampler (default in VLC 4.0)
		#end
		args.push("--ignore-config"); // Ignore any existing VLC config files
		args.push("--drop-late-frames"); // Drop late video frames instead of trying to render them
		args.push("--aout=adummy"); // Disable audio output (we use amem)
		args.push("--intf=none"); // Disable interface / UI
		args.push("--vout=vdummy"); // Disable video output (we use vmem)
		args.push("--text-renderer=freetype"); // Use Freetype for subtitles/text overlays
		args.push("--no-color"); // Disable colored console output
		args.push("--no-lua"); // Disable Lua scripting engine
		args.push("--no-interact"); // Disable interaction prompts
		args.push("--no-keyboard-events"); // Disable keyboard input
		args.push("--no-mouse-events"); // Disable mouse events
		args.push("--no-snapshot-preview"); // Disable snapshot previews
		args.push("--no-sout-keep"); // Disable streaming output persistence
		args.push("--no-sub-autodetect-file"); // Don’t automatically load subtitle files
		args.push("--no-video-title-show"); // Don’t show video title overlay at playback start
		#if (macos || ios)
		args.push("--no-videotoolbox"); // Disable VideoToolbox hardware decoding (to make subtitles work)
		#end
		args.push("--no-volume-save"); // Don’t save last volume level
		args.push("--no-xlib"); // Disable X11 output (irrelevant on Apple)

		#if (windows || macos)
		final pluginPath:Null<String> = Sys.getEnv('VLC_PLUGIN_PATH');

		if (pluginPath != null)
		{
			if (sys.FileSystem.exists(haxe.io.Path.join([pluginPath, 'plugins.dat'])))
				args.push("--no-plugins-scan");
			else
				args.push("--reset-plugins-cache");
		}
		#end

		args.push("--quiet");

		return args;
	}

	/** The raw instance of LibVLC. */
	@:noCompletion
	public var nativeInstance:Null<RawPointer<LibVLC_Instance_T>>;

	@:noCompletion
	private var mutex:Mutex;

	@:noCompletion
	private var onLog:Null<PosInfos->Int->String->Void>;

	/**
	 * Intializes the native LibVLC instance.
	 * 
	 * @param options The options the LibVLC instance should be initialized with (defaults to `defaultArgs()` if none are provided)
	 */
	public function new(?options:Array<String>):Void
	{
		super();

		this.mutex = new Mutex();

		final args:StdVector<ConstCharStar> = new StdVector<ConstCharStar>();

		for (option in options ?? defaultArgs())
		{
			if (option != null && option.length > 0)
				args.push_back(option);
		}

		nativeInstance = LibVLC.alloc(args.size(), args.data());
	}

	/**
	 * Sets the instance's user agent when a protocol requires it.
	 * 
	 * @param name The human-readable application name, e.g. "FooBar player 1.2.3"
	 * @param http The HTTP User Agent, e.g. "FooBar/1.2.3 Python/2.6.0"
	 */
	public function setUserAgent(name:String, http:String):Void
	{
		if (nativeInstance != null)
			LibVLC.set_user_agent(nativeInstance, name, http);
	}

	/**
	 * Sets a callback to receive log messages.
	 * 
	 * @param cb The callback function, or `null` to unset it.
	 */
	public function setLog(cb:PosInfos->Int->String->Void):Void
	{
		if (nativeInstance == null)
			return;

		if (cb != null)
		{
			onLog = cb;

			LibVLC.log_set(nativeInstance, Function.fromStaticFunction(logCallback), untyped __cpp__('this'));
		}
		else if (onLog != null)
		{
			LibVLC.log_unset(nativeInstance);

			onLog = null;
		}
	}

	/** Destroys the native LibVLC instance (even if not called, the GC will be picking it up if unused) */
	public override function destroy():Void
	{
		if (nativeInstance != null)
		{
			LibVLC.release(nativeInstance);

			nativeInstance = null;
		}
	}

	@:noCompletion
	private static function get_version():String
	{
		return LibVLC.get_version();
	}

	@:noCompletion
	private static function get_compiler():String
	{
		return LibVLC.get_compiler();
	}

	@:noCompletion
	private static function get_changeset():String
	{
		return LibVLC.get_changeset();
	}

	@:noCompletion
	@:noDebug
	@:unreflective
	static function logCallback(data:RawPointer<cpp.Void>, level:Int, ctx:RawConstPointer<LibVLC_Log_T>, fmt:ConstCharStar, args:VarList):Void
	{
		final instance:Instance = untyped __cpp__('reinterpret_cast<Instance_obj *>({0})', data);

		if (instance != null && instance.onLog != null)
		{
			untyped __cpp__('int stackBase');

			untyped __cpp__('hx::SetTopOfStack(&stackBase, true)');

			instance.mutex.acquire();

			instance.onLog(getPosFromContext(ctx), level, getStringFromFormat(fmt, args));

			instance.mutex.release();

			untyped __cpp__('hx::SetTopOfStack((int *)0, true)');
		}
	}

	@:noCompletion
	@:noDebug
	@:unreflective
	public static function getStringFromFormat(fmt:ConstCharStar, args:VarList):String
	{
		final len:Int = untyped vsnprintf_safe(untyped nullptr, 0, fmt, args);

		if (len > 0)
		{
			final buffer:CastCharStar = cast Stdlib.nativeMalloc(len + 1);

			untyped vsnprintf_safe(buffer, len + 1, fmt, args);

			final msg:String = new String(untyped buffer);

			Stdlib.nativeFree(untyped buffer);

			return msg;
		}

		return '';
	}

	@:noCompletion
	@:noDebug
	@:unreflective
	private static function getPosFromContext(ctx:RawConstPointer<LibVLC_Log_T>):PosInfos
	{
		final fileName:AsVar<ConstCharStar> = untyped nullptr;

		final lineNumber:AsVar<UInt32> = 0;

		LibVLC.log_get_context(ctx, untyped nullptr, RawPointer.addressOf(fileName), RawPointer.addressOf(lineNumber));

		var normalizedPath:String = fileName != null ? Path.normalize(fileName) : '';

		if (normalizedPath.length > 0)
		{
			for (logPath in POSSIBLE_LIBVLC_LOG_PATHS)
			{
				final index:Int = normalizedPath.indexOf(logPath, 0);

				if (index != -1)
				{
					normalizedPath = normalizedPath.substring(index, normalizedPath.length);
					break;
				}
			}
		}

		return {
			fileName: normalizedPath,
			lineNumber: lineNumber,
			className: '',
			methodName: ''
		};
	}
}
