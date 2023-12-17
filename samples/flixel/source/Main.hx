package;

#if android
import android.content.Context;
#end
import flixel.FlxGame;
import haxe.io.Path;
import haxe.CallStack;
import haxe.Exception;
import haxe.Log;
import openfl.display.Sprite;
import sys.io.File;
import sys.FileSystem;

using StringTools;

class Main extends Sprite
{
	public function new():Void
	{
		super();

		#if android
		Sys.setCwd(Path.addTrailingSlash(Context.getObbDir()));
		#end

		untyped __global__.__hxcpp_set_critical_error_handler(onCriticalError);

		addChild(new FlxGame(1280, 720, PlayState));
	}

	private inline function onCriticalError(error:Dynamic):Void
	{
		final log:Array<String> = [Std.isOfType(error, String) ? error : Std.string(error)];

		for (item in CallStack.exceptionStack(true))
		{
			switch (item)
			{
				case CFunction:
					log.push('C Function');
				case Module(m):
					log.push('Module [$m]');
				case FilePos(s, file, line, column):
					log.push('$file [line $line]');
				case Method(classname, method):
					log.push('$classname [method $method]');
				case LocalFunction(name):
					log.push('Local Function [$name]');
			}
		}

		final msg:String = log.join('\n');

		try
		{
			if (!FileSystem.exists('errors'))
				FileSystem.createDirectory('errors');

			File.saveContent('errors/' + Date.now().toString().replace(' ', '-').replace(':', "'") + '.txt', msg);
		}
		catch (e:Exception)
			Log.trace('Couldn\'t save error message "${e.message}"', null);

		Log.trace(msg, null);
		Lib.application.window.alert(msg, 'Error!');
		System.exit(1);
	}
}
