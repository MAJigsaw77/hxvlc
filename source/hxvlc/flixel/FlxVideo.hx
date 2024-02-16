package hxvlc.flixel;

#if flixel
import flixel.FlxG;
import haxe.io.Bytes;
import haxe.io.Path;
import hxvlc.externs.Types;
import hxvlc.openfl.Video;
import hxvlc.util.OneOfThree;
import openfl.events.Event;
import sys.FileSystem;

class FlxVideo extends Video
{
	/**
	 * Whether you want the video to automatically be resized.
	 */
	public var autoResize:Bool = true;

	/**
	 * Whether flixel should automatically change the volume according to the flixel sound system current volume.
	 */
	public var autoVolumeHandle:Bool = true;

	/**
	 * Initializes a FlxVideo object.
	 *
	 * @param smoothing Whether or not the video is smoothed when scaled.
	 */
	public function new(smoothing:Bool = true):Void
	{
		super(smoothing);

		onOpening.add(function()
		{
			role = LibVLC_Role_Game;

			FlxG.stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		});

		FlxG.addChildBelowMouse(this);
	}

	public override function load(location:OneOfThree<String, Int, Bytes>, ?options:Array<String>):Bool
	{
		if (FlxG.autoPause)
		{
			if (!FlxG.signals.focusGained.has(resume))
				FlxG.signals.focusGained.add(resume);

			if (!FlxG.signals.focusLost.has(pause))
				FlxG.signals.focusLost.add(pause);
		}

		if (!(location is Int) && !(location is Bytes))
		{
			if (FileSystem.exists(Path.join([Sys.getCwd(), location])))
				return super.load(Path.join([Sys.getCwd(), location]), options);
		}

		return super.load(location, options);
	}

	public override function dispose():Void
	{
		if (FlxG.signals.focusGained.has(resume))
			FlxG.signals.focusGained.remove(resume);

		if (FlxG.signals.focusLost.has(pause))
			FlxG.signals.focusLost.remove(pause);

		if (FlxG.stage.hasEventListener(Event.ENTER_FRAME))
			FlxG.stage.removeEventListener(Event.ENTER_FRAME, onEnterFrame);

		super.dispose();

		FlxG.removeChild(this);
	}

	@:noCompletion
	private function onEnterFrame(event:Event):Void
	{
		if (autoResize)
		{
			width = FlxG.scaleMode.gameSize.x;
			height = FlxG.scaleMode.gameSize.y;
		}

		#if FLX_SOUND_SYSTEM
		if (autoVolumeHandle)
		{
			final curVolume:Int = Math.floor((FlxG.sound.muted ? 0 : 1) * FlxG.sound.volume * 100);

			if (volume != curVolume)
				volume = curVolume;
		}
		#end
	}
}
#end
