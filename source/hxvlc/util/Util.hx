package hxvlc.util;

import cpp.CastCharStar;
import cpp.ConstCharStar;
import cpp.RawConstPointer;
import cpp.RawPointer;
import cpp.UInt32;
import cpp.UInt8;
import cpp.VarList;

import haxe.Exception;
import haxe.PosInfos;
import haxe.io.BytesInput;
import haxe.io.Path;

import hxvlc.externs.LibVLC;
import hxvlc.externs.Types;

import sys.FileSystem;

using cpp.NativeArray;

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
	 * @return The formatted string.
	 */
	@:noDebug
	public static function getStringFromFormat(fmt:ConstCharStar, args:VarList):String
	{
		final len:Int = untyped vsnprintf(untyped nullptr, 0, fmt, args);

		if (len <= 0)
			return '';

		final buffer:CastCharStar = cast cpp.Stdlib.nativeMalloc(len + 1);

		untyped vsnprintf(buffer, len + 1, fmt, args);

		final msg:String = new String(untyped buffer);

		cpp.Stdlib.nativeFree(untyped buffer);

		return msg;
	}

	/**
	 * Retrieves file and line number information from a LibVLC log context.
	 * 
	 * This method calls `libvlc_log_get_context` to extract the source file name and 
	 * line number associated with a particular log entry. The module information is 
	 * ignored. If no file name is available, an empty string is returned.
	 * 
	 * @param ctx A pointer to a `LibVLC_Log_T` structure representing the log context.
	 * @return A `PosInfos` object containing the normalized file name, line number, and empty class/method names.
	 */
	public static function getPosFromContext(ctx:RawConstPointer<LibVLC_Log_T>):PosInfos
	{
		final fileName:ConstCharStar = untyped nullptr;

		final lineNumber:UInt32 = 0;

		LibVLC.log_get_context(ctx, untyped nullptr, cpp.RawPointer.addressOf(fileName), cpp.RawPointer.addressOf(lineNumber));

		return {
			fileName: fileName != null ? Path.normalize(fileName) : '',
			lineNumber: lineNumber,
			className: '',
			methodName: ''
		};
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

	/**
	 * Reads data from a `BytesInput` stream into a raw memory buffer.
	 *
	 * @param input The `BytesInput` object acting as the source bitstream.
	 * @param buf Pointer to the destination buffer where data should be copied.
	 * @param len The maximum number of bytes to read into the buffer.
	 * @return A strictly positive number of bytes read, 0 on end-of-stream, or -1 on unrecoverable error.
	 */
	public static function readFromInput(input:BytesInput, buf:RawPointer<UInt8>, len:Int):Int
	{
		if (input.position >= input.length)
			return 0;

		final remaining:Int = input.length - input.position;

		final read:Int = len < remaining ? len : remaining;

		if (input.position > (input.length - read))
			return -1;

		cpp.Stdlib.nativeMemcpy(untyped buf, untyped cpp.RawPointer.addressOf(input.b.getBase().getBase()[input.position]), read);

		input.position += read;

		return read;
	}
}
