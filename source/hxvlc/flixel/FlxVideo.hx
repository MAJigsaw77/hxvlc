package hxvlc.flixel;

#if flixel
import flixel.FlxG;
import flixel.util.FlxAxes;

/**
 * This class extends `FlxInternalVideo` to display video files in HaxeFlixel.
 *
 * ```haxe
 * final video:FlxVideo = new FlxVideo();
 * video.onEndReached.add(function():Void
 * {
 * 	video.dispose();
 *
 * 	FlxG.removeChild(video);
 * });
 * FlxG.addChildBelowMouse(video);
 *
 * if (video.load('assets/videos/video.mp4'))
 * 	FlxTimer.wait(0.001, () -> video.play());
 * ```
 */
class FlxVideo extends FlxInternalVideo
{
	/** Determines the resizing behavior for the video. */
	public var resizeMode(default, set):FlxAxes = FlxAxes.XY;

	@:inheritDoc(hxvlc.openfl.Video.new)
	public function new(smoothing:Bool = true):Void
	{
		super(smoothing);

		onFormatSetup.add(function():Void
		{
			if (!FlxG.signals.gameResized.has(onGameResized))
				FlxG.signals.gameResized.add(onGameResized);

			onGameResized(FlxG.stage.stageWidth, FlxG.stage.stageHeight);
		});
	}

	@:inheritDoc(hxvlc.openfl.Video.dispose)
	public override function dispose():Void
	{
		if (FlxG.signals.gameResized.has(onGameResized))
			FlxG.signals.gameResized.remove(onGameResized);

		super.dispose();
	}

	@:noCompletion
	private function onGameResized(width:Int, height:Int):Void
	{
		if ((resizeMode.x || resizeMode.y) && bitmapData != null)
		{
			this.width = resizeMode.x ? FlxG.scaleMode.gameSize.x : bitmapData.width;
			this.height = resizeMode.y ? FlxG.scaleMode.gameSize.y : bitmapData.height;
		}
	}

	@:noCompletion
	private function set_resizeMode(value:FlxAxes):FlxAxes
	{
		onGameResized(FlxG.stage.stageWidth, FlxG.stage.stageHeight);

		return resizeMode = value;
	}
}
#end
