package hxvlc.util.macros;

import haxe.macro.Expr;

/**
 * Utility class to runs code in the main thread safely.
 */
class MainLoopMacro
{
	/**
	 * Ensures the given code runs in the main thread.
	 * 
	 * If an error occurs, it logs a warning.
	 * 
	 * @param body The code to run.
	 * 
	 * @return The wrapped expression.
	 */
	public static macro function runInMainThreadSafe(body:Expr):Expr
	{
		return macro
		{
			haxe.MainLoop.runInMainThread(function():Void
			{
				try
				{
					$body;
				}
				catch (e:Dynamic)
					lime.utils.Log.warn('Failed to run code in Main Thread: $e');
			});
		};
	}
}
