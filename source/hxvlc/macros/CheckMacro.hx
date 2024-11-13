package hxvlc.macros;

#if macro
import haxe.macro.Context;

class CheckMacro
{
	public static function run():Void
	{
		if (!Context.defined('cpp') && !(Context.defined('desktop') || Context.defined('mobile')))
			Context.fatalError('The current target platform isn\'t supported by hxvlc.', Context.currentPos());

		if (Context.defined('hxCodec'))
			Context.fatalError('hxvlc and hxCodec cannot be used in the same project..', Context.currentPos());
	}
}
#end
