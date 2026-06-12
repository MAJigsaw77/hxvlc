package hxvlc.flixel;

#if flixel
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.util.FlxColor;

import hxvlc.impl.Instance;
import hxvlc.util.Location;

import openfl.display.BitmapData;

/**
 * This class extends `FlxSprite` to display video files in HaxeFlixel.
 *
 * ```haxe
 * final video:FlxVideoSprite = new FlxVideoSprite(0, 0);
 * video.antialiasing = true;
 * video.bitmap.onFormatSetup.add(function():Void
 * {
 * 	if (video.bitmap != null && video.bitmap.bitmapData != null)
 * 	{
 * 		final scale:Float = Math.min(FlxG.width / video.bitmap.bitmapData.width, FlxG.height / video.bitmap.bitmapData.height);
 * 
 * 		video.setGraphicSize(video.bitmap.bitmapData.width * scale, video.bitmap.bitmapData.height * scale);
 * 		video.updateHitbox();
 * 		video.screenCenter();
 * 	}
 * });
 * video.bitmap.onEndReached.add(video.destroy);
 * add(video);
 * 
 * if (video.load('assets/videos/video.mp4'))
 * 	FlxTimer.wait(0.001, () -> video.play());
 * ```
 */
class FlxVideoSprite extends FlxSprite
{
	/** The video bitmap object. */
	public var bitmap:Null<FlxInternalVideo>;

	/**
	 * Creates a `FlxVideoSprite` at a specified position.
	 * 
	 * @param instance (Optional) The instance of LibVLC to be used for this Video object.
	 * @param x The initial X position of the sprite.
	 * @param y The initial Y position of the sprite.
	 */
	public function new(?instance:Instance, ?x:Float = 0, ?y:Float = 0):Void
	{
		super(x, y);

		makeGraphic(1, 1, FlxColor.TRANSPARENT);

		bitmap = new FlxInternalVideo(instance, antialiasing);
		bitmap.onFormatSetup.add(function():Void
		{
			final videoBitmapData:Null<BitmapData> = bitmap?.bitmapData;

			if (videoBitmapData != null)
				loadGraphic(FlxGraphic.fromBitmapData(videoBitmapData, false, null, false));
		});
		bitmap.visible = false;
		FlxG.game.addChild(bitmap);
	}

	@:inheritDoc(hxvlc.openfl.Video.load)
	public function load(location:Location, ?options:Array<String>):Bool
	{
		return bitmap != null ? bitmap.load(location, options) : false;
	}

	@:inheritDoc(hxvlc.openfl.Video.loadFromSubItem)
	public function loadFromSubItem(index:Int, ?options:Array<String>):Bool
	{
		return bitmap != null ? bitmap.loadFromSubItem(index, options) : false;
	}

	@:inheritDoc(hxvlc.openfl.Video.parseWithOptions)
	public function parseWithOptions(parse_flag:Int, timeout:Int):Bool
	{
		return bitmap != null ? bitmap.parseWithOptions(parse_flag, timeout) : false;
	}

	@:inheritDoc(hxvlc.openfl.Video.parseStop)
	public function parseStop():Void
	{
		if (bitmap != null)
			bitmap.parseStop();
	}

	@:inheritDoc(hxvlc.openfl.Video.addSlave)
	public function addSlave(type:Int, location:String, select:Bool):Bool
	{
		return bitmap != null ? bitmap.addSlave(type, location, select) : false;
	}

	@:inheritDoc(hxvlc.openfl.Video.play)
	public function play():Bool
	{
		return bitmap != null ? bitmap.play() : false;
	}

	@:inheritDoc(hxvlc.openfl.Video.stop)
	public function stop():Void
	{
		if (bitmap != null)
			bitmap.stop();
	}

	@:inheritDoc(hxvlc.openfl.Video.pause)
	public function pause():Void
	{
		if (bitmap != null)
			bitmap.pause();
	}

	@:inheritDoc(hxvlc.openfl.Video.resume)
	public function resume():Void
	{
		if (bitmap != null)
			bitmap.resume();
	}

	@:inheritDoc(hxvlc.openfl.Video.togglePaused)
	public function togglePaused():Void
	{
		if (bitmap != null)
			bitmap.togglePaused();
	}

	@:dox(hide)
	public override function destroy():Void
	{
		super.destroy();

		if (bitmap != null)
		{
			FlxG.removeChild(bitmap);

			if (bitmap.bitmapData != null)
			{
				bitmap.bitmapData.dispose();

				@:nullSafety(Off)
				bitmap.bitmapData = null;
			}

			bitmap.dispose();
			bitmap = null;
		}
	}

	@:dox(hide)
	public override function kill():Void
	{
		if (bitmap != null)
			bitmap.pause();

		super.kill();
	}

	@:dox(hide)
	public override function revive():Void
	{
		super.revive();

		if (bitmap != null)
			bitmap.resume();
	}

	@:noCompletion
	private override function set_antialiasing(value:Bool):Bool
	{
		return antialiasing = (bitmap == null ? value : (bitmap.smoothing = value));
	}
}
#end
