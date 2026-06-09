package hxvlc.util;

import hxvlc.impl.Instance;
import hxvlc.impl.externs.LibVLC;

class Handle
{
	/** The instance of LibVLC that is used globally. */
	public static var sharedInstance:Null<Instance>;

	public static function init(?options:Array<String>):Bool
	{
		if (sharedInstance != null)
			return true;

		sharedInstance = new Instance(options);

		if (sharedInstance?.nativeInstance == null)
		{
			final errmsg:String = LibVLC.errmsg();

			if (errmsg != null && errmsg.length > 0)
				throw 'Failed to initialize the LibVLC instance: $errmsg';
			else
				throw 'Failed to initialize the LibVLC instance';

			return false;
		}

		#if HXVLC_LOGGING
		sharedInstance.setLog(function(info:haxe.PosInfos, level:Int, msg:String):Void
		{
			haxe.Log.trace('[$level] $msg', info);
		});
		#end

		return true;
	}

	public static function dispose():Void
	{
		if (sharedInstance == null)
			return;

		sharedInstance.destroy();
		sharedInstance = null;
	}
}
