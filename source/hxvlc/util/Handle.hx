package hxvlc.util;

import hxvlc.impl.Instance;
import hxvlc.impl.externs.LibVLC;

class Handle
{
	/** The instance of LibVLC that is used globally. */
	public static var sharedInstance:Null<Instance>;

	/** Indicates whether the instance is still loading. */
	public static var loading(default, null):Bool = false;

	public static function init(?options:Array<String>):Bool
	{
		if (!loading)
		{
			var result:Bool = true;

			loading = true;

			if (sharedInstance == null)
			{
				sharedInstance = new Instance(options);

				if (sharedInstance?.nativeInstance != null)
				{
					#if HXVLC_LOGGING
					sharedInstance.setLog(function(info:haxe.PosInfos, level:Int, msg:String):Void
					{
						var message:String = msg;

						#if HXVLC_SHOW_LOG_TYPE
						switch (level)
						{
							case 0: /** Debug message */
								message = '[DEBUG] $message';
							case 2: /** Important informational message */
								message = '[NOTICE] $message';
							case 3: /** Warning (potential error) message */
								message = '[WARNING] $message';
							case 4: /** Error message */
								message = '[ERROR] $message';
						}
						#end

						haxe.Log.trace(message, info);
					});
					#end
				}
				else
				{
					sharedInstance = null;

					final errmsg:String = LibVLC.errmsg();

					if (errmsg != null && errmsg.length > 0)
						throw 'Failed to initialize the LibVLC instance: $errmsg';
					else
						throw 'Failed to initialize the LibVLC instance';

					result = false;
				}
			}

			loading = false;

			return result;
		}

		return false;
	}

	public static function initAsync(?options:Array<String>, ?finishCallback:Bool->Void):Void
	{
		if (loading)
			return;

		MainLoop.addThread(function():Void
		{
			final success:Bool = init(options);

			if (finishCallback != null)
				MainLoop.runInMainThread(finishCallback.bind(success));
		});
	}

	public static function dispose():Void
	{
		if (sharedInstance == null)
			return;

		sharedInstance.destroy();
		sharedInstance = null;
	}
}
