package hxvlc.flixel;

#if flixel
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.util.FlxColor;

import hxvlc.util.Location;

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
@:nullSafety
class FlxVideoSprite extends FlxSprite
{
	/** The video bitmap object. */
	public var bitmap:Null<FlxInternalVideo>;

	/**
	 * Creates a `FlxVideoSprite` at a specified position.
	 * 
	 * @param x The initial X position of the sprite.
	 * @param y The initial Y position of the sprite.
	 */
	public function new(?x:Float = 0, ?y:Float = 0):Void
	{
		super(x, y);

		makeGraphic(1, 1, FlxColor.TRANSPARENT);

		bitmap = new FlxInternalVideo(antialiasing);
		bitmap.forceRendering = true;
		bitmap.onFormatSetup.add(function():Void
		{
			if (bitmap != null && bitmap.bitmapData != null)
				loadGraphic(FlxGraphic.fromBitmapData(bitmap.bitmapData, false, null, false));
		});
		bitmap.visible = false;
		FlxG.game.addChild(bitmap);
	}

	/**
	 * Loads a video from the specified location.
	 * 
	 * @param location The location of the media file or stream.
	 * @param options Additional options to configure the media.
	 * @return `true` if the media was loaded successfully, `false` otherwise.
	 */
	public function load(location:Location, ?options:Array<String>):Bool
	{
		return bitmap != null ? bitmap.load(location, options) : false;
	}

	/**
	 * Loads a media subitem from the current media's subitems list at the specified index.
	 * 
	 * @param index The index of the subitem to load.
	 * @param options Additional options to configure the loaded subitem.
	 * @return `true` if the subitem was loaded successfully, `false` otherwise.
	 */
	public function loadFromSubItem(index:Int, ?options:Array<String>):Bool
	{
		return bitmap != null ? bitmap.loadFromSubItem(index, options) : false;
	}

	/**
	 * Parses the current media item with the specified options.
	 * 
	 * @param parse_flag The parsing option.
	 * @param timeout The timeout in milliseconds.
	 * @return `true` if parsing succeeded, `false` otherwise.
	 */
	public function parseWithOptions(parse_flag:Int, timeout:Int):Bool
	{
		return bitmap != null ? bitmap.parseWithOptions(parse_flag, timeout) : false;
	}

	/** Stops parsing the current media item. */
	public function parseStop():Void
	{
		if (bitmap != null)
			bitmap.parseStop();
	}

	/**
	 * Adds a slave to the current media player.
	 * 
	 * @param type The slave type.
	 * @param uri URI of the slave (should contain a valid scheme).
	 * @param select `true` if this slave should be selected when it's loaded.
	 * @return `true` on success, `false` otherwise.
	 */
	public function addSlave(type:Int, location:String, select:Bool):Bool
	{
		return bitmap != null ? bitmap.addSlave(type, location, select) : false;
	}

	/**
	 * Starts video playback.
	 * 
	 * @return `true` if playback started successfully, `false` otherwise.
	 */
	public function play():Bool
	{
		return bitmap != null ? bitmap.play() : false;
	}

	/** Stops video playback. */
	public function stop():Void
	{
		if (bitmap != null)
			bitmap.stop();
	}

	/** Pauses video playback. */
	public function pause():Void
	{
		if (bitmap != null)
			bitmap.pause();
	}

	/** Resumes playback of a paused video. */
	public function resume():Void
	{
		if (bitmap != null)
			bitmap.resume();
	}

	/** Toggles between play and pause states of the video. */
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
