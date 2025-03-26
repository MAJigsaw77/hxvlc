package hxvlc.util.macros;

#if macro
import haxe.macro.Context;

/**
 * Utility class for checking various conditions.
 */
class CheckMacro
{
	/**
	 * This macro function performs several checks to ensure compatibility and proper usage of the hxvlc library.
	 * 
	 * - It checks if the current target platform is supported by the hxvlc library. If the platform is not supported,
	 *   it raises a fatal error.
	 * 
	 * - It verifies that the Lime version is 8.0.1 or newer. If the Lime version is older, it raises a fatal error
	 *   and suggests updating Lime.
	 * 
	 * - It checks if the hxCodec library is defined in the project. If hxCodec is present, it raises a fatal error
	 *   indicating that hxvlc and hxCodec cannot be used together in the same project.
	 * 
	 * @throws Context.fatalError if any of the checks fail.
	 */
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
