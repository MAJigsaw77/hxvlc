package hxvlc.libvlc;

import haxe.macro.Expr;

class Macros
{
	public static macro function checkEvent(event:Expr, body:Expr):Expr
	{
		return macro
		{
			if ($event)
			{
				$event = false;

				$body;
			}
		}
	}
}
