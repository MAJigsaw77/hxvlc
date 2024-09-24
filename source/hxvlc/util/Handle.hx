package hxvlc.util;

#if (!cpp && !(desktop || mobile))
#error 'The current target platform isn\'t supported by hxvlc.'
#end
import haxe.io.Path;
import haxe.Exception;
import haxe.Int64;
import haxe.MainLoop;
import hxvlc.externs.LibVLC;
import hxvlc.externs.Types;
import hxvlc.util.macros.Define;
import lime.system.System;
import lime.utils.AssetLibrary;
import lime.utils.Assets;
import lime.utils.Log;
import sys.io.File;
import sys.thread.Mutex;
import sys.FileSystem;

using StringTools;

/**
 * This class manages the global instance of LibVLC, providing methods for initialization, disposal, and retrieving version information.
 */
#if android
@:headerInclude('android/log.h')
#end
@:cppNamespaceCode('static void instance_logging(void *data, int level, const libvlc_log_t *ctx, const char *fmt, va_list args)
{
	hx::SetTopOfStack((int *)99, true);

#ifdef __ANDROID__
	switch (level)
	{
	case LIBVLC_NOTICE:
		__android_log_vprint(ANDROID_LOG_INFO, "HXVLC", fmt, args);
		break;
	case LIBVLC_ERROR:
		__android_log_vprint(ANDROID_LOG_ERROR, "HXVLC", fmt, args);
		break;
	case LIBVLC_WARNING:
		__android_log_vprint(ANDROID_LOG_WARN, "HXVLC", fmt, args);
		break;
	case LIBVLC_DEBUG:
		__android_log_vprint(ANDROID_LOG_DEBUG, "HXVLC", fmt, args);
		break;
	default:
		__android_log_vprint(ANDROID_LOG_UNKNOWN, "HXVLC", fmt, args);
		break;
	}
#else
	vprintf(fmt, args);
	printf("\\n");
#endif

	hx::SetTopOfStack((int *)0, true);
}')
class Handle
{
	/**
	 * The instance of LibVLC that is used globally.
	 */
	public static var instance(default, null):cpp.RawPointer<LibVLC_Instance_T>;

	/**
	 * Indicates whether the instance is still loading.
	 */
	public static var loading(default, null):Bool = false;

	/**
	 * Retrieves the LibVLC version.
	 *
	 * Example: "1.1.0-git The Luggage"
	 */
	public static var version(get, never):String;

	/**
	 * Retrieves the LibVLC compiler version.
	 *
	 * Example: "gcc version 4.2.3 (Ubuntu 4.2.3-2ubuntu6)"
	 */
	public static var compiler(get, never):String;

	/**
	 * Retrieves the LibVLC changeset.
	 *
	 * Example: "aa9bce0bc4"
	 */
	public static var changeset(get, never):String;

	/**
	 * Returns the current time as defined by LibVLC.
	 *
	 * The unit is the microsecond.
	 *
	 * Time increases monotonically (regardless of time zone changes and RTC adjustments).
	 *
	 * The origin is arbitrary but consistent across the whole system (e.g. the system uptime, the time since the system was booted).
	 *
	 * Note: On systems that support it, the POSIX monotonic clock is used.
	 */
	public static var clock(get, never):Int64;

	@:noCompletion
	private static final instanceMutex:Mutex = new Mutex();

	@:noCompletion
	private static var logFile:cpp.FILE;

	/**
	 * Initializes the LibVLC instance if it isn't already.
	 *
	 * @param options The additional options you can add to the LibVLC instance.
	 *
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

			MainLoop.runInMainThread(function():Void
			{
				if (finishCallback != null)
					finishCallback(success);
			});
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

		#if HXVLC_FILE_LOGGING
		if (logFile != null)
		{
			cpp.Stdio.fclose(logFile);
			logFile = null;
		}
		#end

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
			#if android
			final homePath:String = Path.join([Path.directory(System.applicationStorageDirectory), 'libvlc']);

			#if !HXVLC_NO_SHARE_DIRECTORY
			Assets.loadLibrary('libvlc').onComplete(function(library:AssetLibrary):Void
			{
				final sharePath:String = Path.join([homePath, '.share']);

				mkDirs(Path.directory(sharePath));

				for (file in library.list(null))
				{
					final savePath:String = Path.join([sharePath, file.substring(file.indexOf('/', 0) + 1, file.length)]);

					mkDirs(Path.directory(savePath));

					try
					{
						if (!FileSystem.exists(savePath))
							File.saveBytes(savePath, library.getBytes(file));
					}
					catch (e:Exception)
						Log.warn('Failed to save file "$savePath", ${e.message}.');
				}
			}).onError(function(error:String):Void
			{
				Log.warn('Failed to load library: libvlc, Error: $error');
			});
			#end

			Sys.putEnv('HOME', homePath);
			#elseif macos
			final dataPath:String = Path.join([Path.directory(Sys.programPath()), 'share']);

			if (FileSystem.exists(dataPath))
				Sys.putEnv('VLC_DATA_PATH', dataPath);

			final pluginPath:String = Path.join([Path.directory(Sys.programPath()), 'plugins']);

			if (FileSystem.exists(pluginPath))
				Sys.putEnv('VLC_PLUGIN_PATH', pluginPath);
			#elseif windows
			final pluginPath:String = Path.join([Path.directory(Sys.programPath()), 'plugins']);

			if (FileSystem.exists(pluginPath))
				Sys.putEnv('VLC_PLUGIN_PATH', pluginPath);
			#end

			final args:cpp.VectorConstCharStar = cpp.VectorConstCharStar.alloc();
			#if windows
			args.push_back("--aout=directsound");
			#end
			#if (android || ios || macos)
			args.push_back("--audio-resampler=soxr");
			#end
			args.push_back("--drop-late-frames");
			args.push_back("--ignore-config");
			args.push_back("--intf=none");
			args.push_back("--http-reconnect");
			args.push_back("--no-interact");
			args.push_back("--no-keyboard-events");
			args.push_back("--no-mouse-events");
			#if HXVLC_NO_SHARE_DIRECTORY
			args.push_back("--no-lua");
			#end
			args.push_back("--no-snapshot-preview");
			args.push_back("--no-spu");
			args.push_back("--no-sub-autodetect-file");
			args.push_back("--no-video-title-show");
			args.push_back("--no-volume-save");
			args.push_back("--no-xlib");
			#if (windows || macos)
			args.push_back(!resetCache
				&& FileSystem.exists(Path.join([pluginPath, 'plugins.dat'])) ? "--no-plugins-scan" : "--reset-plugins-cache");
			#end
			args.push_back("--text-renderer=none");
			#if HXVLC_VERBOSE
			args.push_back("--verbose=" + Define.getInt('HXVLC_VERBOSE', 0));
			#elseif (!HXVLC_LOGGING || !HXVLC_FILE_LOGGING)
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
				if (!resetCache)
				{
					Log.warn('Failed to initialize the LibVLC instance, resetting plugins\'s cache');

					return initWithRetry(options, true);
				}
				#end

				final errmsg:String = LibVLC.errmsg();

				if (errmsg != null && errmsg.length > 0)
					Log.error('Failed to initialize the LibVLC instance, Error: $errmsg');
				else
					Log.error('Failed to initialize the LibVLC instance');

				return false;
			}
			else
			{
				#if HXVLC_FILE_LOGGING
				if (logFile != null)
					cpp.Stdio.fclose(logFile);

				logFile = cpp.Stdio.fopen(Define.getString('HXVLC_FILE_LOGGING', 'libvlc-log.txt'), 'w');

				if (logFile == null)
				{
					Log.warn('Failed to open log file for writing.');

					LibVLC.log_set(instance, untyped __cpp__('instance_logging'), null);
				}
				else
					LibVLC.log_set_file(instance, logFile);
				#elseif HXVLC_LOGGING
				LibVLC.log_set(instance, untyped __cpp__('instance_logging'), null);
				#end
			}
		}

		loading = false;

		instanceMutex.release();

		return true;
	}

	#if android
	/**
	 * @see https://github.com/openfl/hxp/blob/master/src/hxp/System.hx#L595
	 */
	@:noCompletion
	private static function mkDirs(directory:String):Void
	{
		try
		{
			if (FileSystem.exists(directory) && FileSystem.isDirectory(directory))
				return;
		}
		catch (e:Dynamic) {}

		var total:String = '';

		if (directory.substr(0, 1) == '/')
			total = '/';

		final parts:Array<String> = directory.split('/');

		if (parts.length > 0 && parts[0].indexOf(':') > -1)
			parts.shift();

		for (part in parts)
		{
			if (part != '.' && part.length > 0)
			{
				if (total != '/' && total.length > 0)
					total += '/';

				total += part;

				try
				{
					if (FileSystem.exists(total) && !FileSystem.isDirectory(total))
						FileSystem.deleteFile(total);

					if (!FileSystem.exists(total))
						FileSystem.createDirectory(total);
				}
				catch (e:Exception)
				{
					Log.warn('Failed to create "$total" directory, ${e.message}');

					break;
				}
			}
		}
	}
	#end

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
	private static function get_clock():Int64
	{
		return LibVLC.clock();
	}
}
