package hxvlc.flixel;

#if flixel
import flixel.FlxG;
import hxvlc.openfl.Video;
import openfl.events.Event;
import sys.FileSystem;

class FlxVideo extends Video
{
	/**
	 * Whether you want the video to automatically be resized.
	 */
	public var autoResize:Bool = true;

	/**
	 * Initializes a FlxVideo object.
	 */
	public function new():Void
	{
		super();

		#if FLX_SOUND_SYSTEM
		onOpening.add(function()
		{
			mute = FlxG.sound.muted;

			volume = Math.floor(FlxG.sound.volume * 100);
		});
		#end

		FlxG.addChildBelowMouse(this);
	}

	public override function play(location:String, loops:Int = 0):Bool
	{
		if (FlxG.autoPause)
		{
			if (!FlxG.signals.focusGained.has(resume))
				FlxG.signals.focusGained.add(resume);

			if (!FlxG.signals.focusLost.has(pause))
				FlxG.signals.focusLost.add(pause);
		}

		FlxG.stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);

		if (FileSystem.exists(Sys.getCwd() + location))
			return super.play(Sys.getCwd() + location, loops);

		return super.play(location, loops);
	}

	public override function dispose():Void
	{
		if (FlxG.autoPause)
		{
			if (FlxG.signals.focusGained.has(resume))
				FlxG.signals.focusGained.remove(resume);

			if (FlxG.signals.focusLost.has(pause))
				FlxG.signals.focusLost.remove(pause);
		}

		if (FlxG.stage.hasEventListener(Event.ENTER_FRAME))
			FlxG.stage.removeEventListener(Event.ENTER_FRAME, onEnterFrame);

		super.dispose();

		FlxG.removeChild(this);
	}

	@:noCompletion
	private function onEnterFrame(e:Event):Void
	{
		if (autoResize)
		{
			final aspectRatio:Float = FlxG.width / FlxG.height;

			if (FlxG.stage.stageWidth / FlxG.stage.stageHeight > aspectRatio)
			{
				width = FlxG.stage.stageHeight * aspectRatio;
				height = FlxG.stage.stageHeight;
			}
			else
			{
				width = FlxG.stage.stageWidth;
				height = FlxG.stage.stageWidth * (1 / aspectRatio);
			}
		}

		#if FLX_SOUND_SYSTEM
		mute = FlxG.sound.muted;

		volume = Math.floor(FlxG.sound.volume * 100);
		#end
	}
}
#end
