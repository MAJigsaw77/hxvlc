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
	public final bitmap:FlxInternalVideo;

	/**
	 * Creates a `FlxVideoSprite` at a specified position.
	 * 
	 * @param x The initial X position of the sprite.
	 * @param y The initial Y position of the sprite.
	 */
	public function new(?x:Float = 0, ?y:Float = 0):Void
	{
		super(x, y);

		bitmap = new FlxInternalVideo(antialiasing);
		bitmap.forceRendering = true;
		bitmap.onFormatSetup.add(function():Void
		{
			if (bitmap.bitmapData != null)
				loadGraphic(FlxGraphic.fromBitmapData(bitmap.bitmapData, false, null, false));
		});
		bitmap.visible = false;
		FlxG.game.addChild(bitmap);

		makeGraphic(1, 1, FlxColor.TRANSPARENT);
	}

	/**
	 * Loads a video from the specified location.
	 * 
	 * @param location The location of the media file or stream.
	 * @param options Additional options to configure the media.
	 * @return `true` if the media was loaded successfully, `false` otherwise.
	 */
	public inline function load(location:Location, ?options:Array<String>):Bool
	{
		return bitmap.load(location, options);
	}

	/**
	 * Loads a media subitem from the current media's subitems list at the specified index.
	 * 
	 * @param index The index of the subitem to load.
	 * @param options Additional options to configure the loaded subitem.
	 * @return `true` if the subitem was loaded successfully, `false` otherwise.
	 */
	public inline function loadFromSubItem(index:Int, ?options:Array<String>):Bool
	{
		return bitmap.loadFromSubItem(index, options);
	}

	/**
	 * Parses the current media item with the specified options.
	 * 
	 * @param parse_flag The parsing option.
	 * @param timeout The timeout in milliseconds.
	 * @return `true` if parsing succeeded, `false` otherwise.
	 */
	public inline function parseWithOptions(parse_flag:Int, timeout:Int):Bool
	{
		return bitmap.parseWithOptions(parse_flag, timeout);
	}

	/** Stops parsing the current media item. */
	public inline function parseStop():Void
	{
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
	public inline function addSlave(type:Int, location:String, select:Bool):Bool
	{
		return bitmap.addSlave(type, location, select);
	}

	/**
	 * Starts video playback.
	 * @return `true` if playback started successfully, `false` otherwise.
	 */
	public inline function play():Bool
	{
		return bitmap.play();
	}

	/** Stops video playback. */
	public inline function stop():Void
	{
		bitmap.stop();
	}

	/** Pauses video playback. */
	public inline function pause():Void
	{
		bitmap.pause();
	}

	/** Resumes playback of a paused video. */
	public inline function resume():Void
	{
		bitmap.resume();
	}

	/** Toggles between play and pause states of the video. */
	public inline function togglePaused():Void
	{
		bitmap.togglePaused();
	}

	@:dox(hide)
	public override function destroy():Void
	{
		super.destroy();

		FlxG.removeChild(bitmap);

		bitmap.dispose();
	}

	@:dox(hide)
	public override function kill():Void
	{
		bitmap.pause();

		super.kill();
	}

	@:dox(hide)
	public override function revive():Void
	{
		super.revive();

		bitmap.resume();
	}

	@:noCompletion
	private override function set_antialiasing(value:Bool):Bool
	{
		return antialiasing = (bitmap == null ? value : (bitmap.smoothing = value));
	}
}
#end
