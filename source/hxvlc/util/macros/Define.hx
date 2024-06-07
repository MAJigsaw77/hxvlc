package hxvlc.util.macros;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
#end

class Define
{
	/**
	 * Retrieves an integer value from the compiler define if it is set.
	 * If the define is not set or the value is not a valid integer, it returns the specified default value.
	 *
	 * @param key The compiler define key to check.
	 * @param defaultValue The default value to return if the define is not set or invalid.
	 * @return The integer value from the compiler define or the default value.
	 */
	public static macro function getDefineInt(key:String, defaultValue:Int):Expr
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
}
