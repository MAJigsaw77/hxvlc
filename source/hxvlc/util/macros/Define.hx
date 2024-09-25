package hxvlc.util.macros;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
#end

/**
 * Utility class to retrieve values from compiler defines.
 */
@:nullSafety
class Define
{
	/**
	 * Retrieves a string value from the compiler define if it is set.
	 * If the define is not set or the value is not a valid string, it returns the specified default value.
	 *
	 * @param key The compiler define key to check.
	 * @param defaultValue The default value to return if the define is not set or invalid.
	 * @return The string value from the compiler define or the default value.
	 */
	public static macro function getString(key:String, defaultValue:String):Expr
	{
		#if !display
		if (Context.defined(key))
		{
			final value:String = Context.definedValue(key);

			if (value != null)
				return macro $v{value};
		}
		#end

		return macro $v{defaultValue};
	}

	/**
	 * Retrieves an integer value from the compiler define if it is set.
	 * If the define is not set or the value is not a valid integer, it returns the specified default value.
	 *
	 * @param key The compiler define key to check.
	 * @param defaultValue The default value to return if the define is not set or invalid.
	 * @return The integer value from the compiler define or the default value.
	 */
	public static macro function getInt(key:String, defaultValue:Int):Expr
	{
		#if !display
		if (Context.defined(key))
		{
			final value:Null<Int> = Std.parseInt(Context.definedValue(key));

			if (value != null)
				return macro $v{value};
		}
		#end

		return macro $v{defaultValue};
	}

	/**
	 * Retrieves a float value from the compiler define if it is set.
	 * If the define is not set or the value is not a valid float, it returns the specified default value.
	 *
	 * @param key The compiler define key to check.
	 * @param defaultValue The default value to return if the define is not set or invalid.
	 * @return The float value from the compiler define or the default value.
	 */
	public static macro function getFloat(key:String, defaultValue:Float):Expr
	{
		#if !display
		if (Context.defined(key))
		{
			final value:Null<Float> = Std.parseFloat(Context.definedValue(key));

			if (value != null)
				return macro $v{value};
		}
		#end

		return macro $v{defaultValue};
	}
}
