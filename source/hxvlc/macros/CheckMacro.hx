package hxvlc.macros;

#if macro
import haxe.macro.Context;

class CheckMacro
{
	public static function run():Void
	{
		if (!Context.defined('cpp') && !(Context.defined('desktop') || Context.defined('mobile')))
			Context.fatalError('The current target platform isn\'t supported by the hxvlc library.', (macro null).pos);

		#if (lime < version("8.0.1"))
		Context.fatalError('The hxvlc library requires Lime version 8.0.1 or newer. Please update Lime by running `haxelib update lime`.', (macro null).pos);
		#end

		if (Context.defined('hxCodec'))
			Context.fatalError('The hxvlc library and hxCodec cannot be used in the same project.', (macro null).pos);
	}
}
#end
