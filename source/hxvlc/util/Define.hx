package hxvlc.util;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
#end

class Define
{
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
