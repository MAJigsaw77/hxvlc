package hxvlc.util;

import haxe.Exception;
import sys.FileSystem;

/**
 * Utility class providing helper methods for common operations.
 */
@:unreflective
class Util
{
	/**
	 * Formats a string using a format specifier and a list of arguments.
	 * 
	 * This method uses the `vsnprintf` function to format the string.
	 * 
	 * @param fmt The format specifier string.
	 * @param args The list of arguments to format the string with.
	 * 
	 * @return The formatted string.
	 */
	public static function getStringFromFormat(fmt:cpp.ConstCharStar, args:cpp.VarList):String
	{
		final size:Int = untyped vsnprintf(untyped nullptr, 0, fmt, args) + 1;

		if (size <= 0)
			return '';

		final buffer:cpp.CastCharStar = cast cpp.Stdlib.nativeMalloc(size);

		untyped vsnprintf(buffer, size, fmt, args);

		final msg:String = new String(untyped buffer);

		cpp.Stdlib.nativeFree(untyped buffer);

		return msg;
	}

	/**
	 * Creates directories recursively.
	 * 
	 * This method ensures that all directories in the specified path are created.
	 * If a directory already exists, it is skipped. If a file exists with the same name
	 * as a directory, it is deleted before creating the directory.
	 * 
	 * @param directory The path of the directory to create.
	 */
	public static function mkDirs(directory:String):Void
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
					trace('Failed to create "$total" directory, ${e.message}');

					break;
				}
			}
		}
	}

	/**
	 * Normalizes a file path based on the operating system.
	 * 
	 * On Windows, it converts forward slashes ('/') to backslashes ('\') 
	 * after normalizing the path. On other platforms, it simply normalizes 
	 * the path without altering the slashes.
	 * 
	 * @param location The file path to normalize.
	 * 
	 * @return The normalized file path.
	 */
	public static function normalizePath(location:String):String
	{
		#if windows
		return haxe.io.Path.normalize(location).split('/').join('\\');
		#else
		return haxe.io.Path.normalize(location);
		#end
	}
}
