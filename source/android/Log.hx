package android;

/**
 * Android log priority levels, in ascending order of severity.
 */
@:dox(hide)
extern enum abstract Android_LogPriority(Android_LogPriority_Impl)
{
	/**
	 * Priority constant for unknown log messages.
	 */
	@:native('ANDROID_LOG_UNKNOWN')
	var UNKNOWN;

	/**
	 * Priority constant for default log messages.
	 * Only used for SetMinPriority().
	 */
	@:native('ANDROID_LOG_DEFAULT')
	var DEFAULT;

	/**
	 * Priority constant for verbose log messages.
	 */
	@:native('ANDROID_LOG_VERBOSE')
	var VERBOSE;

	/**
	 * Priority constant for debug log messages.
	 */
	@:native('ANDROID_LOG_DEBUG')
	var DEBUG;

	/**
	 * Priority constant for info log messages.
	 */
	@:native('ANDROID_LOG_INFO')
	var INFO;

	/**
	 * Priority constant for warning log messages.
	 */
	@:native('ANDROID_LOG_WARN')
	var WARN;

	/**
	 * Priority constant for error log messages.
	 */
	@:native('ANDROID_LOG_ERROR')
	var ERROR;

	/**
	 * Priority constant for fatal log messages.
	 */
	@:native('ANDROID_LOG_FATAL')
	var FATAL;

	/**
	 * Priority constant for silent log messages.
	 * Only used for SetMinPriority(); must be last.
	 */
	@:native('ANDROID_LOG_SILENT')
	var SILENT;

	/**
	 * Converts an integer value to the corresponding Android_LogPriority enum value.
	 *
	 * @param i The integer value representing the log priority.
	 * @return The corresponding Android_LogPriority enum value.
	 */
	@:from
	static public inline function fromInt(i:Int):Android_LogPriority
		return cast i;

	/**
	 * Converts the Android_LogPriority enum value to its integer representation.
	 *
	 * @return The integer representation of the enum value.
	 */
	@:to extern public inline function toInt():Int
		return untyped this;
}

/**
 * Android logging functions for writing logs.
 */
@:include('android/log.h')
extern class Log
{
	/**
	 * Send a simple string to the Android log.
	 *
	 * @param prio The priority level of the log message.
	 * @param tag The tag associated with the log message.
	 * @param text The text message to be logged.
	 */
	@:native('__android_log_write')
	public static function __android_log_write(prio:Int, tag:cpp.ConstCharStar, text:cpp.ConstCharStar):Int;

	/**
	 * Send a formatted string to the Android log, used like printf(fmt,...).
	 *
	 * @param prio The priority level of the log message.
	 * @param tag The tag associated with the log message.
	 * @param fmt The format string for the log message.
	 * @param args Additional arguments to be formatted into the log message.
	 */
	@:native('__android_log_print')
	public static function __android_log_print(prio:Int, tag:cpp.ConstCharStar, fmt:cpp.ConstCharStar, args:cpp.Rest<cpp.VarArg>):Int;

	/**
	 * A variant of __android_log_print() that takes a va_list to list additional parameters.
	 *
	 * @param prio The priority level of the log message.
	 * @param tag The tag associated with the log message.
	 * @param fmt The format string for the log message.
	 * @param ap The va_list containing additional arguments.
	 */
	@:native('__android_log_vprint')
	public static function __android_log_vprint(prio:Int, tag:cpp.ConstCharStar, fmt:cpp.ConstCharStar, ap:cpp.VarList):Int;

	/**
	 * Log an assertion failure and SIGTRAP the process to inspect it, if a debugger is attached.
	 * This uses the FATAL priority.
	 *
	 * @param cond The condition that failed.
	 * @param tag The tag associated with the log message.
	 * @param fmt The format string for the log message.
	 * @param args Additional arguments to be formatted into the log message.
	 */
	@:native('__android_log_assert')
	public static function __android_log_assert(cond:cpp.ConstCharStar, tag:cpp.ConstCharStar, fmt:cpp.ConstCharStar, args:cpp.Rest<cpp.VarArg>):Void;
}
