package hxvlc.util;

#if (!cpp && !(desktop || mobile))
#error 'The current target platform isn\'t supported by hxvlc.'
#end
import haxe.io.Path;
import haxe.Exception;
import hxvlc.externs.LibVLC;
import hxvlc.externs.Types;
import hxvlc.util.Define;
import lime.utils.Log;
import sys.thread.Thread;
import sys.FileSystem;

using StringTools;

#if android
@:headerInclude('android/log.h')
#end
@:cppNamespaceCode('
static void logging(void *data, int level, const libvlc_log_t *ctx, const char *fmt, va_list args)
{
	hx::SetTopOfStack((int *)99, true);

	#ifdef __ANDROID__
	switch (level)
	{
		case LIBVLC_DEBUG:
			__android_log_vprint(ANDROID_LOG_DEBUG, "HXVLC", fmt, args);
			break;
		case LIBVLC_NOTICE:
			__android_log_vprint(ANDROID_LOG_INFO, "HXVLC", fmt, args);
			break;
		case LIBVLC_WARNING:
			__android_log_vprint(ANDROID_LOG_WARN, "HXVLC", fmt, args);
			break;
		case LIBVLC_ERROR:
			__android_log_vprint(ANDROID_LOG_ERROR, "HXVLC", fmt, args);
			break;
		default:
			__android_log_vprint(ANDROID_LOG_VERBOSE, "HXVLC", fmt, args);
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
	 * Whether the instance is still loading or not.
	 */
	public static var loading(default, null):Bool = false;

	/**
	 * Initialize the LibVLC instance if isn't already.
	 *
	 * @param options The additional options you can add to the LibVLC instance.
	 *
	 * @return `true` if the instance created successfully or `false` if there's an error or the instance is still loading.
	 */
	public static function init(?options:Array<String>):Bool
	{
		if (loading)
			return false;

		loading = true;

		if (instance == null)
		{
			if (options == null)
				options = new Array<String>();

			#if (windows || macos)
			Sys.putEnv('VLC_PLUGIN_PATH', Path.join([Path.directory(Sys.programPath()), 'plugins']));
			#elseif linux
			final pluginsPath:String = '/usr/local/lib/vlc/plugins';

			if (FileSystem.exists(pluginsPath))
				Sys.putEnv('VLC_PLUGIN_PATH', pluginsPath);
			else if (FileSystem.exists(pluginsPath.replace('local/', '')))
				Sys.putEnv('VLC_PLUGIN_PATH', pluginsPath.replace('local/', ''));
			#end

			var args:cpp.VectorConstCharStar = cpp.VectorConstCharStar.alloc();
			args.push_back("--drop-late-frames");
			args.push_back("--intf=dummy");
			args.push_back("--no-interact");
			args.push_back("--no-lua");
			args.push_back("--no-snapshot-preview");
			args.push_back("--no-spu");
			args.push_back("--no-stats");
			args.push_back("--no-sub-autodetect-file");
			args.push_back("--no-video-title-show");
			args.push_back("--no-xlib");
			#if (windows || macos)
			args.push_back("--reset-config");
			args.push_back("--reset-plugins-cache");
			#elseif linux
			final pluginsPath:String = Sys.getEnv('VLC_PLUGIN_PATH');

			if (pluginsPath != null && pluginsPath.length > 0)
				args.push_back("--reset-plugins-cache");
			#end
			args.push_back("--text-renderer=dummy");
			#if HXVLC_VERBOSE
			args.push_back("--verbose=" + Define.getDefineInt('HXVLC_VERBOSE', 0));
			#elseif !HXVLC_LOGGING
			args.push_back("--quiet");
			#end

			for (option in options)
			{
				if (option != null)
					args.push_back(option);
			}

			instance = LibVLC.alloc(args.size(), untyped args.data());

			if (instance == null)
			{
				final errmsg:String = cast(LibVLC.errmsg(), String);

				if (errmsg != null && errmsg.length > 0)
					Log.error('Failed to initialize the LibVLC instance, Error: $errmsg');
				else
					Log.error('Failed to initialize the LibVLC instance');

				loading = false;

				return false;
			}
			else
			{
				#if HXVLC_LOGGING
				LibVLC.log_set(instance, untyped __cpp__('logging'), null);
				#end
			}
		}

		loading = false;

		return true;
	}

	/**
	 * Initialize the LibVLC instance asynchronously if isn't already.
	 *
	 * @param options The additional options you can add to the LibVLC instance.
	 * @param finishCallback A callback that is called after it finishes loading.
	 */
	public static function initAsync(?options:Array<String>, ?finishCallback:Bool->Void):Void
	{
		if (loading)
			return;

		Thread.create(function():Void
		{
			final success:Bool = init(options);

			if (finishCallback != null)
				finishCallback(success);
		});
	}

	/**
	 * Frees the LibVLC instance.
	 */
	public static function dispose():Void
	{
		if (instance != null)
		{
			#if HXVLC_LOGGING
			LibVLC.log_unset(instance);
			#end
			LibVLC.release(instance);

			instance = null;
		}
	}
}
