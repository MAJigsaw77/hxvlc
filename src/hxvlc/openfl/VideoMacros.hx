package hxvlc.openfl;

import haxe.macro.Expr;

class VideoMacros
{
	public static macro function checkEvent(event:Expr, body:Expr):Expr
	{
		return macro
		{
			if ($event)
			{
				$event = false;

				if ($body != null)
					$body();
			}
		}
	}
}
