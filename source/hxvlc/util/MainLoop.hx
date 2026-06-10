package hxvlc.util;

#if haxe5
/**
 * Wrapper for compatibility with Haxe 5.
 */
@:forwardStatics
abstract MainLoop(haxe.MainLoop)
{
	public static inline function runInMainThread(f:Void->Void):Void
	{
		haxe.EventLoop.main.run(f);
	}

	public static inline function addThread(f:Void->Void):Void
	{
		haxe.EventLoop.addTask(f);
	}
}
#else
typedef MainLoop = haxe.MainLoop;
#end
