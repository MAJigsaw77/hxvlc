package hxvlc.util;

import haxe.Log;
import haxe.MainLoop;
import haxe.io.Path;
import hxvlc.externs.LibVLC;
import hxvlc.externs.Types;
import hxvlc.util.macros.DefineMacro;
import sys.FileSystem;
import sys.thread.Mutex;

#if android
import haxe.Exception;
import lime.app.Future;
import lime.system.System;
import lime.utils.AssetLibrary;
import lime.utils.Assets;
import sys.io.File;
#end

/** This class manages the global instance of LibVLC, providing methods for initialization, disposal, and retrieving version information. */
#if HXVLC_LOGGING
@:cppNamespaceCode('static void instance_logging(void *data, int level, const libvlc_log_t *ctx, const char *fmt, va_list args)
{
	hx::SetTopOfStack((int *)99, true);

	Handle_obj::instanceLogging(level, ctx, fmt, args);

	hx::SetTopOfStack((int *)0, true);
}')
#end
class Handle
{
	/** The instance of LibVLC that is used globally. */
	public static var instance(default, null):Null<cpp.RawPointer<LibVLC_Instance_T>>;

	/** Indicates whether the instance is still loading. */
	public static var loading(default, null):Bool = false;

	/** Retrieves the LibVLC version. */
	public static var version(get, never):String;

	/** Retrieves the LibVLC compiler version. */
	public static var compiler(get, never):String;

	/** Retrieves the LibVLC changeset. */
	public static var changeset(get, never):String;

	@:noCompletion
	private static final instanceMutex:Mutex = new Mutex();

	#if (HXVLC_LOGGING)
	@:noCompletion
	private static final logMutex:Mutex = new Mutex();
	#end

	/**
	 * Initializes the LibVLC instance if it isn't already.
	 * 
	 * @param options The additional options you can add to the LibVLC instance.
	 * @return `true` if the instance was created successfully or `false` if there was an error or the instance is still loading.
	 */
	public static inline function init(?options:Array<String>):Bool
	{
		return initWithRetry(options, false);
	}

	/**
	 * Initializes the LibVLC instance asynchronously if it isn't already.
	 * 
	 * @param options The additional options you can add to the LibVLC instance.
	 * @param finishCallback A callback that is called after it finishes loading.
	 */
	public static function initAsync(?options:Array<String>, ?finishCallback:Bool->Void):Void
	{
		if (loading)
			return;

		MainLoop.addThread(function():Void
		{
			final success:Bool = init(options);

			if (finishCallback != null)
				MainLoop.runInMainThread(finishCallback.bind(success));
		});
	}

	/**
	 * Frees the LibVLC instance.
	 */
	public static function dispose():Void
	{
		instanceMutex.acquire();

		if (instance != null)
		{
			LibVLC.release(instance);
			instance = null;
		}

		instanceMutex.release();
	}

	@:noCompletion
	private static function initWithRetry(?options:Array<String>, ?resetCache:Bool = false):Bool
	{
		instanceMutex.acquire();

		if (loading)
		{
			instanceMutex.release();

			return false;
		}

		loading = true;

		if (instance == null)
		{
			setupEnvVariables();

			final args:cpp.StdVector<cpp.ConstCharStar> = new cpp.StdVector<cpp.ConstCharStar>();
			args.push_back("--ignore-config");
			args.push_back("--drop-late-frames");
			args.push_back("--aout=none");
			args.push_back("--intf=none");
			args.push_back("--vout=none");
			args.push_back("--no-interact");
			args.push_back("--no-keyboard-events");
			args.push_back("--no-mouse-events");
			#if !HXVLC_SHARE_DIRECTORY
			args.push_back("--no-lua");
			#end
			args.push_back("--no-snapshot-preview");
			args.push_back("--no-sub-autodetect-file");
			args.push_back("--no-video-title-show");
			args.push_back("--no-volume-save");
			args.push_back("--no-xlib");

			#if (windows || macos)
			final pluginPath:Null<String> = Sys.getEnv('VLC_PLUGIN_PATH');

			if (pluginPath != null)
			{
				if (FileSystem.exists(Path.join([pluginPath, 'plugins.dat'])))
				{
					if (resetCache == true)
						args.push_back("--reset-plugins-cache");
					else
						args.push_back("--no-plugins-scan");
				}
				else
					args.push_back("--reset-plugins-cache");
			}
			#end

			#if !HXVLC_LOGGING
			args.push_back("--quiet");
			#end

			if (options != null)
			{
				for (option in options)
				{
					if (option != null && option.length > 0)
						args.push_back(option);
				}
			}

			instance = LibVLC.alloc(args.size(), untyped args.data());

			if (instance == null)
			{
				loading = false;

				instanceMutex.release();

				#if (windows || macos)
				if (resetCache == false)
				{
					trace('Failed to initialize the LibVLC instance, resetting plugins\'s cache');

					return initWithRetry(options, true);
				}
				#end

				final errmsg:String = LibVLC.errmsg();

				if (errmsg != null && errmsg.length > 0)
					trace('Failed to initialize the LibVLC instance: $errmsg');
				else
					trace('Failed to initialize the LibVLC instance');

				return false;
			}
			else
			{
				#if HXVLC_LOGGING
				LibVLC.log_set(instance, untyped __cpp__('instance_logging'), untyped NULL);
				#end
			}
		}

		loading = false;

		instanceMutex.release();

		return true;
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
	private static function setupEnvVariables():Void
	{
		#if android
		final homePath:String = Path.join([Path.directory(System.applicationStorageDirectory), 'libvlc']);

		#if HXVLC_SHARE_DIRECTORY
		final libvlcLibrary:Future<AssetLibrary> = Assets.loadLibrary('libvlc');
		libvlcLibrary.onComplete(function(library:AssetLibrary):Void
		{
			@:nullSafety(Off)
			for (file in library.list(null))
			{
				final savePath:String = Path.join([homePath, '.share', file.substring(file.indexOf('/', 0) + 1, file.length)]);

				Util.mkDirs(Path.directory(savePath));

				try
				{
					if (!FileSystem.exists(savePath))
						File.saveBytes(savePath, library.getBytes(file));
				}
				catch (e:Exception)
					trace('Failed to save file "$savePath", ${e.message}.');
			}
		});
		libvlcLibrary.onError(function(error:String):Void
		{
			trace('Failed to load library: libvlc, Error: $error');
		});
		#end

		Sys.putEnv('HOME', homePath);
		#else
		#if macos
		final dataPath:String = Path.join([Path.directory(Sys.programPath()), 'share']);

		if (FileSystem.exists(dataPath))
			Sys.putEnv('VLC_DATA_PATH', dataPath);
		#end

		#if (windows || macos)
		final pluginPath:String = Path.join([Path.directory(Sys.programPath()), 'plugins']);

		if (FileSystem.exists(pluginPath))
			Sys.putEnv('VLC_PLUGIN_PATH', pluginPath);
		#end
		#end
	}

	#if HXVLC_LOGGING
	@:keep
	@:noCompletion
	@:unreflective
	private static function instanceLogging(level:Int, ctx:cpp.RawConstPointer<LibVLC_Log_T>, fmt:cpp.ConstCharStar, args:cpp.VarList):Void
	{
		if (level > DefineMacro.getInt('HXVLC_VERBOSE', -1))
			return;

		if (level == DefineMacro.getInt('HXVLC_EXCLUDE_LOG_LEVEL', -1))
			return;

		logMutex.acquire();

		final msg:String = Util.getStringFromFormat(fmt, args);

		if (msg.length == 0)
		{
			logMutex.release();
			return;
		}

		final fileName:cpp.ConstCharStar = untyped nullptr;
		final lineNumber:cpp.UInt32 = 0;

		LibVLC.log_get_context(ctx, untyped nullptr, cpp.RawPointer.addressOf(fileName), cpp.RawPointer.addressOf(lineNumber));

		Log.trace(msg, {
			fileName: Path.normalize(fileName),
			lineNumber: lineNumber,
			className: '',
			methodName: ''
		});

		logMutex.release();
	}
	#end
}
